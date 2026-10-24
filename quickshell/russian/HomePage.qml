import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import "../DailyWords.js" as Daily

Item {
    id: root
    required property var store
    signal go(int page)
    signal lookup(string word)

    readonly property var daily: Daily.forDate(new Date())
    readonly property string dailyBare: daily.w.replace(/́/g, "")

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 28
        spacing: 18

        ColumnLayout {
            spacing: 4
            T {
                text: "Приве́т, " + (Quickshell.env("USER") ?? "") + "!"
                color: Theme.accent
                font.pixelSize: 28
                font.bold: true
            }
            T {
                text: {
                    store.rev;
                    const due = store.dueIds().length, nw = store.newLeft();
                    if (!store.ready) return "Loading dictionary…";
                    if (due + nw === 0) return "You're done for today. Отли́чно! Try the word quiz or sentences if you want more.";
                    return `Today: ${due} card${due === 1 ? "" : "s"} to review and ${nw} new word${nw === 1 ? "" : "s"}.`;
                }
                color: Theme.dim
                font.pixelSize: 13
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            StatTile { value: { store.rev; return store.streak(); } label: "day streak" }
            StatTile { value: { store.rev; return store.dueIds().length; } label: "due now" }
            StatTile {
                value: { store.rev; return store.today().newCount + "/" + store.progress.newPerDay; }
                label: "new today"
            }
            StatTile { value: { store.rev; return store.counts().learning; } label: "learning" }
            StatTile { value: { store.rev; return store.counts().known; } label: "known"; valueColor: Theme.fg }
        }

        RowLayout {
            spacing: 10
            Btn { big: true; active: true; text: "Start review  ›"; onClicked: root.go(1) }
            Btn { big: true; text: "Word quiz"; onClicked: root.go(2) }
            Btn { big: true; text: "Sentences"; onClicked: root.go(3) }
            Btn { big: true; text: "Build sentences"; onClicked: root.go(4) }
            Btn { big: true; text: "Dictionary"; onClicked: root.go(8) }
        }

        Card {
            Layout.fillWidth: true
            pad: 16
            spacing: 6

            T { text: "СЛОВО ДНЯ  ·  word of the day"; color: Theme.dim; font.pixelSize: 10 }
            RowLayout {
                Layout.fillWidth: true
                spacing: 14
                T { text: root.daily.w; color: Theme.accent; font.pixelSize: 30; font.bold: true }
                ColumnLayout {
                    spacing: 2
                    T { text: root.daily.tr; color: Theme.dim }
                    T { text: root.daily.m; font.pixelSize: 14 }
                }
                Item { Layout.fillWidth: true }
                Btn {
                    visible: { store.rev; return store.ready && !!store.byId[root.dailyBare.length ? findId(root.dailyBare) : ""]; }
                    text: "Open in dictionary"
                    onClicked: root.lookup(root.dailyBare)
                    function findId(b) {
                        return ["n:", "v:", "a:", "o:"].map(p => p + b).find(id => store.byId[id]) ?? "";
                    }
                }
            }
            T { text: root.daily.ex; font.pixelSize: 15 }
            T { text: root.daily.exT; color: Theme.dim; font.italic: true }
        }

        RowLayout {
            spacing: 8
            T { text: "New words per day:"; color: Theme.dim }
            Btn { text: "−"; onClicked: store.setNewPerDay(store.progress.newPerDay - 5) }
            T { text: { store.rev; return store.progress.newPerDay; } font.bold: true }
            Btn { text: "+"; onClicked: store.setNewPerDay(store.progress.newPerDay + 5) }
        }

        Item { Layout.fillHeight: true }

        T {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            text: "Tip: new words come in frequency order, starting with the most common. Since you already know the basics, press K (\"I know this\") on words you know and they'll never come back. Type answers with the Russian keyboard: Super+Space switches between EN and RU."
            color: Theme.faint
            font.pixelSize: 11
        }
    }
}
