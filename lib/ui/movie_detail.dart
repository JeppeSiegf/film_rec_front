import 'package:film_rec_front/data/models.dart';
import 'package:film_rec_front/state/app_state.dart';
import 'package:film_rec_front/ui/dir_film_dialog.dart';
import 'package:flutter/material.dart';
class MovieDetailsWidget extends StatelessWidget {
  final Film film;
  final bool isImageMoved;
  final VoidCallback onToggle;
  final Function(Film) onFilmSelected;

  const MovieDetailsWidget({
    required this.film,
    required this.isImageMoved,
    required this.onToggle,
    required this.onFilmSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 500),
      crossFadeState: isImageMoved 
          ? CrossFadeState.showSecond 
          : CrossFadeState.showFirst,
      firstChild: _buildVerticalLayout(context),
      secondChild: _buildHorizontalLayout(context),
    );
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return Column(
      children: [
        _buildTitle(context),
        const SizedBox(height: 15),
        _buildResizableImage(context), // Updated image resizing with max height
      ],
    );
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: _buildFixedSizeImage(context), // Fixed size image for horizontal layout
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(context),
            _buildDirectors(context),
            _buildGenreTags(context)
          ],
        ),
      ],
    );
  }

  Widget _buildResizableImage(BuildContext context) {
    // Use MediaQuery to adjust the size based on the screen width in the vertical layout
    double screenWidth = MediaQuery.of(context).size.width;
    double imageWidth = isImageMoved ? 66.75 : screenWidth * 0.8; // Dynamic width
    double imageHeight = imageWidth * (3 / 2); // Maintain the 2:3 aspect ratio
    
    // Set the max width to 300px and max height to 200px
    imageWidth = imageWidth > 400 ? 400 : imageWidth;
    imageHeight = imageHeight > 600 ? 600 : imageHeight;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        film.largeImageRef,
        width: imageWidth,
        height: imageHeight,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildFixedSizeImage(BuildContext context) {
    // In horizontal layout, image stays at a fixed size
    double fixedWidth = 100;
    double fixedHeight = fixedWidth * (3 / 2); // Maintain the 2:3 aspect ratio
    
    // Ensure the height does not exceed 600px
    fixedHeight = fixedHeight > 600 ? 600 : fixedHeight;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        film.largeImageRef,
        width: fixedWidth,  // Fixed width for horizontal layout
        height: fixedHeight, // Fixed height for horizontal layout
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) => Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          Text(
            film.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isImageMoved) 
            Padding(
              padding: const EdgeInsets.only(left: 8.0), 
              child: Text(
                '${film.releaseYear}',  
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
        ],
      ),
    ],
  );

  Widget _buildDirectors(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Row(
      children: [
        Text(
          'dir. ',  // Only display "dir." once before the list of directors
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 12.0,
          ),
        ),
        // Create a list of directors with commas between them
        ...List.generate(film.directors.length, (index) {
          final director = film.directors[index];
          return Row(
            children: [
              GestureDetector(
                onTap: () => showDirectorPopup(context, director, onFilmSelected),
                child: Text(
                  director.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12.0,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              if (index < film.directors.length - 1)
                const Text(', '),  // Add a comma separator, but not after the last director
            ],
          );
        })
      ],
    ),
  );
}

  Widget _buildGenreTags(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(
        spacing: 6.0, 
        runSpacing: 4.0, 
        alignment: WrapAlignment.center,
        children: film.genres.map((genre) {
          return Container(
            height: 22, 
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1), 
              borderRadius: BorderRadius.circular(8.0), 
            ),
            alignment: Alignment.center, 
            child: Text(
              genre,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10.0, 
                color: Theme.of(context).textTheme.bodySmall?.color, 
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
