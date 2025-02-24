
import 'package:film_rec_front/data/api_service.dart';
import 'package:film_rec_front/data/models.dart';
import 'package:film_rec_front/state/app_state.dart';
import 'package:film_rec_front/theme/theme_manager.dart';
import 'package:film_rec_front/ui/movie_detail.dart';
import 'package:film_rec_front/ui/rec_grid.dart';
import 'package:film_rec_front/ui/search_bar.dart';
import 'package:flutter/material.dart';

class FilmRecommenderScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final ThemeMode currentTheme;

  const FilmRecommenderScreen({
    required this.toggleTheme,
    required this.currentTheme,
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
        title: const Text('Film Recommender'),
        actions: [
          IconButton(
            icon: Icon(widget.currentTheme == ThemeMode.dark
                ? Icons.wb_sunny
                : Icons.nights_stay),
            onPressed: widget.toggleTheme,
            tooltip: widget.currentTheme == ThemeMode.dark
                ? 'Switch to Light Mode'
                : 'Switch to Dark Mode',)
                        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(15.0),
      child: Center(
        child: Column(
          children: [
            
            SearchBarWidget(
              repository: _movieRepository,
              appState: _appState,
              onFilmSelected: _handleFilmSelected,
            ),
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
              const SizedBox(height: 30),
             if (_appState.showGrid)
                RecommendationsGrid(
                  key: ValueKey(Theme.of(context).brightness),
                  films: _appState.recommendations,
                  onFilmSelected: _handleFilmSelected),
                
            ],
          ],
        ),
      ),
    );
  }


  void _handleFilmSelected(Film film) {
    setState(() {
      _appState.selectedFilm = film;
      _appState.showGrid = false;
      _appState.isImageMoved = false;
      _appState.isButtonDisabled = false;
      _appState.recommendations = [];
    });
  }

  void _fetchRecommendations() {
    // Use placeholder data
    setState(() {
      _appState.recommendations = _appState.searchResults;
      _appState.showGrid = true;
      _appState.isButtonDisabled = true;
      _appState.isImageMoved = true;
    });
  }

  Widget _buildRecommendationButton() {
    return ElevatedButton(
      onPressed: _appState.isButtonDisabled ? null : _fetchRecommendations,
      child: const Icon(Icons.movie_filter),
    );
  }

  void _toggleImageLayout() {
    setState(() {
      _appState.isImageMoved = !_appState.isImageMoved;
    });
  }
}