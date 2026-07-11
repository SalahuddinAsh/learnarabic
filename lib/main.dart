import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'logic/question_generator.dart';
import 'logic/quiz_controller.dart';
import 'screens/quiz_screen.dart';
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
    // Results screen lands in a later task; for now, return to setup.
    setState(() => _screen = AppScreen.results);
  }

  @override
  Widget build(BuildContext context) {
    switch (_screen) {
      case AppScreen.setup:
        return SetupScreen(onStart: _startQuiz);
      case AppScreen.quiz:
        return QuizScreen(quiz: _quizController!, onQuit: _quitQuiz, onFinished: _onQuizFinished);
      case AppScreen.results:
      case AppScreen.game:
        return Scaffold(
          backgroundColor: AppColors.teal,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Score: ${_quizController?.result?.score ?? 0} / 1000  (results screen coming soon)",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _quitQuiz, child: const Text("Back to setup")),
              ],
            ),
          ),
        );
    }
  }
}
