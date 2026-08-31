import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Ui

// Every open window, grouped by workspace. Click a row to focus it.
Item {
  id: root

  property bool opened: false
  property string filterText: ""
  property int selectedIndex: -1
  // Summed from the model so the card sizes without waiting on the ListView.
  property int rowsHeight: 0

  // Shares the [menu] surface tokens with the other pickers, so a theme
  // that styles the menu styles this too.
  property color background: Color.menu.background
  property color foreground: Color.menu.text
  property color border: Color.menu.border
  property var borderSpec: Border.surfaceSpec("menu", "border", border, Math.max(1, Style.space(2)))
  property color scrim: Color.menu.scrim
  property color selectedBackground: Color.menu.selectedBackground
  property color selectedText: Color.menu.selectedText
  readonly property int cornerRadius: Style.cornerRadius
  property string fontFamily: Style.font.menuFamily
  property int contentMargin: Style.spacing.panelPadding
  property int contentSpacing: Style.spacing.md
  property int headerHeight: Math.max(Style.space(30), Style.font.heading + Style.spacing.controlPaddingY * 2)
  property int groupRowHeight: Math.max(Style.space(28), Style.font.caption * 2 + Style.space(8))
  property int windowRowHeight: Math.max(Style.space(44), Style.font.title + Style.spacing.rowPaddingX * 2)
  property int iconSize: Style.space(22)
  property int cardWidth: Math.min(Style.space(720), panel.width - Style.gapsOut * 2)
  property int maxCardHeight: Math.min(Style.space(760), panel.height - Style.gapsOut * 2)

  function open(payloadJson) {
    root.opened = true
    root.filterText = ""
    root.selectedIndex = -1
    root.disarmPointer()
    Hyprland.refreshWorkspaces()
    Hyprland.refreshToplevels()
    root.rebuildRows()
    root.selectFirst()
    console.log("app-switcher open rows=" + rowModel.count + " rowsHeight=" + root.rowsHeight + " card=" + card.width + "x" + card.height + " panel=" + panel.width + "x" + panel.height + " scrim=" + root.scrim)
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function close() {
    root.opened = false
  }

  function toggle() {
    if (root.opened) root.close()
    else root.open("{}")
  }

  // Positive workspaces first, then specials and unassigned.
  function compareKeys(left, right) {
    if (left > 0 && right <= 0) return -1
    if (right > 0 && left <= 0) return 1
    return left - right
  }

  function groupLabel(workspace) {
    if (!workspace) return "Unassigned"
    var name = String(workspace.name || "")
    if (name.length === 0) return "Workspace " + workspace.id
    if (name.indexOf("special:") === 0) return "Special · " + name.slice(8)
    if (name === String(workspace.id)) return "Workspace " + name
    return name
  }

  function windowClass(toplevel) {
    var ipc = toplevel.lastIpcObject
    return String((ipc && ipc["class"]) || "")
  }

  function iconFor(appClass) {
    var name = String(appClass || "")
    if (name.length === 0) return ""

    var entry = DesktopEntries.heuristicLookup(name)
    var icon = entry ? String(entry.icon || "") : ""
    if (icon.length > 0) {
      if (icon.charAt(0) === "/") return Util.fileUrl(icon)
      var resolved = Quickshell.iconPath(icon, true)
      if (resolved.length > 0) return resolved
    }

    return Quickshell.iconPath(name.toLowerCase(), true)
  }

  function matchesFilter(appClass, title, group) {
    var needle = root.filterText.toLowerCase()
    if (needle.length === 0) return true
    return (appClass + " " + title + " " + group).toLowerCase().indexOf(needle) !== -1
  }

  function rebuildRows() {
    var toplevels = Hyprland.toplevels.values
    var groups = ({})
    var keys = []

    for (var i = 0; i < toplevels.length; i++) {
      var toplevel = toplevels[i]
      var workspace = toplevel.workspace
      var key = workspace ? workspace.id : 0
      if (!groups[key]) {
        groups[key] = { label: root.groupLabel(workspace), windows: [] }
        keys.push(key)
      }

      var appClass = root.windowClass(toplevel)
      var title = String(toplevel.title || "")
      if (!root.matchesFilter(appClass, title, groups[key].label)) continue

      groups[key].windows.push({
        appClass: appClass,
        title: title,
        address: String(toplevel.address || ""),
        focused: toplevel.activated === true
      })
    }

    keys.sort(root.compareKeys)
    rowModel.clear()

    for (var k = 0; k < keys.length; k++) {
      var group = groups[keys[k]]
      if (group.windows.length === 0) continue

      rowModel.append({
        kind: "group",
        label: group.label,
        title: "",
        icon: "",
        address: "",
        focused: false,
        count: group.windows.length
      })

      for (var w = 0; w < group.windows.length; w++) {
        var entry = group.windows[w]
        rowModel.append({
          kind: "window",
          label: entry.appClass || entry.title || "Window",
          title: entry.appClass ? entry.title : "",
          icon: root.iconFor(entry.appClass),
          address: entry.address,
          focused: entry.focused,
          count: 0
        })
      }
    }

    root.rowsHeight = 0
    for (var r = 0; r < rowModel.count; r++)
      root.rowsHeight += rowModel.get(r).kind === "window" ? root.windowRowHeight : root.groupRowHeight

    if (root.selectedIndex >= rowModel.count || !root.isWindowRow(root.selectedIndex)) root.selectedIndex = -1
  }

  function isWindowRow(index) {
    if (index < 0 || index >= rowModel.count) return false
    return rowModel.get(index).kind === "window"
  }

  function selectFirst() {
    for (var i = 0; i < rowModel.count; i++) {
      if (rowModel.get(i).kind !== "window") continue
      if (rowModel.get(i).focused) continue
      root.selectAbsolute(i)
      return
    }

    root.selectStep(1)
  }

  function selectStep(delta) {
    if (rowModel.count === 0) return
    root.disarmPointer()

    var index = root.selectedIndex
    for (var step = 0; step < rowModel.count; step++) {
      index = index < 0
        ? (delta < 0 ? rowModel.count - 1 : 0)
        : (index + delta + rowModel.count) % rowModel.count
      if (root.isWindowRow(index)) {
        root.selectedIndex = index
        rowList.positionViewAtIndex(index, ListView.Contain)
        return
      }
    }
  }

  function selectAbsolute(index) {
    if (!root.isWindowRow(index)) return
    root.disarmPointer()
    root.selectedIndex = index
    rowList.positionViewAtIndex(index, ListView.Contain)
  }

  function setFilter(nextFilter) {
    root.filterText = nextFilter
    root.selectedIndex = -1
    root.rebuildRows()
    root.selectStep(1)
  }

  function disarmPointer() {
    pointerGate.reset()
  }

  function selectFromPointer(index, item, mouse) {
    if (!pointerGate.moved(item, mouse)) return
    root.selectedIndex = index
  }

  // Quickshell drops the 0x Hyprland needs.
  function windowSelector(address) {
    var hex = String(address || "")
    if (hex.length === 0) return ""
    return "address:" + (hex.indexOf("0x") === 0 ? hex : "0x" + hex)
  }

  function activateIndex(index) {
    if (!root.isWindowRow(index)) return
    var selector = root.windowSelector(rowModel.get(index).address)
    root.close()
    // Hyprland's config is Lua, so dispatch takes a Lua expression.
    if (selector.length > 0) Hyprland.dispatch('hl.dsp.focus({ window = "' + selector + '" })')
  }

  Component.onCompleted: console.log("app-switcher loaded")

  ListModel { id: rowModel }

  PointerMoveGate {
    id: pointerGate
    referenceItem: card
  }

  // Windows open and close behind the switcher; keep the list honest.
  Connections {
    target: Hyprland.toplevels
    function onValuesChanged() { if (root.opened) root.rebuildRows() }
  }

  PanelWindow {
    id: panel
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "marcos-app-switcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
      anchors.fill: parent
      color: root.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.close()
    }

    BorderSurface {
      id: card
      width: root.cardWidth
      height: Math.min(root.maxCardHeight,
        contentTopInset + contentBottomInset + root.headerHeight + root.contentSpacing
          + Math.max(root.rowsHeight, Style.space(120)))
      radius: root.cornerRadius
      anchors.centerIn: parent
      color: root.background
      borderSpec: root.borderSpec
      padding: root.contentMargin

      MouseArea { anchors.fill: parent; onClicked: {} }

      Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true

        Keys.priority: Keys.BeforeItem
        Keys.onPressed: function(event) {
          if (event.key === Qt.Key_Escape) {
            if (root.filterText) root.setFilter("")
            else root.close()
            event.accepted = true
          } else if (Util.editsFilter(event, root.filterText)) {
            root.setFilter(Util.editedFilter(event, root.filterText))
            event.accepted = true
          } else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab) {
            root.selectStep(-1)
            event.accepted = true
          } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab) {
            root.selectStep(1)
            event.accepted = true
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.activateIndex(root.selectedIndex)
            event.accepted = true
          } else if (event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127) {
            root.setFilter(root.filterText + event.text)
            event.accepted = true
          }
        }
      }

      Column {
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset
        spacing: root.contentSpacing

        Item {
          width: parent.width
          height: root.headerHeight

          Text {
            textFormat: Text.PlainText
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: root.filterText || "Windows by workspace"
            color: root.foreground
            opacity: root.filterText ? 1 : 0.58
            font.family: root.fontFamily
            font.pixelSize: Style.font.heading
            elide: Text.ElideRight
          }
        }

        Item {
          width: parent.width
          height: parent.height - root.headerHeight - root.contentSpacing
          clip: true

          ListView {
            id: rowList
            anchors.fill: parent
            model: rowModel
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            delegate: Item {
              id: row
              required property int index
              required property string kind
              required property string label
              required property string title
              required property string icon
              required property bool focused
              required property int count

              readonly property bool isWindow: kind === "window"
              readonly property bool hasCursor: row.isWindow && row.index === root.selectedIndex

              width: ListView.view.width
              height: row.isWindow ? root.windowRowHeight : root.groupRowHeight

              PanelSectionHeader {
                visible: !row.isWindow
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Style.space(4)
                text: row.label + "  ·  " + row.count
                foreground: root.foreground
                fontFamily: root.fontFamily
              }

              Rectangle {
                visible: row.isWindow
                anchors.fill: parent
                radius: root.cornerRadius
                color: row.hasCursor ? root.selectedBackground : "transparent"

                Row {
                  anchors.fill: parent
                  anchors.leftMargin: Style.space(10)
                  anchors.rightMargin: Style.space(10)
                  spacing: Style.space(10)

                  Image {
                    anchors.verticalCenter: parent.verticalCenter
                    width: root.iconSize
                    height: root.iconSize
                    source: row.icon
                    visible: row.icon.length > 0
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    smooth: true
                  }

                  Text {
                    textFormat: Text.PlainText
                    anchors.verticalCenter: parent.verticalCenter
                    text: row.label
                    color: row.hasCursor ? root.selectedText : root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.title
                    font.bold: row.focused
                  }

                  Text {
                    textFormat: Text.PlainText
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - x
                    text: row.title
                    color: row.hasCursor ? root.selectedText : root.foreground
                    opacity: 0.6
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.body
                    elide: Text.ElideRight
                  }
                }

                MouseArea {
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onPositionChanged: function(mouse) {
                    root.selectFromPointer(row.index, row, mouse)
                  }
                  onClicked: {
                    root.selectedIndex = row.index
                    root.activateIndex(row.index)
                  }
                }
              }
            }
          }

          Text {
            textFormat: Text.PlainText
            anchors.centerIn: parent
            visible: rowModel.count === 0
            text: root.filterText ? "No matching windows" : "No open windows"
            color: root.foreground
            opacity: 0.7
            font.family: root.fontFamily
            font.pixelSize: Style.font.title
          }
        }
      }
    }
  }
}
