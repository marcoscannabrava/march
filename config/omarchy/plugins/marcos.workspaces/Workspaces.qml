import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

// Workspace indicators for this bar's monitor block.
BarWidget {
  id: root
  moduleName: "marcos.workspaces"

  // Each monitor owns a block of ten.
  readonly property int slots: 10

  readonly property string screenName: {
    var window = root.QsWindow ? root.QsWindow.window : null
    return window && window.screen ? String(window.screen.name || "") : ""
  }

  // Connector -> block, from Omarchy's state file.
  property var blocks: ({})

  function readBlocks(text) {
    var next = {}
    var lines = String(text || "").split("\n")
    for (var i = 0; i < lines.length; i++) {
      var fields = lines[i].split("\t")
      if (fields.length >= 3 && fields[1] !== "") next[fields[1]] = parseInt(fields[0], 10)
    }
    root.blocks = next
  }

  FileView {
    path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/omarchy/monitor-workspaces"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.readBlocks(text())
    onLoadFailed: root.readBlocks("")
  }

  function blockOf(id) {
    return Math.floor((id - 1) / root.slots)
  }

  function slotOf(id) {
    return (id - 1) % root.slots + 1
  }

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }

    return null
  }

  // Before the file exists, use the shown workspace.
  readonly property int block: {
    var block = root.blocks[root.screenName]
    if (block !== undefined) return block
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      var workspace = values[i]
      if (workspace.id > 0 && workspace.active && workspace.monitor
          && String(workspace.monitor.name || "") === root.screenName) return root.blockOf(workspace.id)
    }
    return 0
  }

  // Slots 1-5, plus any open higher slot.
  function workspaceIds() {
    var base = root.block * root.slots
    var ids = [base + 1, base + 2, base + 3, base + 4, base + 5]
    var values = Hyprland.workspaces.values

    for (var i = 0; i < values.length; i++) {
      var id = values[i].id
      if (id > 0 && root.blockOf(id) === root.block && ids.indexOf(id) === -1) ids.push(id)
    }

    ids.sort(function(left, right) { return left - right })
    return ids
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    var expression = "o.workspaces.focus(" + root.slotOf(id) + ", \"" + root.screenName + "\")"
    root.bar.run("hyprctl dispatch " + Util.shellQuote(expression))
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  // Focused workspace's custom name, on its own screen.
  readonly property string activeTitle: {
    var workspace = Hyprland.focusedWorkspace
    if (root.vertical || !workspace) return ""
    if (root.workspaceIds().indexOf(workspace.id) === -1) return ""
    var name = String(workspace.name || "")
    return name === String(workspace.id) ? "" : name
  }

  implicitWidth: grid.implicitWidth + trailingGap + (titleLabel.visible ? titleLabel.width + Style.space(12) : 0)
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    columns: root.vertical ? 1 : Math.max(1, root.workspaceIds().length)
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.workspaceIds()

      WidgetButton {
        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData
        readonly property int slot: root.slotOf(modelData)

        bar: root.bar
        text: focused ? "󱓻" : (slot === root.slots ? "0" : String(slot))
        opacity: occupied || focused ? 1 : 0.5
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Style.space(20)
        fixedHeight: root.barSize
        onPressed: function() { root.focusWorkspace(modelData) }
      }
    }
  }

  Text {
    id: titleLabel
    visible: root.activeTitle.length > 0
    anchors.left: grid.right
    anchors.leftMargin: Style.space(12)
    anchors.verticalCenter: parent.verticalCenter
    width: Math.min(implicitWidth, Style.space(400))
    text: root.activeTitle
    textFormat: Text.PlainText
    elide: Text.ElideRight
    color: root.bar ? root.bar.barForeground : Color.bar.text
    font.family: root.bar ? root.bar.fontFamily : Style.font.family
    font.pixelSize: Style.font.body
  }
}
