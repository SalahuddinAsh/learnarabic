import 'package:flutter/material.dart';
import '../logic/quiz_controller.dart';
import '../theme.dart';

/// Build mode: tap letter/word tiles in order + a backspace tile —
/// mirrors buildTiles()/onTile() in app.js.
class BuildTiles extends StatelessWidget {
  final QuizController quiz;
  const BuildTiles({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    final q = quiz.current;
    final tiles = q.tiles!;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        for (var i = 0; i < tiles.length; i++)
          _Tile(
            label: tiles[i],
            sent: q.sent,
            used: quiz.builtTileIndices.contains(i),
            onTap: quiz.locked ? null : () => quiz.tapTile(i),
          ),
        _BackspaceTile(onTap: (quiz.locked || quiz.builtTileIndices.isEmpty) ? null : quiz.backspaceTile),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final bool sent;
  final bool used;
  final VoidCallback? onTap;
  const _Tile({required this.label, required this.sent, required this.used, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: used ? 0.25 : 1,
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        elevation: 3,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: used ? null : onTap,
          child: Container(
            constraints: BoxConstraints(minWidth: sent ? 0 : 64, minHeight: 64),
            padding: EdgeInsets.symmetric(horizontal: sent ? 16 : 10, vertical: sent ? 8 : 6),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Text(
                label,
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: sent ? 22 : 30, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackspaceTile extends StatelessWidget {
  final VoidCallback? onTap;
  const _BackspaceTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.25 : 1,
      child: Material(
        color: const Color(0xFFFFE9D6),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: const SizedBox(
            width: 64,
            height: 64,
            child: Center(child: Text("⌫", style: TextStyle(fontSize: 26, color: Color(0xFFE07B1D), fontWeight: FontWeight.w800))),
          ),
        ),
      ),
    );
  }
}
