"use strict";

const APP_VERSION = "2.4.3";

/* ================= tunable constants ================= */
const COUNT_OPTIONS = [5, 10, 15, 20];
const WEAK_BIAS = 0.4;         // chance a question is drawn from saved weak items

// per-question time when the timer is on (read mode is never timed)
function timeForQ(q) { return q.level === "sent" || q.mode === "connect" ? 30 : 15; }

/* ================= content data ================= */
// group: letters that look alike (used to pick tricky distractors)
const LETTERS = [
  { c: "ا", group: 0 }, { c: "ب", group: 1 }, { c: "ت", group: 1 }, { c: "ث", group: 1 },
  { c: "ج", group: 2 }, { c: "ح", group: 2 }, { c: "خ", group: 2 },
  { c: "د", group: 3 }, { c: "ذ", group: 3 }, { c: "ر", group: 4 }, { c: "ز", group: 4 },
  { c: "س", group: 5 }, { c: "ش", group: 5 }, { c: "ص", group: 6 }, { c: "ض", group: 6 },
  { c: "ط", group: 7 }, { c: "ظ", group: 7 }, { c: "ع", group: 8 }, { c: "غ", group: 8 },
  { c: "ف", group: 9 }, { c: "ق", group: 9 }, { c: "ك", group: 0 }, { c: "ل", group: 0 },
  { c: "م", group: 0 }, { c: "ن", group: 1 }, { c: "ه", group: 0 }, { c: "و", group: 0 },
  { c: "ي", group: 1 },
];
const ALL_LETTER_CHARS = LETTERS.map(L => L.c);

// w: vocalized word, b: bare letters (tiles / first-letter games), e: emoji picture
const WORDS = [
  { w: "قِطّ", b: "قط", e: "🐱" },
  { w: "بَيْت", b: "بيت", e: "🏠" },
  { w: "شَمْس", b: "شمس", e: "☀️" },
  { w: "قَمَر", b: "قمر", e: "🌙" },
  { w: "سَمَك", b: "سمك", e: "🐟" },
  { w: "كِتَاب", b: "كتاب", e: "📖" },
  { w: "قَلَم", b: "قلم", e: "✏️" },
  { w: "بَاب", b: "باب", e: "🚪" },
  { w: "عَيْن", b: "عين", e: "👁️" },
  { w: "يَد", b: "يد", e: "✋" },
  { w: "أَسَد", b: "اسد", e: "🦁" },
  { w: "فِيل", b: "فيل", e: "🐘" },
  { w: "جَمَل", b: "جمل", e: "🐪" },
  { w: "دُبّ", b: "دب", e: "🐻" },
  { w: "بَقَرَة", b: "بقرة", e: "🐄" },
  { w: "حِصَان", b: "حصان", e: "🐴" },
  { w: "دَجَاجَة", b: "دجاجة", e: "🐔" },
  { w: "مَوْز", b: "موز", e: "🍌" },
  { w: "تُفَّاحَة", b: "تفاحة", e: "🍎" },
  { w: "عِنَب", b: "عنب", e: "🍇" },
  { w: "خُبْز", b: "خبز", e: "🍞" },
  { w: "حَلِيب", b: "حليب", e: "🥛" },
  { w: "مَاء", b: "ماء", e: "💧" },
  { w: "وَرْدَة", b: "وردة", e: "🌹" },
  { w: "شَجَرَة", b: "شجرة", e: "🌳" },
  { w: "نَجْمَة", b: "نجمة", e: "⭐" },
  { w: "نَار", b: "نار", e: "🔥" },
  { w: "ثَلْج", b: "ثلج", e: "❄️" },
  { w: "مَطَر", b: "مطر", e: "🌧️" },
  { w: "سَيَّارَة", b: "سيارة", e: "🚗" },
  { w: "قِطَار", b: "قطار", e: "🚂" },
  { w: "سَفِينَة", b: "سفينة", e: "⛵" },
  { w: "بَيْضَة", b: "بيضة", e: "🥚" },
  { w: "سَاعَة", b: "ساعة", e: "⌚" },
  { w: "مِفْتَاح", b: "مفتاح", e: "🔑" },
  { w: "كُرَة", b: "كرة", e: "⚽" },
  { w: "قَلْب", b: "قلب", e: "❤️" },
  { w: "نَحْلَة", b: "نحلة", e: "🐝" },
  { w: "فَرَاشَة", b: "فراشة", e: "🦋" },
  { w: "عُصْفُور", b: "عصفور", e: "🐦" },
  { w: "ضِفْدَع", b: "ضفدع", e: "🐸" },
  { w: "زَرَافَة", b: "زرافة", e: "🦒" },
  { w: "غَزَال", b: "غزال", e: "🦌" },
  { w: "صَقْر", b: "صقر", e: "🦅" },
  { w: "ظَرْف", b: "ظرف", e: "✉️" },
  { w: "طَبْل", b: "طبل", e: "🥁" },
  { w: "جَبَل", b: "جبل", e: "⛰️" },
  { w: "بَحْر", b: "بحر", e: "🌊" },
  { w: "لَيْمُون", b: "ليمون", e: "🍋" },
  { w: "جَزَر", b: "جزر", e: "🥕" },
  { w: "بِطِّيخ", b: "بطيخ", e: "🍉" },
  { w: "مِظَلَّة", b: "مظلة", e: "☂️" },
  { w: "نَظَّارَة", b: "نظارة", e: "👓" },
  { w: "كُرْسِيّ", b: "كرسي", e: "🪑" },
  { w: "مِصْبَاح", b: "مصباح", e: "💡" },
  { w: "هَاتِف", b: "هاتف", e: "📱" },
  { w: "وَجْه", b: "وجه", e: "🙂" },
  { w: "أُذُن", b: "اذن", e: "👂" },
  { w: "أَنْف", b: "انف", e: "👃" },
  { w: "فَم", b: "فم", e: "👄" },
  { w: "ذِئْب", b: "ذئب", e: "🐺" },
  { w: "رِيشَة", b: "ريشة", e: "🪶" },
];

