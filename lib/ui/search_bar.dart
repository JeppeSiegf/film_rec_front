import 'package:film_rec_front/data/api_service.dart';
import 'package:film_rec_front/state/app_state.dart';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final ApiService repository;
  final AppState appState;
  final Function(String) onFilmSelected;
  
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
        onPressed: () {
          // Clear any previous search text when opening the search
          _searchController.clear();
          // Clear previous search results
          widget.appState.searchResults = [];
          controller.openView();
        },
      ),
      suggestionsBuilder: (context, controller) async {
        final query = controller.text.trim();
        if (query.isEmpty) return [];
        
        final currentQuery = query;
        final results = await widget.repository.searchFilms(currentQuery);
        
        if (_searchController.text.trim() == currentQuery) {
          Future.microtask(() {
            if (mounted) {
              setState(() {
                widget.appState.searchResults = results;
              });
            }
          });
        }
        
        return _buildSuggestions(currentQuery);
      },
    );
  }
  
  List<ListTile> _buildSuggestions(String query) {
    return widget.appState.searchResults.map((film) => ListTile(
      title: Text(film.title),
      onTap: () {
        widget.onFilmSelected(film.pageRef);
        
        // Clear search results
        widget.appState.searchResults = [];
        
        // Clear the search text and close the view
        _searchController.clear();
        _searchController.closeView("");
      },
    )).toList();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}