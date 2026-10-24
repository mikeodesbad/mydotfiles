import QtQuick
import QtQuick.Layouts

// Bordered box; children are laid out in a column
Rectangle {
    id: root
    default property alias content: inner.data
    property int pad: 10
    property alias spacing: inner.spacing
    property bool clickable: false
    signal clicked

    color: Theme.card
    border.color: clickable && cardMouse.containsMouse ? Theme.accent : Theme.border
    border.width: 1
    implicitHeight: inner.implicitHeight + pad * 2

    ColumnLayout {
        id: inner
        x: root.pad
        y: root.pad
        width: root.width - root.pad * 2
        height: root.height - root.pad * 2
        spacing: 6
    }

    MouseArea {
        id: cardMouse
        anchors.fill: parent
        enabled: root.clickable
        hoverEnabled: root.clickable
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
