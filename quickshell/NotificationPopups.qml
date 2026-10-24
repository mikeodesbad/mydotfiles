import QtQuick
import Quickshell
import Quickshell.Wayland

// Top-right popups for new notifications (hidden in DND or while the panel is open)
PanelWindow {
    visible: Notifs.popups.length > 0 && !Globals.panelOpen
    anchors {
        top: true
        right: true
    }
    margins {
        top: 30
        right: 8
    }
    implicitWidth: 320
    implicitHeight: popupCol.implicitHeight
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-notifications"

    Column {
        id: popupCol
        width: parent.width
        spacing: 6

        Repeater {
            model: Notifs.popups
            NotificationItem {
                id: item
                required property var modelData
                notification: modelData
                width: popupCol.width
                onCloseClicked: Notifs.dismissPopup(modelData)

                // Critical notifications stay until closed; others hide after 5s (still kept in the panel)
                Timer {
                    running: item.modelData?.urgency !== 2
                    interval: 5000
                    onTriggered: Notifs.dismissPopup(item.modelData)
                }
            }
        }
    }
}