// simple vocalized sentences (3–5 words) with an emoji hint.
// sw: the first two words may swap (verb-first and subject-first are both correct)
const SENTENCES = [
  { t: ["القِطُّ", "يَشْرَبُ", "الحَلِيبَ"], e: "🐱🥛", sw: true },
  { t: ["الشَّمْسُ", "فِي", "السَّمَاءِ"], e: "☀️" },
  { t: ["السَّمَكَةُ", "فِي", "المَاءِ"], e: "🐟💧" },
  { t: ["الوَلَدُ", "يَقْرَأُ", "الكِتَابَ"], e: "👦📖", sw: true },
  { t: ["البِنْتُ", "تَشْرَبُ", "الحَلِيبَ"], e: "👧🥛", sw: true },
  { t: ["الوَلَدُ", "يَلْعَبُ", "بِالكُرَةِ"], e: "👦⚽", sw: true },
  { t: ["الطَّائِرُ", "فَوْقَ", "الشَّجَرَةِ"], e: "🐦🌳" },
  { t: ["القَمَرُ", "يَظْهَرُ", "فِي", "اللَّيْلِ"], e: "🌙", sw: true },
  { t: ["أَنَا", "أُحِبُّ", "أُمِّي"], e: "❤️" },
  { t: ["الفِيلُ", "حَيَوَانٌ", "كَبِيرٌ"], e: "🐘" },
  { t: ["الأَسَدُ", "مَلِكُ", "الغَابَةِ"], e: "🦁" },
  { t: ["البَيْتُ", "جَمِيلٌ", "وَنَظِيفٌ"], e: "🏠✨" },
  { t: ["أَكَلَ", "الوَلَدُ", "التُّفَّاحَةَ"], e: "👦🍎", sw: true },
  { t: ["رَكِبَ", "الأَبُ", "السَّيَّارَةَ"], e: "👨🚗", sw: true },
  { t: ["النَّحْلَةُ", "تَصْنَعُ", "العَسَلَ"], e: "🐝🍯", sw: true },
  { t: ["المَطَرُ", "يَنْزِلُ", "مِنَ", "السَّمَاءِ"], e: "🌧️", sw: true },
  { t: ["الكَلْبُ", "يَحْرُسُ", "البَيْتَ"], e: "🐕🏠", sw: true },
  { t: ["القِطَارُ", "سَرِيعٌ", "جِدًّا"], e: "🚂" },
  { t: ["أَشْرَبُ", "المَاءَ", "البَارِدَ"], e: "💧" },
  { t: ["الفَرَاشَةُ", "فَوْقَ", "الوَرْدَةِ"], e: "🦋🌹" },
];

const FIRST_LETTERS = new Set(WORDS.map(w => w.b[0]));

/* ================= i18n (UI only; question content is always Arabic) ================= */
const STRINGS = {
  ar: {
    title: "نجوم القراءة ⭐",
    level: "المستوى", lvlLetters: "الحروف", lvlWords: "الكلمات", lvlSent: "الجمل",
    mode: "اللعبة",
    modeMatch: "الصورة والحرف", modeConnect: "وصّل", modeBuild: "رتّب", modeRead: "اقرأ لي",
    letters: "الحروف المختارة", all: "الكل",
    count: "كم عدد الأسئلة؟",
    timer: "المؤقت", timerOn: "⏱️ يعمل", timerOff: "🚫 بدون",
    game: "نقاط فتح اللعبة", gameOff: "🚫 إيقاف",
    gameNote: "احصل على هذه النقاط في التمرين لتفتح جولة من لعبة المظلات 🪂",
    gamePlay: "!العب لعبة المظلات 🪂",
    gameOver: "انتهت اللعبة! 🪂",
    start: "!ابدأ 🚀",
    hintLetters: "اختر حرفًا واحدًا على الأقل",
    insPickLetter: "بأي حرف تبدأ الصورة؟",
    insPickPic: "اختر الصورة التي تبدأ بهذا الحرف",
    insPic: "اختر الصورة الصحيحة",
    insPicWord: "اختر الكلمة الصحيحة",
    insBuild: "ركّب الكلمة",
    insSent: "رتّب الجملة",
    insConnect: "اسحب كل كلمة إلى صورتها",
    insOrder: "اسحب الكلمات إلى أماكنها لترتيب الجملة",
    insRead: "🎤 اقرأ بصوت عالٍ",
    timeUp: "انتهى الوقت! ⏰",
    answerIs: "الصحيح",
    good: ["أحسنت! 🎉", "رائع! ⭐", "ممتاز! 💪", "عظيم! 🌟", "مذهل! 🚀"],
    score: "نتيجتك",
    best: "أفضل نتيجة", newRecord: "🏆 رقم قياسي جديد!",
    review: "راجع هذه",
    again: "العب مرة أخرى 🔁",
    settings: "غيّر الإعدادات ⚙️",
    cheer3: "!مدهش! أنت نجم في القراءة",
    cheer2: "!عمل رائع! واصل التدريب",
    cheer1: "!محاولة جيدة! ستتحسن",
    cheer0: "!واصل التدريب، أنت تستطيع",
  },
  en: {
    title: "Reading Stars ⭐",
    level: "Level", lvlLetters: "Letters", lvlWords: "Words", lvlSent: "Sentences",
    mode: "Game",
    modeMatch: "Picture & letter", modeConnect: "Connect", modeBuild: "Arrange", modeRead: "Read to me",
    letters: "Letters to practice", all: "All",
    count: "How many questions?",
    timer: "Timer", timerOn: "⏱️ On", timerOff: "🚫 Off",
    game: "Game unlock score", gameOff: "🚫 Off",
    gameNote: "Score at least this much to unlock one round of Falling Pictures 🪂",
    gamePlay: "🪂 Play Falling Pictures!",
    gameOver: "Game over! 🪂",
    start: "Start! 🚀",
    hintLetters: "Pick at least one letter",
    insPickLetter: "Which letter does the picture start with?",
    insPickPic: "Tap the picture that starts with this letter",
    insPic: "Tap the right picture",
    insPicWord: "Tap the right word",
    insBuild: "Build the word",
    insSent: "Arrange the sentence",
    insConnect: "Drag each word to its picture",
    insOrder: "Drag the words into their places",
    insRead: "🎤 Read out loud",
    timeUp: "Time's up! ⏰",
    answerIs: "The answer is",
    good: ["Great job! 🎉", "Awesome! ⭐", "You rock! 💪", "Super! 🌟", "Amazing! 🚀"],
    score: "Your score",
    best: "Best score", newRecord: "🏆 New record!",
    review: "Review these",
    again: "Play again 🔁",
    settings: "Change settings ⚙️",
    cheer3: "Fantastic! You're a reading star!",
    cheer2: "Great work! Keep practicing!",
    cheer1: "Good try! You'll get better!",
    cheer0: "Keep practicing, you can do it!",
  },
  de: {
    title: "Lese-Sterne ⭐",
    level: "Stufe", lvlLetters: "Buchstaben", lvlWords: "Wörter", lvlSent: "Sätze",
    mode: "Spiel",
    modeMatch: "Bild & Buchstabe", modeConnect: "Verbinden", modeBuild: "Ordnen", modeRead: "Lies mir vor",
    letters: "Buchstaben zum Üben", all: "Alle",
    count: "Wie viele Aufgaben?",
    timer: "Zeitlimit", timerOn: "⏱️ An", timerOff: "🚫 Aus",
    game: "Punkte fürs Spiel", gameOff: "🚫 Aus",
    gameNote: "Erreiche diese Punktzahl, um eine Runde Fallende Bilder freizuschalten 🪂",
    gamePlay: "🪂 Fallende Bilder spielen!",
    gameOver: "Game over! 🪂",
    start: "Los! 🚀",
    hintLetters: "Wähle mindestens einen Buchstaben",
    insPickLetter: "Mit welchem Buchstaben beginnt das Bild?",
    insPickPic: "Tippe auf das Bild, das mit diesem Buchstaben beginnt",
    insPic: "Tippe auf das richtige Bild",
    insPicWord: "Tippe auf das richtige Wort",
    insBuild: "Baue das Wort",
    insSent: "Ordne den Satz",
    insConnect: "Ziehe jedes Wort zu seinem Bild",
    insOrder: "Ziehe die Wörter an ihre Plätze",
    insRead: "🎤 Lies laut vor",
    timeUp: "Zeit ist um! ⏰",
    answerIs: "Richtig ist",
    good: ["Super! 🎉", "Toll! ⭐", "Klasse! 💪", "Spitze! 🌟", "Fantastisch! 🚀"],
    score: "Deine Punkte",
    best: "Bester Punktestand", newRecord: "🏆 Neuer Rekord!",
    review: "Diese nochmal üben",
    again: "Nochmal spielen 🔁",
    settings: "Einstellungen ⚙️",
    cheer3: "Fantastisch! Du bist ein Lese-Star!",
    cheer2: "Super gemacht! Weiter so!",
    cheer1: "Guter Versuch! Übung macht den Meister!",
    cheer0: "Weiter üben, du schaffst das!",
  },
};

