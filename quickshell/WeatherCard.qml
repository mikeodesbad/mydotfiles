import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Card {
    id: root
    property var data: null

    // wttr.in weather codes -> icon
    function icon(code) {
        const c = parseInt(code);
        if (c === 113) return Theme.ic.sunny;
        if (c === 116) return Theme.ic.partly;
        if (c === 119 || c === 122) return Theme.ic.cloudy;
        if ([143, 248, 260].includes(c)) return Theme.ic.fog;
        if ([200, 386, 389, 392, 395].includes(c)) return Theme.ic.storm;
        if ([179, 182, 185, 227, 230, 317, 320, 323, 326, 329, 332, 335, 338, 350, 362, 365, 368, 371, 374, 377].includes(c)) return Theme.ic.snowy;
        return Theme.ic.rainy;
    }

    function parse(text) {
        try {
            const j = JSON.parse(text);
            const cur = j.current_condition[0];
            data = {
                icon: icon(cur.weatherCode),
                temp: cur.temp_C,
                desc: cur.weatherDesc[0].value,
                wind: cur.windspeedKmph,
                humidity: cur.humidity,
                hi: j.weather[0].maxtempC,
                lo: j.weather[0].mintempC,
                days: j.weather.slice(1, 3).map(d => ({
                    name: Qt.formatDate(new Date(d.date), "ddd").toUpperCase(),
                    icon: icon(d.hourly[4].weatherCode),
                    hi: d.maxtempC,
                    lo: d.mintempC
                }))
            };
        } catch (e) {
            // keep the last good data
        }
    }

    // Location is detected from your IP; use e.g. "wttr.in/Tel+Aviv?format=j1" to pin a city
    Process {
        id: proc
        running: true
        command: ["curl", "-sf", "--max-time", "10", "wttr.in/?format=j1"]
        stdout: StdioCollector { onStreamFinished: root.parse(this.text) }
    }

    Timer {
        running: true
        interval: 30 * 60 * 1000
        repeat: true
        onTriggered: proc.running = true
    }

    T {
        visible: !root.data
        Layout.alignment: Qt.AlignHCenter
        text: "Loading weather…"
        color: Theme.dim
    }

    RowLayout {
        visible: !!root.data
        Layout.fillWidth: true
        T { text: root.data?.icon ?? ""; font.pixelSize: 34; color: Theme.fg }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            T {
                Layout.alignment: Qt.AlignHCenter
                text: (root.data?.temp ?? "") + "°C"
                color: Theme.accent
                font.pixelSize: 26
                font.bold: true
            }
            T {
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: 140
                text: root.data?.desc ?? ""
                color: Theme.dim
                elide: Text.ElideRight
            }
        }
        ColumnLayout {
            spacing: 2
            T { text: (root.data?.hi ?? "") + "°C " + Theme.ic.up; color: Theme.dim; font.pixelSize: 10 }
            T { text: (root.data?.lo ?? "") + "°C " + Theme.ic.down; color: Theme.dim; font.pixelSize: 10 }
        }
    }

    RowLayout {
        visible: !!root.data
        Layout.alignment: Qt.AlignHCenter
        spacing: 16
        T { text: Theme.ic.wind + " " + (root.data?.wind ?? "") + " km/h"; color: Theme.dim }
        T { text: Theme.ic.humidity + " " + (root.data?.humidity ?? "") + "%"; color: Theme.dim }
    }

    RowLayout {
        visible: !!root.data
        Layout.alignment: Qt.AlignHCenter
        spacing: 20
        Repeater {
            model: root.data?.days ?? []
            T {
                required property var modelData
                text: `<b>${modelData.name}</b> ${modelData.icon} <font color="${Theme.dim}">${modelData.hi}° / ${modelData.lo}°</font>`
                textFormat: Text.StyledText
                font.pixelSize: 11
            }
        }
    }
}
