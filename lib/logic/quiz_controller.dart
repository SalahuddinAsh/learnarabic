import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/strings.dart';
import '../models/question.dart';
import '../models/quiz_result.dart';
import '../models/settings.dart';
import '../services/high_scores.dart';
import '../services/weak_memory.dart';
import 'question_generator.dart';

enum FeedbackKind { none, good, bad }

/// Drives one round of quiz play — mirrors the `quiz` object and its
/// startQuiz/nextQuestion/finishAnswer/onTimeout/advance/finishQuiz functions
/// in app.js. Pure state/logic; screens (Task 5-9) render off of it.
///
/// Sound hooks (onGood/onBad/onTick/onPairMatched) are left for the UI layer
/// to wire to audioplayers, matching app.js's soundGood/soundBad/soundTick/
/// beep([880]) call sites.
class QuizController extends ChangeNotifier {
  final Settings settings;
  final List<Question> questions;
  final bool gameEligible;
  final String bestKey;

  int index = 0;
  int correct = 0;
  double points = 0;
  final List<Question> missed = [];
  QuizResult? result;

  bool locked = false;
  FeedbackKind feedback = FeedbackKind.none;
  String feedbackText = "";

  // build mode: indices into current.tiles, in tap order
  List<int> builtTileIndices = [];
  String builtText = "";
  bool builtOk = false;
  bool builtNo = false;

  // connect (words) mode
  int pairsDone = 0;
  int connectMistakes = 0;
  final Set<String> wrongWords = {};

  // connect (sentence order) mode: slotTileIndex[slot] = index into current.tiles, or null if empty
  List<int?> slotTileIndex = [];
  final Set<int> usedTileIndices = {};

  // timer
  Timer? _timer;
  Timer? _advanceTimer;
  DateTime? _timerStart;
  double _timerTotalMs = 1;
  int timeLeftSeconds = 0;
  double timerFraction = 1.0;

  void Function()? onGood;
  void Function()? onBad;
  void Function()? onTick;
  void Function()? onPairMatched;

  QuizController(this.settings, QuestionConfig cfg)
      : questions = _generateQuestions(settings, cfg),
        gameEligible = settings.mode != "read",
        bestKey = "${settings.mode}:${settings.level}";

  // One shared `recent` list across the whole round, matching app.js's
  // `Array.from({length: settings.count}, () => genQuestion(cfg, recent))` —
  // this is what lets genQuestion avoid repeating the last 4 keys.
  static List<Question> _generateQuestions(Settings settings, QuestionConfig cfg) {
    final recent = <String>[];
    return List.generate(settings.count, (_) => genQuestion(cfg, recent), growable: false);
  }

  Question get current => questions[index];
  L10n get _t => kStrings[settings.lang]!;
  bool get isUntimed => current.mode == "read" || !settings.timed;
  int get progressCurrent => index + 1;
  int get progressTotal => questions.length;
  int get scoreRounded => points.round();

  void start() => _beginQuestion();

  void _beginQuestion() {
    locked = false;
    builtTileIndices = [];
    builtText = "";
    builtOk = false;
    builtNo = false;
    pairsDone = 0;
    connectMistakes = 0;
    wrongWords.clear();
    usedTileIndices.clear();
    slotTileIndex = (current.mode == "connect" && current.level == "sent")
        ? List<int?>.filled(current.tiles!.length, null)
        : [];
    feedback = FeedbackKind.none;
    feedbackText = "";

    if (isUntimed) {
      _stopTimer();
      _timerStart = DateTime.now();
      _timerTotalMs = double.infinity;
      timeLeftSeconds = 0;
      timerFraction = 1.0;
    } else {
      _startTimer(timeForQ(current));
    }
    notifyListeners();
  }

