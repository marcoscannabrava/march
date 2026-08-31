import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// Countdown beside the clock while `timer` runs.
//
// The `timer` script writes an end timestamp once and sleeps; this widget
// owns the ticking. So a shell reload mid-timer picks the countdown back up
// from the file instead of losing it.
//
// The script calls `reload` after every write. A file watch would miss the
// first write, because the state directory does not exist until then.
BarWidget {
  id: root
  moduleName: "marcos.countdown"

  readonly property string statePath: Quickshell.env("HOME") + "/.local/state/march/timer.json"

  property real endsAt: 0
  property real now: 0
  property string message: ""

  // The script clears the file 5s after zero, so this holds
  // 00:00 in the bar and also drops a file a killed timer left.
  readonly property int graceSeconds: 6

  readonly property int remaining: Math.max(0, Math.ceil(endsAt - now))
  readonly property bool counting: endsAt > 0

  function pad(value) {
    return value < 10 ? "0" + value : String(value)
  }

  // MM:SS, and H:MM:SS past an hour.
  readonly property var timeParts: {
    var parts = [pad(Math.floor(remaining / 60) % 60), pad(remaining % 60)]
    if (remaining >= 3600) parts.unshift(String(Math.floor(remaining / 3600)))
    return parts
  }

  readonly property string label: "󱎫 " + timeParts.join(":")
  readonly property string tooltip: remaining > 0
    ? timeParts.join(":") + " left" + (message === "" ? "" : ": " + message)
    : "Time is up"

  function applyState(raw) {
    var data = {}
    try {
      data = JSON.parse(String(raw || "{}"))
    } catch (e) {
      data = {}
    }
    // Clock before deadline, so the first frame draws a fresh remaining.
    now = Date.now() / 1000
    var deadline = Number(data.endsAt || 0)
    endsAt = deadline > now - graceSeconds ? deadline : 0
    message = String(data.message || "")
  }

  function clearState() {
    endsAt = 0
    message = ""
  }

  function reloadState() {
    stateFile.reload()
  }

  visible: counting
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  FileView {
    id: stateFile
    path: root.statePath
    printErrors: false
    onLoaded: root.applyState(text())
    onLoadFailed: root.clearState()
  }

  IpcHandler {
    target: "marcos.countdown"

    // One bar surface per monitor, so relay to the peers.
    function reload(): void { root.broadcast("reloadState") }
  }

  SystemClock {
    precision: SystemClock.Seconds
    enabled: root.endsAt > 0
    onDateChanged: {
      root.now = date.getTime() / 1000
      if (root.now > root.endsAt + root.graceSeconds) root.clearState()
    }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.vertical ? "" : root.label
    labelVisible: !root.vertical
    hasVisualContent: root.counting
    fixedHeight: root.vertical ? root.timeParts.length * Style.bar.iconSlot : -1
    active: root.remaining === 0
    pressable: false
    tooltipText: root.tooltip
    horizontalMargin: 8.75
    verticalPadding: 8.75

    Column {
      visible: root.vertical
      anchors.fill: parent

      Repeater {
        model: root.timeParts

        OpticalGlyph {
          required property string modelData
          width: button.width
          height: Style.bar.iconSlot
          text: modelData
          fontFamily: button.fontFamily
          fontSize: button.fontSize
          color: button.foreground
        }
      }
    }
  }
}
