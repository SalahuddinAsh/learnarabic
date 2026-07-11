import 'package:flutter/material.dart';

import '../data/strings.dart';
import '../models/quiz_result.dart';
import '../models/settings.dart';
import '../theme.dart';
import '../widgets/app_card.dart';
import '../widgets/big_button.dart';

/// Mirrors finishQuiz()'s DOM updates and the #screen-results markup: stars,
/// score/1000, correct count, best/new-record line, cheer text, missed-item
/// review list, and the play-again/game/settings buttons.
class ResultsScreen extends StatelessWidget {
  final Settings settings;
  final QuizResult result;
  final VoidCallback onPlayGame;
  final VoidCallback onAgain;
  final VoidCallback onSettings;

  const ResultsScreen({
    super.key,
    required this.settings,
    required this.result,
    required this.onPlayGame,
    required this.onAgain,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final t = kStrings[settings.lang]!;
    final dir = settings.lang == "ar" ? TextDirection.rtl : TextDirection.ltr;
    final starsText = result.stars > 0 ? "⭐" * result.stars : "🌱";

    return AppScreenBackground(
      child: Center(
        child: SingleChildScrollView(
          child: AppCard(
            child: Directionality(
              textDirection: dir,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: Text(starsText, style: const TextStyle(fontSize: 44, letterSpacing: 6))),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(t.s("score"), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: "${result.score} ", style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: AppColors.teal)),
                            const TextSpan(text: "/ 1000", style: TextStyle(fontSize: 19, color: AppColors.textFaint, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        "✓ ${result.correctCount} / ${result.total}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.goodDark),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      result.isNewRecord ? t.s("newRecord") : "${t.s("best")}: ${result.best}",
                      style: TextStyle(
                        fontSize: result.isNewRecord ? 18 : 15,
                        fontWeight: FontWeight.w700,
                        color: result.isNewRecord ? AppColors.record : AppColors.textFaint,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      t.s("cheer${result.stars}"),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (result.missed.isNotEmpty) _MissedReview(t: t, result: result),
                  if (result.canPlayGame) ...[
                    BigButton(label: t.s("gamePlay"), onTap: onPlayGame, gradient: AppColors.gameBtnGradient),
                    const SizedBox(height: 10),
                  ],
                  BigButton(label: t.s("again"), onTap: onAgain),
                  const SizedBox(height: 10),
                  BigButton(label: t.s("settings"), onTap: onSettings, secondary: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MissedReview extends StatelessWidget {
  final L10n t;
  final QuizResult result;
  const _MissedReview({required this.t, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F8),
        border: Border.all(color: const Color(0xFFFFDBE1), width: 2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.s("review"), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.badDark)),
          const SizedBox(height: 6),
          for (final m in result.missed)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                "${m.answerText} ${m.reveal ?? ""}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textMid),
              ),
            ),
        ],
      ),
    );
  }
}
