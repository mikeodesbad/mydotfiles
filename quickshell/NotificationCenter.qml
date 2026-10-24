import QtQuick
import QtQuick.Layouts

Rectangle {
    color: Theme.card
    border.color: Theme.border
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            T { text: Theme.ic.bell; color: Theme.accent; font.pixelSize: 14 }
            T { text: "Notifications"; font.bold: true; font.pixelSize: 13 }
            Item { Layout.fillWidth: true }
            Btn {
                text: (Notifs.dnd ? Theme.ic.bellOff : Theme.ic.bell) + " DND"
                active: Notifs.dnd
                onClicked: Notifs.dnd = !Notifs.dnd
            }
            Btn {
                text: Theme.ic.trash + " Clear All"
                onClicked: Notifs.clearAll()
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            T {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 40
                visible: Notifs.list.length === 0
                text: "No notifications"
                color: Theme.dim
            }

            ListView {
                anchors.fill: parent
                clip: true
                spacing: 6
                model: Notifs.list.slice().reverse()
                delegate: NotificationItem {
                    required property var modelData
                    notification: modelData
                    width: ListView.view.width
                }
            }
        }
    }
}
