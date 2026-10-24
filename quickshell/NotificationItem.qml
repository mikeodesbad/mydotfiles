import QtQuick
import QtQuick.Layouts

// One notification; used in the center and in popups
Rectangle {
    id: root
    property var notification
    signal closeClicked

    color: Theme.bg
    border.color: notification?.urgency === 2 ? Theme.red : Theme.border
    border.width: 1
    implicitHeight: col.implicitHeight + 16

    ColumnLayout {
        id: col
        x: 8
        y: 8
        width: root.width - 16
        spacing: 3

        RowLayout {
            Layout.fillWidth: true
            T {
                Layout.fillWidth: true
                text: root.notification?.appName ?? ""
                color: Theme.accent
                font.pixelSize: 10
                elide: Text.ElideRight
            }
            T {
                text: Theme.ic.close
                color: closeMouse.containsMouse ? Theme.red : Theme.dim
                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    anchors.margins: -4
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.closeClicked();
                        root.notification?.dismiss();
                    }
                }
            }
        }
        T {
            Layout.fillWidth: true
            text: root.notification?.summary ?? ""
            font.bold: true
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
        }
        T {
            Layout.fillWidth: true
            visible: text !== ""
            text: root.notification?.body ?? ""
            color: Theme.dim
            wrapMode: Text.Wrap
            maximumLineCount: 3
            elide: Text.ElideRight
            font.pixelSize: 11
        }
    }
}
