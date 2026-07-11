import '../data/letters.dart';

const List<int> kCountOptions = [5, 10, 15, 20];
const List<int> kGameScoreOptions = [0, 500, 700, 800, 900];
const List<String> kLevels = ["letters", "words", "sent"];
const List<String> kLanguages = ["ar", "en", "de"];

/// Which game modes are offered for a given level — mirrors validModes() in app.js.
List<String> validModes(String level) {
  if (level == "letters") return ["match", "read"];
  if (level == "words") {
    return ["match", "missing", "connect", "build", "read"];
  }
  return ["build", "connect", "read"]; // sentences
}

class Settings {
  String lang;
  String level;
  String mode;
  List<String> letters;
  int count;
  bool timed;
  bool sound;
  int gameScore;

  Settings({
    this.lang = "ar",
    this.level = "letters",
    this.mode = "match",
    List<String>? letters,
    this.count = 10,
    this.timed = false,
    this.sound = true,
    this.gameScore = 700,
  }) : letters = letters ?? List<String>.from(kAllLetterChars);

  factory Settings.defaults() => Settings(letters: List<String>.from(kAllLetterChars));

  Settings copy() => Settings(
        lang: lang,
        level: level,
        mode: mode,
        letters: List<String>.from(letters),
        count: count,
        timed: timed,
        sound: sound,
        gameScore: gameScore,
      );

  Map<String, dynamic> toJson() => {
        "lang": lang,
        "level": level,
        "mode": mode,
        "letters": letters,
        "count": count,
        "timed": timed,
        "sound": sound,
        "gameScore": gameScore,
      };

  /// Mirrors loadSettings()'s validation/fallback logic exactly: any field
  /// that fails validation silently falls back to its default rather than
  /// leaving the app in a broken state (e.g. after a data-shape change).
  factory Settings.fromJson(Map<String, dynamic> json) {
    final defaults = Settings.defaults();
    final rawLetters = json["letters"];
    final letters = (rawLetters is List)
        ? rawLetters.whereType<String>().where(kAllLetterChars.contains).toList()
        : <String>[];
    final level = kLevels.contains(json["level"]) ? json["level"] as String : defaults.level;
    final modes = validModes(level);
    final mode = modes.contains(json["mode"]) ? json["mode"] as String : modes.first;
    final lang = kLanguages.contains(json["lang"]) ? json["lang"] as String : defaults.lang;
    final count = kCountOptions.contains(json["count"]) ? json["count"] as int : defaults.count;
    final gameScore = kGameScoreOptions.contains(json["gameScore"]) ? json["gameScore"] as int : defaults.gameScore;
    return Settings(
      lang: lang,
      level: level,
      mode: mode,
      letters: letters.isNotEmpty ? letters : List<String>.from(kAllLetterChars),
      count: count,
      timed: json["timed"] == true,
      sound: json["sound"] != false,
      gameScore: gameScore,
    );
  }
}
