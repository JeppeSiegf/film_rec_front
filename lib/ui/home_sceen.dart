import 'dart:math';

import 'package:film_rec_front/data/api_service.dart';
import 'package:film_rec_front/data/models.dart';
import 'package:film_rec_front/state/app_state.dart';
import 'package:film_rec_front/theme/theme_manager.dart';
import 'package:film_rec_front/ui/film_header.dart';
import 'package:film_rec_front/ui/film_home_screen.dart';
import 'package:film_rec_front/ui/rec_grid.dart';
import 'package:film_rec_front/ui/search_bar.dart';
import 'package:film_rec_front/utils/poster_diplay.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback toggleLocale;
  final ThemeMode currentTheme;
  final Locale currentLocale;

  const HomeScreen({
    required this.toggleTheme,
    required this.toggleLocale,
    required this.currentTheme,
    required this.currentLocale,
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AppState _appState = AppState();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _resetState,
          child: const Text('siegf.org'),
        ),
        actions: [
          IconButton(
            icon: Icon(
              widget.currentLocale.languageCode == 'local'
                  ? Icons.translate_rounded
                  : Icons.translate,
            ),
            onPressed: widget.toggleLocale,
            tooltip: widget.currentLocale.languageCode == 'local'
                ? 'Globalize'
                : 'Localize',
          ),
          IconButton(
            icon: Icon(widget.currentTheme == ThemeMode.dark
                ? Icons.wb_sunny
                : Icons.nightlight),
            onPressed: widget.toggleTheme,
            tooltip: widget.currentTheme == ThemeMode.dark
                ? 'Light Mode'
                : 'Dark Mode',
          ),
        ],
      ),
     body: Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ResponsiveImage(imagePath: 'lib/assets/constanza.gif'),
      const SizedBox(height: 60), 
      const Text("Udvalgte Projekter"),
      const SizedBox(height: 20), 
      ElevatedButton(
        onPressed: () {
          // Navigate to the Film page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FilmRecommenderScreen(
                 toggleTheme: widget.toggleTheme,
                toggleLocale: widget.toggleLocale,
                currentTheme: ThemeManager.themeMode,
                currentLocale: LocalizationManager.locale,
              ),
            ),
          );
        },
        
        child: const Icon(Icons.movie),
      ),
    ],
  ),
    ),
    ); 
  }



  

  void _resetState() {
      
    setState(() {
      _appState.selectedFilm = null;
      _appState.recommendations = [];
      _appState.isImageMoved = false;
      _appState.isButtonDisabled = false;
      _appState.showGrid = false;
    });
  }
}
