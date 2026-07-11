import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/strings.dart';
import '../logic/quiz_controller.dart';
import '../models/question.dart';
import '../theme.dart';
import '../widgets/app_card.dart';
import '../widgets/build_tiles.dart';
import '../widgets/connect_board.dart';
import '../widgets/grade_buttons.dart';
import '../widgets/order_board.dart';

/// Hosts the shared chrome (quit/progress/score, timer bar, instruction,
/// prompt, feedback) and swaps its answer area by mode — mirrors
/// nextQuestion()'s DOM updates in app.js. Cards grid (match/missing) is
/// implemented here; build/connect/read areas land in later tasks.
class QuizScreen extends StatelessWidget {
  final QuizController quiz;
  final VoidCallback onQuit;
  final VoidCallback onFinished;

  const QuizScreen({super.key, required this.quiz, required this.onQuit, required this.onFinished});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: quiz,
      child: Consumer<QuizController>(
        builder: (context, q, _) {
          if (q.result != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) => onFinished());
          }
          final t = kStrings[q.settings.lang]!;
          // Only the localized chrome (instruction/feedback text) follows the UI
          // language; the question content (prompt/cards/tiles/connect/order) is
          // Arabic and stays RTL regardless — mirrors dir="rtl" hardcoded on
          // #prompt/#built/#cards/#tiles/#connect/#order in index.html.
          final uiDir = q.settings.lang == "ar" ? TextDirection.rtl : TextDirection.ltr;

