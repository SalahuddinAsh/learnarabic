import 'dart:math';
import '../data/ayahs.dart';
import '../data/letters.dart';
import '../data/sentences.dart';
import '../data/words.dart';
import '../models/question.dart';
import '../models/settings.dart';
import '../services/weak_memory.dart';

const double kWeakBias = 0.4;

int timeForQ(Question q) => (q.level == "sent" || q.mode == "connect") ? 30 : 15;

final Set<String> kFirstLetters = kWords.map((w) => w.bare.substring(0, 1)).toSet();

final Random _rng = Random();
T pick<T>(List<T> arr) => arr[_rng.nextInt(arr.length)];
double _random() => _rng.nextDouble();

List<T> shuffle<T>(List<T> arr) {
  final a = List<T>.from(arr);
  for (var i = a.length - 1; i > 0; i--) {
    final j = _rng.nextInt(i + 1);
    final tmp = a[i];
    a[i] = a[j];
    a[j] = tmp;
  }
  return a;
}

List<T> takeDistinct<T>(Set<T> taken, List<T> candidates, int n) {
  final out = <T>[];
  for (final c in candidates) {
    if (out.length >= n) break;
    if (!taken.contains(c) && !out.contains(c)) out.add(c);
  }
  return out;
}

Letter? letterByChar(String c) {
  for (final l in kLetters) {
    if (l.char == c) return l;
  }
  return null;
}

/// Everything a question generator needs about the current settings + weak-memory —
/// mirrors buildCfg()'s returned `cfg` object.
class QuestionConfig {
  final String level;
  final String mode;
  final List<String> letterPool;
  final WeakTargets weak;
  const QuestionConfig({
    required this.level,
    required this.mode,
    required this.letterPool,
    required this.weak,
  });
}

QuestionConfig buildCfg(Settings settings) {
  final withWords = settings.letters.where(kFirstLetters.contains).toList();
  final letterPool = withWords.isNotEmpty ? withWords : kFirstLetters.toList();
  final weak = WeakMemory.targets(letterPool: letterPool);
  return QuestionConfig(level: settings.level, mode: settings.mode, letterPool: letterPool, weak: weak);
}

/// Anti-repeat wrapper — mirrors genQuestion(cfg, recent): tries up to 60 times
/// to avoid one of the last 4 question keys, but gives up avoiding repeats
/// past attempt 50 rather than looping forever on a starved question pool.
Question genQuestion(QuestionConfig cfg, List<String> recent) {
  Question? result;
  for (var attempt = 0; attempt < 60; attempt++) {
    final q = _makeQ(cfg);
    if (!recent.contains(q.key) || attempt >= 50) {
      recent.add(q.key);
      if (recent.length > 4) recent.removeAt(0);
      result = q;
      break;
    }
  }
  return result!;
}

String _pickLetterChar(QuestionConfig cfg) {
  if (cfg.weak.letters.isNotEmpty && _random() < kWeakBias) return pick(cfg.weak.letters);
  return pick(cfg.letterPool);
}

WordEntry _pickWord(QuestionConfig cfg, [List<WordEntry>? pool]) {
  final p = pool ?? kWords;
  if (cfg.weak.words.isNotEmpty && _random() < kWeakBias) {
    final b = pick(cfg.weak.words);
    final w = p.where((x) => x.bare == b).firstOrNull;
    if (w != null) return w;
  }
  return pick(p);
}

int _pickSentenceIdx(QuestionConfig cfg) {
  if (cfg.weak.sentenceIdx.isNotEmpty && _random() < kWeakBias) {
    return int.parse(pick(cfg.weak.sentenceIdx));
  }
  return _rng.nextInt(kSentences.length);
}

Question _makeQ(QuestionConfig cfg) {
  final m = cfg.mode, lv = cfg.level;
  if (lv == "letters") return m == "read" ? _qReadLetter(cfg) : _qLetterMatch(cfg);
  if (lv == "words") {
    if (m == "match") return _qPic(cfg);
    if (m == "missing") return _qMissing(cfg);
    if (m == "connect") return _qConnect(cfg);
    if (m == "build") return _qBuild(cfg);
    return _qReadWord(cfg);
  }
  if (m == "build") return _qSentBuild(cfg);
  if (m == "connect") return _qOrder(cfg);
  return _qReadSent(cfg);
}

List<AnswerCard> makeCards(String correct, List<String> distractors, int n) {
  final taken = <String>{correct};
  final labels = [correct, ...takeDistinct(taken, distractors, n - 1)];
  return shuffle(labels.map((t) => AnswerCard(t, t == correct)).toList());
}

