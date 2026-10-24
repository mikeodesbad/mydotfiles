import QtQuick
import Quickshell
import Quickshell.Io
import "russian"

ShellRoot {
    Panel {}
    NotificationPopups {}

    // Russian learning app; only loaded while open
    LazyLoader {
        active: Globals.russianOpen
        RussianApp {}
    }

    // qs ipc call panel toggle | open | close
    IpcHandler {
        target: "panel"
        function toggle(): void { Globals.panelOpen = !Globals.panelOpen; }
        function open(): void { Globals.panelOpen = true; }
        function close(): void { Globals.panelOpen = false; }
    }

    // qs ipc call russian toggle | open | close | lookup <word>
    IpcHandler {
        target: "russian"
        function toggle(): void { Globals.russianOpen = !Globals.russianOpen; }
        function open(): void { Globals.russianOpen = true; }
        function close(): void { Globals.russianOpen = false; }
        function lookup(word: string): void {
            Globals.russianLookup = word;
            Globals.russianOpen = true;
        }
    }

    // Touch the notification singleton so the server starts at launch
    Component.onCompleted: Notifs.dnd
}
