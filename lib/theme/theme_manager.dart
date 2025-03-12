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
class LocalizationManager {
  static Locale _locale = const Locale('local');
  
  static Locale get locale => _locale;
  
  static void toggleLocale() {
    _locale = _locale.languageCode == 'local'
        ? const Locale('global')
        : const Locale('local');
  }
  
  static void setLocale(Locale locale) {
    _locale = locale;
  }
}
