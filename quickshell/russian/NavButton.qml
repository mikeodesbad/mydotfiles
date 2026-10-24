import QtQuick
import QtQuick.Layouts
import qs

// Sidebar entry: Russian label + English subtitle
Rectangle {
    id: root
    property string ru
    property string en
    property string keyHint
    property bool selected: false
    signal clicked

    Layout.fillWidth: true
    implicitHeight: 44
    color: selected ? Theme.border : (mouse.containsMouse ? "#1b1e18" : "transparent")

    Rectangle {
        width: 3
        height: parent.height
        color: Theme.accent
        visible: root.selected
    }

    ColumnLayout {
        anchors.verticalCenter: parent.verticalCenter
        x: 16
        spacing: 1
        T {
            text: root.ru
            color: root.selected ? Theme.accent : Theme.fg
            font.pixelSize: 14
            font.bold: true
        }
        T {
            text: root.en
            color: Theme.dim
            font.pixelSize: 10
        }
    }

    T {
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        text: root.keyHint
        color: Theme.faint
        font.pixelSize: 9
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
