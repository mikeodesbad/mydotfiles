import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Card {
    id: root
    pad: 8
    property var bars: []

    // cava only runs while the panel is open
    Process {
        running: Globals.panelOpen
        command: ["cava", "-p", Qt.resolvedUrl("cava.conf").toString().replace("file://", "")]
        stdout: SplitParser {
            onRead: data => root.bars = data.split(";").filter(s => s !== "").map(Number)
        }
    }

    Item {
        id: area
        Layout.fillWidth: true
        Layout.fillHeight: true
        implicitHeight: 30

        Row {
            anchors.fill: parent
            spacing: 2
            Repeater {
                model: root.bars.length
                Rectangle {
                    required property int index
                    width: (area.width - 2 * (root.bars.length - 1)) / root.bars.length
                    height: Math.max(2, root.bars[index] / 100 * area.height)
                    y: area.height - height
                    color: Theme.accent
                }
            }
        }
    }
}
