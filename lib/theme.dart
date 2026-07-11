import 'package:flutter/material.dart';

/// Color palette lifted 1:1 from web_app/style.css so the Flutter app reads
/// as the same product, not a re-skin.
class AppColors {
  AppColors._();

  static const teal = Color(0xFF0D9488);
  static const tealLight = Color(0xFF2DD4BF);
  static const amber = Color(0xFFF59E0B);
  static const orange = Color(0xFFF97316);

  static const bgGradient = LinearGradient(
    begin: Alignment(-0.6, -1),
    end: Alignment(0.9, 1),
    colors: [tealLight, teal, amber],
    stops: [0.0, 0.45, 1.0],
  );

  static const card = Color(0xFFFFFFFF);
  static const chipBg = Color(0xFFF6FDFB);
  static const chipBorder = Color(0xFFCCECE6);
  static const chipSoftBg = Color(0xFFE7F8F4);
  static const chipSoftBg2 = Color(0xFFF0FBF9);

  static const textDark = Color(0xFF1F3D3A);
  static const textMid = Color(0xFF2A5A52);
  static const textMuted = Color(0xFF55786F);
  static const textFaint = Color(0xFF7BA39A);
  static const textPale = Color(0xFFB9DED6);

  static const good = Color(0xFF3DDC84);
  static const goodDark = Color(0xFF1DA75C);
  static const goodBg = Color(0xFFE2FBE9);

  static const bad = Color(0xFFFF5C72);
  static const badDark = Color(0xFFE0284A);
  static const badBg = Color(0xFFFFE6EA);

  static const record = Color(0xFFE07B1D);

  static const bigBtnGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [amber, orange],
  );
  static const gameBtnGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [teal, Color(0xFF5EC8F8)],
  );

  static const skyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7DD3FC), Color(0xFFBAE6FD), Color(0xFF86EFAC)],
    stops: [0.0, 0.7, 1.0],
  );
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: ".SF UI Text",
    scaffoldBackgroundColor: AppColors.teal,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      primary: AppColors.teal,
    ),
    splashFactory: NoSplash.splashFactory,
  );
}
