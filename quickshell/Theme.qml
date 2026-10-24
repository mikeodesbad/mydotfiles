pragma Singleton
import QtQuick
import Quickshell

Singleton {
    // Colors
    readonly property color bg: "#e60f110e"
    readonly property color card: "#151713"
    readonly property color border: "#2c3127"
    readonly property color accent: "#a7b86d"
    readonly property color accentDim: "#5f6a3c"
    readonly property color fg: "#d0d0c4"
    readonly property color dim: "#7a7d6f"
    readonly property color faint: "#45483f"
    readonly property color warm: "#d8a657"
    readonly property color red: "#e67e80"

    readonly property string font: "JetBrainsMono Nerd Font"

    // Calendar days drawn in the warm color (0 = Sunday … 6 = Saturday)
    readonly property var weekendDays: [6, 0]

    // World clocks: first entry is treated as "local"
    readonly property var worldClocks: [
        { label: "Israel", tz: "Asia/Jerusalem" },
        { label: "USA · New York", tz: "America/New_York" },
        { label: "Japan · Tokyo", tz: "Asia/Tokyo" }
    ]

    // Nerd Font icons, by codepoint (they are invisible in most editors/terminals)
    readonly property var ic: ({
        prev: String.fromCodePoint(0xF04AE),
        play: String.fromCodePoint(0xF040A),
        pause: String.fromCodePoint(0xF03E4),
        next: String.fromCodePoint(0xF04AD),
        music: String.fromCodePoint(0xF0386),
        bell: String.fromCodePoint(0xF009A),
        bellOff: String.fromCodePoint(0xF009B),
        trash: String.fromCodePoint(0xF01B4),
        close: String.fromCodePoint(0xF0156),
        left: String.fromCodePoint(0xF0141),
        right: String.fromCodePoint(0xF0142),
        cloudy: String.fromCodePoint(0xF0590),
        sunny: String.fromCodePoint(0xF0599),
        partly: String.fromCodePoint(0xF0595),
        rainy: String.fromCodePoint(0xF0597),
        snowy: String.fromCodePoint(0xF0598),
        fog: String.fromCodePoint(0xF0591),
        storm: String.fromCodePoint(0xF0593),
        wind: String.fromCodePoint(0xF059D),
        humidity: String.fromCodePoint(0xF058E),
        up: String.fromCodePoint(0xF005D),
        down: String.fromCodePoint(0xF0045),
        camera: String.fromCodePoint(0xF0100)
    })
}
