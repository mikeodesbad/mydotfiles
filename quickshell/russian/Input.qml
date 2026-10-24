import QtQuick
import qs

// Single-line text box in the panel style
Rectangle {
    id: root
    property alias text: input.text
    property string placeholder: ""
    property color frame: input.activeFocus ? Theme.accent : Theme.border
    property int fontSize: 18
    signal accepted

    function focusInput() {
        input.forceActiveFocus();
    }

    implicitHeight: fontSize + 22
    color: Theme.bg
    border.color: frame
    border.width: 1

    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        verticalAlignment: TextInput.AlignVCenter
        color: Theme.fg
        font.family: Theme.font
        font.pixelSize: root.fontSize
        selectionColor: Theme.accentDim
        clip: true
        onAccepted: root.accepted()

        T {
            anchors.verticalCenter: parent.verticalCenter
            visible: !input.text
            text: root.placeholder
            color: Theme.faint
            font.pixelSize: Math.min(15, root.fontSize)
        }
    }
}
