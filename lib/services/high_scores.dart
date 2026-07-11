import 'storage.dart';

/// Per-mode/level (and per-game) best scores — mirrors loadBest/saveBest in app.js.
class HighScores {
  static const _storageKey = "readstars-best";

  static Map<String, int> load() {
    final json = Storage.getJson(_storageKey);
    if (json == null) return {};
    return json.map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  /// Records [score] under [key] if it beats the existing best. Returns true
  /// if this was a new record.
  static bool recordIfBest(String key, int score) {
    final best = load();
    final prev = best[key] ?? 0;
    if (score > prev) {
      best[key] = score;
      Storage.setJson(_storageKey, best);
      return true;
    }
    return false;
  }

  static int bestFor(String key) => load()[key] ?? 0;
}
