import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Card {
    id: root
    spacing: 8
    property var rows: []

    // "+0300" -> minutes
    function offsetMinutes(z) {
        const sign = z[0] === "-" ? -1 : 1;
        return sign * (parseInt(z.slice(1, 3)) * 60 + parseInt(z.slice(3, 5)));
    }

    function gmtLabel(mins) {
        const h = mins / 60;
        return "GMT" + (h >= 0 ? "+" : "") + (Number.isInteger(h) ? h : h.toFixed(1));
    }

    function parse(text) {
        const lines = text.trim().split("\n");
        const localOff = lines.length ? offsetMinutes(lines[0].split("|")[2]) : 0;
        rows = lines.map((line, i) => {
            const [time, date, z] = line.split("|");
            const off = offsetMinutes(z);
            const diff = (off - localOff) / 60;
            return {
                label: Theme.worldClocks[i].label,
                time: time,
                sub: date + "  |  " + gmtLabel(off),
                diff: i === 0 ? "local" : (diff === 0 ? "same" : (diff > 0 ? "+" : "") + diff + "h")
            };
        });
    }

    Process {
        id: proc
        running: true
        command: ["sh", "-c", Theme.worldClocks.map(c => `TZ=${c.tz} date '+%H:%M|%a %b %d|%z'`).join("; ")]
        stdout: StdioCollector { onStreamFinished: root.parse(this.text) }
    }

    Timer {
        running: Globals.panelOpen
        triggeredOnStart: true
        interval: 30000
        repeat: true
        onTriggered: proc.running = true
    }

    Repeater {
        model: root.rows
        RowLayout {
            required property var modelData
            Layout.fillWidth: true
            ColumnLayout {
                spacing: 1
                T { text: modelData.label; color: Theme.accent; font.bold: true }
                T { text: modelData.sub; color: Theme.dim; font.pixelSize: 10 }
            }
            Item { Layout.fillWidth: true }
            ColumnLayout {
                spacing: 1
                T { Layout.alignment: Qt.AlignRight; text: modelData.time; font.pixelSize: 16; font.bold: true }
                T { Layout.alignment: Qt.AlignRight; text: modelData.diff; color: Theme.dim; font.pixelSize: 10 }
            }
        }
    }
}
