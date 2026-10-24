pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    property bool dnd: false
    // Notifications currently shown as popups (newest first)
    property var popups: []
    readonly property var list: server.trackedNotifications.values

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: false
        imageSupported: true
        actionsSupported: true
        persistenceSupported: true

        onNotification: n => {
            n.tracked = true;
            n.closed.connect(() => root.dismissPopup(n));
            if (!root.dnd && !Globals.panelOpen)
                root.popups = [n].concat(root.popups).slice(0, 3);
        }
    }

    function dismissPopup(n) {
        popups = popups.filter(p => p !== n);
    }

    function clearAll() {
        for (const n of server.trackedNotifications.values.slice())
            n.dismiss();
        popups = [];
    }
}
