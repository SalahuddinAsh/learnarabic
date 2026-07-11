import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/letters.dart';
import '../data/strings.dart';
import '../models/settings.dart';
import '../services/settings_controller.dart';
import '../theme.dart';
import '../widgets/app_card.dart';
import '../widgets/big_button.dart';
import '../widgets/chips.dart';

const String kAppVersion = "1.0.0";

const Map<String, String> _levelSymbols = {"letters": "أ ب", "words": "🐱", "sent": "📖"};
const Map<String, String> _modeSymbols = {
  "match": "🖼️",
  "missing": "▢",
  "connect": "🔗",
  "build": "🧩",
  "read": "🎤",
};

/// Mirrors buildSetup()/refreshSetup() in app.js: level/mode/letters/count/
/// timer/game-unlock chip groups, language switch, sound toggle, Start button.
class SetupScreen extends StatelessWidget {
  final VoidCallback onStart;
  const SetupScreen({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SettingsController>();
    final s = controller.settings;
    final t = kStrings[s.lang]!;
    final modes = validModes(s.level);
    final allSelected = s.letters.length == kAllLetterChars.length;
    final hint = (s.level == "letters" && s.letters.isEmpty) ? t.s("hintLetters") : null;
    final dir = s.lang == "ar" ? TextDirection.rtl : TextDirection.ltr;

    void update(void Function(Settings) fn) => controller.update(fn);

    return AppScreenBackground(
      child: Center(
        child: SingleChildScrollView(
          child: AppCard(
            child: Directionality(
              textDirection: dir,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(t.s("title"), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                      ),
                      Wrap(
                        spacing: 6,
                        children: [
                          for (final lang in kLanguages)
                            LangChip(
                              label: lang == "ar" ? "ع" : lang.toUpperCase(),
                              selected: s.lang == lang,
                              onTap: () => update((x) => x.lang = lang),
                            ),
                          LangChip(
                            label: s.sound ? "🔊" : "🔇",
                            selected: false,
                            onTap: () => update((x) => x.sound = !x.sound),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  _Group(
                    title: t.s("level"),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final level in kLevels)
                          OptionChip(
                            symbol: _levelSymbols[level]!,
                            name: t.s(_levelNameKey(level)),
                            selected: s.level == level,
                            onTap: () => update((x) {
                              x.level = level;
                              if (!validModes(level).contains(x.mode)) x.mode = validModes(level).first;
                            }),
                          ),
                      ],
                    ),
                  ),

                  _Group(
                    title: t.s("mode"),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final mode in modes)
                          OptionChip(
                            symbol: _modeSymbols[mode]!,
                            name: t.s(_modeNameKey(mode)),
                            selected: s.mode == mode,
                            onTap: () => update((x) => x.mode = mode),
                          ),
                      ],
                    ),
                  ),

                  if (s.level == "letters")
                    _Group(
                      title: t.s("letters"),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Letter chips are Arabic content, always RTL regardless of UI
                          // language — mirrors dir="rtl" hardcoded on #letters-row.
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                for (final l in kLetters)
                                  SimpleChip(
                                    label: l.char,
                                    selected: s.letters.contains(l.char),
                                    fontSize: 22,
                                    padding: const EdgeInsets.all(8),
                                    onTap: () => update((x) {
                                      if (x.letters.contains(l.char)) {
                                        x.letters.remove(l.char);
                                      } else {
                                        x.letters.add(l.char);
                                      }
                                    }),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          SimpleChip(
                            label: t.s("all"),
                            selected: allSelected,
                            onTap: () => update((x) {
                              x.letters = allSelected ? <String>[] : List<String>.from(kAllLetterChars);
                            }),
                          ),
                        ],
                      ),
                    ),

                  _Group(
                    title: t.s("count"),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final c in kCountOptions)
                          SimpleChip(
                            label: "$c",
                            selected: s.count == c,
                            textDirection: TextDirection.ltr,
                            onTap: () => update((x) => x.count = c),
                          ),
                      ],
                    ),
                  ),

                  if (s.mode != "read")
                    _Group(
                      title: t.s("timer"),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          SimpleChip(
                            label: t.s("timerOn"),
                            selected: s.timed,
                            onTap: () => update((x) => x.timed = true),
                          ),
                          SimpleChip(
                            label: t.s("timerOff"),
                            selected: !s.timed,
                            onTap: () => update((x) => x.timed = false),
                          ),
                        ],
                      ),
                    ),

                  _Group(
                    title: t.s("game"),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final g in kGameScoreOptions)
                              SimpleChip(
                                label: g == 0 ? t.s("gameOff") : "$g",
                                selected: s.gameScore == g,
                                textDirection: g == 0 ? null : TextDirection.ltr,
                                onTap: () => update((x) => x.gameScore = g),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(t.s("gameNote"), style: const TextStyle(color: AppColors.textFaint, fontSize: 13)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  BigButton(label: t.s("start"), onTap: hint == null ? onStart : null),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      hint ?? "",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textFaint, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      "v$kAppVersion",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textPale, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _levelNameKey(String level) => switch (level) {
        "letters" => "lvlLetters",
        "words" => "lvlWords",
        _ => "lvlSent",
      };

  static String _modeNameKey(String mode) => switch (mode) {
        "match" => "modeMatch",
        "missing" => "modeMissing",
        "connect" => "modeConnect",
        "build" => "modeBuild",
        _ => "modeRead",
      };
}

class _Group extends StatelessWidget {
  final String title;
  final Widget child;
  const _Group({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