/* ================= settings ================= */
const DEFAULTS = {
  lang: "ar", level: "letters", mode: "match",
  letters: [...ALL_LETTER_CHARS],
  count: 10, timed: false, sound: true, gameScore: 700,
};
let settings = loadSettings();

function validModes(level) {
  if (level === "letters") return ["match", "read"];
  if (level === "words") return ["match", "connect", "build", "read"];
  return ["build", "connect", "read"]; // sentences
}

function loadSettings() {
  try {
    const s = JSON.parse(localStorage.getItem("readstars-settings"));
    if (!s) return { ...DEFAULTS };
    const letters = Array.isArray(s.letters) ? s.letters.filter(c => ALL_LETTER_CHARS.includes(c)) : [];
    const level = ["letters", "words", "sent"].includes(s.level) ? s.level : DEFAULTS.level;
    return {
      lang: ["ar", "en", "de"].includes(s.lang) ? s.lang : DEFAULTS.lang,
      level,
      mode: validModes(level).includes(s.mode) ? s.mode : validModes(level)[0],
      letters: letters.length ? letters : [...DEFAULTS.letters],
      count: COUNT_OPTIONS.includes(s.count) ? s.count : DEFAULTS.count,
      timed: s.timed === true,
      sound: s.sound !== false,
      gameScore: [0, 500, 700, 800, 900].includes(s.gameScore) ? s.gameScore : DEFAULTS.gameScore,
    };
  } catch { return { ...DEFAULTS }; }
}
function saveSettings() {
  try { localStorage.setItem("readstars-settings", JSON.stringify(settings)); } catch {}
}

/* ================= weak items & high scores ================= */
// keys: "L:ب" (letter), "W:قط" (word by bare letters), "T:3" (sentence index)
function loadWeak() {
  try { return JSON.parse(localStorage.getItem("readstars-weak")) || {}; } catch { return {}; }
}
function saveWeak(w) {
  try { localStorage.setItem("readstars-weak", JSON.stringify(w)); } catch {}
}
function recordResult(key, correct) {
  if (!key) return;
  const w = loadWeak();
  if (correct) {
    if (w[key]) { w[key]--; if (w[key] <= 0) delete w[key]; saveWeak(w); }
  } else {
    w[key] = Math.min(5, (w[key] || 0) + 1);
    saveWeak(w);
  }
}
function weakTargets(cfg) {
  const w = loadWeak();
  const out = { L: [], W: [], T: [] };
  for (const key of Object.keys(w)) {
    const kind = key[0], val = key.slice(2);
    let ok = false;
    if (kind === "L") ok = cfg.letterPool.includes(val);
    else if (kind === "W") ok = WORDS.some(x => x.b === val);
    else if (kind === "T") ok = +val >= 0 && +val < SENTENCES.length;
    if (ok) for (let i = 0; i < w[key]; i++) out[kind].push(val);
  }
  return out;
}
function loadBest() {
  try { return JSON.parse(localStorage.getItem("readstars-best")) || {}; } catch { return {}; }
}
function saveBest(b) {
  try { localStorage.setItem("readstars-best", JSON.stringify(b)); } catch {}
}

/* ================= helpers ================= */
const $ = id => document.getElementById(id);
const pick = arr => arr[Math.floor(Math.random() * arr.length)];
const T = () => STRINGS[settings.lang];
function shuffle(arr) {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}
function takeDistinct(taken, candidates, n) {
  const out = [];
  for (const c of candidates) {
    if (out.length >= n) break;
    if (!taken.has(c) && !out.includes(c)) out.push(c);
  }
  return out;
}
const letterByChar = c => LETTERS.find(L => L.c === c);

/* ================= sounds (tiny WebAudio blips) ================= */
let audioCtx = null;
function beep(freqs, dur, vol = 0.15) {
  if (!settings.sound) return;
  try {
    audioCtx = audioCtx || new (window.AudioContext || window.webkitAudioContext)();
    freqs.forEach((f, i) => {
      const o = audioCtx.createOscillator(), g = audioCtx.createGain();
      o.type = "sine"; o.frequency.value = f;
      g.gain.setValueAtTime(vol, audioCtx.currentTime + i * dur);
      g.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + (i + 1) * dur);
      o.connect(g).connect(audioCtx.destination);
      o.start(audioCtx.currentTime + i * dur);
      o.stop(audioCtx.currentTime + (i + 1) * dur);
    });
  } catch {}
}
const soundGood = () => beep([660, 880], 0.12);
const soundBad = () => beep([220, 180], 0.18);
const soundTick = () => beep([1250], 0.05, 0.07);

/* ================= question generation ================= */
function buildCfg() {
  // in the letters level, only letters that start at least one word are usable
  const withWords = settings.letters.filter(c => FIRST_LETTERS.has(c));
  const cfg = {
    level: settings.level,
    mode: settings.mode,
    letterPool: withWords.length ? withWords : [...FIRST_LETTERS],
  };
  cfg.weak = weakTargets(cfg);
  return cfg;
}

function genQuestion(cfg, recent) {
  for (let attempt = 0; attempt < 60; attempt++) {
    const q = makeQ(cfg);
    if (!recent.includes(q.key) || attempt >= 50) {
      recent.push(q.key);
      if (recent.length > 4) recent.shift();
      return q;
    }
  }
}

function pickLetterChar(cfg) {
  if (cfg.weak.L.length && Math.random() < WEAK_BIAS) return pick(cfg.weak.L);
  return pick(cfg.letterPool);
}
function pickWord(cfg, pool) {
  const p = pool || WORDS;
  if (cfg.weak.W.length && Math.random() < WEAK_BIAS) {
    const b = pick(cfg.weak.W);
    const w = p.find(x => x.b === b);
    if (w) return w;
  }
  return pick(p);
}
function pickSentenceIdx(cfg) {
  if (cfg.weak.T.length && Math.random() < WEAK_BIAS) return +pick(cfg.weak.T);
  return Math.floor(Math.random() * SENTENCES.length);
}

