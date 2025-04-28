import 'package:flutter/material.dart';

/// Utility class for handling movie images and posters
class MovieImageUtils {
  /// Builds a movie poster image that can be resized based on layout
  static Widget buildMoviePoster({
    required String imageUrl,
    required bool isCompact,
    double? maxWidth,
    double? maxHeight,
    BorderRadius? borderRadius,
    double aspectRatio = 3/2,
  }) {
    return Builder(builder: (context) {
      double screenWidth = MediaQuery.of(context).size.width;
      double imageWidth = isCompact ? 100 : (maxWidth ?? screenWidth * 0.8);
      double imageHeight = imageWidth * aspectRatio;
      
      // Cap sizes
      imageWidth = maxWidth != null && imageWidth > maxWidth ? maxWidth : imageWidth;
      imageHeight = maxHeight != null && imageHeight > maxHeight ? maxHeight : imageHeight;
      
      final imageWidget = ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: imageWidth,
          height: imageHeight,
          fit: BoxFit.cover,
        ),
      );
      
      // If the image is compact, don't center it
      return isCompact ? imageWidget : Center(child: imageWidget);
    });
  }
}

class FilmBannerImage extends StatelessWidget {
  final String imageUrl;
  
  const FilmBannerImage({
    Key? key, 
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Vælg enten asset eller network baseret på om URL’en starter med "http"
    final Widget img = imageUrl.startsWith('http')
      ? Image.network(
          imageUrl,
          fit: BoxFit.cover,
        )
      : Image.asset(
          imageUrl,
          fit: BoxFit.cover,
        );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.transparent],
            stops: [0.75, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: img,
      ),
    );
  }
}
