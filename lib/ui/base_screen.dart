import 'package:film_rec_front/data/api_service.dart';
import 'package:film_rec_front/state/app_state.dart';
import 'package:film_rec_front/data/models.dart';
import 'package:film_rec_front/theme/theme_manager.dart';
import 'package:film_rec_front/ui/movie_detail.dart';
import 'package:film_rec_front/ui/rec_grid';
import 'package:film_rec_front/ui/search_bar';
import 'package:flutter/material.dart';

class FilmRecommenderScreen extends StatefulWidget {
  const FilmRecommenderScreen({super.key});

  @override
  State<FilmRecommenderScreen> createState() => _FilmRecommenderScreenState();
}

class _FilmRecommenderScreenState extends State<FilmRecommenderScreen> {
  final AppState _appState = AppState();
  final ApiService _movieRepository = ApiService('http://10.0.2.2:5000');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Film Recommender'),
        actions: [
          IconButton(
            icon: Icon(_themeIcon),
            onPressed: () => _toggleTheme(),
            tooltip: _themeTooltip,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
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
            ),
            const SizedBox(height: 20),
            _buildRecommendationButton(),
            if (_appState.showGrid)
              RecommendationsGrid(films: _appState.recommendations),
          ],
        ],
      ),
    );
  }

  
  IconData get _themeIcon {
    final themeMode = ThemeManager.themeMode;
    if (themeMode == ThemeMode.system) {
      final brightness = MediaQuery.of(context).platformBrightness;
      return brightness == Brightness.dark ? Icons.wb_sunny : Icons.nights_stay;
    }
    return themeMode == ThemeMode.dark ? Icons.wb_sunny : Icons.nights_stay;
  }

  String get _themeTooltip {
    final themeMode = ThemeManager.themeMode;
    if (themeMode == ThemeMode.system) {
      final brightness = MediaQuery.of(context).platformBrightness;
      return brightness == Brightness.dark 
          ? 'Switch to Light Mode' 
          : 'Switch to Dark Mode';
    }
    return themeMode == ThemeMode.dark 
        ? 'Switch to Light Mode' 
        : 'Switch to Dark Mode';
  }

  void _toggleTheme() {
    ThemeManager.toggleTheme(context);
    setState(() {});
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

 
  Future<void> _fetchRecommendations() async {
  // Directly proceed if selectedFilm is not null
  final film = _appState.selectedFilm;
  
  // If no film is selected, just return (pre-check done outside)
  if (film == null) return;

  final recommendations = await _movieRepository.reccomendFilms(film.pageRef);
  setState(() {
    _appState.recommendations = _appState.searchResults;
  });
}

  void _toggleImageLayout() {
    setState(() {
      _appState.isImageMoved = !_appState.isImageMoved;
    });
  }

  Widget _buildRecommendationButton() {
    return ElevatedButton(
      onPressed: _appState.isButtonDisabled ? null : () async {
        if (_appState.recommendations.isEmpty) {
          await _fetchRecommendations();
        }
        setState(() {
          _appState.showGrid = true;
          _appState.isButtonDisabled = true;
          _appState.isImageMoved = true;
        });
      },
      child: const Text('Show Recommendations'),
    );
  }

  
}
