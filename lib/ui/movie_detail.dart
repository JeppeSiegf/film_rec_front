import 'package:film_rec_front/data/models.dart';
import 'package:flutter/material.dart';

class MovieDetailsWidget extends StatelessWidget {
  final Film film;
  final bool isImageMoved;
  final VoidCallback onToggle;

  const MovieDetailsWidget({
    required this.film,
    required this.isImageMoved,
    required this.onToggle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 500),
      crossFadeState: isImageMoved 
          ? CrossFadeState.showSecond 
          : CrossFadeState.showFirst,
      firstChild: _buildVerticalLayout(context), // Pass context here
      secondChild: _buildHorizontalLayout(context), // Pass context here
    );
  }

  Widget _buildVerticalLayout(BuildContext context) => Column(
    children: [_buildTitle(context), _buildImage()],
  );

  Widget _buildHorizontalLayout(BuildContext context) => Row(
    children: [_buildImage(), _buildTitle(context)],
  );

  Widget _buildTitle(BuildContext context) => Text(
    film.title,
    textAlign: TextAlign.center,
    style: Theme.of(context).textTheme.titleMedium,
  );

  Widget _buildImage() => ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.network(
      film.largeImageRef,
      width: isImageMoved ? 66.75 : 267,
      height: isImageMoved ? 100 : 400,
      fit: BoxFit.cover,
    ),
  );
}
