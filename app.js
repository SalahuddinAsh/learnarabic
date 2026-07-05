"use strict";

const APP_VERSION = "1.0.0";

/* ================= tunable constants ================= */
const COUNT_OPTIONS = [5, 10, 15, 20];
const QUESTION_SECONDS = 15;   // when the timer is on (read mode is never timed)
const WEAK_BIAS = 0.4;         // chance a question is drawn from saved weak items
const TATWEEL = "ـ";

/* ================= content data ================= */
// group: letters that look alike (used to pick tricky distractors); join: connects to the next letter
const LETTERS = [
  { c: "ا", name: "ألف", group: 0, join: false },
  { c: "ب", name: "باء", group: 1, join: true },
  { c: "ت", name: "تاء", group: 1, join: true },
  { c: "ث", name: "ثاء", group: 1, join: true },
  { c: "ج", name: "جيم", group: 2, join: true },
  { c: "ح", name: "حاء", group: 2, join: true },
  { c: "خ", name: "خاء", group: 2, join: true },
  { c: "د", name: "دال", group: 3, join: false },
  { c: "ذ", name: "ذال", group: 3, join: false },
  { c: "ر", name: "راء", group: 4, join: false },
  { c: "ز", name: "زاي", group: 4, join: false },
  { c: "س", name: "سين", group: 5, join: true },
  { c: "ش", name: "شين", group: 5, join: true },
  { c: "ص", name: "صاد", group: 6, join: true },
  { c: "ض", name: "ضاد", group: 6, join: true },
  { c: "ط", name: "طاء", group: 7, join: true },
  { c: "ظ", name: "ظاء", group: 7, join: true },
  { c: "ع", name: "عين", group: 8, join: true },
  { c: "غ", name: "غين", group: 8, join: true },
  { c: "ف", name: "فاء", group: 9, join: true },
  { c: "ق", name: "قاف", group: 9, join: true },
  { c: "ك", name: "كاف", group: 0, join: true },
  { c: "ل", name: "لام", group: 0, join: true },
  { c: "م", name: "ميم", group: 0, join: true },
  { c: "ن", name: "نون", group: 1, join: true },
  { c: "ه", name: "هاء", group: 0, join: true },
  { c: "و", name: "واو", group: 0, join: false },
  { c: "ي", name: "ياء", group: 1, join: true },
];
const ALL_LETTER_CHARS = LETTERS.map(L => L.c);

// w: vocalized word, b: bare letters (tiles / filtering), e: emoji picture
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
];

// harakat: short vowels and long (madd) variants — value appended to a letter char
const MARKS = {
  a: "َ", u: "ُ", i: "ِ",          // بَ بُ بِ
  A: "َا", U: "ُو", I: "ِي",       // با بو بي
};
const POS_AR = ["في البداية", "في الوسط", "في النهاية"];

function formOf(c, pos) { // 0 initial, 1 medial, 2 final (joining letters only)
  return pos === 0 ? c + TATWEEL : pos === 1 ? TATWEEL + c + TATWEEL : TATWEEL + c;
}
function syllable(c, hk) { return c + MARKS[hk]; }

