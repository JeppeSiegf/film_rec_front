import 'package:film_rec_front/theme/theme_manager.dart';
import 'package:film_rec_front/ui/base_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  await dotenv.load(); // Load .env file
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
 
  Locale _locale = const Locale('local');

 
  void _toggleTheme() {
    setState(() {
      ThemeManager.toggleTheme();
    });
  }

    void _toggleLocale() {
    setState(() {
      LocalizationManager.toggleLocale();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeManager.themeMode,
      locale: LocalizationManager.locale,
      home: FilmRecommenderScreen(
        toggleTheme: _toggleTheme,
        toggleLocale: _toggleLocale,
        currentTheme: ThemeManager.themeMode,
        currentLocale: LocalizationManager.locale,
      )
    );
  }
}