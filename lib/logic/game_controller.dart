import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/letters.dart';
import '../data/words.dart';
import '../models/falling_item.dart';
import '../models/settings.dart';
import '../services/high_scores.dart';
import '../services/weak_memory.dart';
import 'question_generator.dart';

enum GameKind { letters, word }

/// Falling Pictures reward game — mirrors the `game` object and
/// startGame/gameTick/spawnItem/onLetterKey/zapItem/itemLanded/endGame
/// functions in app.js. Driven by a 60fps Timer computing a delta-time step,
/// same as the original's requestAnimationFrame loop.
class GameController extends ChangeNotifier {
  final Settings settings;
  final GameKind kind;
  final List<String> pool;
  final List<String> weakL;
  final List<String> weakW;

  int score = 0;
  int lives = 3;
  final List<FallingItem> items = [];
  final List<FallingItem> boomingItems = [];
  String entry = "";
  double speed;
  double spawnEvery;
  final int maxItems;
  double sinceSpawn;
  bool over = false;
  double skyHeight = 400;

  List<String> letterPanel = [];
  List<String> wordPanelKeys = [];
  final Set<int> usedWordPanelIndices = {};

  bool isNewRecord = false;
  int bestScore = 0;

  bool _disposed = false;
  final Random _rng = Random();
  Timer? _ticker;
  DateTime? _prevTick;

  void Function()? onZap;
  void Function()? onBad;
  void Function()? onKeyTick;

  GameController(this.settings, QuestionConfig cfg)
      : kind = settings.level == "letters" ? GameKind.letters : GameKind.word,
        pool = cfg.letterPool,
        weakL = cfg.weak.letters,
        weakW = cfg.weak.words,
        speed = settings.level == "letters" ? 22 : 13,
        spawnEvery = settings.level == "letters" ? 3300 : 1200,
        maxItems = settings.level == "letters" ? 3 : 1,
        sinceSpawn = 2800;

  void start() {
    if (kind == GameKind.letters) _refreshLetterPanel();
    _prevTick = DateTime.now();
    _ticker = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
    notifyListeners();
  }

  void setSkyHeight(double h) => skyHeight = h;

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  void _tick() {
    if (over || _disposed) return;
    final now = DateTime.now();
    final dt = (now.difference(_prevTick!).inMicroseconds / 1e6).clamp(0.0, 0.1);
    _prevTick = now;
    sinceSpawn += dt * 1000;
    if (sinceSpawn >= spawnEvery && items.length < maxItems) {
      _spawnItem();
      sinceSpawn = 0;
    }
    for (final it in List<FallingItem>.of(items)) {
      it.y += speed * dt;
      if (it.y > skyHeight - 110) _itemLanded(it);
    }
    notifyListeners();
  }

  void _spawnItem() {
    WordEntry w;
    if (kind == GameKind.letters) {
      final c = (weakL.isNotEmpty && _rng.nextDouble() < kWeakBias) ? pick(weakL) : pick(pool);
      final candidates = kWords.where((x) => x.bare.substring(0, 1) == c && !items.any((it) => it.emoji == x.emoji)).toList();
      if (candidates.isEmpty) return;
      w = pick(candidates);
    } else {
      final poolW = kWords.where((x) => x.bare.length <= 5).toList();
      if (weakW.isNotEmpty && _rng.nextDouble() < kWeakBias) {
        final target = pick(weakW);
        final match = poolW.where((x) => x.bare == target);
        w = match.isNotEmpty ? match.first : pick(poolW);
      } else {
        w = pick(poolW);
      }
    }
    final item = FallingItem(letterChar: w.bare.substring(0, 1), bare: w.bare, emoji: w.emoji, leftPercent: 5 + _rng.nextDouble() * 65, y: -130);
    items.add(item);
    if (kind == GameKind.letters) {
      _refreshLetterPanel();
    } else {
      _buildWordPanel(w);
    }
  }

  void _buildWordPanel(WordEntry w) {
    entry = "";
    var keys = shuffle(w.bare.split(""));
    for (var i = 0; i < 10 && keys.join() == w.bare && w.bare.length > 1; i++) {
      keys = shuffle(w.bare.split(""));
    }
    wordPanelKeys = keys;
    usedWordPanelIndices.clear();
  }

  void _refreshLetterPanel() {
    final need = items.map((it) => it.letterChar).toSet().toList();
    final fillers = <String>[];
    for (final c in need) {
      final l = letterByChar(c);
      if (l == null) continue;
      for (final x in kLetters) {
        if (x.group == l.group && x.char != c) fillers.add(x.char);
      }
    }
    fillers.addAll(shuffle(pool));
    fillers.addAll(shuffle(kAllLetterChars));
    final taken = need.toSet();
    final letters = [...need, ...takeDistinct(taken, fillers, 8 - need.length)];
    letterPanel = shuffle(letters);
  }

  /// Letters-kind tap: hits the lowest (most urgent) falling item starting
  /// with [c]. Returns whether it was a hit, so the UI can flash the key red.
  bool tapLetterKey(String c) {
    if (over) return true;
    final hits = items.where((it) => it.letterChar == c).toList()..sort((a, b) => b.y.compareTo(a.y));
    if (hits.isNotEmpty) {
      _zapItem(hits.first);
      WeakMemory.recordResult("L:$c", true);
      return true;
    }
    onBad?.call();
    return false;
  }

  /// Word-kind tap: spells the single falling word letter by letter, in
  /// order, tracking which pool-panel index was already used.
  bool tapWordKey(int index) {
    if (over || usedWordPanelIndices.contains(index) || items.isEmpty) return true;
    final it = items.first;
    final c = wordPanelKeys[index];
    if (entry.length < it.bare.length && c == it.bare.substring(entry.length, entry.length + 1)) {
      usedWordPanelIndices.add(index);
      entry += c;
      onKeyTick?.call();
      if (entry == it.bare) {
        _zapItem(it);
        WeakMemory.recordResult("W:${it.bare}", true);
      }
      notifyListeners();
      return true;
    }
    onBad?.call();
    return false;
  }

  void _zapItem(FallingItem it) {
    _boom(it);
    if (kind == GameKind.letters) {
      score += 10;
      speed += 1.2;
      spawnEvery = spawnEvery - 55 < 1500 ? 1500 : spawnEvery - 55;
      _refreshLetterPanel();
    } else {
      score += 10 + 2 * it.bare.length;
      speed += 1.0;
      entry = "";
      wordPanelKeys = [];
      usedWordPanelIndices.clear();
    }
    onZap?.call();
    notifyListeners();
  }

  void _itemLanded(FallingItem it) {
    _boom(it);
    WeakMemory.recordResult(kind == GameKind.letters ? "L:${it.letterChar}" : "W:${it.bare}", false);
    lives--;
    onBad?.call();
    if (lives <= 0) {
      _endGame();
      return;
    }
    for (final other in List<FallingItem>.of(items)) {
      items.remove(other);
    }
    entry = "";
    wordPanelKeys = [];
    usedWordPanelIndices.clear();
    sinceSpawn = -1500;
    if (kind == GameKind.letters) _refreshLetterPanel();
  }

  void _boom(FallingItem it) {
    items.remove(it);
    boomingItems.add(it);
    Timer(const Duration(milliseconds: 400), () {
      boomingItems.remove(it);
      notifyListeners();
    });
  }

  void _endGame() {
    over = true;
    _ticker?.cancel();
    isNewRecord = HighScores.recordIfBest("fall", score);
    bestScore = HighScores.bestFor("fall");
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker?.cancel();
    super.dispose();
  }
}
