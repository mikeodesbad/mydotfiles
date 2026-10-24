#!/usr/bin/env python3
"""Build data.json for the Russian app from the OpenRussian.org CSV export.

Data: https://github.com/Badestrand/russian-dictionary (OpenRussian.org, CC BY-SA 4.0)
Usage: build_data.py <dir with nouns/verbs/adjectives/others.csv> <out.json>
"""
import csv, json, sys, pathlib

LIMITS = {"nouns": 1500, "verbs": 1000, "adjectives": 700, "others": 400}
CASES = ["nom", "gen", "dat", "acc", "inst", "prep"]
STRESS = "́"


def acc(s):
    """OpenRussian marks stress with an apostrophe after the vowel; use a combining acute."""
    return (s or "").replace("'", STRESS).strip()


def rows(src, name):
    with open(src / f"{name}.csv", newline="", encoding="utf-8") as f:
        for r in csv.DictReader(f, delimiter="\t"):
            if r["bare"] and r["translations_en"] and " " not in r["bare"]:
                yield r


def build(src):
    cats = {}
    for name, limit in LIMITS.items():
        out = []
        for r in rows(src, name):
            w = {"w": acc(r["accented"]) or r["bare"], "b": r["bare"], "en": r["translations_en"]}
            if name == "nouns":
                if r["indeclinable"] == "1":
                    continue
                w.update(t="n", g=r["gender"], an=r["animate"] == "1",
                         sgOnly=r["sg_only"] == "1", plOnly=r["pl_only"] == "1",
                         sg=[acc(r[f"sg_{c}"]) for c in CASES],
                         pl=[acc(r[f"pl_{c}"]) for c in CASES])
            elif name == "verbs":
                w.update(t="v", asp=r["aspect"], partner=r["partner"],
                         pres=[acc(r[f"presfut_{p}"]) for p in ("sg1", "sg2", "sg3", "pl1", "pl2", "pl3")],
                         past=[acc(r[f"past_{p}"]) for p in ("m", "f", "n", "pl")],
                         imp=[acc(r["imperative_sg"]), acc(r["imperative_pl"])])
            elif name == "adjectives":
                w.update(t="a", cmp=acc(r["comparative"]), sup=acc(r["superlative"]),
                         short=[acc(r[f"short_{g}"]) for g in ("m", "f", "n", "pl")],
                         decl={g: [acc(r[f"decl_{g}_{c}"]) for c in CASES] for g in ("m", "f", "n", "pl")})
            else:
                w["t"] = "o"
            out.append(w)
            if len(out) >= limit:
                break
        cats[name] = out

    # Interleave by relative frequency rank so the list is roughly "most common first"
    merged = []
    for name, words in cats.items():
        for i, w in enumerate(words):
            merged.append((i / len(words), w))
    merged.sort(key=lambda x: x[0])
    words = []
    seen = set()
    for _, w in merged:
        key = w["t"] + ":" + w["b"]
        if key in seen:
            continue
        seen.add(key)
        w["id"] = key
        words.append(w)
    return words


if __name__ == "__main__":
    src, out = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
    words = build(src)
    out.write_text(json.dumps({"source": "OpenRussian.org (CC BY-SA 4.0)", "words": words}, ensure_ascii=False, separators=(",", ":")))
    print(len(words), "words", out.stat().st_size // 1024, "KiB")
