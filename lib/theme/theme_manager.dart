import 'package:flutter/material.dart';

class ThemeManager {
  static ThemeMode _themeMode = ThemeMode.system;
  
  static ThemeMode get themeMode => _themeMode;
  
  static void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    // For system mode cycling: light -> dark -> system -> light...
    // _themeMode = ThemeMode.values[(_themeMode.index + 1) % ThemeMode.values.length];
  }
  
  static void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
  }
}