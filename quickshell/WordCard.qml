import QtQuick
import QtQuick.Layouts
import Quickshell
import "DailyWords.js" as Daily

// Russian word of the day; click to open the Russian app on it
Card {
    id: root
    clickable: true
    onClicked: {
        Globals.russianLookup = word.w.replace(/\u0301/g, "");
        Globals.russianOpen = true;
        Globals.panelOpen = false;
    }

    SystemClock {
        id: clock
        precision: SystemClock.Hours
    }


    readonly property var word: Daily.forDate(clock.date)

    RowLayout {
        Layout.fillWidth: true
        T { text: "СЛОВО ДНЯ  ·  word of the day"; color: Theme.dim; font.pixelSize: 9 }
        Item { Layout.fillWidth: true }
        T { text: "practice ›"; color: Theme.accent; font.pixelSize: 9 }
    }
    RowLayout {
        Layout.fillWidth: true
        T { text: root.word.w; color: Theme.accent; font.pixelSize: 22; font.bold: true }
        Item { Layout.fillWidth: true }
        T { text: root.word.tr; color: Theme.dim; font.pixelSize: 11 }
    }
    T { text: root.word.m }
    T {
        Layout.fillWidth: true
        Layout.topMargin: 2
        text: root.word.ex
        font.pixelSize: 11
        wrapMode: Text.Wrap
    }
    T {
        Layout.fillWidth: true
        text: root.word.exT
        color: Theme.dim
        font.pixelSize: 10
        font.italic: true
        wrapMode: Text.Wrap
    }
}
