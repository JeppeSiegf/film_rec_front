import 'package:film_rec_front/theme/theme_manager.dart';
import 'package:film_rec_front/utils/hover_overlay.dart';
import 'package:flutter/material.dart';
import '../../data/models.dart';
import 'movie_detail_dialog.dart';

class RecommendationsGrid extends StatelessWidget {
  final List<Film> films;
  final void Function(Film) onFilmSelected;

  const RecommendationsGrid({
    Key? key,
    required this.films,
    required this.onFilmSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Get the total available width.
      final gridWidth = constraints.maxWidth;
      int columns = _calculateColumns(gridWidth);
      // Define ideal fixed sizes.
      const double idealPosterWidth = 150.0;
      const double idealPosterHeight = 225.0;
      const double idealTitleHeight = 60.0;
      const double idealSpacing = 6.0;
      const double crossAxisSpacing = 8.0;
      
      // Calculate cell width from available grid width.
      final cellWidth = (gridWidth - (columns - 1) * crossAxisSpacing) / columns;
      // Compute scale factor relative to the ideal width.
      final scaleFactor = cellWidth / idealPosterWidth;
      // Scale the ideal dimensions.
      final posterWidth = cellWidth;
      final posterHeight = idealPosterHeight * scaleFactor;
      final titleHeight = idealTitleHeight * scaleFactor;
      final spacing = idealSpacing * scaleFactor;
      
      // Total cell height
      final totalCellHeight = posterHeight + spacing + titleHeight;
      final childAspectRatio = cellWidth / totalCellHeight;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: 2.0,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: films.length,
        itemBuilder: (context, index) {
          return FilmGridItem(
            film: films[index],
            onFilmSelected: onFilmSelected,
            posterWidth: posterWidth,
            posterHeight: posterHeight,
            titleHeight: titleHeight,
            spacing: spacing,
          );
        },
      );
    });
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
  final double posterWidth;
  final double posterHeight;
  final double titleHeight;
  final double spacing;

  const FilmGridItem({
    Key? key,
    required this.film,
    required this.onFilmSelected,
    required this.posterWidth,
    required this.posterHeight,
    required this.titleHeight,
    required this.spacing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showFilmPopup(context, film, onFilmSelected),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Fixed-size image container.
          SizedBox(
            width: posterWidth,
            height: posterHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: HoverOverlay(
                icon: Icons.more_horiz,
                iconSize: 50 * (posterWidth / 150), // Scale icon accordingly
                child: Container(
                  color: Colors.black, // Background for letterboxing
                  child: Image.network(
                    film.largeImageRef.isNotEmpty
                        ? film.largeImageRef
                        : 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhjT4UGd119zdsNYIaupM5Qi1-BaHpIVfQcOUsUl3CutWQWFhRK4vafq7wDKsiv_kN1JmPwO60zEDr2CyOe_imY0fGSOAKTyB76VAOulsJEseCYZJvIEVhFSdloM5KWyaQQ1vzRAsOYRryT/s1600-h/technical-difficulties.jpg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: spacing),
          // Fixed title container.
          SizedBox(
            width: posterWidth,
            height: titleHeight,
            child: FilmTitle(film: film),
          ),
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
    final textStyle = Theme.of(context).textTheme.bodyMedium!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: Text(
          LocalizationManager.locale.languageCode == 'local'
              ? film.title
              : film.originalTitle,
          key: ValueKey<String>(LocalizationManager.locale.languageCode),
          textAlign: TextAlign.center,
          style: textStyle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
