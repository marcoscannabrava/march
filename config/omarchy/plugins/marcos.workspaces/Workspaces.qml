import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

// Workspace indicators, filtered to the monitor this bar sits on.
BarWidget {
  id: root
  moduleName: "marcos.workspaces"

  // Workspace id -> monitor name, from Hyprland's workspace rules.
  property var ruleMonitors: ({})

  readonly property string screenName: {
    var window = root.QsWindow ? root.QsWindow.window : null
    return window && window.screen ? String(window.screen.name || "") : ""
  }

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }

    return null
  }

  // The monitor a live workspace currently sits on, which differs from its
  // rule whenever the ruled output is unplugged.
  function liveMonitor(id) {
    var workspace = root.workspaceById(id)
    var monitor = workspace ? workspace.monitor : null
    return monitor ? String(monitor.name || "") : ""
  }

  // Ruled for this screen, plus any ruled workspace displaced onto it. An
  // unruled workspace (the minimize parking spot) stays out of every bar.
  function workspaceIds() {
    var ids = []
    var screen = root.screenName

    for (var key in root.ruleMonitors) {
      var id = parseInt(key, 10)
      if (root.ruleMonitors[key] === screen || root.liveMonitor(id) === screen) ids.push(id)
    }

    if (ids.length === 0) ids = root.liveIds()
    ids.sort(function(left, right) { return left - right })
    return ids
  }

  // Fallback for a monitor no rule names: whatever is open on it, else 1-5.
  function liveIds() {
    var ids = []
    var values = Hyprland.workspaces.values

    for (var i = 0; i < values.length; i++) {
      var workspace = values[i]
      if (workspace.id <= 0) continue
      var monitor = workspace.monitor
      if (monitor && String(monitor.name || "") === root.screenName) ids.push(workspace.id)
    }

    return ids.length > 0 ? ids : [1, 2, 3, 4, 5]
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  function refreshRules() {
    if (!rulesProc.running) rulesProc.running = true
  }

  Component.onCompleted: root.refreshRules()

  // Rules only move when the Hyprland config reloads.
  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (event && String(event.name) === "configreloaded") root.refreshRules()
    }
  }

  Process {
    id: rulesProc
    command: ["hyprctl", "-j", "workspacerules"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var listed
        try {
          listed = JSON.parse(text || "[]")
        } catch (e) {
          return
        }

        if (!Array.isArray(listed)) return

        var mapped = ({})
        for (var i = 0; i < listed.length; i++) {
          var rule = listed[i]
          var id = parseInt(rule.workspaceString, 10)
          if (isNaN(id) || id <= 0 || !rule.monitor) continue
          mapped[id] = String(rule.monitor)
        }

        root.ruleMonitors = mapped
      }
    }
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
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

        bar: root.bar
        text: focused ? "󱓻" : (modelData === 10 ? "0" : String(modelData))
        opacity: occupied || focused ? 1 : 0.5
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Style.space(20)
        fixedHeight: root.barSize
        onPressed: function() { root.focusWorkspace(modelData) }
      }
    }
  }
}
