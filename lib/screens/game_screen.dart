import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/strings.dart';
import '../logic/game_controller.dart';
import '../theme.dart';
import '../widgets/app_card.dart';
import '../widgets/big_button.dart';

/// Falling Pictures reward game — mirrors #screen-game: a sky of falling
/// pictures on parachutes, a lives/score HUD, and a bottom keyboard panel
/// (8 letters in letters-kind, or the falling word's shuffled letters in
/// word-kind). Game-over shows an overlay with score/best and a done button.
class GameScreen extends StatefulWidget {
  final GameController game;
  final VoidCallback onQuit;
  const GameScreen({super.key, required this.game, required this.onQuit});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    widget.game.start();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.game,
      child: Consumer<GameController>(
        builder: (context, game, _) {
          final t = kStrings[game.settings.lang]!;
          return AppScreenBackground(
            child: Column(
              children: [
                _TopBar(game: game, onQuit: widget.onQuit),
                const SizedBox(height: 10),
                Expanded(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          decoration: const BoxDecoration(gradient: AppColors.skyGradient),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              game.setSkyHeight(constraints.maxHeight);
                              return _Sky(game: game);
                            },
                          ),
                        ),
                      ),
                      if (game.over) _GameOverOverlay(game: game, t: t, onDone: widget.onQuit),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (game.kind == GameKind.word) _EntryBox(game: game),
                const SizedBox(height: 10),
                _KeysPanel(game: game),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final GameController game;
  final VoidCallback onQuit;
  const _TopBar({required this.game, required this.onQuit});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onQuit,
              child: const SizedBox(width: 44, height: 44, child: Center(child: Text("✕", style: TextStyle(color: Colors.white, fontSize: 18)))),
            ),
          ),
          Text(game.lives > 0 ? "❤️" * game.lives : "💔", style: const TextStyle(fontSize: 20)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(14)),
            child: Text("🪂 ${game.score}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
          ),
        ],
      ),
    );
  }
}

class _Sky extends StatelessWidget {
  final GameController game;
  const _Sky({required this.game});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            for (final it in game.items)
              Positioned(
                top: it.y,
                left: it.leftPercent / 100 * constraints.maxWidth,
                child: const _FallItem(chute: "🪂"),
              ),
            for (final it in game.boomingItems)
              Positioned(top: it.y, left: it.leftPercent / 100 * constraints.maxWidth, child: const _BoomItem()),
            for (final it in game.items)
              Positioned(
                top: it.y + 46,
                left: it.leftPercent / 100 * constraints.maxWidth,
                child: Text(it.emoji, style: const TextStyle(fontSize: 44)),
              ),
          ],
        );
      },
    );
  }
}

class _FallItem extends StatelessWidget {
  final String chute;
  const _FallItem({required this.chute});
  @override
  Widget build(BuildContext context) => Text(chute, style: const TextStyle(fontSize: 30));
}

class _BoomItem extends StatelessWidget {
  const _BoomItem();
  @override
  Widget build(BuildContext context) => const Text("💥", style: TextStyle(fontSize: 40));
}

class _EntryBox extends StatelessWidget {
  final GameController game;
  const _EntryBox({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 56, minWidth: 200, maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: const Color(0xFF99DCD2), width: 3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        game.entry.isEmpty ? " " : game.entry,
        textDirection: TextDirection.rtl,
        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.teal),
      ),
    );
  }
}

class _KeysPanel extends StatefulWidget {
  final GameController game;
  const _KeysPanel({required this.game});

  @override
  State<_KeysPanel> createState() => _KeysPanelState();
}

class _KeysPanelState extends State<_KeysPanel> {
  int? _flashIndex;

  void _flash(int index) {
    setState(() => _flashIndex = index);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted && _flashIndex == index) setState(() => _flashIndex = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final letters = game.kind == GameKind.letters ? game.letterPanel : game.wordPanelKeys;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: [
          for (var i = 0; i < letters.length; i++)
            _Key(
              label: letters[i],
              flash: _flashIndex == i,
              disabled: game.kind == GameKind.word && game.usedWordPanelIndices.contains(i),
              onTap: () {
                final ok = game.kind == GameKind.letters ? game.tapLetterKey(letters[i]) : game.tapWordKey(i);
                if (!ok) _flash(i);
              },
            ),
        ],
      ),
    );
  }
}

class _Key extends StatelessWidget {
  final String label;
  final bool flash;
  final bool disabled;
  final VoidCallback onTap;
  const _Key({required this.label, required this.flash, required this.disabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.25 : 1,
      child: Material(
        color: flash ? AppColors.badBg : AppColors.card,
        borderRadius: BorderRadius.circular(18),
        elevation: 3,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: disabled ? null : onTap,
          child: SizedBox(
            width: 68,
            height: 68,
            child: Center(child: Text(label, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark))),
          ),
        ),
      ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  final GameController game;
  final L10n t;
  final VoidCallback onDone;
  const _GameOverOverlay({required this.game, required this.t, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF083E38).withValues(alpha: 0.85),
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.s("gameOver"), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text("🪂 ${game.score}", style: const TextStyle(color: Color(0xFFFFD54A), fontSize: 34, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 8),
              Text(
                game.isNewRecord ? t.s("newRecord") : "${t.s("best")}: ${game.bestScore}",
                style: const TextStyle(color: Color(0xFFD7F5EF), fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              SizedBox(width: 220, child: BigButton(label: "OK", onTap: onDone)),
            ],
          ),
        ),
      ),
    );
  }
}
