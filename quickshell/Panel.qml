import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

// Two-column dashboard that slides in from the left (SUPER+D / click the waybar clock)
PanelWindow {
    id: win

    // Shown as soon as the panel opens; hidden only after the slide-out finishes
    visible: false
    Connections {
        target: Globals
        function onPanelOpenChanged() {
            if (Globals.panelOpen) win.visible = true;
        }
    }
    anchors {
        left: true
        top: true
        bottom: true
    }
    margins {
        top: 30
        bottom: 6
        left: 6
    }
    implicitWidth: 628
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-panel"
    WlrLayershell.keyboardFocus: Globals.panelOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    Rectangle {
        id: slide
        width: win.implicitWidth
        height: parent.height
        x: Globals.panelOpen ? 0 : -win.implicitWidth - 10
        color: Theme.bg
        border.color: Theme.border
        border.width: 1

        Behavior on x {
            NumberAnimation {
                duration: 220
                easing.type: Easing.OutCubic
                onRunningChanged: if (!running && !Globals.panelOpen) win.visible = false
            }
        }

        focus: Globals.panelOpen
        Keys.onEscapePressed: Globals.panelOpen = false

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8

            ColumnLayout {
                Layout.preferredWidth: 300
                Layout.fillHeight: true
                spacing: 8

                ClockCard { Layout.fillWidth: true }
                MediaCard { Layout.fillWidth: true }
                // Grows to fill the leftover height
                VisualizerCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
                WorldClocksCard { Layout.fillWidth: true }
                WeatherCard { Layout.fillWidth: true }
                ProfileCard { Layout.fillWidth: true }
            }

            Rectangle {
                Layout.fillHeight: true
                implicitWidth: 1
                color: Theme.border
            }

            ColumnLayout {
                Layout.preferredWidth: 300
                Layout.fillHeight: true
                spacing: 8

                CalendarCard { Layout.fillWidth: true }
                NotificationCenter {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
                WordCard { Layout.fillWidth: true }
                ScreenshotsCard { Layout.fillWidth: true }
            }
        }
    }
}