function makeQ(cfg) {
  const m = cfg.mode, lv = cfg.level;
  if (lv === "letters") return m === "read" ? qReadLetter(cfg) : qLetterMatch(cfg);
  if (lv === "words") {
    if (m === "match") return qPic(cfg);
    if (m === "connect") return qConnect(cfg);
    if (m === "build") return qBuild(cfg);
    return qReadWord(cfg);
  }
  if (m === "build") return qSentBuild(cfg);
  if (m === "connect") return qOrder(cfg);
  return qReadSent(cfg);
}

function makeCards(correct, distractors, n) {
  const taken = new Set([correct]);
  const labels = [correct, ...takeDistinct(taken, distractors, n - 1)];
  return shuffle(labels.map(t => ({ t, ok: t === correct })));
}

/* --- letters level: picture ↔ first letter, both directions --- */
function qLetterMatch(cfg) {
  const c = pickLetterChar(cfg);
  const word = pick(WORDS.filter(x => x.b[0] === c));
  if (Math.random() < 0.5) {
    // show the picture → pick the letter it starts with (6 letter cards)
    const L = letterByChar(c);
    const sameGroup = LETTERS.filter(x => x.group === L.group && x.c !== c).map(x => x.c);
    const others = shuffle(ALL_LETTER_CHARS.filter(x => x !== c && !sameGroup.includes(x)));
    return {
      mode: "match", level: "letters", key: "L:" + c + ":pic", weakKey: "L:" + c,
      insKey: "insPickLetter",
      promptEmoji: word.e,
      cards: makeCards(c, [...shuffle(sameGroup), ...others], 6),
      answerText: c, reveal: word.w,
    };
  }
  // show the letter → pick the picture that starts with it (4 emoji cards)
  const ds = shuffle(WORDS.filter(x => x.b[0] !== c && x.e !== word.e)).map(x => x.e);
  return {
    mode: "match", level: "letters", key: "L:" + c + ":ltr", weakKey: "L:" + c,
    insKey: "insPickPic", emojiCards: true,
    prompt: c,
    cards: makeCards(word.e, ds, 4),
    answerText: word.e, reveal: word.w,
  };
}

function qReadLetter(cfg) {
  const c = pickLetterChar(cfg);
  const ex = pick(WORDS.filter(x => x.b[0] === c));
  return {
    mode: "read", level: "letters", key: "L:" + c, weakKey: "L:" + c,
    insKey: "insRead", prompt: c,
    answerText: c, reveal: `${ex.w} ${ex.e}`,
  };
}

/* --- words level --- */
function wordDistractors(w, words) {
  const rest = words.filter(x => x.b !== w.b && x.e !== w.e && x.w !== w.w);
  const scored = rest.map(x => ({
    x,
    s: (x.b[0] === w.b[0] ? 2 : 0) + (Math.abs(x.b.length - w.b.length) <= 1 ? 1 : 0) + Math.random(),
  }));
  scored.sort((a, b) => b.s - a.s);
  return scored.map(o => o.x);
}

function qPic(cfg) {
  const w = pickWord(cfg);
  const ds = wordDistractors(w, WORDS);
  const toEmoji = Math.random() < 0.5;
  return {
    mode: "match", level: "words", key: "W:" + w.b, weakKey: "W:" + w.b,
    insKey: toEmoji ? "insPic" : "insPicWord",
    emojiCards: toEmoji,
    prompt: toEmoji ? w.w : "", promptEmoji: toEmoji ? "" : w.e,
    cards: toEmoji
      ? makeCards(w.e, ds.map(x => x.e), 4)
      : makeCards(w.w, ds.map(x => x.w), 4),
    answerText: toEmoji ? w.e : w.w, reveal: toEmoji ? "" : w.e,
  };
}

function qBuild(cfg) {
  const pool = WORDS.filter(x => x.b.length >= 2 && x.b.length <= 5);
  const w = pickWord(cfg, pool);
  let tiles = shuffle([...w.b]);
  for (let i = 0; i < 10 && tiles.join("") === w.b && w.b.length > 1; i++) tiles = shuffle([...w.b]);
  return {
    mode: "build", level: "words", key: "W:" + w.b, weakKey: "W:" + w.b,
    insKey: "insBuild",
    promptEmoji: w.e, tiles, accepted: [w.b], targetShow: w.w, joiner: "",
    answerText: w.w,
  };
}

// connect board: 4 words to drag onto their 4 pictures
function qConnect(cfg) {
  const first = pickWord(cfg);
  const pairs = [first];
  for (const x of shuffle(WORDS)) {
    if (pairs.length >= 4) break;
    if (!pairs.some(p => p.b === x.b || p.e === x.e || p.w === x.w)) pairs.push(x);
  }
  return {
    mode: "connect", level: "words",
    key: "C:" + pairs.map(p => p.b).sort().join(","), weakKey: null, // words are recorded one by one
    insKey: "insConnect", pairs,
    answerText: pairs.map(p => `${p.w} ${p.e}`).join(" · "),
  };
}

// drag the sentence's words into ordered slots
function qOrder(cfg) {
  const idx = pickSentenceIdx(cfg);
  const s = SENTENCES[idx];
  const accepted = [s.t.join(" ")];
  if (s.sw) accepted.push([s.t[1], s.t[0], ...s.t.slice(2)].join(" "));
  let tiles = shuffle([...s.t]);
  for (let i = 0; i < 10 && accepted.includes(tiles.join(" ")); i++) tiles = shuffle([...s.t]);
  return {
    mode: "connect", level: "sent", key: "T:" + idx, weakKey: "T:" + idx,
    insKey: "insOrder",
    promptEmoji: s.e, tiles, accepted, targetShow: s.t.join(" "),
    answerText: s.t.join(" "), sent: true,
  };
}

function qReadWord(cfg) {
  const w = pickWord(cfg);
  return {
    mode: "read", level: "words", key: "W:" + w.b, weakKey: "W:" + w.b,
    insKey: "insRead", prompt: w.w,
    answerText: w.w, reveal: w.e,
  };
}

/* --- sentences level --- */
function qSentBuild(cfg) {
  const idx = pickSentenceIdx(cfg);
  const s = SENTENCES[idx];
  // every accepted word order counts as correct (verb-first or subject-first)
  const accepted = [s.t.join(" ")];
  if (s.sw) accepted.push([s.t[1], s.t[0], ...s.t.slice(2)].join(" "));
  let tiles = shuffle([...s.t]);
  for (let i = 0; i < 10 && accepted.includes(tiles.join(" ")); i++) tiles = shuffle([...s.t]);
  return {
    mode: "build", level: "sent", key: "T:" + idx, weakKey: "T:" + idx,
    insKey: "insSent",
    promptEmoji: s.e, tiles, accepted, targetShow: s.t.join(" "), joiner: " ",
    answerText: s.t.join(" "), sent: true,
  };
}

