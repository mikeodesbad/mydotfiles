import QtQuick
import QtQuick.Layouts
import qs
import "Grammar.js" as G

// Type the right conjugated form of a verb
Item {
    id: root
    required property var store
    property bool active: false

    property var pool: []
    property var w: null
    property string tense: "pres"    // pres | past | imp
    property int pi: 0               // person index
    property string phase: "ask"
    property int total: 0
    property int nCorrect: 0
    property int streak: 0

    readonly property var forms: w ? w[tense] : []
    readonly property string target: forms[pi] ?? ""
    readonly property var persons: tense === "pres" ? G.presPersons : tense === "past" ? G.pastPersons : G.impPersons
    readonly property string tenseLabel: tense === "past" ? "past" : tense === "imp" ? "imperative"
        : (w?.asp === "perfective" ? "future (perfective)" : "present")

    function complete(w) {
        return w && w.t === "v" && w.pres.every(f => f) && w.past.every(f => f);
    }

    function buildPool() {
        let ws = Object.keys(store.progress.cards).filter(id => id.startsWith("v:")).map(id => store.byId[id]).filter(complete);
        if (ws.length < 15)
            ws = store.words.filter(complete).slice(0, 200);
        pool = ws;
    }

    function ask() {
        for (let tries = 0; tries < 50; tries++) {
            const cand = pool[Math.floor(Math.random() * pool.length)];
            const r = Math.random();
            const t = r < 0.6 ? "pres" : r < 0.9 ? "past" : "imp";
            const p = Math.floor(Math.random() * cand[t].length);
            if (cand[t][p]) {
                w = cand;
                tense = t;
                pi = p;
                break;
            }
        }
        input.text = "";
        phase = "ask";
        input.focusInput();
    }

    function check(giveUp) {
        if (phase !== "ask") {
            ask();
            return;
        }
        if (!giveUp && !input.text.trim()) return;
        const ok = !giveUp && store.matches(input.text, target);
        phase = ok ? "right" : "wrong";
        total++;
        if (ok) {
            nCorrect++;
            streak++;
        } else {
            streak = 0;
        }
        store.recordDrill(ok);
    }

    onActiveChanged: {
        if (active && store.ready) {
            if (!w) {
                buildPool();
                ask();
            }
            input.focusInput();
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 28
        spacing: 14

        RowLayout {
            Layout.fillWidth: true
            T { text: "Глаго́лы"; color: Theme.accent; font.pixelSize: 22; font.bold: true }
            T { text: "verb conjugation"; color: Theme.dim; Layout.alignment: Qt.AlignBottom; bottomPadding: 3 }
            Item { Layout.fillWidth: true }
            T { text: root.nCorrect + " / " + root.total + " correct  ·  streak " + root.streak; color: Theme.dim }
        }

        Card {
            Layout.fillWidth: true
            pad: 18
            spacing: 8

            RowLayout {
                spacing: 12
                T { text: root.w?.w ?? ""; color: Theme.accent; font.pixelSize: 34; font.bold: true }
                ColumnLayout {
                    spacing: 2
                    T { text: root.w?.en ?? ""; color: Theme.dim; Layout.maximumWidth: 420; elide: Text.ElideRight }
                    T { text: root.store.kind(root.w); color: Theme.faint; font.pixelSize: 11 }
                }
            }
            T {
                text: "→  " + root.persons[root.pi] + "  ·  " + root.tenseLabel
                font.pixelSize: 18
                font.bold: true
            }
        }

        Input {
            id: input
            Layout.fillWidth: true
            fontSize: 22
            placeholder: "type the form in Russian, Enter to check"
            frame: root.phase === "right" ? Theme.accent : root.phase === "wrong" ? Theme.red : (activeFocus ? Theme.accent : Theme.border)
            onAccepted: root.check(false)
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            T {
                Layout.fillWidth: true
                text: root.phase === "right" ? "✓  Пра́вильно!  " + root.target
                    : root.phase === "wrong" ? "✗  Correct answer:  " + root.target
                    : root.store.hasLatin(input.text) ? "Looks like Latin letters: press Super+Space to switch to the Russian keyboard"
                    : ""
                color: root.phase === "right" ? Theme.accent : root.phase === "wrong" ? Theme.red : Theme.warm
                font.pixelSize: root.phase === "ask" ? 12 : 17
                font.bold: root.phase !== "ask"
            }
            Btn { visible: root.phase === "ask"; big: true; text: "Show answer"; onClicked: root.check(true) }
            Btn { big: true; active: root.phase !== "ask"; text: root.phase === "ask" ? "Check  ⏎" : "Next  ⏎"; onClicked: root.check(false) }
        }

        RowLayout {
            visible: root.phase !== "ask"
            Layout.topMargin: 6
            spacing: 30
            FormTable {
                Layout.alignment: Qt.AlignTop
                labelWidth: 80
                rowLabels: G.presPersons
                columns: root.w ? [{ title: root.w.asp === "perfective" ? "FUTURE" : "PRESENT", forms: root.w.pres }] : []
                hiRow: root.tense === "pres" ? root.pi : -1
                hiCol: 0
                hiColor: root.phase === "right" ? Theme.accent : Theme.red
            }
            FormTable {
                Layout.alignment: Qt.AlignTop
                labelWidth: 50
                rowLabels: G.pastPersons
                columns: root.w ? [{ title: "PAST", forms: root.w.past }] : []
                hiRow: root.tense === "past" ? root.pi : -1
                hiCol: 0
                hiColor: root.phase === "right" ? Theme.accent : Theme.red
            }
            FormTable {
                Layout.alignment: Qt.AlignTop
                labelWidth: 40
                rowLabels: G.impPersons
                columns: root.w ? [{ title: "IMPERATIVE", forms: root.w.imp }] : []
                hiRow: root.tense === "imp" ? root.pi : -1
                hiCol: 0
                hiColor: root.phase === "right" ? Theme.accent : Theme.red
            }
        }

        Item { Layout.fillHeight: true }
    }
}