/* ================= i18n (UI only; question content is always Arabic) ================= */
const STRINGS = {
  ar: {
    title: "نجوم القراءة ⭐",
    level: "المستوى", lvl1: "الحروف", lvl2: "أشكال الحروف", lvl3: "المقاطع", lvl4: "الكلمات",
    mode: "اللعبة",
    modeHear: "اسمع واختر", modePic: "الكلمة والصورة", modeBuild: "ركّب الكلمة", modeRead: "اقرأ لي",
    letters: "الحروف المختارة", all: "الكل",
    harakat: "الحركات",
    count: "كم عدد الأسئلة؟",
    timer: "المؤقت", timerOn: "⏱️ يعمل", timerOff: "🚫 بدون",
    start: "!ابدأ 🚀",
    hintLetters: "اختر حرفًا واحدًا على الأقل",
    hintHarakat: "اختر حركة واحدة على الأقل",
    insHear: "👂 اسمع ثم اختر",
    insForm: "أين شكل الحرف؟",
    insPic: "اختر الصورة الصحيحة",
    insPicWord: "اختر الكلمة الصحيحة",
    insBuild: "ركّب الكلمة",
    insRead: "🎤 اقرأ بصوت عالٍ",
    pos: POS_AR,
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
    noVoice: "لا يوجد صوت عربي — فعِّله من إعدادات الجهاز",
  },
  en: {
    title: "Reading Stars ⭐",
    level: "Level", lvl1: "Letters", lvl2: "Letter shapes", lvl3: "Syllables", lvl4: "Words",
    mode: "Game",
    modeHear: "Hear & tap", modePic: "Word & picture", modeBuild: "Build the word", modeRead: "Read to me",
    letters: "Letters to practice", all: "All",
    harakat: "Vowel marks",
    count: "How many questions?",
    timer: "Timer", timerOn: "⏱️ On", timerOff: "🚫 Off",
    start: "Start! 🚀",
    hintLetters: "Pick at least one letter",
    hintHarakat: "Pick at least one vowel mark",
    insHear: "👂 Listen, then tap",
    insForm: "Where is this letter's shape?",
    insPic: "Tap the right picture",
    insPicWord: "Tap the right word",
    insBuild: "Build the word",
    insRead: "🎤 Read out loud",
    pos: ["at the start", "in the middle", "at the end"],
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
    noVoice: "No Arabic voice found — enable it in device settings",
  },
  de: {
    title: "Lese-Sterne ⭐",
    level: "Stufe", lvl1: "Buchstaben", lvl2: "Buchstabenformen", lvl3: "Silben", lvl4: "Wörter",
    mode: "Spiel",
    modeHear: "Hören & tippen", modePic: "Wort & Bild", modeBuild: "Wort bauen", modeRead: "Lies mir vor",
    letters: "Buchstaben zum Üben", all: "Alle",
    harakat: "Vokalzeichen",
    count: "Wie viele Aufgaben?",
    timer: "Zeitlimit", timerOn: "⏱️ An", timerOff: "🚫 Aus",
    start: "Los! 🚀",
    hintLetters: "Wähle mindestens einen Buchstaben",
    hintHarakat: "Wähle mindestens ein Vokalzeichen",
    insHear: "👂 Hör zu, dann tippe",
    insForm: "Wo ist diese Buchstabenform?",
    insPic: "Tippe auf das richtige Bild",
    insPicWord: "Tippe auf das richtige Wort",
    insBuild: "Baue das Wort",
    insRead: "🎤 Lies laut vor",
    pos: ["am Anfang", "in der Mitte", "am Ende"],
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
    noVoice: "Keine arabische Stimme gefunden — in den Geräteeinstellungen aktivieren",
  },
};

/* ================= settings ================= */
const DEFAULTS = {
  lang: "ar", level: 1, mode: "hear",
  letters: [...ALL_LETTER_CHARS], harakat: ["a", "u", "i"],
  count: 10, timed: false, sound: true,
};
let settings = loadSettings();

function validModes(level) {
  if (level === 1) return ["hear", "read"];
  if (level === 2) return ["hear"];
  if (level === 3) return ["hear", "read"];
  return ["hear", "pic", "build", "read"];
}

function loadSettings() {
  try {
    const s = JSON.parse(localStorage.getItem("readstars-settings"));
    if (!s) return { ...DEFAULTS };
    const letters = Array.isArray(s.letters) ? s.letters.filter(c => ALL_LETTER_CHARS.includes(c)) : [];
    const harakat = Array.isArray(s.harakat) ? s.harakat.filter(h => Object.keys(MARKS).includes(h)) : [];
    const level = [1, 2, 3, 4].includes(s.level) ? s.level : DEFAULTS.level;
    return {
      lang: ["ar", "en", "de"].includes(s.lang) ? s.lang : DEFAULTS.lang,
      level,
      mode: validModes(level).includes(s.mode) ? s.mode : "hear",
      letters: letters.length ? letters : [...DEFAULTS.letters],
      harakat: harakat.length ? harakat : [...DEFAULTS.harakat],
      count: COUNT_OPTIONS.includes(s.count) ? s.count : DEFAULTS.count,
      timed: s.timed === true,
      sound: s.sound !== false,
    };
  } catch { return { ...DEFAULTS }; }
}
function saveSettings() {
  try { localStorage.setItem("readstars-settings", JSON.stringify(settings)); } catch {}
}

