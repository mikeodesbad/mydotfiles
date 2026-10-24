import QtQuick
import QtQuick.Layouts
import qs

// Table of word forms: rows × columns, with one cell optionally highlighted
ColumnLayout {
    id: root
    property var rowLabels: []
    property var columns: []          // [{ title, forms: [] }]
    property int hiRow: -1
    property int hiCol: -1
    property color hiColor: Theme.accent
    property int labelWidth: 110
    property int colWidth: 150
    spacing: 3

    RowLayout {
        spacing: 0
        Item { implicitWidth: root.labelWidth }
        Repeater {
            model: root.columns
            T {
                required property var modelData
                Layout.preferredWidth: root.colWidth
                text: modelData.title
                color: Theme.dim
                font.pixelSize: 10
                font.bold: true
            }
        }
    }

    Repeater {
        model: root.rowLabels
        RowLayout {
            id: row
            required property var modelData
            required property int index
            spacing: 0
            T {
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: root.labelWidth
                text: row.modelData
                color: Theme.dim
                font.pixelSize: 11
            }
            Repeater {
                model: root.columns
                T {
                    required property var modelData
                    required property int index
                    readonly property bool hi: row.index === root.hiRow && index === root.hiCol
                    Layout.preferredWidth: root.colWidth
                    Layout.alignment: Qt.AlignTop
                    // Alternatives ("краси́вый,краси́вого") go on separate lines
                    text: (modelData.forms[row.index] || "—").split(",").map(s => s.trim()).join("\n")
                    color: hi ? root.hiColor : Theme.fg
                    font.bold: hi
                    font.pixelSize: 13
                }
            }
        }
    }
}
