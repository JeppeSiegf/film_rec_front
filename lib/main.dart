import 'package:film_rec_front/theme/theme_manager.dart';
import 'package:film_rec_front/ui/film_home_screen.dart';
import 'package:film_rec_front/ui/home_sceen.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

Future<void> main() async {

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

      onGenerateRoute: (settings) {
        // Handle dynamic paths
        final Uri uri = Uri.parse(settings.name!);

        if (uri.pathSegments.isEmpty) {
          return MaterialPageRoute(builder: (_) => HomeScreen( toggleTheme: _toggleTheme,
              toggleLocale: _toggleLocale,
              currentTheme: ThemeManager.themeMode,
              currentLocale: LocalizationManager.locale,));
        }

          if (uri.pathSegments[0] == 'film') {
          return MaterialPageRoute(builder: (_) => FilmRecommenderScreen(
              toggleTheme: _toggleTheme,
              toggleLocale: _toggleLocale,
              currentTheme: ThemeManager.themeMode,
              currentLocale: LocalizationManager.locale,
      ));
        }

        // Fallback 404 page
        // return MaterialPageRoute(builder: (_) => NotFoundPage());

      }
      
    );
  }
}