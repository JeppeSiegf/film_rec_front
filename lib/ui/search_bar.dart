import 'package:film_rec_front/data/api_service.dart';
import 'package:film_rec_front/state/app_state.dart';
import 'package:flutter/material.dart';
import '../../data/models.dart';
import '../../data/api_service.dart';
import '../../state/app_state.dart';

class SearchBarWidget extends StatefulWidget {
  final ApiService repository;
  final AppState appState;
  final Function(Film) onFilmSelected;

  const SearchBarWidget({
    required this.repository,
    required this.appState,
    required this.onFilmSelected,
    super.key,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final SearchController _searchController = SearchController();

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      searchController: _searchController,
      builder: (context, controller) => IconButton(
        icon: const Icon(Icons.search),
        onPressed: () => controller.openView(),
      ),
      suggestionsBuilder: (context, controller) async {
        final query = controller.text.trim();
        if (query.isEmpty) return [];

        
        final results = await widget.repository.searchFilms(query);
        

        // Use Future.microtask to ensure UI updates before returning suggestions
        Future.microtask(() {
          setState(() {
            widget.appState.searchResults = results;
          });
        });

        return _buildSuggestions(query);
      },
    );
  }

  List<ListTile> _buildSuggestions(String query) {
    return widget.appState.searchResults.map((film) => ListTile(
          title: Text(film.title),
          onTap: () {
            widget.onFilmSelected(film);
            _searchController.closeView(film.title);
          },
        )).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