  void _startTimer(int seconds) {
    _stopTimer();
    final totalMs = seconds * 1000.0;
    _timerTotalMs = totalMs;
    _timerStart = DateTime.now();
    timeLeftSeconds = seconds;
    timerFraction = 1.0;
    var lastTick = -1;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final elapsed = DateTime.now().difference(_timerStart!).inMilliseconds;
      final left = totalMs - elapsed;
      final frac = (left / totalMs).clamp(0.0, 1.0);
      final secLeft = (left / 1000).ceil().clamp(0, 999);
      timerFraction = frac;
      timeLeftSeconds = secLeft;
      if (secLeft <= 5 && secLeft >= 1 && secLeft != lastTick) {
        lastTick = secLeft;
        onTick?.call();
      }
      notifyListeners();
      if (left <= 0) {
        _stopTimer();
        _onTimeout();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// match/missing modes: tap an answer card.
  void answerCard(AnswerCard c) {
    if (locked) return;
    _finishAnswer(c.ok);
  }

  /// build mode: tap the next letter/word tile.
  void tapTile(int tileIndex) {
    if (locked || builtTileIndices.contains(tileIndex)) return;
    builtTileIndices.add(tileIndex);
    builtText = builtTileIndices.map((i) => current.tiles![i]).join(current.joiner);
    notifyListeners();
    if (builtTileIndices.length == current.tiles!.length) {
      final good = current.accepted!.contains(builtText);
      _finishAnswer(good, builtText: builtText);
    }
  }

  /// build mode: remove the last-tapped tile.
  void backspaceTile() {
    if (locked || builtTileIndices.isEmpty) return;
    builtTileIndices.removeLast();
    builtText = builtTileIndices.map((i) => current.tiles![i]).join(current.joiner);
    notifyListeners();
  }

  /// connect (words) mode: a word tile with bare form [draggedBare] was
  /// dropped on a picture card with bare form [targetBare].
  void connectDrop(String draggedBare, String targetBare) {
    if (locked) return;
    if (draggedBare == targetBare) {
      pairsDone++;
      WeakMemory.recordResult("W:$draggedBare", !wrongWords.contains(draggedBare));
      onPairMatched?.call();
      notifyListeners();
      if (pairsDone == current.pairs!.length) {
        _finishAnswer(connectMistakes == 0);
      }
    } else {
      connectMistakes++;
      wrongWords.add(draggedBare);
      WeakMemory.recordResult("W:$draggedBare", false);
      onBad?.call();
      notifyListeners();
    }
  }

  /// connect (sentence order) mode: drop pool tile [tileIndex] onto slot [slotIndex].
  void orderPlaceTile(int tileIndex, int slotIndex) {
    if (locked) return;
    if (slotTileIndex[slotIndex] != null || usedTileIndices.contains(tileIndex)) return;
    slotTileIndex[slotIndex] = tileIndex;
    usedTileIndices.add(tileIndex);
    notifyListeners();
    if (slotTileIndex.every((i) => i != null)) {
      final text = slotTileIndex.map((i) => current.tiles![i!]).join(" ");
      _finishAnswer(current.accepted!.contains(text));
    }
  }

  /// connect (sentence order) mode: tap a filled slot to send its tile back to the pool.
  void orderRecallSlot(int slotIndex) {
    if (locked) return;
    final tileIndex = slotTileIndex[slotIndex];
    if (tileIndex == null) return;
    usedTileIndices.remove(tileIndex);
    slotTileIndex[slotIndex] = null;
    notifyListeners();
  }

  /// read mode: the parent marks the child's reading as correct or not.
  void grade(bool good) {
    if (locked) return;
    _finishAnswer(good);
  }

  void _finishAnswer(bool good, {String? builtText}) {
    final elapsed = DateTime.now().difference(_timerStart!).inMicroseconds / 1000.0;
    final frac = (1 - elapsed / _timerTotalMs).clamp(0.0, double.infinity);
    _stopTimer();
    locked = true;

    if (current.mode == "build") {
      this.builtText = (good && current.sent) ? (builtText ?? this.builtText) : (current.targetShow ?? "");
      builtOk = good;
      builtNo = !good;
    }

    WeakMemory.recordResult(current.weakKey, good);
    if (good) {
      final maxPts = 1000 / questions.length;
      final pts = maxPts * (0.5 + 0.5 * (frac > 1.0 ? 1.0 : frac));
      correct++;
      points += pts;
      feedback = FeedbackKind.good;
      feedbackText = "${pick(_t.list("good"))} +${pts.round()} ${current.reveal ?? ""}".trim();
      onGood?.call();
      notifyListeners();
      _scheduleAdvance(1200);
    } else {
      missed.add(current);
      feedback = FeedbackKind.bad;
      feedbackText = "${_t.s("answerIs")}: ${current.answerText} ${current.reveal ?? ""}".trim();
      onBad?.call();
      notifyListeners();
      _scheduleAdvance(2300);
    }
  }

  void _onTimeout() {
    locked = true;
    missed.add(current);
    WeakMemory.recordResult(current.weakKey, false);
    feedback = FeedbackKind.bad;
    feedbackText = "${_t.s("timeUp")} ${_t.s("answerIs")}: ${current.answerText} ${current.reveal ?? ""}".trim();
    if (current.mode == "build") {
      builtText = current.targetShow ?? "";
      builtNo = true;
    }
    onBad?.call();
    notifyListeners();
    _scheduleAdvance(2300);
  }

  void _scheduleAdvance(int ms) {
    _advanceTimer?.cancel();
    _advanceTimer = Timer(Duration(milliseconds: ms), _advance);
  }

  void _advance() {
    index++;
    if (index >= questions.length) {
      _finish();
    } else {
      _beginQuestion();
    }
  }

  void _finish() {
    _stopTimer();
    final score = points.round();
    final stars = score >= 900 ? 3 : score >= 700 ? 2 : score >= 450 ? 1 : 0;
    final isNewRecord = HighScores.recordIfBest(bestKey, score);
    final best = HighScores.bestFor(bestKey);
    result = QuizResult(
      score: score,
      total: questions.length,
      correctCount: correct,
      stars: stars,
      missed: List.unmodifiable(missed),
      isNewRecord: isNewRecord,
      best: best,
      canPlayGame: gameEligible && settings.gameScore > 0 && score >= settings.gameScore,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimer();
    _advanceTimer?.cancel();
    super.dispose();
  }
}
