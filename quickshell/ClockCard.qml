import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Card {
    pad: 12

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Process {
        id: tzProc
        running: true
        command: ["date", "+%Z"]
        stdout: StdioCollector { onStreamFinished: tzLabel.text = this.text.trim() }
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: 6
        T {
            text: Qt.formatDateTime(clock.date, "HH:mm")
            color: Theme.accent
            font.pixelSize: 44
            font.bold: true
        }
        T {
            id: tzLabel
            Layout.alignment: Qt.AlignBottom
            bottomPadding: 8
            color: Theme.dim
            font.pixelSize: 11
        }
    }

    T {
        Layout.alignment: Qt.AlignHCenter
        text: Qt.formatDateTime(clock.date, "dddd  •  MMMM d, yyyy")
        font.bold: true
    }
}
