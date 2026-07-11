import 'package:flutter/material.dart';
import '../logic/quiz_controller.dart';
import '../theme.dart';

/// Connect (sentence order) mode: drag word tiles into ordered slots, or tap
/// a filled slot to send its word back to the pool — mirrors
/// renderOrder()/onOrderDrop() in app.js.
class OrderBoard extends StatelessWidget {
  final QuizController quiz;
  const OrderBoard({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    final q = quiz.current;
    final tiles = q.tiles!;
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [for (var i = 0; i < quiz.slotTileIndex.length; i++) _Slot(index: i, quiz: quiz)],
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < tiles.length; i++)
              quiz.usedTileIndices.contains(i)
                  ? Visibility(
                      visible: false,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: _PoolTileContent(word: tiles[i]),
                    )
                  : _PoolTile(index: i, word: tiles[i], quiz: quiz),
          ],
        ),
      ],
    );
  }
}

class _Slot extends StatelessWidget {
  final int index;
  final QuizController quiz;
  const _Slot({required this.index, required this.quiz});

  @override
  Widget build(BuildContext context) {
    final tileIndex = quiz.slotTileIndex[index];
    final filled = tileIndex != null;
    final word = filled ? quiz.current.tiles![tileIndex] : null;
    return DragTarget<int>(
      onWillAcceptWithDetails: (_) => !filled && !quiz.locked,
      onAcceptWithDetails: (details) => quiz.orderPlaceTile(details.data, index),
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onTap: (filled && !quiz.locked) ? () => quiz.orderRecallSlot(index) : null,
          child: Container(
            constraints: const BoxConstraints(minWidth: 78, minHeight: 58),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: filled ? AppColors.card : Colors.white.withValues(alpha: 0.55),
              border: Border.all(color: filled ? AppColors.teal : const Color(0xFFB5E6DE), width: 3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Text(
                word ?? "",
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0D6E63)),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PoolTile extends StatelessWidget {
  final int index;
  final String word;
  final QuizController quiz;
  const _PoolTile({required this.index, required this.word, required this.quiz});

  @override
  Widget build(BuildContext context) {
    final content = _PoolTileContent(word: word);
    if (quiz.locked) return content;
    return Draggable<int>(
      data: index,
      feedback: Material(color: Colors.transparent, child: content),
      childWhenDragging: Opacity(opacity: 0.35, child: content),
      child: content,
    );
  }
}

class _PoolTileContent extends StatelessWidget {
  final String word;
  const _PoolTileContent({required this.word});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.teal.withValues(alpha: 0.22), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Text(
        word,
        textDirection: TextDirection.rtl,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark),
      ),
    );
  }
}
