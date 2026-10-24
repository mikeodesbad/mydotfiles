import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Card {
    id: root
    property string user: Quickshell.env("USER") ?? ""
    property string uptime: ""

    Process {
        id: proc
        command: ["uptime", "-p"]
        stdout: StdioCollector { onStreamFinished: root.uptime = this.text.trim().replace(/^up /, "") }
    }

    Timer {
        running: Globals.panelOpen
        triggeredOnStart: true
        interval: 60000
        repeat: true
        onTriggered: proc.running = true
    }

    RowLayout {
        spacing: 10

        // Uses ~/.face if present, otherwise the first letter of your username
        Rectangle {
            implicitWidth: 48
            implicitHeight: 48
            color: Theme.accentDim
            border.color: Theme.border
            border.width: 1
            Image {
                id: face
                anchors.fill: parent
                anchors.margins: 1
                source: "file://" + Quickshell.env("HOME") + "/.face"
                fillMode: Image.PreserveAspectCrop
            }
            T {
                anchors.centerIn: parent
                visible: face.status !== Image.Ready
                text: root.user.charAt(0).toUpperCase()
                font.pixelSize: 22
                font.bold: true
            }
        }

        ColumnLayout {
            spacing: 2
            T { text: "@" + root.user; color: Theme.accent; font.bold: true; font.pixelSize: 13 }
            T { text: "Arch Linux · Hyprland"; color: Theme.dim; font.pixelSize: 11 }
            T { text: "Uptime: " + root.uptime; color: Theme.dim; font.pixelSize: 11 }
        }
    }
}
