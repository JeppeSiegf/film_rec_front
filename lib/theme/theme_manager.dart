import 'package:flutter/material.dart';

class ThemeManager {
  static ThemeMode _themeMode = ThemeMode.system;

  static ThemeMode get themeMode => _themeMode;

  static void toggleTheme(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    _themeMode = brightness == Brightness.dark 
        ? ThemeMode.light 
        : ThemeMode.dark;
  }
}