function qReadSent(cfg) {
  const idx = pickSentenceIdx(cfg);
  const s = SENTENCES[idx];
  return {
    mode: "read", level: "sent", key: "T:" + idx, weakKey: "T:" + idx,
    insKey: "insRead", prompt: s.t.join(" "),
    answerText: s.t.join(" "), reveal: s.e, sent: true,
  };
}

/* ================= setup screen ================= */
function buildSetup() {
  const row = $("letters-row");
  row.innerHTML = "";
  for (const L of LETTERS) {
    const b = document.createElement("button");
    b.type = "button"; b.className = "chip letter-chip"; b.textContent = L.c;
    b.dataset.letter = L.c;
    b.onclick = () => {
      const i = settings.letters.indexOf(L.c);
      i >= 0 ? settings.letters.splice(i, 1) : settings.letters.push(L.c);
      refreshSetup();
    };
    row.appendChild(b);
  }
  $("btn-all").onclick = () => {
    settings.letters = settings.letters.length === ALL_LETTER_CHARS.length ? [] : [...ALL_LETTER_CHARS];
    refreshSetup();
  };
  const crow = $("count-row");
  crow.innerHTML = "";
  for (const c of COUNT_OPTIONS) {
    const b = document.createElement("button");
    b.type = "button"; b.className = "chip"; b.textContent = c; b.dir = "ltr";
    b.dataset.count = c;
    b.onclick = () => { settings.count = c; refreshSetup(); };
    crow.appendChild(b);
  }
  document.querySelectorAll("#level-row .op-chip").forEach(chip => {
    chip.onclick = () => {
      settings.level = chip.dataset.level;
      if (!validModes(settings.level).includes(settings.mode)) settings.mode = validModes(settings.level)[0];
      refreshSetup();
    };
  });
  document.querySelectorAll("#mode-row .op-chip").forEach(chip => {
    chip.onclick = () => { settings.mode = chip.dataset.mode; refreshSetup(); };
  });
  document.querySelectorAll("#timer-row .chip").forEach(chip => {
    chip.onclick = () => { settings.timed = chip.dataset.timed === "1"; refreshSetup(); };
  });
  document.querySelectorAll("#game-row .chip").forEach(chip => {
    chip.onclick = () => { settings.gameScore = +chip.dataset.game; refreshSetup(); };
  });
  document.querySelectorAll(".lang-chip:not(.sound-btn)").forEach(chip => {
    chip.onclick = () => { settings.lang = chip.dataset.lang; applyLang(); refreshSetup(); };
  });
  $("btn-sound").onclick = () => { settings.sound = !settings.sound; refreshSetup(); };
  $("btn-start").onclick = startQuiz;
}

function refreshSetup() {
  const lv = settings.level;
  const modes = validModes(lv);
  document.querySelectorAll("#level-row .op-chip").forEach(c => c.classList.toggle("selected", c.dataset.level === lv));
  document.querySelectorAll("#mode-row .op-chip").forEach(c => {
    c.hidden = !modes.includes(c.dataset.mode);
    c.classList.toggle("selected", c.dataset.mode === settings.mode);
  });
  $("letters-group").hidden = lv !== "letters";
  document.querySelectorAll("#letters-row .chip").forEach(c => c.classList.toggle("selected", settings.letters.includes(c.dataset.letter)));
  $("btn-all").classList.toggle("selected", settings.letters.length === ALL_LETTER_CHARS.length);
  document.querySelectorAll("#count-row .chip").forEach(c => c.classList.toggle("selected", +c.dataset.count === settings.count));
  $("timer-group").hidden = settings.mode === "read";
  document.querySelectorAll("#timer-row .chip").forEach(c => c.classList.toggle("selected", (c.dataset.timed === "1") === settings.timed));
  document.querySelectorAll("#game-row .chip").forEach(c => c.classList.toggle("selected", +c.dataset.game === settings.gameScore));
  $("btn-sound").textContent = settings.sound ? "🔊" : "🔇";

  let hint = "";
  if (lv === "letters" && settings.letters.length === 0) hint = T().hintLetters;
  $("setup-hint").textContent = hint;
  $("btn-start").disabled = !!hint;
  saveSettings();
}

function applyLang() {
  const t = T();
  document.documentElement.lang = settings.lang;
  document.documentElement.dir = settings.lang === "ar" ? "rtl" : "ltr";
  $("t-title").textContent = t.title;
  $("t-level").textContent = t.level;
  $("t-mode").textContent = t.mode;
  $("t-letters").textContent = t.letters;
  $("btn-all").textContent = t.all;
  $("t-count").textContent = t.count;
  $("t-timer").textContent = t.timer;
  $("t-game").textContent = t.game;
  $("game-note").textContent = t.gameNote;
  $("btn-play-game").textContent = t.gamePlay;
  $("go-title").textContent = t.gameOver;
  $("btn-start").textContent = t.start;
  $("t-score").textContent = t.score;
  $("t-review").textContent = t.review;
  $("btn-again").textContent = t.again;
  $("btn-settings").textContent = t.settings;
  document.querySelectorAll("[data-t]").forEach(el => { el.textContent = t[el.dataset.t]; });
}

/* ================= quiz flow ================= */
let quiz = null;

function showScreen(name) {
  document.querySelectorAll(".screen").forEach(s => s.classList.remove("active"));
  $("screen-" + name).classList.add("active");
}

function startQuiz() {
  const cfg = buildCfg();
  const recent = [];
  const questions = Array.from({ length: settings.count }, () => genQuestion(cfg, recent));
  quiz = {
    questions, index: 0, correct: 0, points: 0, missed: [],
    gameEligible: settings.mode !== "read", // parent-graded reading earns no game
    bestKey: `${settings.mode}:${settings.level}`,
    timerId: null, timerStart: 0, timerTotal: 1, locked: false, built: [],
  };
  showScreen("quiz");
  nextQuestion();
}

function untimed(q) { return q.mode === "read" || !settings.timed; }

function nextQuestion() {
  const q = quiz.questions[quiz.index];
  quiz.locked = false;
  quiz.built = [];
  const t = T();

  $("instruction").textContent = t[q.insKey] || "";

  const promptEl = $("prompt");
  promptEl.textContent = q.promptEmoji || q.prompt || "";
  promptEl.classList.toggle("emoji", !!q.promptEmoji);
  promptEl.classList.toggle("read-big", q.mode === "read" && !q.sent);
  promptEl.classList.toggle("sent", !!q.sent && q.mode === "read");

  const builtEl = $("built");
  builtEl.hidden = q.mode !== "build";
  builtEl.textContent = "";
  builtEl.className = "built" + (q.sent ? " sent-built" : "");

  $("feedback").textContent = "";
  $("feedback").className = "feedback";

  const cardsEl = $("cards");
  cardsEl.innerHTML = "";
  cardsEl.hidden = !q.cards;
  if (q.cards) {
    cardsEl.classList.toggle("grid3", q.cards.length > 4);
    cardsEl.classList.toggle("emoji-cards", !!q.emojiCards);
    for (const c of q.cards) {
      const b = document.createElement("button");
      b.type = "button"; b.className = "acard"; b.textContent = c.t; b.dir = "rtl";
      b.onclick = () => onCard(b, c);
      cardsEl.appendChild(b);
    }
  }
  $("builder").hidden = q.mode !== "build";
  if (q.mode === "build") buildTiles(q);
  const connectWords = q.mode === "connect" && q.level === "words";
  const orderSent = q.mode === "connect" && q.level === "sent";
  $("connect").hidden = !connectWords;
  $("order").hidden = !orderSent;
  if (connectWords) renderConnect(q);
  if (orderSent) renderOrder(q);
  $("grade").hidden = q.mode !== "read";

  $("progress-text").textContent = `${quiz.index + 1} / ${quiz.questions.length}`;
  $("score-pill").textContent = `⭐ ${Math.round(quiz.points)}`;

  $("timebar-row").hidden = untimed(q);
  if (untimed(q)) {
    stopTimer();
    quiz.timerStart = performance.now();
    quiz.timerTotal = Infinity;
  } else {
    startTimer(timeForQ(q));
  }
}

