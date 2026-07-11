import '../data/ayahs.dart';
import '../data/sentences.dart';
import '../data/words.dart';
import 'storage.dart';

/// Weighted lists of weak targets usable with the current settings — mirrors
/// weakTargets(cfg) in app.js. Keys: `L:letter`, `W:bare word`, `T:sentence idx`, `A:ayah idx`.
class WeakTargets {
  final List<String> letters;
  final List<String> words;
  final List<String> sentenceIdx;
  final List<String> ayahIdx;
  const WeakTargets({
    required this.letters,
    required this.words,
    required this.sentenceIdx,
    required this.ayahIdx,
  });
}

/// Tracks items the kid gets wrong, drawn more often in future questions,
/// and worked back down on success — mirrors loadWeak/saveWeak/recordResult
/// in app.js exactly (same key scheme, same cap-at-5 / delete-at-0 behavior).
class WeakMemory {
  static const _storageKey = "readstars-weak";

  static Map<String, int> _load() {
    final json = Storage.getJson(_storageKey);
    if (json == null) return {};
    return json.map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  static void _save(Map<String, int> w) {
    Storage.setJson(_storageKey, w);
  }

  static void recordResult(String? key, bool correct) {
    if (key == null || key.isEmpty) return;
    final w = _load();
    if (correct) {
      if (w.containsKey(key)) {
        final next = w[key]! - 1;
        if (next <= 0) {
          w.remove(key);
        } else {
          w[key] = next;
        }
        _save(w);
      }
    } else {
      w[key] = ((w[key] ?? 0) + 1).clamp(0, 5);
      _save(w);
    }
  }

  static WeakTargets targets({required List<String> letterPool}) {
    final w = _load();
    final letters = <String>[];
    final words = <String>[];
    final sentenceIdx = <String>[];
    final ayahIdx = <String>[];
    for (final key in w.keys) {
      final kind = key[0];
      final val = key.substring(2);
      bool ok = false;
      if (kind == "L") {
        ok = letterPool.contains(val);
      } else if (kind == "W") {
        ok = kWords.any((x) => x.bare == val);
      } else if (kind == "T") {
        final i = int.tryParse(val);
        ok = i != null && i >= 0 && i < kSentences.length;
      } else if (kind == "A") {
        final i = int.tryParse(val);
        ok = i != null && i >= 0 && i < kAyahs.length;
      }
      if (!ok) continue;
      final count = w[key]!;
      final target = switch (kind) {
        "L" => letters,
        "W" => words,
        "T" => sentenceIdx,
        "A" => ayahIdx,
        _ => null,
      };
      if (target != null) {
        for (var i = 0; i < count; i++) {
          target.add(val);
        }
      }
    }
    return WeakTargets(letters: letters, words: words, sentenceIdx: sentenceIdx, ayahIdx: ayahIdx);
  }
}
