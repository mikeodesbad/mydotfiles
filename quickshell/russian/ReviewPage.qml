import QtQuick
import QtQuick.Layouts
import qs

// Flashcards: due reviews first, then today's new words
Item {
    id: root
    required property var store
    property bool active: false

    property var queue: []
    property string current: ""
    property bool revealed: false
    property bool production: false   // EN -> RU
    property int done: 0

    readonly property var word: store.byId[current] ?? null
    readonly property bool isNew: { store.rev; return !!current && !store.card(current); }

    function start(extraNew) {
        queue = store.dueIds().concat(store.newIds(extraNew ?? store.newLeft()));
        next();
    }

    function next() {
        if (queue.length === 0) {
            current = "";
            return;
        }
        current = queue[0];
        queue = queue.slice(1);
        revealed = false;
        const c = store.card(current);
        production = !!c && c.reps >= 1 && Math.random() < 0.35;
        keys.forceActiveFocus();
    }

    function answer(g) {
        if (!revealed || !current) return;
        store.grade(current, g);
        if (g === 0) {
            const q = queue.slice();
            q.splice(Math.min(3, q.length), 0, current);
            queue = q;
        }
        done++;
        next();
    }

    function known() {
        if (!current) return;
        store.markKnown(current);
        next();
    }

    onActiveChanged: {
        if (active) {
            if (!current) start();
            keys.forceActiveFocus();
        }
    }

    Item {
        id: keys
        anchors.fill: parent
        focus: true
        Keys.onPressed: event => {
            // Leave Ctrl/Alt combos to the window shortcuts (Ctrl+1..5)
            if (event.modifiers & (Qt.ControlModifier | Qt.AltModifier)) return;
            if (event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (!root.revealed) root.revealed = true;
                else root.answer(2);
            } else if (event.key >= Qt.Key_1 && event.key <= Qt.Key_4) {
                root.answer(event.key - Qt.Key_1);
            } else if (event.key === Qt.Key_K && root.isNew) {
                root.known();
            } else {
                return;
            }
            event.accepted = true;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 28
        spacing: 14

        RowLayout {
            Layout.fillWidth: true
            T { text: "Карто́чки"; color: Theme.accent; font.pixelSize: 22; font.bold: true }
            T { text: "flashcards"; color: Theme.dim; Layout.alignment: Qt.AlignBottom; bottomPadding: 3 }
            Item { Layout.fillWidth: true }
            T {
                visible: !!root.current
                text: (root.queue.length + 1) + " left  ·  " + root.done + " done"
                color: Theme.dim
            }
        }

        // The card
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.card
            border.color: Theme.border
            border.width: 1
            visible: !!root.word

            Rectangle {
                visible: root.isNew
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 12
                implicitWidth: newLabel.implicitWidth + 12
                implicitHeight: 20
                color: Theme.accentDim
                T { id: newLabel; anchors.centerIn: parent; text: "NEW"; font.pixelSize: 10; font.bold: true }
            }

            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width - 60
                spacing: 10

                T {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: parent.width
                    text: root.production ? (root.word?.en ?? "") : (root.word?.w ?? "")
                    color: Theme.accent
                    font.pixelSize: root.production ? 24 : 44
                    font.bold: true
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                }
                T {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.production ? "say it in Russian" : root.store.kind(root.word)
                    color: Theme.dim
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    implicitHeight: 1
                    color: Theme.border
                    visible: root.revealed
                }

                T {
                    visible: root.revealed
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: parent.width
                    text: root.production ? (root.word?.w ?? "") : (root.word?.en ?? "")
                    font.pixelSize: root.production ? 36 : 22
                    color: root.production ? Theme.accent : Theme.fg
                    font.bold: root.production
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                }
                T {
                    visible: root.revealed && root.production
                    Layout.alignment: Qt.AlignHCenter
                    text: root.store.kind(root.word)
                    color: Theme.dim
                }
                T {
                    visible: root.revealed
                    Layout.alignment: Qt.AlignHCenter
                    text: root.store.formsSummary(root.word)
                    color: Theme.dim
                    font.pixelSize: 13
                }
            }
        }

        // Done state
        ColumnLayout {
            visible: !root.word
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12
            Item { Layout.fillHeight: true }
            T {
                Layout.alignment: Qt.AlignHCenter
                text: root.store.ready ? "Всё! Nothing left to review." : "Loading…"
                color: Theme.accent
                font.pixelSize: 24
                font.bold: true
            }
            T {
                Layout.alignment: Qt.AlignHCenter
                text: root.done ? "You reviewed " + root.done + " cards this session." : "Come back later for due cards, or learn some extra words."
                color: Theme.dim
            }
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10
                Btn { big: true; text: "Learn 5 more words"; onClicked: root.start(5) }
                Btn { big: true; text: "Check for due cards"; onClicked: root.start(0) }
            }
            Item { Layout.fillHeight: true }
        }

        // Controls
        RowLayout {
            visible: !!root.word
            Layout.alignment: Qt.AlignHCenter
            spacing: 10

            Btn { visible: !root.revealed; big: true; active: true; text: "Show answer  (Space)"; onClicked: root.revealed = true }
            Btn { visible: !root.revealed && root.isNew; big: true; text: "I know this  (K)"; onClicked: root.known() }

            Btn { visible: root.revealed; big: true; text: "Again  1"; onClicked: root.answer(0) }
            Btn { visible: root.revealed; big: true; text: "Hard  2"; onClicked: root.answer(1) }
            Btn { visible: root.revealed; big: true; active: true; text: "Good  3"; onClicked: root.answer(2) }
            Btn { visible: root.revealed; big: true; text: "Easy  4"; onClicked: root.answer(3) }
        }
    }
}
