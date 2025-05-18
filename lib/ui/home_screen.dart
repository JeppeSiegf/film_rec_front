import 'dart:math';

import 'package:film_rec_front/data/api_service.dart';
import 'package:film_rec_front/data/models.dart';
import 'package:film_rec_front/state/app_state.dart';
import 'package:film_rec_front/theme/theme_manager.dart';
import 'package:film_rec_front/ui/film_header.dart';
import 'package:film_rec_front/ui/rec_grid.dart';
import 'package:film_rec_front/ui/search_bar.dart';
import 'package:flutter/material.dart';

class FilmRecommenderScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback toggleLocale;
  final ThemeMode currentTheme;
  final Locale currentLocale;

  const FilmRecommenderScreen({
    required this.toggleTheme,
    required this.toggleLocale,
    required this.currentTheme,
    required this.currentLocale,
    super.key,
  });

  @override
  State<FilmRecommenderScreen> createState() => _FilmRecommenderScreenState();
}
class _FilmRecommenderScreenState extends State<FilmRecommenderScreen> {
  final AppState _appState = AppState();
  final ApiService _movieRepository = ApiService();

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _resetState,
          child: const Text('Siegflix'),
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
      body: _buildBody(),
    );
  }

Widget _buildBody() {
  return LayoutBuilder(
    builder: (context, constraints) {
      // Calculate available height in the viewport.
      final totalHeight = constraints.maxHeight;
      // Assume that other UI elements (above the spinner area) take ~250 px.
      const otherUIHeight = 250.0;
      // Compute available space for the spinner.
      final availableForSpinner = totalHeight - otherUIHeight;
      // Only show spinner if there’s enough space (say, at least 100 px)
      final showSpinner = availableForSpinner >= 100;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             Center(
      child: SearchBarWidget(
        repository: _movieRepository,
        onFilmSelected: _handleFilmSelected,
            
            ),),
            const SizedBox(height: 20),
            if (_appState.selectedFilm != null) ...[
              MovieDetailsWidget(
                film: _appState.selectedFilm!,
                isImageMoved: _appState.isImageMoved,
                onToggle: _toggleImageLayout,
                onFilmSelected: _handleFilmSelected,
              ),
              const SizedBox(height: 20),
              _buildRecommendationButton(),
              const SizedBox(height: 20),
              // Spinner container that occupies available space if enough room exists.
              if (_appState.isLoading && showSpinner)
                Container(
                  height: availableForSpinner,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                )
              else if (_appState.showGrid && !_appState.isLoading)
                RecommendationsGrid(
                  key: ValueKey(Theme.of(context).brightness),
                  films: _appState.recommendations,
                  onFilmSelected: _handleFilmSelected,
                ),
            ],
          ],
        ),
      );
    },
  );
}


  Future<void> _fetchRecommendations() async {
  final selectedFilm = _appState.selectedFilm;  // Store in a local variable

  if (selectedFilm != null) {  // Ensure it's not null
    try {
      
      setState(() {
        _appState.isButtonDisabled = true;  // Disable the button
        _appState.showGrid = false;  // Show the recommendations grid
        _appState.isImageMoved = true;  // Update other UI states
        _appState.isLoading = true;
      });

     
      List<Film> recommendations = await ApiService().reccomendFilms(selectedFilm.pageRef);
      

      setState(() {
        _appState.recommendations = recommendations;
        _appState.showGrid = true;
        _appState.isLoading = false; // Stop spinner
      });
    } catch (error) {
      setState(() {
        _appState.recommendations = [];
        _appState.isLoading = false; // Stop spinner
        _appState.showGrid = false;
      });
    }
  }
}


Future<void> _handleFilmSelected(String page_ref) async {
  Film film = await ApiService().getFilm(page_ref);

  setState(() {
    _appState.selectedFilm = film;
    _appState.showGrid = false;
    _appState.isImageMoved = false;
    _appState.isButtonDisabled = false;
    _appState.recommendations = [];
   
  });

    // Call this to fetch recommendations after film selection
}

  Widget _buildRecommendationButton() {
    return ElevatedButton(
      onPressed: _appState.isButtonDisabled 
        ? null 
        : () => _fetchRecommendations(),
      child: const Icon(Icons.movie_filter),
    );
  }

  void _toggleImageLayout() {
    setState(() {
      _appState.isImageMoved = !_appState.isImageMoved;
    });
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
