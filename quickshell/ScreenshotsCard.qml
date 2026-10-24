import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// Latest 4 files from ~/Pictures/Screenshots (written by hypr/scripts/screenshot.sh)
Card {
    id: root
    pad: 8
    property var files: []

    Process {
        id: proc
        command: ["sh", "-c", "ls -t \"$HOME\"/Pictures/Screenshots/*.png 2>/dev/null | head -4"]
        stdout: StdioCollector { onStreamFinished: root.files = this.text.split("\n").filter(s => s !== "") }
    }

    Connections {
        target: Globals
        function onPanelOpenChanged() {
            if (Globals.panelOpen) proc.running = true;
        }
    }
    Component.onCompleted: proc.running = true

    RowLayout {
        Layout.fillWidth: true
        T { text: "SCREENSHOTS"; color: Theme.dim; font.pixelSize: 9; font.bold: true }
        Item { Layout.fillWidth: true }
        T { text: "click: open · right: copy"; color: Theme.dim; font.pixelSize: 9 }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 6
        Repeater {
            model: 4
            Rectangle {
                required property int index
                readonly property string file: root.files[index] ?? ""
                Layout.fillWidth: true
                implicitHeight: 48
                color: Theme.bg
                border.color: thumbMouse.containsMouse && file ? Theme.accent : Theme.border
                border.width: 1

                Image {
                    anchors.fill: parent
                    anchors.margins: 1
                    source: parent.file ? "file://" + parent.file : ""
                    fillMode: Image.PreserveAspectCrop
                    sourceSize.width: 160
                    asynchronous: true
                }
                T {
                    anchors.centerIn: parent
                    visible: !parent.file
                    text: Theme.ic.camera
                    color: Theme.faint
                    font.pixelSize: 16
                }
                MouseArea {
                    id: thumbMouse
                    anchors.fill: parent
                    enabled: !!parent.file
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton) {
                            Quickshell.execDetached(["sh", "-c", "wl-copy < \"$1\"", "sh", parent.file]);
                        } else {
                            Quickshell.execDetached(["xdg-open", parent.file]);
                            Globals.panelOpen = false;
                        }
                    }
                }
            }
        }
    }
}
