import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

Card {
    id: root

    // Prefer whichever player is playing, else the first one
    readonly property var player: {
        const ps = Mpris.players.values;
        return ps.find(p => p.isPlaying) ?? ps[0] ?? null;
    }

    function fmt(secs) {
        if (!secs || secs < 0) return "0:00";
        const s = Math.floor(secs);
        return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0");
    }

    // MPRIS doesn't push position updates; poll while visible
    Timer {
        running: Globals.panelOpen && (root.player?.isPlaying ?? false)
        interval: 1000
        repeat: true
        onTriggered: root.player.positionChanged()
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Rectangle {
            implicitWidth: 64
            implicitHeight: 64
            color: Theme.bg
            border.color: Theme.border
            border.width: 1

            Image {
                id: art
                anchors.fill: parent
                anchors.margins: 1
                source: root.player?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }
            T {
                anchors.centerIn: parent
                visible: art.status !== Image.Ready
                text: Theme.ic.music
                color: Theme.dim
                font.pixelSize: 26
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            T {
                Layout.fillWidth: true
                text: root.player?.trackTitle || "Nothing playing"
                font.bold: true
                elide: Text.ElideRight
            }
            T {
                Layout.fillWidth: true
                text: root.player?.trackArtist ?? ""
                color: Theme.dim
                elide: Text.ElideRight
            }
            T {
                text: root.player?.identity ?? ""
                color: Theme.accent
                font.pixelSize: 10
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 3
        color: Theme.border
        Rectangle {
            height: parent.height
            color: Theme.accent
            width: {
                const p = root.player;
                return p && p.length > 0 ? parent.width * Math.min(1, p.position / p.length) : 0;
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 4
        Btn {
            text: Theme.ic.prev
            onClicked: root.player?.previous()
        }
        Btn {
            text: root.player?.isPlaying ? Theme.ic.pause : Theme.ic.play
            onClicked: root.player?.togglePlaying()
        }
        Btn {
            text: Theme.ic.next
            onClicked: root.player?.next()
        }
        Item { Layout.fillWidth: true }
        T {
            text: root.fmt(root.player?.position) + " / " + root.fmt(root.player?.length)
            color: Theme.dim
            font.pixelSize: 10
        }
    }
}