function buildTiles(q) {
  const tilesEl = $("tiles");
  tilesEl.innerHTML = "";
  q.tiles.forEach((ch, i) => {
    const b = document.createElement("button");
    b.type = "button"; b.className = "tile" + (q.sent ? " tile-word" : ""); b.textContent = ch;
    b.dataset.i = i;
    b.onclick = () => onTile(q, b, ch);
    tilesEl.appendChild(b);
  });
  const back = document.createElement("button");
  back.type = "button"; back.className = "tile tile-back"; back.textContent = "⌫";
  back.onclick = () => {
    if (quiz.locked || !quiz.built.length) return;
    const last = quiz.built.pop();
    const btn = document.querySelector(`#tiles .tile[data-i="${last.i}"]`);
    if (btn) btn.disabled = false;
    $("built").textContent = quiz.built.map(x => x.ch).join(q.joiner);
  };
  tilesEl.appendChild(back);
}

function onTile(q, btn, ch) {
  if (quiz.locked || btn.disabled) return;
  btn.disabled = true;
  quiz.built.push({ ch, i: +btn.dataset.i });
  const text = quiz.built.map(x => x.ch).join(q.joiner);
  $("built").textContent = text;
  if (quiz.built.length === q.tiles.length) {
    const good = q.accepted.includes(text);
    finishAnswer(good, q, () => {
      // correct sentences keep the kid's own valid order; words show the vocalized form
      $("built").textContent = good && q.sent ? text : q.targetShow;
    });
  }
}

/* ---- pointer-based dragging (fingers on iPad, mouse on desktop) ---- */
function makeDraggable(el, onDrop) {
  el.addEventListener("pointerdown", e => {
    if (!quiz || quiz.locked || el.classList.contains("paired") || el.classList.contains("used")) return;
    e.preventDefault();
    const ghost = el.cloneNode(true);
    ghost.classList.add("ghost");
    ghost.style.width = el.offsetWidth + "px";
    document.body.appendChild(ghost);
    el.classList.add("dragging");
    const place = ev => {
      ghost.style.left = (ev.clientX - ghost.offsetWidth / 2) + "px";
      ghost.style.top = (ev.clientY - ghost.offsetHeight / 2) + "px";
    };
    place(e);
    const move = ev => { ev.preventDefault(); place(ev); };
    const up = ev => {
      document.removeEventListener("pointermove", move);
      document.removeEventListener("pointerup", up);
      document.removeEventListener("pointercancel", up);
      ghost.remove();
      el.classList.remove("dragging");
      const under = document.elementFromPoint(ev.clientX, ev.clientY);
      onDrop(under ? under.closest("[data-drop]") : null);
    };
    document.addEventListener("pointermove", move, { passive: false });
    document.addEventListener("pointerup", up);
    document.addEventListener("pointercancel", up);
  });
}

/* ---- connect: 4 pictures (right) ↔ 4 words (left) ---- */
function renderConnect(q) {
  quiz.pairsDone = 0;
  quiz.connectMistakes = 0;
  quiz.wrongWords = new Set();
  const pics = $("c-pics"), words = $("c-words");
  pics.innerHTML = "";
  words.innerHTML = "";
  for (const p of shuffle(q.pairs)) {
    const d = document.createElement("div");
    d.className = "ccard pic";
    d.textContent = p.e;
    d.dataset.b = p.b;
    d.dataset.drop = "1";
    pics.appendChild(d);
  }
  for (const p of shuffle(q.pairs)) {
    const d = document.createElement("div");
    d.className = "ccard word";
    d.textContent = p.w;
    d.dataset.b = p.b;
    makeDraggable(d, target => onConnectDrop(q, d, target));
    words.appendChild(d);
  }
}

function onConnectDrop(q, wordEl, target) {
  if (!quiz || quiz.locked || !target || !target.classList.contains("pic") || target.classList.contains("paired")) return;
  const b = wordEl.dataset.b;
  if (target.dataset.b === b) {
    wordEl.classList.add("paired");
    target.classList.add("paired");
    target.textContent = `${target.textContent} ✓`;
    recordResult("W:" + b, !quiz.wrongWords.has(b));
    quiz.pairsDone++;
    beep([880], 0.09);
    if (quiz.pairsDone === q.pairs.length) {
      finishAnswer(quiz.connectMistakes === 0, q, null);
    }
  } else {
    quiz.connectMistakes++;
    quiz.wrongWords.add(b);
    recordResult("W:" + b, false);
    target.classList.remove("wrongflash");
    void target.offsetWidth; // restart the animation
    target.classList.add("wrongflash");
    soundBad();
  }
}

/* ---- order: drag sentence words into slots ---- */
function renderOrder(q) {
  const slots = $("slots"), pool = $("pool");
  slots.innerHTML = "";
  pool.innerHTML = "";
  for (let i = 0; i < q.tiles.length; i++) {
    const s = document.createElement("div");
    s.className = "slot";
    s.dataset.drop = "1";
    s.dataset.slot = i;
    s.onclick = () => { // tap a filled slot to send its word back to the pool
      if (quiz.locked || !s.dataset.word) return;
      const tile = pool.querySelector(`.otile.used[data-word="${s.dataset.word}"]`);
      if (tile) tile.classList.remove("used");
      delete s.dataset.word;
      s.textContent = "";
      s.classList.remove("filled");
    };
    slots.appendChild(s);
  }
  q.tiles.forEach((word, i) => {
    const t = document.createElement("div");
    t.className = "otile";
    t.textContent = word;
    t.dataset.word = word;
    t.dataset.i = i;
    makeDraggable(t, target => onOrderDrop(q, t, target));
    pool.appendChild(t);
  });
}

function onOrderDrop(q, tile, target) {
  if (!quiz || quiz.locked || !target || !target.classList.contains("slot") || target.dataset.word) return;
  target.dataset.word = tile.dataset.word;
  target.textContent = tile.dataset.word;
  target.classList.add("filled");
  tile.classList.add("used");
  const slotEls = [...document.querySelectorAll("#slots .slot")];
  if (slotEls.every(s => s.dataset.word)) {
    const text = slotEls.map(s => s.dataset.word).join(" ");
    finishAnswer(q.accepted.includes(text), q, null);
  }
}

