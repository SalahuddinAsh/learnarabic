import 'question.dart';

/// Summary shown on the results screen — mirrors the values finishQuiz() computes in app.js.
class QuizResult {
  final int score; // out of 1000
  final int total;
  final int correctCount;
  final int stars; // 0-3
  final List<Question> missed;
  final bool isNewRecord;
  final int best;
  final bool canPlayGame;

  const QuizResult({
    required this.score,
    required this.total,
    required this.correctCount,
    required this.stars,
    required this.missed,
    required this.isNewRecord,
    required this.best,
    required this.canPlayGame,
  });
}
