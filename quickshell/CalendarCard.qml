import QtQuick
import QtQuick.Layouts
import Quickshell

Card {
    id: root

    SystemClock {
        id: clock
        precision: SystemClock.Hours
    }

    property int year: clock.date.getFullYear()
    property int month: clock.date.getMonth()

    // Jump back to the current month whenever the panel opens
    Connections {
        target: Globals
        function onPanelOpenChanged() {
            root.year = clock.date.getFullYear();
            root.month = clock.date.getMonth();
        }
    }

    // 42 cells starting on the Monday on/before the 1st
    readonly property var cells: {
        const first = new Date(year, month, 1);
        const offset = (first.getDay() + 6) % 7;
        const out = [];
        for (let i = 0; i < 42; i++)
            out.push(new Date(year, month, 1 - offset + i));
        return out;
    }

    function shiftMonth(d) {
        const n = new Date(year, month + d, 1);
        year = n.getFullYear();
        month = n.getMonth();
    }

    RowLayout {
        Layout.fillWidth: true
        Btn { text: Theme.ic.left; onClicked: root.shiftMonth(-1) }
        T {
            Layout.preferredWidth: 80
            horizontalAlignment: Text.AlignHCenter
            text: Qt.formatDate(new Date(root.year, root.month, 1), "MMMM")
            color: Theme.accent
            font.pixelSize: 13
        }
        Btn { text: Theme.ic.right; onClicked: root.shiftMonth(1) }
        Item { Layout.fillWidth: true }
        Btn { text: Theme.ic.left; onClicked: root.year-- }
        T { text: root.year; color: Theme.accent; font.pixelSize: 13 }
        Btn { text: Theme.ic.right; onClicked: root.year++ }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 7
        rowSpacing: 2
        columnSpacing: 0

        Repeater {
            model: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            T {
                required property string modelData
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: modelData
                color: Theme.dim
                font.pixelSize: 10
            }
        }

        Repeater {
            model: root.cells
            Item {
                required property var modelData
                readonly property bool inMonth: modelData.getMonth() === root.month
                readonly property bool isToday: modelData.toDateString() === clock.date.toDateString()

                Layout.fillWidth: true
                implicitHeight: 24

                Rectangle {
                    anchors.centerIn: parent
                    width: 26
                    height: 22
                    color: "transparent"
                    border.color: Theme.accent
                    border.width: isToday ? 1 : 0
                }
                T {
                    anchors.centerIn: parent
                    text: modelData.getDate()
                    color: !inMonth ? Theme.faint
                        : isToday ? Theme.accent
                        : Theme.weekendDays.includes(modelData.getDay()) ? Theme.warm
                        : Theme.fg
                }
            }
        }
    }
}