          return AppScreenBackground(
            child: Column(
              children: [
                _TopBar(quiz: q, onQuit: onQuit),
                const SizedBox(height: 10),
                if (!q.isUntimed) _TimeBar(quiz: q),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _QuestionArea(quiz: q, t: t, uiDir: uiDir),
                            const SizedBox(height: 16),
                            Directionality(textDirection: TextDirection.rtl, child: _AnswerArea(quiz: q)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final QuizController quiz;
  final VoidCallback onQuit;
  const _TopBar({required this.quiz, required this.onQuit});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _RoundIconButton(icon: "✕", onTap: onQuit),
          Text(
            "${quiz.progressCurrent} / ${quiz.progressTotal}",
            style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(14)),
            child: Text("⭐ ${quiz.scoreRounded}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(width: 44, height: 44, child: Center(child: Text(icon, style: const TextStyle(color: Colors.white, fontSize: 18)))),
      ),
    );
  }
}

class _TimeBar extends StatelessWidget {
  final QuizController quiz;
  const _TimeBar({required this.quiz});

  @override
  Widget build(BuildContext context) {
    final frac = quiz.timerFraction.clamp(0.0, 1.0);
    final color = frac < 0.25 ? AppColors.bad : (frac < 0.5 ? const Color(0xFFFFC542) : AppColors.good);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 22,
                  color: Colors.white.withValues(alpha: 0.3),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: frac,
                    child: Container(color: color),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 34,
              child: Text(
                "${quiz.timeLeftSeconds}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionArea extends StatelessWidget {
  final QuizController quiz;
  final L10n t;
  final TextDirection uiDir;
  const _QuestionArea({required this.quiz, required this.t, required this.uiDir});

  @override
  Widget build(BuildContext context) {
    final q = quiz.current;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.teal.withValues(alpha: 0.25), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Directionality(
            textDirection: uiDir,
            child: Text(
              t.s(q.insKey),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 8),
          Directionality(textDirection: TextDirection.rtl, child: _Prompt(quiz: quiz)),
          if (q.mode == "build") ...[
            const SizedBox(height: 12),
            Directionality(textDirection: TextDirection.rtl, child: _BuiltBox(quiz: quiz)),
          ],
          const SizedBox(height: 10),
          Directionality(
            textDirection: uiDir,
            child: SizedBox(
              width: double.infinity,
              child: Text(
                quiz.feedbackText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: quiz.feedback == FeedbackKind.good
                      ? AppColors.goodDark
                      : (quiz.feedback == FeedbackKind.bad ? AppColors.badDark : AppColors.textMuted),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Prompt extends StatelessWidget {
  final QuizController quiz;
  const _Prompt({required this.quiz});

  @override
  Widget build(BuildContext context) {
    final q = quiz.current;
    if (q.missingWord) {
      return Column(
        children: [
          Text(q.promptEmoji ?? "", style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 6),
          Text(q.prompt ?? "", style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800, letterSpacing: 2)),
        ],
      );
    }
    final hasEmoji = (q.promptEmoji ?? "").isNotEmpty;
    // onGrade()'s decorate: once graded, the reveal (emoji/example) is appended to the prompt.
    final revealed = q.mode == "read" && quiz.locked && (q.reveal ?? "").isNotEmpty;
    final text = revealed ? "${q.prompt} ${q.reveal}" : (q.promptEmoji ?? q.prompt ?? "");
    double fontSize = 40;
    if (hasEmoji) {
      fontSize = 72;
    } else if (q.mode == "read" && !q.sent) {
      fontSize = 56;
    } else if (q.sent && q.mode == "read") {
      fontSize = 28;
    }
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800, height: 1.5),
    );
  }
}

class _BuiltBox extends StatelessWidget {
  final QuizController quiz;
  const _BuiltBox({required this.quiz});

  @override
  Widget build(BuildContext context) {
    final ok = quiz.builtOk, no = quiz.builtNo;
    return Container(
      constraints: const BoxConstraints(minHeight: 70, maxWidth: 340),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ok ? AppColors.goodBg : (no ? AppColors.badBg : AppColors.chipSoftBg2),
        border: Border.all(color: ok ? AppColors.good : (no ? AppColors.bad : const Color(0xFF99DCD2)), width: 3, style: ok || no ? BorderStyle.solid : BorderStyle.solid),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        quiz.builtText,
        style: TextStyle(
          fontSize: quiz.current.sent ? 24 : 34,
          fontWeight: FontWeight.w800,
          color: ok ? AppColors.goodDark : (no ? AppColors.badDark : AppColors.teal),
        ),
      ),
    );
  }
}

class _AnswerArea extends StatelessWidget {
  final QuizController quiz;
  const _AnswerArea({required this.quiz});

  @override
  Widget build(BuildContext context) {
    final q = quiz.current;
    if (q.cards != null) return _CardsGrid(quiz: quiz);
    if (q.mode == "build") return BuildTiles(quiz: quiz);
    if (q.mode == "connect" && q.level == "words") return ConnectBoard(quiz: quiz);
    if (q.mode == "connect" && q.level == "sent") return OrderBoard(quiz: quiz);
    if (q.mode == "read") return GradeButtons(quiz: quiz);
    return const SizedBox.shrink();
  }
}

class _CardsGrid extends StatefulWidget {
  final QuizController quiz;
  const _CardsGrid({required this.quiz});

  @override
  State<_CardsGrid> createState() => _CardsGridState();
}

class _CardsGridState extends State<_CardsGrid> {
  String? _tapped;
  String? _seenQuestionKey;

  @override
  Widget build(BuildContext context) {
    final q = widget.quiz.current;
    if (_seenQuestionKey != q.key) {
      _seenQuestionKey = q.key;
      _tapped = null;
    }
    final cards = q.cards!;
    final crossAxisCount = cards.length > 4 ? 3 : 2;
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: q.emojiCards ? 1.15 : 1.7,
      children: [
        for (final c in cards)
          _AnswerCardTile(
            card: c,
            emoji: q.emojiCards,
            revealRight: widget.quiz.locked && c.text == q.answerText,
            showWrong: widget.quiz.locked && _tapped == c.text && !c.ok,
            onTap: () {
              if (widget.quiz.locked) return;
              setState(() => _tapped = c.text);
              widget.quiz.answerCard(c);
            },
          ),
      ],
    );
  }
}

class _AnswerCardTile extends StatelessWidget {
  final AnswerCard card;
  final bool emoji;
  final bool revealRight;
  final bool showWrong;
  final VoidCallback onTap;

  const _AnswerCardTile({
    required this.card,
    required this.emoji,
    required this.revealRight,
    required this.showWrong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = revealRight ? AppColors.good : (showWrong ? AppColors.bad : AppColors.card);
    final fg = (revealRight || showWrong) ? Colors.white : AppColors.textDark;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Center(
          child: Text(
            card.text,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: emoji ? 48 : 32, fontWeight: FontWeight.w800, color: fg),
          ),
        ),
      ),
    );
  }
}
