import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'logic/game_controller.dart';
import 'logic/question_generator.dart';
import 'logic/quiz_controller.dart';
import 'screens/game_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/results_screen.dart';
import 'screens/setup_screen.dart';
import 'services/settings_controller.dart';
import 'services/sound_service.dart';
import 'services/storage.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Storage.init();
  final settingsController = SettingsController()..load();
  runApp(ReadingStarsApp(settingsController: settingsController));
}

class ReadingStarsApp extends StatelessWidget {
  final SettingsController settingsController;
  const ReadingStarsApp({super.key, required this.settingsController});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: settingsController,
      child: MaterialApp(
        title: "Reading Stars",
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const AppRoot(),
      ),
    );
  }
}

/// Screens toggled explicitly (setup/quiz/results/game), not a Navigator
/// stack — mirrors the web app's showScreen()/CSS-class-toggle model, so
/// there's no OS back-gesture semantics, only in-app quit buttons.
enum AppScreen { setup, quiz, results, game }

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  AppScreen _screen = AppScreen.setup;
  QuizController? _quizController;
  GameController? _gameController;
  late final SoundService _sound = SoundService(context.read<SettingsController>());

  void _startQuiz() {
    _quizController?.dispose();
    final settings = context.read<SettingsController>().settings;
    final cfg = buildCfg(settings);
    final controller = QuizController(settings, cfg)
      ..onGood = _sound.good
      ..onBad = _sound.bad
      ..onTick = _sound.tick
      ..onPairMatched = _sound.pairMatched
      ..start();
    setState(() {
      _quizController = controller;
      _screen = AppScreen.quiz;
    });
  }

  void _quitQuiz() {
    _quizController?.dispose();
    setState(() {
      _quizController = null;
      _screen = AppScreen.setup;
    });
  }

  void _onQuizFinished() {
    setState(() => _screen = AppScreen.results);
  }

  void _playGame() {
    final settings = _quizController!.settings;
    final cfg = buildCfg(settings);
    final controller = GameController(settings, cfg)
      ..onZap = _sound.zap
      ..onBad = _sound.bad
      ..onKeyTick = _sound.keyTick;
    setState(() {
      _gameController = controller;
      _screen = AppScreen.game;
    });
  }

  // quitGame() in app.js always returns to the results screen, whether the
  // kid quits mid-game or taps "OK" on the game-over overlay.
  void _leaveGame() {
    _gameController?.dispose();
    setState(() {
      _gameController = null;
      _screen = AppScreen.results;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_screen) {
      case AppScreen.setup:
        return SetupScreen(onStart: _startQuiz);
      case AppScreen.quiz:
        return QuizScreen(quiz: _quizController!, onQuit: _quitQuiz, onFinished: _onQuizFinished);
      case AppScreen.results:
        return ResultsScreen(
          settings: _quizController!.settings,
          result: _quizController!.result!,
          onPlayGame: _playGame,
          onAgain: _startQuiz,
          onSettings: _quitQuiz,
        );
      case AppScreen.game:
        return GameScreen(game: _gameController!, onQuit: _leaveGame);
    }
  }
}