function onCard(btn, c) {
  if (!quiz || quiz.locked) return;
  const q = quiz.questions[quiz.index];
  finishAnswer(c.ok, q, () => {
    btn.classList.add(c.ok ? "right" : "wrong");
    if (!c.ok) {
      document.querySelectorAll("#cards .acard").forEach(b => {
        if (b.textContent === q.answerText) b.classList.add("right");
      });
    }
  });
}

function finishAnswer(good, q, decorate) {
  const frac = Math.max(0, 1 - (performance.now() - quiz.timerStart) / quiz.timerTotal);
  stopTimer();
  quiz.locked = true;
  if (decorate) decorate();
  recordResult(q.weakKey, good);
  if (good) {
    const maxPts = 1000 / quiz.questions.length;
    const pts = maxPts * (0.5 + 0.5 * frac);
    quiz.correct++;
    quiz.points += pts;
    $("feedback").textContent = `${pick(T().good)} +${Math.round(pts)} ${q.reveal || ""}`;
    $("feedback").className = "feedback good";
    $("built").classList.add("ok");
    $("score-pill").textContent = `⭐ ${Math.round(quiz.points)}`;
    soundGood();
    setTimeout(advance, 1200);
  } else {
    quiz.missed.push(q);
    $("feedback").textContent = `${T().answerIs}: ${q.answerText} ${q.reveal || ""}`;
    $("feedback").className = "feedback bad";
    $("built").classList.add("no");
    if (q.mode === "build") $("built").textContent = q.targetShow;
    soundBad();
    setTimeout(advance, 2300);
  }
}

function onTimeout() {
  const q = quiz.questions[quiz.index];
  quiz.locked = true;
  quiz.missed.push(q);
  recordResult(q.weakKey, false);
  $("feedback").textContent = `${T().timeUp} ${T().answerIs}: ${q.answerText} ${q.reveal || ""}`;
  $("feedback").className = "feedback bad";
  document.querySelectorAll("#cards .acard").forEach(b => {
    if (b.textContent === q.answerText) b.classList.add("right");
  });
  if (q.mode === "build") { $("built").textContent = q.targetShow; $("built").classList.add("no"); }
  soundBad();
  setTimeout(advance, 2300);
}

function onGrade(good) {
  if (!quiz || quiz.locked) return;
  const q = quiz.questions[quiz.index];
  finishAnswer(good, q, () => {
    if (q.reveal) $("prompt").textContent = `${q.prompt} ${q.reveal}`;
  });
}

function startTimer(seconds) {
  stopTimer();
  const total = seconds * 1000;
  const start = performance.now();
  quiz.timerStart = start;
  quiz.timerTotal = total;
  const bar = $("timebar");
  bar.className = "timebar";
  bar.style.width = "100%";
  $("time-left").textContent = seconds;
  let lastTick = -1;
  quiz.timerId = setInterval(() => {
    const left = total - (performance.now() - start);
    const frac = Math.max(0, left / total);
    const secLeft = Math.max(0, Math.ceil(left / 1000));
    bar.style.width = (frac * 100) + "%";
    bar.className = "timebar" + (frac < 0.25 ? " danger" : frac < 0.5 ? " warn" : "");
    $("time-left").textContent = secLeft;
    if (secLeft <= 5 && secLeft >= 1 && secLeft !== lastTick) { lastTick = secLeft; soundTick(); }
    if (left <= 0) { stopTimer(); onTimeout(); }
  }, 100);
}
function stopTimer() {
  if (quiz && quiz.timerId) { clearInterval(quiz.timerId); quiz.timerId = null; }
}

function advance() {
  if (!quiz) return; // quit was pressed during feedback
  quiz.index++;
  if (quiz.index >= quiz.questions.length) finishQuiz();
  else nextQuestion();
}

function finishQuiz() {
  stopTimer();
  const total = quiz.questions.length;
  const score = Math.round(quiz.points);
  const stars = score >= 900 ? 3 : score >= 700 ? 2 : score >= 450 ? 1 : 0;
  $("stars").textContent = stars ? "⭐".repeat(stars) : "🌱";
  $("final-score").innerHTML = `${score} <span class="of-1000">/ 1000</span>`;
  $("sub-score").textContent = `✓ ${quiz.correct} / ${total}`;
  $("cheer").textContent = T()["cheer" + stars];

  // qualifying score earns one round of the parachute game (not in read-to-me)
  $("btn-play-game").hidden = !(quiz.gameEligible && settings.gameScore > 0 && score >= settings.gameScore);

  const best = loadBest();
  const bestLine = $("best-line");
  if (score > (best[quiz.bestKey] || 0)) {
    best[quiz.bestKey] = score;
    saveBest(best);
    bestLine.textContent = T().newRecord;
    bestLine.classList.add("record");
  } else {
    bestLine.textContent = `${T().best}: ${best[quiz.bestKey] || 0}`;
    bestLine.classList.remove("record");
  }

  const missedWrap = $("missed-wrap");
  const list = $("missed-list");
  list.innerHTML = "";
  if (quiz.missed.length) {
    for (const q of quiz.missed) {
      const li = document.createElement("li");
      li.textContent = `${q.answerText} ${q.reveal || ""}`;
      list.appendChild(li);
    }
    missedWrap.hidden = false;
  } else missedWrap.hidden = true;

  quiz = null;
  showScreen("results");
}

/* ================= Falling Pictures (reward game) =================
   The game matches the level being practiced:
   - letters level: tap the letter each falling picture's word starts with
   - words/sentences level: spell the falling picture's whole word */
let game = null;

function startGame() {
  if ($("btn-play-game").hidden) return; // no ticket, no game
  $("btn-play-game").hidden = true;      // the ticket is spent
  document.querySelectorAll("#sky .fall").forEach(el => el.remove());
  $("game-over").hidden = true;
  const cfg = buildCfg();
  const kind = settings.level === "letters" ? "letters" : "word";
  game = {
    kind,
    pool: cfg.letterPool, weakL: cfg.weak.L, weakW: cfg.weak.W,
    score: 0, lives: 3, items: [], entry: "",
    speed: kind === "letters" ? 22 : 13,
    spawnEvery: kind === "letters" ? 3300 : 1200,
    maxItems: kind === "letters" ? 3 : 1,
    sinceSpawn: 2800,
    over: false, prev: performance.now(), raf: null,
  };
  $("game-entry").hidden = kind !== "word";
  $("game-entry").textContent = " ";
  $("game-letters").innerHTML = "";
  updateGameHud();
  if (kind === "letters") refreshLetterPanel();
  showScreen("game");
  game.raf = requestAnimationFrame(gameTick);
}

function updateGameHud() {
  $("game-lives").textContent = "❤️".repeat(game.lives) || "💔";
  $("game-score").textContent = `🪂 ${game.score}`;
}

