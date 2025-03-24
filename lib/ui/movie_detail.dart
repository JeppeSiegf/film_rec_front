import 'package:film_rec_front/data/models.dart';
import 'package:film_rec_front/state/app_state.dart';
import 'package:film_rec_front/theme/theme_manager.dart';
import 'package:film_rec_front/ui/dir_film_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      duration: const Duration(milliseconds: 350),
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
        child: _buildFixedSizeImage(context),
      ),
      // Ensure the text starts top-left and doesn't get centered
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(context),
            _buildDirectors(context),
            const SizedBox(height: 4),
            _buildGenreTags(context),
          ],
        ),
      ),
    ],
  );
}



Widget _buildResizableImage(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double imageWidth = isImageMoved ? 66.75 : screenWidth * 0.8;
  double imageHeight = imageWidth * (3 / 2);

  // Cap sizes
  imageWidth = imageWidth > 400 ? 400 : imageWidth;
  imageHeight = imageHeight > 600 ? 600 : imageHeight;

  final imageWidget = ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.network(
      film.largeImageRef,
      width: imageWidth,
      height: imageHeight,
      fit: BoxFit.cover,
    ),
  );

  // If the image is large, center it; otherwise, keep it left-aligned
  return isImageMoved ? imageWidget : Center(child: imageWidget);
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

Widget _buildTitle(BuildContext context) {
  final locale = LocalizationManager.locale.languageCode;
  final title = locale == 'local' ? film.title : film.originalTitle;

  return Padding(
    padding: const EdgeInsets.only(top: 0),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          TextSpan(
            text: ' (${film.releaseYear})',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12.0,
                ),
          ),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
    ),
  );
}






  Widget _buildDirectors(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(top: 0.0),
    child: Wrap(
      spacing: 4.0,
      runSpacing: 2.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'dir.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 12.0,
              ),
        ),
        ...List.generate(film.directors.length, (index) {
          final director = film.directors[index];
          final isLast = index == film.directors.length - 1;
          return GestureDetector(
            onTap: () => showDirectorPopup(context, director, onFilmSelected),
            child: Text(
              '${director.name}${isLast ? '' : ','}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12.0,
                    decoration: TextDecoration.underline,
                  ),
            ),
          );
        }),
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
  alignment: WrapAlignment.start,
  children: film.genres.map((genre) {
    return IntrinsicWidth( // This forces width to match content
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withAlpha(25),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          genre,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10.0,
              ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }).toList(),
)
,
    );
  }
}
