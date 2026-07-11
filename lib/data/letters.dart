// GENERATED from web_app/app.js LETTERS — do not hand-edit; regenerate instead.
// group: letters that look alike (used to pick tricky distractors in games).
class Letter {
  final String char;
  final int group;
  const Letter(this.char, this.group);
}

const List<Letter> kLetters = [
  Letter("ا", 0),
  Letter("ب", 1),
  Letter("ت", 1),
  Letter("ث", 1),
  Letter("ج", 2),
  Letter("ح", 2),
  Letter("خ", 2),
  Letter("د", 3),
  Letter("ذ", 3),
  Letter("ر", 4),
  Letter("ز", 4),
  Letter("س", 5),
  Letter("ش", 5),
  Letter("ص", 6),
  Letter("ض", 6),
  Letter("ط", 7),
  Letter("ظ", 7),
  Letter("ع", 8),
  Letter("غ", 8),
  Letter("ف", 9),
  Letter("ق", 9),
  Letter("ك", 0),
  Letter("ل", 0),
  Letter("م", 0),
  Letter("ن", 1),
  Letter("ه", 0),
  Letter("و", 0),
  Letter("ي", 1),
];

final List<String> kAllLetterChars = kLetters.map((l) => l.char).toList();
