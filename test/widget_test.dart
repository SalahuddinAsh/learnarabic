import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reading_stars/main.dart';
import 'package:reading_stars/services/settings_controller.dart';
import 'package:reading_stars/services/storage.dart';

void main() {
  testWidgets('Setup screen shows the title and a Start button', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await Storage.init();
    final settingsController = SettingsController()..load();

    await tester.pumpWidget(ReadingStarsApp(settingsController: settingsController));
    await tester.pumpAndSettle();

    expect(find.text('نجوم القراءة ⭐'), findsOneWidget);
    expect(find.text('!ابدأ 🚀'), findsOneWidget);
  });
}
