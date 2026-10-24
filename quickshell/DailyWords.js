.pragma library

// Russian word of the day (shared by the side panel and the Russian app).
// Accent marks show the stressed vowel.

var words = [
    { w: "приве́т", tr: "privet", m: "hi, hello", ex: "Приве́т, как дела́?", exT: "Hi, how are you?" },
    { w: "спаси́бо", tr: "spasibo", m: "thank you", ex: "Спаси́бо за по́мощь.", exT: "Thanks for the help." },
    { w: "пожа́луйста", tr: "pozhaluysta", m: "please; you're welcome", ex: "Да́йте, пожа́луйста, во́ду.", exT: "Please give me some water." },
    { w: "учи́ть", tr: "uchit'", m: "to learn, to study", ex: "Я учу́ ру́сский язы́к.", exT: "I'm learning Russian." },
    { w: "понима́ть", tr: "ponimat'", m: "to understand", ex: "Я не понима́ю.", exT: "I don't understand." },
    { w: "говори́ть", tr: "govorit'", m: "to speak, to say", ex: "Вы говори́те по-англи́йски?", exT: "Do you speak English?" },
    { w: "ме́дленно", tr: "medlenno", m: "slowly", ex: "Говори́те ме́дленнее, пожа́луйста.", exT: "Please speak more slowly." },
    { w: "сло́во", tr: "slovo", m: "word", ex: "Что зна́чит э́то сло́во?", exT: "What does this word mean?" },
    { w: "язы́к", tr: "yazyk", m: "language; tongue", ex: "Ру́сский язы́к о́чень краси́вый.", exT: "Russian is a very beautiful language." },
    { w: "чита́ть", tr: "chitat'", m: "to read", ex: "Я люблю́ чита́ть.", exT: "I love to read." },
    { w: "кни́га", tr: "kniga", m: "book", ex: "Э́то интере́сная кни́га.", exT: "This is an interesting book." },
    { w: "у́тро", tr: "utro", m: "morning", ex: "До́брое у́тро!", exT: "Good morning!" },
    { w: "день", tr: "den'", m: "day", ex: "До́брый день!", exT: "Good afternoon!" },
    { w: "ночь", tr: "noch'", m: "night", ex: "Споко́йной но́чи!", exT: "Good night!" },
    { w: "сего́дня", tr: "segodnya", m: "today", ex: "Сего́дня суббо́та.", exT: "Today is Saturday." },
    { w: "за́втра", tr: "zavtra", m: "tomorrow", ex: "До за́втра!", exT: "See you tomorrow!" },
    { w: "вчера́", tr: "vchera", m: "yesterday", ex: "Вчера́ бы́ло хо́лодно.", exT: "It was cold yesterday." },
    { w: "вре́мя", tr: "vremya", m: "time", ex: "У меня́ нет вре́мени.", exT: "I don't have time." },
    { w: "хорошо́", tr: "khorosho", m: "good, well, okay", ex: "Всё хорошо́.", exT: "Everything is fine." },
    { w: "пло́хо", tr: "plokho", m: "badly, poorly", ex: "Я пло́хо спал.", exT: "I slept badly." },
    { w: "мно́го", tr: "mnogo", m: "a lot, many", ex: "У меня́ мно́го рабо́ты.", exT: "I have a lot of work." },
    { w: "рабо́та", tr: "rabota", m: "work, job", ex: "Я сейча́с на рабо́те.", exT: "I'm at work right now." },
    { w: "дом", tr: "dom", m: "house, home", ex: "Я иду́ домо́й.", exT: "I'm going home." },
    { w: "семья́", tr: "sem'ya", m: "family", ex: "У меня́ больша́я семья́.", exT: "I have a big family." },
    { w: "друг", tr: "drug", m: "friend", ex: "Он мой лу́чший друг.", exT: "He's my best friend." },
    { w: "любо́вь", tr: "lyubov'", m: "love", ex: "Любо́вь — э́то всё.", exT: "Love is everything." },
    { w: "го́род", tr: "gorod", m: "city, town", ex: "Москва́ — большо́й го́род.", exT: "Moscow is a big city." },
    { w: "у́лица", tr: "ulitsa", m: "street", ex: "Я живу́ на э́той у́лице.", exT: "I live on this street." },
    { w: "вода́", tr: "voda", m: "water", ex: "Я пью во́ду.", exT: "I'm drinking water." },
    { w: "чай", tr: "chay", m: "tea", ex: "Хо́чешь ча́ю?", exT: "Do you want some tea?" },
    { w: "хлеб", tr: "khleb", m: "bread", ex: "Купи́, пожа́луйста, хлеб.", exT: "Please buy some bread." },
    { w: "еда́", tr: "yeda", m: "food", ex: "Еда́ о́чень вку́сная.", exT: "The food is very tasty." },
    { w: "ко́шка", tr: "koshka", m: "cat", ex: "У меня́ есть ко́шка.", exT: "I have a cat." },
    { w: "соба́ка", tr: "sobaka", m: "dog", ex: "Соба́ка спит.", exT: "The dog is sleeping." },
    { w: "со́лнце", tr: "solntse", m: "sun", ex: "Сего́дня све́тит со́лнце.", exT: "The sun is shining today." },
    { w: "не́бо", tr: "nebo", m: "sky", ex: "Не́бо голубо́е.", exT: "The sky is blue." },
    { w: "дождь", tr: "dozhd'", m: "rain", ex: "Идёт дождь.", exT: "It's raining." },
    { w: "снег", tr: "sneg", m: "snow", ex: "Идёт снег.", exT: "It's snowing." },
    { w: "мо́ре", tr: "more", m: "sea", ex: "Мы е́дем на мо́ре.", exT: "We're going to the sea." },
    { w: "му́зыка", tr: "muzyka", m: "music", ex: "Я слу́шаю му́зыку.", exT: "I'm listening to music." },
    { w: "краси́вый", tr: "krasivyy", m: "beautiful", ex: "Како́й краси́вый вид!", exT: "What a beautiful view!" },
    { w: "ма́ленький", tr: "malen'kiy", m: "small, little", ex: "Э́то ма́ленькая ко́мната.", exT: "This is a small room." },
    { w: "пра́вда", tr: "pravda", m: "truth; true", ex: "Э́то пра́вда?", exT: "Is that true?" }
];

function forDate(d) {
    const day = Math.floor((d - new Date(d.getFullYear(), 0, 0)) / 86400000);
    return words[day % words.length];
}
