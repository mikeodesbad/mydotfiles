import QtQuick
import QtQuick.Layouts
import qs

Rectangle {
    id: root
    property string value
    property string label
    property color valueColor: Theme.accent

    Layout.fillWidth: true
    implicitHeight: 74
    color: Theme.card
    border.color: Theme.border
    border.width: 1

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 2
        T {
            Layout.alignment: Qt.AlignHCenter
            text: root.value
            color: root.valueColor
            font.pixelSize: 26
            font.bold: true
        }
        T {
            Layout.alignment: Qt.AlignHCenter
            text: root.label
            color: Theme.dim
            font.pixelSize: 10
        }
    }
}
