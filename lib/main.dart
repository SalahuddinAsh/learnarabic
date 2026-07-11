import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'logic/question_generator.dart';
import 'logic/quiz_controller.dart';
import 'screens/quiz_screen.dart';
import 'screens/results_screen.dart';
import 'screens/setup_screen.dart';
import 'services/settings_controller.dart';
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

  void _startQuiz() {
    _quizController?.dispose();
    final settings = context.read<SettingsController>().settings;
    final cfg = buildCfg(settings);
    final controller = QuizController(settings, cfg)..start();
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
    setState(() => _screen = AppScreen.game);
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
        return Scaffold(
          backgroundColor: AppColors.teal,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Falling Pictures game coming soon", style: TextStyle(color: Colors.white, fontSize: 18)),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _quitQuiz, child: const Text("Back to setup")),
              ],
            ),
          ),
        );
    }
  }
}