/* ================= weak items & high scores ================= */
// keys: "L:ب" (letter), "S:بَ" (syllable), "W:قط" (word by bare letters)
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
// weighted lists of weak targets usable with the current settings
function weakTargets(cfg) {
  const w = loadWeak();
  const out = { L: [], S: [], W: [] };
  for (const key of Object.keys(w)) {
    const kind = key[0], val = key.slice(2);
    let ok = false;
    if (kind === "L") ok = cfg.letters.includes(val);
    else if (kind === "S") ok = cfg.letters.includes(val[0]) && cfg.syllables.includes(val);
    else if (kind === "W") ok = cfg.words.some(x => x.b === val);
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
// up to n distinct labels from candidates (kept in order), skipping taken ones
function takeDistinct(taken, candidates, n) {
  const out = [];
  for (const c of candidates) {
    if (out.length >= n) break;
    if (!taken.has(c) && !out.includes(c)) out.push(c);
  }
  return out;
}
const letterByChar = c => LETTERS.find(L => L.c === c);

/* ================= speech (built-in Arabic voice) ================= */
let arVoice = null;
function pickVoice() {
  try {
    const vs = speechSynthesis.getVoices();
    arVoice = vs.find(v => /^ar([-_]|$)/i.test(v.lang)) || null;
  } catch {}
}
if ("speechSynthesis" in window) {
  pickVoice();
  speechSynthesis.onvoiceschanged = pickVoice;
}
function speak(text) {
  if (!settings.sound || !text || !("speechSynthesis" in window)) return;
  try {
    speechSynthesis.cancel();
    const u = new SpeechSynthesisUtterance(text);
    u.lang = arVoice ? arVoice.lang : "ar-SA";
    if (arVoice) u.voice = arVoice;
    u.rate = 0.8;
    speechSynthesis.speak(u);
  } catch {}
}

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
  const letters = [...settings.letters];
  const cfg = {
    level: settings.level,
    mode: settings.mode,
    letters,
    harakat: [...settings.harakat],
    timed: settings.timed,
  };
  cfg.syllables = [];
  for (const c of letters) for (const h of cfg.harakat) cfg.syllables.push(syllable(c, h));
  const filtered = WORDS.filter(x => [...x.b].some(c => letters.includes(c)));
  cfg.words = filtered.length ? filtered : [...WORDS];
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

function pickLetter(cfg) {
  if (cfg.weak.L.length && Math.random() < WEAK_BIAS) return letterByChar(pick(cfg.weak.L));
  return letterByChar(pick(cfg.letters));
}
function pickSyll(cfg) {
  if (cfg.weak.S.length && Math.random() < WEAK_BIAS) return pick(cfg.weak.S);
  return pick(cfg.syllables);
}
function pickWord(cfg) {
  if (cfg.weak.W.length && Math.random() < WEAK_BIAS) {
    const b = pick(cfg.weak.W);
    const w = cfg.words.find(x => x.b === b);
    if (w) return w;
  }
  return pick(cfg.words);
}

function makeQ(cfg) {
  const m = cfg.mode, lv = cfg.level;
  if (m === "hear") {
    if (lv === 1) return qLetterHear(cfg);
    if (lv === 2) return qFormMatch(cfg);
    if (lv === 3) return qSyllHear(cfg);
    return qWordHear(cfg);
  }
  if (m === "pic") return qPic(cfg);
  if (m === "build") return qBuild(cfg);
  return qRead(cfg);
}

function makeCards(correct, distractors, n) {
  const taken = new Set([correct]);
  const labels = [correct, ...takeDistinct(taken, distractors, n - 1)];
  return shuffle(labels.map(t => ({ t, ok: t === correct })));
}

function qLetterHear(cfg) {
  const L = pickLetter(cfg);
  const sameGroup = LETTERS.filter(x => x.group === L.group && x.c !== L.c).map(x => x.c);
  const others = shuffle(ALL_LETTER_CHARS.filter(c => c !== L.c && !sameGroup.includes(c)));
  return {
    mode: "hear", level: 1, key: "L:" + L.c, weakKey: "L:" + L.c,
    say: L.name, sayFirst: true,
    cards: makeCards(L.c, [...shuffle(sameGroup), ...others], 6),
    answerText: L.c,
  };
}

function qFormMatch(cfg) {
  const joiningSel = cfg.letters.filter(c => letterByChar(c).join);
  const poolChars = joiningSel.length ? joiningSel : LETTERS.filter(L => L.join).map(L => L.c);
  let c;
  if (cfg.weak.L.length && Math.random() < WEAK_BIAS) {
    const weakJoin = cfg.weak.L.filter(x => letterByChar(x).join);
    c = weakJoin.length ? pick(weakJoin) : pick(poolChars);
  } else c = pick(poolChars);
  const L = letterByChar(c);
  const p = Math.floor(Math.random() * 3);
  const otherForms = [0, 1, 2].filter(x => x !== p).map(x => formOf(c, x));
  const groupForms = LETTERS
    .filter(x => x.join && x.c !== c && x.group === L.group)
    .map(x => formOf(x.c, p));
  const randForms = shuffle(LETTERS.filter(x => x.join && x.c !== c)).map(x => formOf(x.c, p));
  return {
    mode: "hear", level: 2, key: `F:${c}:${p}`, weakKey: "L:" + c,
    say: `${L.name}، ${POS_AR[p]}`,
    prompt: c, posIdx: p,
    cards: makeCards(formOf(c, p), [...otherForms, ...shuffle(groupForms), ...randForms], 6),
    answerText: formOf(c, p),
  };
}

function qSyllHear(cfg) {
  const s = pickSyll(cfg);
  const c = s[0];
  const L = letterByChar(c);
  // distractors: same letter with other marks, then look-alike letters with the same mark
  const sameLetter = cfg.syllables.filter(x => x[0] === c && x !== s);
  const mark = s.slice(1);
  const similar = LETTERS.filter(x => x.c !== c && x.group === L.group).map(x => x.c + mark);
  const rest = shuffle(LETTERS.filter(x => x.c !== c && x.group !== L.group)).map(x => x.c + mark);
  return {
    mode: "hear", level: 3, key: "S:" + s, weakKey: "S:" + s,
    say: s, sayFirst: true,
    cards: makeCards(s, [...shuffle(sameLetter), ...shuffle(similar), ...rest], 6),
    answerText: s,
  };
}

function wordDistractors(w, words) {
  const rest = words.filter(x => x.b !== w.b && x.e !== w.e && x.w !== w.w);
  const scored = rest.map(x => ({
    x,
    s: (x.b[0] === w.b[0] ? 2 : 0) + (Math.abs(x.b.length - w.b.length) <= 1 ? 1 : 0) + Math.random(),
  }));
  scored.sort((a, b) => b.s - a.s);
  return scored.map(o => o.x);
}

function qWordHear(cfg) {
  const w = pickWord(cfg);
  const ds = wordDistractors(w, cfg.words).map(x => x.w);
  return {
    mode: "hear", level: 4, key: "W:" + w.b, weakKey: "W:" + w.b,
    say: w.w, sayFirst: true,
    cards: makeCards(w.w, ds, 4),
    answerText: w.w, reveal: w.e,
  };
}

function qPic(cfg) {
  const w = pickWord(cfg);
  const ds = wordDistractors(w, cfg.words);
  const toEmoji = Math.random() < 0.5; // word shown → pick emoji, or emoji shown → pick word
  return {
    mode: "pic", level: 4, key: "W:" + w.b, weakKey: "W:" + w.b,
    say: w.w, sayFirst: toEmoji,
    toEmoji,
    prompt: toEmoji ? w.w : "", promptEmoji: toEmoji ? "" : w.e,
    cards: toEmoji
      ? makeCards(w.e, ds.map(x => x.e), 4)
      : makeCards(w.w, ds.map(x => x.w), 4),
    answerText: toEmoji ? w.e : w.w, reveal: toEmoji ? "" : w.e,
  };
}

function qBuild(cfg) {
  const pool = cfg.words.filter(x => x.b.length >= 2 && x.b.length <= 5);
  let w;
  if (cfg.weak.W.length && Math.random() < WEAK_BIAS) {
    const b = pick(cfg.weak.W);
    w = pool.find(x => x.b === b) || pick(pool);
  } else w = pick(pool);
  let tiles = shuffle([...w.b]);
  for (let i = 0; i < 10 && tiles.join("") === w.b && w.b.length > 1; i++) tiles = shuffle([...w.b]);
  return {
    mode: "build", level: 4, key: "W:" + w.b, weakKey: "W:" + w.b,
    say: w.w, sayFirst: true,
    promptEmoji: w.e, word: w, tiles,
    answerText: w.w,
  };
}

function qRead(cfg) {
  if (cfg.level === 1) {
    const L = pickLetter(cfg);
    return { mode: "read", level: 1, key: "L:" + L.c, weakKey: "L:" + L.c, prompt: L.c, say: L.name, answerText: L.c };
  }
  if (cfg.level === 3) {
    const s = pickSyll(cfg);
    return { mode: "read", level: 3, key: "S:" + s, weakKey: "S:" + s, prompt: s, say: s, answerText: s };
  }
  const w = pickWord(cfg);
  return { mode: "read", level: 4, key: "W:" + w.b, weakKey: "W:" + w.b, prompt: w.w, say: w.w, answerText: w.w, reveal: w.e };
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
      settings.level = +chip.dataset.level;
      if (!validModes(settings.level).includes(settings.mode)) settings.mode = "hear";
      refreshSetup();
    };
  });
  document.querySelectorAll("#mode-row .op-chip").forEach(chip => {
    chip.onclick = () => { settings.mode = chip.dataset.mode; refreshSetup(); };
  });
  document.querySelectorAll("#harakat-row .hk").forEach(chip => {
    chip.onclick = () => {
      const h = chip.dataset.hk;
      const i = settings.harakat.indexOf(h);
      i >= 0 ? settings.harakat.splice(i, 1) : settings.harakat.push(h);
      refreshSetup();
    };
  });
  document.querySelectorAll("#timer-row .chip").forEach(chip => {
    chip.onclick = () => { settings.timed = chip.dataset.timed === "1"; refreshSetup(); };
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
  document.querySelectorAll("#level-row .op-chip").forEach(c => c.classList.toggle("selected", +c.dataset.level === lv));
  document.querySelectorAll("#mode-row .op-chip").forEach(c => {
    c.hidden = !modes.includes(c.dataset.mode);
    c.classList.toggle("selected", c.dataset.mode === settings.mode);
  });
  document.querySelectorAll("#letters-row .chip").forEach(c => c.classList.toggle("selected", settings.letters.includes(c.dataset.letter)));
  $("btn-all").classList.toggle("selected", settings.letters.length === ALL_LETTER_CHARS.length);
  $("harakat-group").hidden = lv !== 3;
  document.querySelectorAll("#harakat-row .hk").forEach(c => c.classList.toggle("selected", settings.harakat.includes(c.dataset.hk)));
  document.querySelectorAll("#count-row .chip").forEach(c => c.classList.toggle("selected", +c.dataset.count === settings.count));
  $("timer-group").hidden = settings.mode === "read";
  document.querySelectorAll("#timer-row .chip").forEach(c => c.classList.toggle("selected", (c.dataset.timed === "1") === settings.timed));
  $("btn-sound").textContent = settings.sound ? "🔊" : "🔇";

  let hint = "";
  if (settings.letters.length === 0) hint = T().hintLetters;
  else if (lv === 3 && settings.harakat.length === 0) hint = T().hintHarakat;
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
  $("t-harakat").textContent = t.harakat;
  $("t-count").textContent = t.count;
  $("t-timer").textContent = t.timer;
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

  let ins = "";
  if (q.mode === "hear") ins = q.level === 2 ? t.insForm : t.insHear;
  else if (q.mode === "pic") ins = q.toEmoji ? t.insPic : t.insPicWord;
  else if (q.mode === "build") ins = t.insBuild;
  else ins = t.insRead;
  $("instruction").textContent = ins;

  const promptEl = $("prompt");
  let ptext = q.prompt || "";
  if (q.level === 2 && q.posIdx != null && q.mode === "hear") ptext = `${q.prompt} ← ${t.pos[q.posIdx]}`;
  promptEl.textContent = q.promptEmoji || ptext;
  promptEl.classList.toggle("emoji", !!q.promptEmoji);
  promptEl.classList.toggle("read-big", q.mode === "read");
  $("btn-say").hidden = !q.say;

  const builtEl = $("built");
  builtEl.hidden = q.mode !== "build";
  builtEl.textContent = "";
  builtEl.className = "built";

  $("feedback").textContent = "";
  $("feedback").className = "feedback";

  const cardsEl = $("cards");
  cardsEl.innerHTML = "";
  cardsEl.hidden = !q.cards;
  if (q.cards) {
    cardsEl.classList.toggle("grid3", q.cards.length > 4);
    cardsEl.classList.toggle("emoji-cards", q.mode === "pic" && q.toEmoji);
    for (const c of q.cards) {
      const b = document.createElement("button");
      b.type = "button"; b.className = "acard"; b.textContent = c.t; b.dir = "rtl";
      b.onclick = () => onCard(b, c);
      cardsEl.appendChild(b);
    }
  }
  $("builder").hidden = q.mode !== "build";
  if (q.mode === "build") buildTiles(q);
  $("grade").hidden = q.mode !== "read";

  $("progress-text").textContent = `${quiz.index + 1} / ${quiz.questions.length}`;
  $("score-pill").textContent = `⭐ ${Math.round(quiz.points)}`;

  $("timebar-row").hidden = untimed(q);
  if (untimed(q)) {
    stopTimer();
    quiz.timerStart = performance.now();
    quiz.timerTotal = Infinity;
  } else {
    startTimer(QUESTION_SECONDS);
  }

  if (q.sayFirst) setTimeout(() => speak(q.say), 250);
}

function buildTiles(q) {
  const tilesEl = $("tiles");
  tilesEl.innerHTML = "";
  q.tiles.forEach((ch, i) => {
    const b = document.createElement("button");
    b.type = "button"; b.className = "tile"; b.textContent = ch;
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
    $("built").textContent = quiz.built.map(x => x.ch).join("");
  };
  tilesEl.appendChild(back);
}

function onTile(q, btn, ch) {
  if (quiz.locked || btn.disabled) return;
  btn.disabled = true;
  quiz.built.push({ ch, i: +btn.dataset.i });
  const word = quiz.built.map(x => x.ch).join("");
  $("built").textContent = word;
  if (quiz.built.length === q.tiles.length) {
    finishAnswer(word === q.word.b, q, () => { $("built").textContent = q.word.w; });
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
    setTimeout(advance, 1100);
  } else {
    quiz.missed.push(q);
    $("feedback").textContent = `${T().answerIs}: ${q.answerText} ${q.reveal || ""}`;
    $("feedback").className = "feedback bad";
    $("built").classList.add("no");
    if (q.mode === "build") $("built").textContent = q.word.w;
    soundBad();
    speak(q.say);
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
  if (q.mode === "build") { $("built").textContent = q.word.w; $("built").classList.add("no"); }
  soundBad();
  speak(q.say);
  setTimeout(advance, 2300);
}

function onGrade(good) {
  if (!quiz || quiz.locked) return;
  const q = quiz.questions[quiz.index];
  finishAnswer(good, q, () => {
    if (q.reveal) $("prompt").textContent = `${q.prompt} ${q.reveal}`;
    speak(q.say); // the kid hears the correct reading either way
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
      li.textContent = `🔊 ${q.answerText} ${q.reveal || ""}`;
      const say = q.say;
      li.onclick = () => speak(say);
      list.appendChild(li);
    }
    missedWrap.hidden = false;
  } else missedWrap.hidden = true;

  quiz = null;
  showScreen("results");
}

/* ================= wiring ================= */
$("btn-say").onclick = () => {
  if (!quiz) return;
  const q = quiz.questions[quiz.index];
  if (!arVoice) { pickVoice(); if (!arVoice && "speechSynthesis" in window) $("feedback").textContent = T().noVoice; }
  speak(q.say);
};
$("btn-good").onclick = () => onGrade(true);
$("btn-bad").onclick = () => onGrade(false);
$("btn-quit").onclick = () => {
  stopTimer(); quiz = null;
  try { speechSynthesis.cancel(); } catch {}
  showScreen("setup");
};
$("btn-again").onclick = startQuiz;
$("btn-settings").onclick = () => showScreen("setup");

buildSetup();
applyLang();
refreshSetup();
$("app-version").textContent = "v" + APP_VERSION;

if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => navigator.serviceWorker.register("sw.js").catch(() => {}));
}
