import 'package:flutter/material.dart';
import '../../data/models.dart';
import 'movie_detail_dialog.dart';

class RecommendationsGrid extends StatelessWidget {
  final List<Film> films;
  final void Function(Film) onFilmSelected; // Accept callback for film selection

  const RecommendationsGrid({Key? key, required this.films, required this.onFilmSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the number of films per row
        int columns = 3; // Default columns
        double screenWidth = constraints.maxWidth;

        // Adjust the number of columns based on screen width
        if (screenWidth > 600) {
          columns = 4;
        }
        if (screenWidth > 800) {
          columns = 6;
        }
        if (screenWidth > 1000) {
          columns = 12; // Maximum columns (as per your request)

          // Ensure the number of films per row is divisible by 12
          if (films.length % 12 != 0) {
            columns = (films.length % 12 == 0) ? 12 : 6; // Adjust based on available films
          }
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 2 / 3,
          ),
          itemCount: films.length,
          itemBuilder: (context, index) {
            final film = films[index];
            return _buildGridItem(film, context);
          },
        );
      },
    );
  }

  Widget _buildGridItem(Film film, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    double resolution = screenWidth > 600
        ? 1.5
        : (screenWidth > 400 ? 1.0 : 0.75);

    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => showFilmPopup(context, film, onFilmSelected),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                film.largeImageRef.isNotEmpty
                    ? film.largeImageRef
                    : 'https://via.placeholder.com/267x400',
                fit: BoxFit.cover,
                width: 230 * resolution,
                height: 345 * resolution,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          film.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
