import 'package:film_rec_front/data/models.dart';
import 'package:flutter/material.dart';

void showFilmPopup(BuildContext context, Film film, void Function(Film) onFilmSelected) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 400, // Max width of the popup
            maxHeight: 600, // Max height but can shrink if needed
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Allows shrinking if content is small
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          film.largeImageRef.isNotEmpty
                              ? film.largeImageRef
                              : 'https://via.placeholder.com/267x400',
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        film.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s...",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity, // Makes the container full width
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12.0)),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 4.0, offset: Offset(0, -2))
                  ],
                ),
                child: Center(
                  child: SizedBox(
                    width: 140, // Fixed width for button
                    child: ElevatedButton(
                      onPressed: () {
                        onFilmSelected(film);
                        Navigator.of(context).popUntil((route) => route.isFirst); 
                      },
                      child: const Icon(Icons.movie_filter),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
