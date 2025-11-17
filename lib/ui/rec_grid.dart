import 'package:film_rec_front/data/models.dart';
import 'package:film_rec_front/ui/film_dialog.dart';
import 'package:film_rec_front/utils/hover_overlay.dart';
import 'package:film_rec_front/utils/lazy_loader.dart';
import 'package:film_rec_front/utils/poster_diplay.dart';
import 'package:film_rec_front/utils/title_display.dart';
import 'package:flutter/material.dart';

class RecommendationsGrid extends StatelessWidget {
  final List<Film> films;
  final void Function(String) onFilmSelected;

  const RecommendationsGrid({
    Key? key,
    required this.films,
    required this.onFilmSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      
      final gridWidth = constraints.maxWidth;
      int columns = _calculateColumns(gridWidth);
    
      const double idealPosterWidth = 150.0;
      const double idealPosterHeight = 225.0;
      const double idealTitleHeight = 60.0;
      const double idealSpacing = 1.0;
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
  final void Function(String) onFilmSelected;
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
    // Only reduce font size for small screens, otherwise use default
    final screenWidth = MediaQuery.of(context).size.width;
    TextStyle? titleStyle = Theme.of(context).textTheme.bodyLarge;
    if (screenWidth < 500) {
      titleStyle = titleStyle?.copyWith(fontSize: 13);
    }

    // Prevent posterWidth from exceeding screen width
    final safePosterWidth = posterWidth > screenWidth ? screenWidth : posterWidth;
    final safePosterHeight = posterHeight > (screenWidth / (2/3)) ? (screenWidth / (2/3)) : posterHeight;

    return GestureDetector(
      onTap: () => showFilmPopup(context, film, onFilmSelected),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: safePosterWidth,
            height: safePosterHeight,
            child: LazyLoad(
              
              builder: (_) => HoverOverlay(
                icon: Icons.more_horiz,
                iconSize: 50 * (safePosterWidth / 150),
                child: MovieImageUtils.buildMoviePoster(
                  imageUrl: film.largeImageRef,
                  size: PosterSize.medium,
                ),
              ),
            ),
          ),
          SizedBox(height: spacing),
          SizedBox(
            width: safePosterWidth,
            height: titleHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: MovieTextUtils.buildMovieTitle(
                film: film,
                context: context,
                includeYear: false,
                textAlign: TextAlign.center,
                animateLocaleChanges: true,
                maxLines: 2,
                titleStyle: titleStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}