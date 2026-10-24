import QtQuick

// Small square bordered button
Rectangle {
    id: root
    property alias text: label.text
    property bool active: false
    property bool big: false
    signal clicked

    implicitWidth: Math.max(big ? 40 : 24, label.implicitWidth + (big ? 28 : 14))
    implicitHeight: big ? 34 : 22
    color: mouse.containsMouse ? Theme.border : (active ? Theme.accentDim : "transparent")
    border.color: Theme.border
    border.width: 1

    T {
        id: label
        anchors.centerIn: parent
        font.pixelSize: root.big ? 13 : 11
        font.bold: true
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
