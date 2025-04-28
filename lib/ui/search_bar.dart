import 'package:film_rec_front/data/api_service.dart';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final ApiService repository;
  final Function(String) onFilmSelected;

  const SearchBarWidget({
    required this.repository,
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
          _searchController.clear();
          controller.openView();
        },
      ),
      suggestionsBuilder: (context, controller) async {
        final query = controller.text.trim();
        if (query.isEmpty) return [];

        // Hent forslag baseret på den aktuelle query
        final results = await widget.repository.searchFilms(query);

        // Returnér straks ListTile-forslagene
        return results.map((film) {
          return ListTile(
            title: Text(film.title),
            onTap: () {
              widget.onFilmSelected(film.pageRef);
              controller.clear();
              controller.closeView("");
            },
          );
        }).toList();
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
