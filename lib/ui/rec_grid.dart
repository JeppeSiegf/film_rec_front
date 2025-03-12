import 'package:film_rec_front/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import '../../data/models.dart';
import 'movie_detail_dialog.dart';

class RecommendationsGrid extends StatelessWidget {
  final List<Film> films;
  final void Function(Film) onFilmSelected;

  const RecommendationsGrid({Key? key, required this.films, required this.onFilmSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = _calculateColumns(constraints.maxWidth);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 0.6, // Ensures no overlap between rows
            childAspectRatio: 0.6, // Allows space for text
          ),
          itemCount: films.length,
          itemBuilder: (context, index) {
            return FilmGridItem(film: films[index], onFilmSelected: onFilmSelected);
          },
        );
      },
    );
  }

  int _calculateColumns(double screenWidth) {
    if (screenWidth > 1000) return 6;
    if (screenWidth > 800) return 5;
    if (screenWidth > 600) return 4;
    return 3;
  }
}

class FilmGridItem extends StatelessWidget {
  final Film film;
  final void Function(Film) onFilmSelected;

  const FilmGridItem({Key? key, required this.film, required this.onFilmSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight( // Ensures height adjusts to fit both image and text
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded( // Ensures image takes all available space while respecting aspect ratio
            child: GestureDetector(
              onTap: () => showFilmPopup(context, film, onFilmSelected),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  film.largeImageRef.isNotEmpty
                      ? film.largeImageRef
                      : 'https://via.placeholder.com/267x400',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8), // Ensures spacing between image and text
          FilmTitle(film: film),
        ],
      ),
    );
  }
}

class FilmTitle extends StatelessWidget {
  final Film film;

  const FilmTitle({Key? key, required this.film}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48, // Ensures enough space for 2 lines of text
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child:AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: Text(
          LocalizationManager.locale.languageCode == 'local'
              ? film.title
              : film.originalTitle,
          key: ValueKey<String>(LocalizationManager.locale.languageCode),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
      ),
    )));
  }
}

