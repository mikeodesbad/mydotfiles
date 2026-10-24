import QtQuick
import Quickshell
import Quickshell.Io

// Word data + learning progress (spaced repetition, daily stats)
Item {
    id: store

    property var words: []
    property var byId: ({})
    property var progress: ({ cards: {}, days: {}, newPerDay: 10, sentLevel: 0, numLevel: 1 })
    property var sentences: []
    property var glosses: []
    // Bumped on every change so bindings that read `progress` re-evaluate
    property int rev: 0
    readonly property bool ready: words.length > 0

    readonly property int day_ms: 86400000

    FileView {
        path: Qt.resolvedUrl("data.json").toString().replace("file://", "")
        onLoaded: {
            const ws = JSON.parse(text()).words;
            const map = {};
            ws.forEach((w, i) => {
                w.rank = i;
                map[w.id] = w;
            });
            store.byId = map;
            store.words = ws;
        }
    }

    // Tatoeba sentences with per-word glosses (built by build_sentences.py)
    FileView {
        path: Qt.resolvedUrl("sentences.json").toString().replace("file://", "")
        onLoaded: {
            const d = JSON.parse(text());
            store.glosses = d.glosses;
            store.sentences = d.sentences;
        }
    }

    FileView {
        id: progressFile
        path: Quickshell.env("HOME") + "/.local/share/russian-app/progress.json"
        printErrors: false
        onLoaded: {
            try {
                store.progress = Object.assign(store.progress, JSON.parse(text()));
            } catch (e) {}
            store.rev++;
        }
    }

    function save() {
        progressFile.setText(JSON.stringify(progress));
        rev++;
    }

    // ---- text helpers ----

    function normalize(s) {
        return (s ?? "").toLowerCase().replace(/[́']/g, "").replace(/ё/g, "е").trim();
    }

    // Forms may list alternatives: "то́й, то́ю"
    function matches(answer, form) {
        const a = normalize(answer);
        return a !== "" && form.split(",").some(f => normalize(f) === a);
    }

    function hasLatin(s) {
        return /[a-z]/i.test(s ?? "");
    }

    function kind(w) {
        if (!w) return "";
        if (w.t === "n") {
            const g = { m: "masculine", f: "feminine", n: "neuter" }[w.g] ?? (w.plOnly ? "plural only" : "");
            return "noun · " + g + (w.an ? " · animate" : "");
        }
        if (w.t === "v") return "verb · " + w.asp + (w.partner ? "  (pair: " + w.partner.replace(/;/g, ", ") + ")" : "");
        if (w.t === "a") return "adjective";
        return "word";
    }

    function formsSummary(w) {
        if (!w) return "";
        if (w.t === "n") return [w.sg?.[1] && "gen. " + w.sg[1], w.pl?.[0] && "pl. " + w.pl[0]].filter(Boolean).join("   ·   ");
        if (w.t === "v") return [w.pres?.[0] && "я " + w.pres[0], w.pres?.[1] && "ты " + w.pres[1], w.past?.[0] && "past " + w.past[0] + " / " + w.past[1]].filter(Boolean).join("   ·   ");
        if (w.t === "a" && w.decl) return [w.decl.m[0], w.decl.f[0], w.decl.n[0], w.decl.pl[0]].filter(Boolean).join("  ·  ");
        return "";
    }

    // ---- days / stats ----

    function dayKey(d) {
        return Qt.formatDate(d ?? new Date(), "yyyy-MM-dd");
    }

    function today() {
        const k = dayKey();
        if (!progress.days[k])
            progress.days[k] = { reviews: 0, newCount: 0, drills: 0, correct: 0 };
        return progress.days[k];
    }

    function streak() {
        const active = k => {
            const x = progress.days[k];
            return x && x.reviews + x.drills > 0;
        };
        const d = new Date();
        if (!active(dayKey(d))) d.setDate(d.getDate() - 1);
        let s = 0;
        while (active(dayKey(d))) {
            s++;
            d.setDate(d.getDate() - 1);
        }
        return s;
    }

    function counts() {
        let learning = 0, known = 0;
        for (const id in progress.cards) {
            if (progress.cards[id].known) known++;
            else learning++;
        }
        return { learning, known };
    }

    // ---- spaced repetition (SM-2 style) ----

    function card(id) {
        return progress.cards[id];
    }

    function dueIds() {
        const now = Date.now();
        return Object.keys(progress.cards)
            .filter(id => byId[id] && !progress.cards[id].known && progress.cards[id].due <= now)
            .sort((a, b) => progress.cards[a].due - progress.cards[b].due);
    }

    // Next unseen words, most frequent first
    function newIds(n) {
        const out = [];
        for (let i = 0; i < words.length && out.length < n; i++)
            if (!progress.cards[words[i].id]) out.push(words[i].id);
        return out;
    }

    function newLeft() {
        return Math.max(0, progress.newPerDay - today().newCount);
    }

    // g: 0 again, 1 hard, 2 good, 3 easy
    function grade(id, g) {
        let c = progress.cards[id];
        const isNew = !c;
        if (!c)
            c = progress.cards[id] = { ease: 2.5, interval: 0, reps: 0, lapses: 0, due: 0, added: Date.now() };

        if (g === 0) {
            c.reps = 0;
            c.lapses++;
            c.ease = Math.max(1.3, c.ease - 0.2);
            c.interval = 0;
            c.due = Date.now() + 60000;
        } else {
            if (g === 1) {
                c.interval = Math.max(1, Math.round(c.interval * 1.2));
                c.ease = Math.max(1.3, c.ease - 0.15);
            } else {
                c.interval = c.reps === 0 ? 1 : c.reps === 1 ? 3 : Math.round(c.interval * c.ease);
                if (g === 3) {
                    c.interval = Math.round(c.interval * 1.3) + 1;
                    c.ease += 0.15;
                }
            }
            c.reps++;
            c.due = Date.now() + c.interval * day_ms;
        }

        const d = today();
        d.reviews++;
        if (isNew) d.newCount++;
        if (g > 0) d.correct++;
        save();
    }

    function markKnown(id) {
        progress.cards[id] = { known: true, added: Date.now() };
        save();
    }

    function addCard(id) {
        if (!progress.cards[id] || progress.cards[id].known)
            progress.cards[id] = { ease: 2.5, interval: 0, reps: 0, lapses: 0, due: Date.now(), added: Date.now() };
        save();
    }

    function recordDrill(ok) {
        const d = today();
        d.drills++;
        if (ok) d.correct++;
        save();
    }

    function setNewPerDay(n) {
        progress.newPerDay = Math.max(0, Math.min(50, n));
        save();
    }

    function setLevel(key, n) {
        progress[key] = n;
        save();
    }

    // ---- quizzes ----

    // First couple of meanings: "hi, hello; hey there" -> "hi, hello"
    function shortEn(en) {
        return (en ?? "").split(/[;,] */).slice(0, 2).join(", ");
    }

    function pick(list) {
        return list[Math.floor(Math.random() * list.length)];
    }

    function shuffled(list) {
        const a = list.slice();
        for (let i = a.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [a[i], a[j]] = [a[j], a[i]];
        }
        return a;
    }

    // Words you're learning or know, or the most common ones until you have enough
    function quizPool() {
        const own = Object.keys(progress.cards).map(id => byId[id]).filter(Boolean);
        return own.length >= 20 ? own : words.slice(0, 400);
    }

    // The word plus 3 distractors of the same kind and similar frequency, shuffled
    function choicesFor(w) {
        const first = x => shortEn(x.en).split(",")[0].toLowerCase();
        const out = [w];
        const clash = x => out.some(o => o.b === x.b || first(o) === first(x));
        for (let span = 150; out.length < 4 && span < 20000; span *= 4) {
            const near = words.filter(x => x.t === w.t && Math.abs(x.rank - w.rank) <= span);
            for (const x of shuffled(near)) {
                if (out.length >= 4) break;
                if (!clash(x)) out.push(x);
            }
        }
        return shuffled(out);
    }

    // Sentence difficulty bands: frequency rank of the rarest word in the sentence
    readonly property var sentLevels: [
        { label: "Easy", max: 150 },
        { label: "Medium", max: 500 },
        { label: "Hard", max: 1500 },
        { label: "All", max: 1e9 }
    ]

    function sentencePool(level, minWords, maxWords) {
        const max = sentLevels[level].max;
        return sentences.filter(s => s.lvl < max && s.t.length >= (minWords ?? 0) && s.t.length <= (maxWords ?? 99));
    }

    function gloss(i) {
        const g = glosses[i];
        return g ? { lemma: g[0], en: g[1], form: g[2] } : null;
    }

    function statusText(id) {
        rev;
        const c = progress.cards[id];
        if (!c) return "";
        if (c.known) return "known";
        const days = Math.ceil((c.due - Date.now()) / day_ms);
        return days <= 0 ? "in review · due now" : "in review · due in " + days + "d";
    }
}
