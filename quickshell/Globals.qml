pragma Singleton
import QtQuick
import Quickshell

Singleton {
    property bool panelOpen: false
    property bool russianOpen: false
    // Word to show in the Russian app's dictionary when it opens
    property string russianLookup: ""
}
