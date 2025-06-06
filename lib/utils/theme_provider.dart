import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isFemaleTheme = true; // الوضع الافتراضي: بنت

  bool get isFemaleTheme => _isFemaleTheme;

  ThemeData get themeData => _isFemaleTheme ? _femaleTheme : _maleTheme;

  void toggleTheme() {
    _isFemaleTheme = !_isFemaleTheme;
    notifyListeners();
  }

  void setFemaleTheme() {
    _isFemaleTheme = true;
    notifyListeners();
  }

  void setMaleTheme() {
    _isFemaleTheme = false;
    notifyListeners();
  }

  final ThemeData _femaleTheme = ThemeData(
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFF48FB1),    // زهري
      secondary: Color(0xFFFFB74D),  // برتقالي
    ),
    scaffoldBackgroundColor: const Color(0xFFFFF3F7), // خلفية ناعمة
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF48FB1),
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFF48FB1),
      foregroundColor: Colors.white,
    ),
    useMaterial3: true,
  );

  final ThemeData _maleTheme = ThemeData(
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF81D4FA),    // أزرق
      secondary: Color(0xFFFFB74D),  // برتقالي
    ),
    scaffoldBackgroundColor: const Color(0xFFE3F2FD), // خلفية هادئة
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF81D4FA),
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF81D4FA),
      foregroundColor: Colors.white,
    ),
    useMaterial3: true,
  );
}
