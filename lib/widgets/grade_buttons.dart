import 'package:flutter/material.dart';
import '../logic/quiz_controller.dart';
import '../theme.dart';

/// Read-to-me mode: the parent listens to the child read aloud, then marks
/// it right or wrong — mirrors the #grade ✗/✓ buttons and onGrade() in app.js.
class GradeButtons extends StatelessWidget {
  final QuizController quiz;
  const GradeButtons({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: [
          Expanded(child: _GradeButton(label: "✗", color: AppColors.bad, onTap: quiz.locked ? null : () => quiz.grade(false))),
          const SizedBox(width: 14),
          Expanded(child: _GradeButton(label: "✓", color: AppColors.good, onTap: quiz.locked ? null : () => quiz.grade(true))),
        ],
      ),
    );
  }
}

class _GradeButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _GradeButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: SizedBox(
            height: 96,
            child: Center(child: Text(label, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white))),
          ),
        ),
      ),
    );
  }
}
