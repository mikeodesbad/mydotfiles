import QtQuick
import QtQuick.Layouts
import Quickshell
import qs

// "Русский": flashcards, case + verb drills and a dictionary.
// Open with SUPER+SHIFT+R, the launcher, or by clicking the word of the day in the side panel.
FloatingWindow {
    id: win
    title: "Русский"
    implicitWidth: 1000
    implicitHeight: 640
    color: "#0f110e"

    property int page: 0

    onClosed: Globals.russianOpen = false
    onVisibleChanged: if (!visible) Globals.russianOpen = false

    Store {
        id: store
        onReadyChanged: win.applyLookup()
    }

    // Open the dictionary on a word requested from the side panel
    function applyLookup() {
        if (!store.ready || !Globals.russianLookup) return;
        const word = Globals.russianLookup;
        Globals.russianLookup = "";
        page = win.dictPage;
        dict.lookup(word);
    }

    readonly property int dictPage: 8

    Connections {
        target: Globals
        function onRussianLookupChanged() {
            win.applyLookup();
        }
    }

    Shortcut { sequence: "Ctrl+1"; onActivated: win.page = 0 }
    Shortcut { sequence: "Ctrl+2"; onActivated: win.page = 1 }
    Shortcut { sequence: "Ctrl+3"; onActivated: win.page = 2 }
    Shortcut { sequence: "Ctrl+4"; onActivated: win.page = 3 }
    Shortcut { sequence: "Ctrl+5"; onActivated: win.page = 4 }
    Shortcut { sequence: "Ctrl+6"; onActivated: win.page = 5 }
    Shortcut { sequence: "Ctrl+7"; onActivated: win.page = 6 }
    Shortcut { sequence: "Ctrl+8"; onActivated: win.page = 7 }
    Shortcut { sequence: "Ctrl+9"; onActivated: win.page = 8 }
    Shortcut { sequence: "Ctrl+F"; onActivated: win.page = win.dictPage }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Sidebar
        Rectangle {
            Layout.fillHeight: true
            implicitWidth: 190
            color: Theme.card

            Rectangle {
                anchors.right: parent.right
                width: 1
                height: parent.height
                color: Theme.border
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: 22
                anchors.bottomMargin: 16
                spacing: 2

                ColumnLayout {
                    Layout.leftMargin: 16
                    Layout.bottomMargin: 18
                    spacing: 0
                    T { text: "Ру́сский"; color: Theme.accent; font.pixelSize: 24; font.bold: true }
                    T { text: "learn Russian"; color: Theme.dim; font.pixelSize: 11 }
                }

                NavButton { ru: "Сего́дня"; en: "today"; keyHint: "^1"; selected: win.page === 0; onClicked: win.page = 0 }
                NavButton {
                    ru: "Карто́чки"
                    en: { store.rev; const n = store.dueIds().length + store.newLeft(); return n ? "flashcards · " + n + " waiting" : "flashcards"; }
                    keyHint: "^2"
                    selected: win.page === 1
                    onClicked: win.page = 1
                }
                NavButton { ru: "Перево́д"; en: "word quiz"; keyHint: "^3"; selected: win.page === 2; onClicked: win.page = 2 }
                NavButton { ru: "Предложе́ния"; en: "sentence meanings"; keyHint: "^4"; selected: win.page === 3; onClicked: win.page = 3 }
                NavButton { ru: "Сбо́рка"; en: "build the sentence"; keyHint: "^5"; selected: win.page === 4; onClicked: win.page = 4 }
                NavButton { ru: "Падежи́"; en: "noun cases"; keyHint: "^6"; selected: win.page === 5; onClicked: win.page = 5 }
                NavButton { ru: "Глаго́лы"; en: "verb conjugation"; keyHint: "^7"; selected: win.page === 6; onClicked: win.page = 6 }
                NavButton { ru: "Чи́сла"; en: "numbers"; keyHint: "^8"; selected: win.page === 7; onClicked: win.page = 7 }
                NavButton { ru: "Слова́рь"; en: "dictionary"; keyHint: "^9"; selected: win.page === 8; onClicked: win.page = 8 }

                Item { Layout.fillHeight: true }

                T {
                    Layout.leftMargin: 16
                    text: { store.rev; const s = store.streak(); return s ? s + "-day streak" : "start a streak today"; }
                    color: Theme.warm
                    font.bold: true
                }
                T {
                    Layout.leftMargin: 16
                    Layout.topMargin: 8
                    text: "Super+Space  ·  EN ⇄ RU"
                    color: Theme.dim
                    font.pixelSize: 10
                }
                T {
                    Layout.leftMargin: 16
                    Layout.rightMargin: 12
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    text: "Dictionary: OpenRussian.org, CC BY-SA 4.0 · Sentences: Tatoeba.org, CC BY 2.0 FR"
                    color: Theme.faint
                    font.pixelSize: 9
                }
            }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: win.page

            HomePage {
                store: store
                onGo: p => win.page = p
                onLookup: word => {
                    win.page = win.dictPage;
                    dict.lookup(word);
                }
            }
            ReviewPage { store: store; active: win.page === 1 }
            QuizPage { store: store; active: win.page === 2 }
            SentencesPage {
                store: store
                active: win.page === 3
                onLookup: word => {
                    win.page = win.dictPage;
                    dict.lookup(word);
                }
            }
            BuildPage { store: store; active: win.page === 4 }
            CasesPage { store: store; active: win.page === 5 }
            VerbsPage { store: store; active: win.page === 6 }
            NumbersPage { store: store; active: win.page === 7 }
            DictionaryPage { id: dict; store: store; active: win.page === 8 }
        }
    }
}