/* --- letters level: picture <-> first letter, both directions --- */
Question _qLetterMatch(QuestionConfig cfg) {
  final c = _pickLetterChar(cfg);
  final word = pick(kWords.where((x) => x.bare.substring(0, 1) == c).toList());
  if (_random() < 0.5) {
    // show the picture -> pick the letter it starts with (6 letter cards)
    final l = letterByChar(c)!;
    final sameGroup = kLetters.where((x) => x.group == l.group && x.char != c).map((x) => x.char).toList();
    final others = shuffle(kAllLetterChars.where((x) => x != c && !sameGroup.contains(x)).toList());
    return Question(
      mode: "match", level: "letters", key: "L:$c:pic", weakKey: "L:$c",
      insKey: "insPickLetter",
      promptEmoji: word.emoji,
      cards: makeCards(c, [...shuffle(sameGroup), ...others], 6),
      answerText: c, reveal: word.vocalized,
    );
  }
  // show the letter -> pick the picture that starts with it (4 emoji cards)
  final ds = shuffle(kWords.where((x) => x.bare.substring(0, 1) != c && x.emoji != word.emoji).toList())
      .map((x) => x.emoji)
      .toList();
  return Question(
    mode: "match", level: "letters", key: "L:$c:ltr", weakKey: "L:$c",
    insKey: "insPickPic", emojiCards: true,
    prompt: c,
    cards: makeCards(word.emoji, ds, 4),
    answerText: word.emoji, reveal: word.vocalized,
  );
}

Question _qReadLetter(QuestionConfig cfg) {
  final c = _pickLetterChar(cfg);
  final ex = pick(kWords.where((x) => x.bare.substring(0, 1) == c).toList());
  return Question(
    mode: "read", level: "letters", key: "L:$c", weakKey: "L:$c",
    insKey: "insRead", prompt: c,
    answerText: c, reveal: "${ex.vocalized} ${ex.emoji}",
  );
}

/* --- words level --- */
List<WordEntry> _wordDistractors(WordEntry w, List<WordEntry> words) {
  final rest = words.where((x) => x.bare != w.bare && x.emoji != w.emoji && x.vocalized != w.vocalized).toList();
  final scored = rest
      .map((x) => (
            x: x,
            s: (x.bare.substring(0, 1) == w.bare.substring(0, 1) ? 2 : 0) +
                ((x.bare.length - w.bare.length).abs() <= 1 ? 1 : 0) +
                _random(),
          ))
      .toList();
  scored.sort((a, b) => b.s.compareTo(a.s));
  return scored.map((o) => o.x).toList();
}

Question _qPic(QuestionConfig cfg) {
  final w = _pickWord(cfg);
  final ds = _wordDistractors(w, kWords);
  final toEmoji = _random() < 0.5;
  return Question(
    mode: "match", level: "words", key: "W:${w.bare}", weakKey: "W:${w.bare}",
    insKey: toEmoji ? "insPic" : "insPicWord",
    emojiCards: toEmoji,
    prompt: toEmoji ? w.vocalized : "",
    promptEmoji: toEmoji ? "" : w.emoji,
    toEmoji: toEmoji,
    cards: toEmoji
        ? makeCards(w.emoji, ds.map((x) => x.emoji).toList(), 4)
        : makeCards(w.vocalized, ds.map((x) => x.vocalized).toList(), 4),
    answerText: toEmoji ? w.emoji : w.vocalized,
    reveal: toEmoji ? "" : w.emoji,
  );
}

// missing letter: word shown with one blanked spot + its picture; pick the letter that fills it.
// Some bare words contain ة or hamza-alif forms that aren't in the 28-letter kLetters
// list (only ever used mid/end-word elsewhere) — only blank a position we can look up.
Question _qMissing(QuestionConfig cfg) {
  final pool = kWords.where((x) => x.bare.length >= 3).toList();
  var w = _pickWord(cfg, pool.isNotEmpty ? pool : kWords);
  var chars = w.bare.split("");
  List<int> validIdx() => [for (var i = 0; i < chars.length; i++) i].where((i) => letterByChar(chars[i]) != null).toList();
  var idxCandidates = validIdx();
  for (var attempt = 0; attempt < 20 && idxCandidates.isEmpty; attempt++) {
    w = pick(pool.isNotEmpty ? pool : kWords);
    chars = w.bare.split("");
    idxCandidates = validIdx();
  }
  final idx = pick(idxCandidates);
  final correct = chars[idx];
  final display = [for (var i = 0; i < chars.length; i++) i == idx ? "▢" : chars[i]].join();
  final l = letterByChar(correct)!;
  final sameGroup = kLetters.where((x) => x.group == l.group && x.char != correct).map((x) => x.char).toList();
  final others = shuffle(kAllLetterChars.where((c) => c != correct && !sameGroup.contains(c)).toList());
  return Question(
    mode: "missing", level: "words", key: "W:${w.bare}:$idx", weakKey: "W:${w.bare}",
    insKey: "insMissing",
    prompt: display, promptEmoji: w.emoji, missingWord: true,
    cards: makeCards(correct, [...shuffle(sameGroup), ...others], 5),
    answerText: correct, reveal: w.vocalized,
  );
}

