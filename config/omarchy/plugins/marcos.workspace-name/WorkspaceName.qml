import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

// Shown workspace title beside the numbers.
//
// The app switcher renames workspaces with Ctrl+R. A name equal to
// the id counts as no name, so the widget hides.
BarWidget {
  id: root
  moduleName: "marcos.workspace-name"

  // This bar's monitor, not the focused one.
  readonly property var monitor: {
    var window = root.QsWindow.window
    var screen = window ? window.screen : null
    return screen ? Hyprland.monitorFor(screen) : Hyprland.focusedMonitor
  }
  readonly property var workspace: root.monitor ? root.monitor.activeWorkspace : null

  readonly property string title: {
    if (!root.workspace) return ""
    var name = String(root.workspace.name || "")
    return name === String(root.workspace.id) ? "" : name
  }

  visible: root.title !== "" && !root.vertical
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  // Ask Hyprland again after a rename.
  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (event && String(event.name) === "renameworkspace") Hyprland.refreshWorkspaces()
    }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.title
    hasVisualContent: root.title !== ""
    pressable: false
    horizontalMargin: 6
    verticalPadding: 6
    fixedHeight: root.barSize
  }
}
