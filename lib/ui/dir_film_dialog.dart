import 'package:film_rec_front/data/api_service.dart';
import 'package:film_rec_front/data/models.dart';
import 'package:film_rec_front/ui/rec_grid.dart';
import 'package:flutter/material.dart';
void showDirectorPopup(BuildContext context, Director director, void Function(Film) onFilmSelected) {
  ApiService apiService = ApiService();

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400, // Max width of the popup
            maxHeight: 600, // Max height but can shrink if needed
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Allows shrinking if content is small
            children: [
              // Add director name at the top
              Padding(
                padding: const EdgeInsets.all(8.0), // Padding around the text
                child: Text(
                  director.name, // Display the director's name
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Film>>(
                  future: apiService.getFilmography(director.pageRef), // Use the instance method
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No films found for this director.'));
                    } else {
                      return SingleChildScrollView( // This ensures scrolling behavior
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Add padding
                        child: RecommendationsGrid(
                          films: snapshot.data!,
                          onFilmSelected: onFilmSelected,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
