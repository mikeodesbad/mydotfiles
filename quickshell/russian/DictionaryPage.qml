import QtQuick
import QtQuick.Layouts
import qs
import "Grammar.js" as G

// Search Russian or English; shows full declension/conjugation tables
Item {
    id: root
    required property var store
    property bool active: false

    property var results: []
    property var sel: null

    function search(q) {
        const nq = store.normalize(q);
        const lq = q.toLowerCase().trim();
        if (!nq) {
            results = store.words.slice(0, 100);
        } else {
            const scored = [];
            for (const w of store.words) {
                const b = store.normalize(w.b);
                const s = b === nq ? 0 : b.startsWith(nq) ? 1 : w.en.toLowerCase().split(/[,;] */).includes(lq) ? 2 : w.en.toLowerCase().includes(lq) ? 3 : -1;
                if (s >= 0) scored.push([s, w]);
            }
            scored.sort((a, b) => a[0] - b[0] || a[1].rank - b[1].rank);
            results = scored.slice(0, 80).map(x => x[1]);
        }
        sel = results[0] ?? null;
    }

    function lookup(word) {
        input.text = word;
        search(word);
    }

    onActiveChanged: {
        if (active) {
            if (!results.length) search(input.text);
            input.focusInput();
        }
    }

    Connections {
        target: root.store
        function onReadyChanged() {
            if (root.store.ready && !root.results.length) root.search(input.text);
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // Search + results
        ColumnLayout {
            Layout.preferredWidth: 220
            Layout.maximumWidth: 220
            Layout.fillWidth: false
            Layout.fillHeight: true
            spacing: 8

            Input {
                id: input
                Layout.fillWidth: true
                fontSize: 15
                placeholder: "search RU or EN…"
                onTextChanged: root.search(text)
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: root.results
                delegate: Rectangle {
                    required property var modelData
                    width: ListView.view.width
                    height: 40
                    color: root.sel === modelData ? Theme.border : (rowMouse.containsMouse ? "#1b1e18" : "transparent")

                    ColumnLayout {
                        anchors.verticalCenter: parent.verticalCenter
                        x: 8
                        width: parent.width - 16
                        spacing: 0
                        T { text: modelData.w; font.pixelSize: 14; font.bold: true; color: root.sel === modelData ? Theme.accent : Theme.fg }
                        T { Layout.fillWidth: true; text: modelData.en; color: Theme.dim; font.pixelSize: 10; elide: Text.ElideRight }
                    }
                    MouseArea {
                        id: rowMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.sel = modelData
                    }
                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            implicitWidth: 1
            color: Theme.border
        }

        // Details
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentHeight: detail.implicitHeight
            visible: !!root.sel

            ColumnLayout {
                id: detail
                width: parent.width
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    T { text: root.sel?.w ?? ""; color: Theme.accent; font.pixelSize: 36; font.bold: true }
                    Item { Layout.fillWidth: true }
                    T {
                        text: root.sel ? root.store.statusText(root.sel.id) : ""
                        color: Theme.dim
                    }
                    Btn {
                        visible: { root.store.rev; return !!root.sel && !root.store.card(root.sel.id); }
                        big: true
                        text: "+ Add to review"
                        onClicked: root.store.addCard(root.sel.id)
                    }
                    Btn {
                        visible: { root.store.rev; return !!root.sel && !!root.store.card(root.sel.id)?.known; }
                        big: true
                        text: "Review it again"
                        onClicked: root.store.addCard(root.sel.id)
                    }
                }
                T { Layout.fillWidth: true; text: root.sel?.en ?? ""; font.pixelSize: 15; wrapMode: Text.Wrap }
                T { text: root.store.kind(root.sel); color: Theme.dim }

                Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.border; Layout.topMargin: 6 }

                // Noun
                FormTable {
                    visible: root.sel?.t === "n"
                    rowLabels: G.caseLabels
                    columns: root.sel?.t === "n" ? [{ title: "SINGULAR", forms: root.sel.sg }, { title: "PLURAL", forms: root.sel.pl }] : []
                }

                // Verb
                RowLayout {
                    visible: root.sel?.t === "v"
                    spacing: 30
                    FormTable {
                        Layout.alignment: Qt.AlignTop
                        labelWidth: 80
                        rowLabels: G.presPersons
                        columns: root.sel?.t === "v" ? [{ title: root.sel.asp === "perfective" ? "FUTURE" : "PRESENT", forms: root.sel.pres }] : []
                    }
                    FormTable {
                        Layout.alignment: Qt.AlignTop
                        labelWidth: 50
                        rowLabels: G.pastPersons
                        columns: root.sel?.t === "v" ? [{ title: "PAST", forms: root.sel.past }] : []
                    }
                    FormTable {
                        Layout.alignment: Qt.AlignTop
                        labelWidth: 40
                        rowLabels: G.impPersons
                        columns: root.sel?.t === "v" ? [{ title: "IMPERATIVE", forms: root.sel.imp }] : []
                    }
                }

                // Adjective
                FormTable {
                    visible: root.sel?.t === "a" && !!root.sel.decl
                    labelWidth: 95
                    colWidth: 105
                    rowLabels: G.caseLabels
                    columns: root.sel?.t === "a" && root.sel.decl ? [
                        { title: "MASC", forms: root.sel.decl.m },
                        { title: "FEM", forms: root.sel.decl.f },
                        { title: "NEUT", forms: root.sel.decl.n },
                        { title: "PLURAL", forms: root.sel.decl.pl }
                    ] : []
                }
                T {
                    visible: root.sel?.t === "a" && (root.sel.short.some(f => f) || !!root.sel.cmp)
                    Layout.topMargin: 4
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    text: root.sel?.t === "a"
                        ? [root.sel.short.some(f => f) && "short: " + root.sel.short.filter(f => f).join(" · "),
                           root.sel.cmp && "comparative: " + root.sel.cmp.replace(/;/g, ", ")].filter(Boolean).join("     ")
                        : ""
                    color: Theme.dim
                }
            }
        }
    }
}