function gameTick(now) {
  if (!game || game.over) return;
  const dt = Math.min(0.1, (now - game.prev) / 1000);
  game.prev = now;
  const H = $("sky").clientHeight;
  game.sinceSpawn += dt * 1000;
  if (game.sinceSpawn >= game.spawnEvery && game.items.length < game.maxItems) {
    spawnItem();
    game.sinceSpawn = 0;
  }
  for (const it of [...game.items]) {
    it.y += game.speed * dt;
    it.el.style.top = it.y + "px";
    if (it.y > H - 110) itemLanded(it);
  }
  game.raf = requestAnimationFrame(gameTick);
}

function spawnItem() {
  let w;
  if (game.kind === "letters") {
    const useWeak = game.weakL.length && Math.random() < WEAK_BIAS;
    const c = useWeak ? pick(game.weakL) : pick(game.pool);
    const candidates = WORDS.filter(x => x.b[0] === c && !game.items.some(it => it.e === x.e));
    if (!candidates.length) return;
    w = pick(candidates);
  } else {
    const pool = WORDS.filter(x => x.b.length <= 5);
    if (game.weakW.length && Math.random() < WEAK_BIAS) {
      w = pool.find(x => x.b === pick(game.weakW)) || pick(pool);
    } else w = pick(pool);
  }
  const el = document.createElement("div");
  el.className = "fall";
  el.innerHTML = `<span class="chute">🪂</span><span class="cargo">${w.e}</span>`;
  el.style.left = (5 + Math.random() * 65) + "%";
  el.style.top = "-130px";
  $("sky").appendChild(el);
  game.items.push({ c: w.b[0], b: w.b, e: w.e, el, y: -130 });
  if (game.kind === "letters") refreshLetterPanel();
  else buildWordPanel(w);
}

// spelling panel: exactly the word's letters, shuffled — the kid orders them
function buildWordPanel(w) {
  game.entry = "";
  $("game-entry").textContent = " ";
  let keys = shuffle([...w.b]);
  for (let i = 0; i < 10 && keys.join("") === w.b && w.b.length > 1; i++) keys = shuffle([...w.b]);
  const panel = $("game-letters");
  panel.classList.add("few");
  panel.innerHTML = "";
  for (const c of keys) {
    const b = document.createElement("button");
    b.type = "button"; b.className = "lkey"; b.textContent = c;
    b.onclick = () => onLetterKey(c, b);
    panel.appendChild(b);
  }
}

// 8 letter buttons: the answers for what's falling, padded with look-alikes
function refreshLetterPanel() {
  const need = [...new Set(game.items.map(it => it.c))];
  const fillers = [];
  for (const c of need) {
    const L = letterByChar(c);
    for (const x of LETTERS) if (x.group === L.group && x.c !== c) fillers.push(x.c);
  }
  fillers.push(...shuffle(game.pool));
  fillers.push(...shuffle(ALL_LETTER_CHARS));
  const taken = new Set(need);
  const letters = [...need, ...takeDistinct(taken, fillers, 8 - need.length)];
  const panel = $("game-letters");
  panel.classList.remove("few");
  panel.innerHTML = "";
  for (const c of shuffle(letters)) {
    const b = document.createElement("button");
    b.type = "button"; b.className = "lkey"; b.textContent = c;
    b.onclick = () => onLetterKey(c, b);
    panel.appendChild(b);
  }
}

function buzzKey(btn) {
  btn.classList.remove("wrongflash");
  void btn.offsetWidth;
  btn.classList.add("wrongflash");
  soundBad();
}

function onLetterKey(c, btn) {
  if (!game || game.over) return;
  if (game.kind === "letters") {
    const hit = game.items.filter(it => it.c === c).sort((a, b) => b.y - a.y)[0];
    if (hit) {
      zapItem(hit);
      recordResult("L:" + c, true);
    } else buzzKey(btn);
    return;
  }
  // word kind: spell the falling word letter by letter, in order
  const it = game.items[0];
  if (!it || btn.disabled) return;
  if (c === it.b[game.entry.length]) {
    btn.disabled = true;
    game.entry += c;
    $("game-entry").textContent = game.entry;
    beep([980], 0.06, 0.08);
    if (game.entry === it.b) {
      zapItem(it);
      recordResult("W:" + it.b, true);
    }
  } else buzzKey(btn);
}

function zapItem(it) {
  it.el.innerHTML = "💥";
  it.el.classList.add("boom");
  const el = it.el;
  game.items = game.items.filter(x => x !== it);
  setTimeout(() => el.remove(), 400);
  if (game.kind === "letters") {
    game.score += 10;
    game.speed += 1.2;
    game.spawnEvery = Math.max(1500, game.spawnEvery - 55);
    refreshLetterPanel();
  } else {
    game.score += 10 + 2 * it.b.length; // longer words are worth more
    game.speed += 1.0;
    game.entry = "";
    $("game-entry").textContent = " ";
    $("game-letters").innerHTML = "";
  }
  updateGameHud();
  beep([880, 1320], 0.08);
}

function itemLanded(it) {
  it.el.innerHTML = "💥";
  it.el.classList.add("boom");
  const el = it.el;
  game.items = game.items.filter(x => x !== it);
  setTimeout(() => el.remove(), 400);
  recordResult(game.kind === "letters" ? "L:" + it.c : "W:" + it.b, false);
  game.lives--;
  updateGameHud();
  soundBad();
  if (game.lives <= 0) { endGame(); return; }
  // fresh sky after losing a life: keep the pace, short breather
  for (const other of game.items) other.el.remove();
  game.items = [];
  game.entry = "";
  game.sinceSpawn = -1500;
  if (game.kind === "letters") refreshLetterPanel();
  else { $("game-entry").textContent = " "; $("game-letters").innerHTML = ""; }
}

function endGame() {
  game.over = true;
  if (game.raf) cancelAnimationFrame(game.raf);
  const best = loadBest();
  const prev = best.fall || 0;
  $("go-score").textContent = `🪂 ${game.score}`;
  if (game.score > prev) {
    best.fall = game.score;
    saveBest(best);
    $("go-best").textContent = T().newRecord;
  } else {
    $("go-best").textContent = `${T().best}: ${prev}`;
  }
  $("game-over").hidden = false;
}

function quitGame(target) {
  if (game && game.raf) cancelAnimationFrame(game.raf);
  game = null;
  showScreen(target);
}

$("btn-play-game").onclick = startGame;
$("btn-game-quit").onclick = () => quitGame("results");
$("btn-game-done").onclick = () => quitGame("results");

/* ================= wiring ================= */
$("btn-good").onclick = () => onGrade(true);
$("btn-bad").onclick = () => onGrade(false);
$("btn-quit").onclick = () => { stopTimer(); quiz = null; showScreen("setup"); };
$("btn-again").onclick = startQuiz;
$("btn-settings").onclick = () => showScreen("setup");

buildSetup();
applyLang();
refreshSetup();
$("app-version").textContent = "v" + APP_VERSION;

if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => navigator.serviceWorker.register("sw.js").catch(() => {}));
}
