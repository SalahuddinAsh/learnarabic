import 'package:flutter/material.dart';
import '../logic/quiz_controller.dart';
import '../models/question.dart';
import '../theme.dart';

/// Connect (words) mode: drag each word card onto its matching picture card —
/// mirrors renderConnect()/onConnectDrop() in app.js. Pictures and words are
/// each shuffled independently, same as the original.
class ConnectBoard extends StatefulWidget {
  final QuizController quiz;
  const ConnectBoard({super.key, required this.quiz});

  @override
  State<ConnectBoard> createState() => _ConnectBoardState();
}

class _ConnectBoardState extends State<ConnectBoard> {
  String? _seenKey;
  late List<ConnectPair> _picOrder;
  late List<ConnectPair> _wordOrder;

  void _shuffleIfNeeded() {
    final q = widget.quiz.current;
    if (_seenKey != q.key) {
      _seenKey = q.key;
      _picOrder = List.of(q.pairs!)..shuffle();
      _wordOrder = List.of(q.pairs!)..shuffle();
    }
  }

  @override
  Widget build(BuildContext context) {
    _shuffleIfNeeded();
    final quiz = widget.quiz;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Column(children: [for (final p in _picOrder) _PicCard(pair: p, quiz: quiz)])),
          const SizedBox(width: 12),
          Expanded(child: Column(children: [for (final p in _wordOrder) _WordCard(pair: p, quiz: quiz)])),
        ],
      ),
    );
  }
}

class _PicCard extends StatelessWidget {
  final ConnectPair pair;
  final QuizController quiz;
  const _PicCard({required this.pair, required this.quiz});

  @override
  Widget build(BuildContext context) {
    final paired = quiz.pairedBare.contains(pair.bare);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DragTarget<String>(
        onWillAcceptWithDetails: (_) => !paired && !quiz.locked,
        onAcceptWithDetails: (details) => quiz.connectDrop(details.data, pair.bare),
        builder: (context, candidateData, rejectedData) {
          return Container(
            height: 68,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: paired ? AppColors.goodBg : AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: paired ? Border.all(color: AppColors.good, width: 3) : null,
              boxShadow: paired
                  ? null
                  : [BoxShadow(color: AppColors.teal.withValues(alpha: 0.22), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Text(paired ? "${pair.emoji} ✓" : pair.emoji, style: const TextStyle(fontSize: 38)),
          );
        },
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  final ConnectPair pair;
  final QuizController quiz;
  const _WordCard({required this.pair, required this.quiz});

  @override
  Widget build(BuildContext context) {
    final paired = quiz.pairedBare.contains(pair.bare);
    final card = Container(
      height: 68,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: paired ? AppColors.goodBg : AppColors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: paired
            ? null
            : [BoxShadow(color: AppColors.teal.withValues(alpha: 0.22), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Text(
        pair.vocalized,
        textDirection: TextDirection.rtl,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: paired ? AppColors.goodDark : AppColors.textDark),
      ),
    );
    final wrapped = Padding(padding: const EdgeInsets.only(bottom: 10), child: card);
    if (paired || quiz.locked) {
      return Opacity(opacity: paired ? 0.85 : 1, child: IgnorePointer(child: wrapped));
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Draggable<String>(
        data: pair.bare,
        feedback: Material(color: Colors.transparent, child: SizedBox(width: 150, child: card)),
        childWhenDragging: Opacity(opacity: 0.35, child: card),
        child: card,
      ),
    );
  }
}
