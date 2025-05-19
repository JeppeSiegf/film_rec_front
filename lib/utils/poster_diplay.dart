import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum PosterSize { large, medium, small }

/// Utility class for handling movie images and posters
class MovieImageUtils {
  /// Proxy wrapper for image URLs
  static String proxyWrap(String url) {
    final base = dotenv.env['PROXY_URL'] ?? 'https://www.siegf.org/proxy';
    return '$base?url=${Uri.encodeComponent(url)}';
  }

  /// Builds a movie poster image with consistent, context-driven sizing
  static Widget buildMoviePoster({
    required String imageUrl,
    required PosterSize size,
    BorderRadius? borderRadius,
    bool useProxy = true,
  }) {
    return Builder(builder: (context) {
      double screenWidth = MediaQuery.of(context).size.width;
      double width;
      double aspectRatio = 2 / 3;

      // Responsive width based on enum and screen size
      switch (size) {
        case PosterSize.large:
          width = screenWidth * 0.6;
          // If the calculated width is less than a max (e.g. 400), use the max, but never exceed screen width
          double maxLarge = 400.0;
          if (width > maxLarge && maxLarge <= screenWidth) {
            width = maxLarge;
          } else if (width > screenWidth) {
            width = screenWidth;
          }
          break;
        case PosterSize.medium:
          width = screenWidth * 0.24; // for home grid
          break;
        case PosterSize.small:
        default:
          width = screenWidth * 0.08; // for dialog grid
          break;
      }
      // Clamp width for reasonable min/max
      width = width.clamp(100.0, screenWidth);
      double height = width / aspectRatio;

      // Calculate pixel dimensions for caching to save memory
      final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      final cacheWidth = (width * devicePixelRatio).round();
      final cacheHeight = (height * devicePixelRatio).round();

      // Apply proxy if requested
      final finalUrl = useProxy && imageUrl.startsWith('http') ? proxyWrap(imageUrl) : imageUrl;

      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: Image.network(
          finalUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
          gaplessPlayback: true,
        ),
      );
    });
  }
}

class FilmBannerImage extends StatelessWidget {
  final String imageUrl;
  final bool useProxy;

  const FilmBannerImage({
    Key? key,
    required this.imageUrl,
    this.useProxy = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final screenWidth = MediaQuery.of(context).size.width;
    final cacheWidth = (screenWidth * devicePixelRatio).round();
    final cacheHeight = ((screenWidth / 2) * devicePixelRatio).round();

    final finalUrl = useProxy && imageUrl.startsWith('http')
        ? MovieImageUtils.proxyWrap(imageUrl)
        : imageUrl;

    final Widget img = imageUrl.startsWith('http')
        ? Image.network(
            finalUrl,
            fit: BoxFit.cover,
            cacheWidth: cacheWidth,
            cacheHeight: cacheHeight,
            gaplessPlayback: true,
          )
        : Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            cacheWidth: cacheWidth,
            cacheHeight: cacheHeight,
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.transparent],
            stops: [0.6, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: img,
      ),
    );
  }
}