Question _qBuild(QuestionConfig cfg) {
  final pool = kWords.where((x) => x.bare.length >= 2 && x.bare.length <= 5).toList();
  final w = _pickWord(cfg, pool);
  var tiles = shuffle(w.bare.split(""));
  for (var i = 0; i < 10 && tiles.join() == w.bare && w.bare.length > 1; i++) {
    tiles = shuffle(w.bare.split(""));
  }
  return Question(
    mode: "build", level: "words", key: "W:${w.bare}", weakKey: "W:${w.bare}",
    insKey: "insBuild",
    promptEmoji: w.emoji, tiles: tiles, accepted: [w.bare], targetShow: w.vocalized, joiner: "",
    answerText: w.vocalized,
  );
}

// connect board: 4 words to drag onto their 4 pictures
Question _qConnect(QuestionConfig cfg) {
  final first = _pickWord(cfg);
  final pairs = [first];
  for (final x in shuffle(kWords)) {
    if (pairs.length >= 4) break;
    if (!pairs.any((p) => p.bare == x.bare || p.emoji == x.emoji || p.vocalized == x.vocalized)) {
      pairs.add(x);
    }
  }
  final sortedBare = pairs.map((p) => p.bare).toList()..sort();
  return Question(
    mode: "connect", level: "words",
    key: "C:${sortedBare.join(",")}", weakKey: null, // words are recorded one by one
    insKey: "insConnect",
    pairs: pairs.map((p) => ConnectPair(p.bare, p.vocalized, p.emoji)).toList(),
    answerText: pairs.map((p) => "${p.vocalized} ${p.emoji}").join(" · "),
  );
}

// drag the sentence's words into ordered slots
Question _qOrder(QuestionConfig cfg) {
  final idx = _pickSentenceIdx(cfg);
  final s = kSentences[idx];
  final accepted = [s.words.join(" ")];
  if (s.swappable) accepted.add([s.words[1], s.words[0], ...s.words.skip(2)].join(" "));
  var tiles = shuffle(s.words);
  for (var i = 0; i < 10 && accepted.contains(tiles.join(" ")); i++) {
    tiles = shuffle(s.words);
  }
  return Question(
    mode: "connect", level: "sent", key: "T:$idx", weakKey: "T:$idx",
    insKey: "insOrder",
    promptEmoji: s.emoji, tiles: tiles, accepted: accepted, targetShow: s.words.join(" "), joiner: " ",
    answerText: s.words.join(" "), sent: true,
  );
}

Question _qReadWord(QuestionConfig cfg) {
  final w = _pickWord(cfg);
  return Question(
    mode: "read", level: "words", key: "W:${w.bare}", weakKey: "W:${w.bare}",
    insKey: "insRead", prompt: w.vocalized,
    answerText: w.vocalized, reveal: w.emoji,
  );
}

/* --- sentences level --- */
Question _qSentBuild(QuestionConfig cfg) {
  final idx = _pickSentenceIdx(cfg);
  final s = kSentences[idx];
  // every accepted word order counts as correct (verb-first or subject-first)
  final accepted = [s.words.join(" ")];
  if (s.swappable) accepted.add([s.words[1], s.words[0], ...s.words.skip(2)].join(" "));
  var tiles = shuffle(s.words);
  for (var i = 0; i < 10 && accepted.contains(tiles.join(" ")); i++) {
    tiles = shuffle(s.words);
  }
  return Question(
    mode: "build", level: "sent", key: "T:$idx", weakKey: "T:$idx",
    insKey: "insSent",
    promptEmoji: s.emoji, tiles: tiles, accepted: accepted, targetShow: s.words.join(" "), joiner: " ",
    answerText: s.words.join(" "), sent: true,
  );
}

Question _qReadSent(QuestionConfig cfg) {
  // read-to-me draws from sentences AND short ayahs
  final weakKeys = [
    ...cfg.weak.sentenceIdx.map((v) => "T:$v"),
    ...cfg.weak.ayahIdx.map((v) => "A:$v"),
  ];
  String key;
  if (weakKeys.isNotEmpty && _random() < kWeakBias) {
    key = pick(weakKeys);
  } else {
    final i = _rng.nextInt(kSentences.length + kAyahs.length);
    key = i < kSentences.length ? "T:$i" : "A:${i - kSentences.length}";
  }
  if (key.startsWith("A")) {
    final a = kAyahs[int.parse(key.substring(2))];
    return Question(
      mode: "read", level: "sent", key: key, weakKey: key,
      insKey: "insRead", prompt: a, answerText: a, reveal: "📖", sent: true,
    );
  }
  final s = kSentences[int.parse(key.substring(2))];
  return Question(
    mode: "read", level: "sent", key: key, weakKey: key,
    insKey: "insRead", prompt: s.words.join(" "),
    answerText: s.words.join(" "), reveal: s.emoji, sent: true,
  );
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
