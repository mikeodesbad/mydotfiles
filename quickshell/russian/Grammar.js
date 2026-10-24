.pragma library

var cases = [
    { en: "Nominative", ru: "имени́тельный", q: "кто? что?", use: "the subject" },
    { en: "Genitive", ru: "роди́тельный", q: "кого́? чего́?", use: "of · нет ___ · after 2–4 (sg) and 5+ (pl)" },
    { en: "Dative", ru: "да́тельный", q: "кому́? чему́?", use: "to / for someone · к ___" },
    { en: "Accusative", ru: "вини́тельный", q: "кого́? что?", use: "direct object · в / на + motion" },
    { en: "Instrumental", ru: "твори́тельный", q: "кем? чем?", use: "with (с ___) · by means of" },
    { en: "Prepositional", ru: "предло́жный", q: "о ком? о чём?", use: "about (о ___) · location with в / на" }
];

var caseLabels = cases.map(c => c.en);

var presPersons = ["я", "ты", "он / она́", "мы", "вы", "они́"];
var pastPersons = ["он", "она́", "оно́", "они́"];
var impPersons = ["ты", "вы"];

// ---- numbers (0–9999) ----

var units = ["", "оди́н", "два", "три", "четы́ре", "пять", "шесть", "семь", "во́семь", "де́вять"];
var unitsFem = ["", "одна́", "две", "три", "четы́ре", "пять", "шесть", "семь", "во́семь", "де́вять"];
var teens = ["де́сять", "оди́ннадцать", "двена́дцать", "трина́дцать", "четы́рнадцать", "пятна́дцать",
             "шестна́дцать", "семна́дцать", "восемна́дцать", "девятна́дцать"];
var tens = ["", "", "два́дцать", "три́дцать", "со́рок", "пятьдеся́т", "шестьдеся́т", "се́мьдесят", "во́семьдесят", "девяно́сто"];
var hundreds = ["", "сто", "две́сти", "три́ста", "четы́реста", "пятьсо́т", "шестьсо́т", "семьсо́т", "восемьсо́т", "девятьсо́т"];

function below1000(n, fem) {
    var out = [hundreds[Math.floor(n / 100)]];
    var r = n % 100;
    if (r >= 10 && r < 20) out.push(teens[r - 10]);
    else out.push(tens[Math.floor(r / 10)], (fem ? unitsFem : units)[r % 10]);
    return out.filter(function (s) { return s; }).join(" ");
}

// Number in words. Alternatives are comma-separated (1000 can be "ты́сяча" or "одна́ ты́сяча").
function numberWords(n) {
    if (n === 0) return "ноль, нуль";
    var t = Math.floor(n / 1000), rest = below1000(n % 1000, false);
    if (t === 0) return rest;
    var last = t % 10, word = t % 100 >= 11 && t % 100 <= 14 ? "ты́сяч" : last === 1 ? "ты́сяча" : last >= 2 && last <= 4 ? "ты́сячи" : "ты́сяч";
    var join = function (a) { return [a, word, rest].filter(function (s) { return s; }).join(" "); };
    return t === 1 ? join("") + ", " + join("одна́") : join(below1000(t, true));
}

var numLevels = [
    { label: "0–20", max: 20 },
    { label: "0–100", max: 100 },
    { label: "0–1000", max: 1000 },
    { label: "0–9999", max: 9999 }
];
