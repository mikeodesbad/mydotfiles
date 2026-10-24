import QtQuick
import QtQuick.Layouts
import qs
import "Grammar.js" as G

// Type the right case form of a noun
Item {
    id: root
    required property var store
    property bool active: false

    property var pool: []
    property var w: null
    property int num: 0        // 0 singular, 1 plural
    property int ci: 0         // case index
    property string phase: "ask"   // ask | right | wrong
    property int total: 0
    property int nCorrect: 0
    property int streak: 0

    readonly property string target: w ? (num ? w.pl : w.sg)[ci] : ""

    function complete(w) {
        return w && w.t === "n" && (w.sg.every(f => f) || w.pl.every(f => f));
    }

    // Practice your own nouns once you have enough, otherwise the 300 most common
    function buildPool() {
        let ws = Object.keys(store.progress.cards).filter(id => id.startsWith("n:")).map(id => store.byId[id]).filter(complete);
        if (ws.length < 20)
            ws = store.words.filter(complete).slice(0, 300);
        pool = ws;
    }

    function ask() {
        for (let tries = 0; tries < 50; tries++) {
            const cand = pool[Math.floor(Math.random() * pool.length)];
            const n = cand.sgOnly ? 0 : cand.plOnly ? 1 : (Math.random() < 0.6 ? 0 : 1);
            const c = n === 0 ? 1 + Math.floor(Math.random() * 5) : Math.floor(Math.random() * 6);
            if ((n ? cand.pl : cand.sg)[c]) {
                w = cand;
                num = n;
                ci = c;
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
            T { text: "Падежи́"; color: Theme.accent; font.pixelSize: 22; font.bold: true }
            T { text: "noun cases"; color: Theme.dim; Layout.alignment: Qt.AlignBottom; bottomPadding: 3 }
            Item { Layout.fillWidth: true }
            T { text: root.nCorrect + " / " + root.total + " correct  ·  streak " + root.streak; color: Theme.dim }
        }

        Card {
            Layout.fillWidth: true
            pad: 18
            spacing: 8

            RowLayout {
                spacing: 12
                T { text: root.w ? (root.w.sg[0] || root.w.pl[0]) : ""; color: Theme.accent; font.pixelSize: 34; font.bold: true }
                T { text: root.w?.en ?? ""; color: Theme.dim; Layout.maximumWidth: 380; elide: Text.ElideRight }
            }
            T {
                text: "→  " + G.cases[root.ci].en + "  ·  " + (root.num ? "plural" : "singular")
                font.pixelSize: 18
                font.bold: true
            }
            T {
                text: G.cases[root.ci].ru + "  ·  " + G.cases[root.ci].q + "  ·  " + G.cases[root.ci].use
                color: Theme.dim
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

        // Full table after answering
        FormTable {
            visible: root.phase !== "ask"
            Layout.topMargin: 6
            rowLabels: G.caseLabels
            columns: root.w ? [{ title: "SINGULAR", forms: root.w.sg }, { title: "PLURAL", forms: root.w.pl }] : []
            hiRow: root.ci
            hiCol: root.num
            hiColor: root.phase === "right" ? Theme.accent : Theme.red
        }

        Item { Layout.fillHeight: true }
    }
}
