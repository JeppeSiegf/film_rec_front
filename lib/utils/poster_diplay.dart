import 'dart:math';

import 'package:flutter/material.dart';

enum PosterSize { large, medium, small }

/// Utility class for handling movie images and posters
class MovieImageUtils {
  /// Wraps an image URL with a proxy ti bypass CORS issues
 static String proxyWrap(String url) {
  const base = String.fromEnvironment(
    'PROXY_URL',
    defaultValue: 'https://www.siegf.org/proxy'
  );
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
  double screenHeight = MediaQuery.of(context).size.height;
  double width;
  double aspectRatio = 2 / 3;

  switch (size) {
    case PosterSize.large:
      width = screenWidth * 0.8;
      width = min(width, 400); // your max large size
      break;
    case PosterSize.medium:
      width = screenWidth * 0.24;
      break;
    case PosterSize.small:
    default:
      width = screenWidth * 0.08;
  }

  width = width.clamp(100.0, screenWidth); // width clamp

  // Compute height
  double height = width / aspectRatio;
  const maxHeightPercent = 0.65; 
  double maxHeight = screenHeight * maxHeightPercent;

  if (height > maxHeight) {
    height = maxHeight;
    width = height * aspectRatio; // maintain aspect ratio
  }

  // Pixel sizes for caching
  final dpr = MediaQuery.of(context).devicePixelRatio;
  final cacheWidth = (width * dpr).round();
  final cacheHeight = (height * dpr).round();

  // Apply proxy
  final finalUrl = useProxy && imageUrl.startsWith('http')
      ? proxyWrap(imageUrl)
      : imageUrl;

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

}}
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
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) return child;
              return frame != null 
                  ? child 
                  : AspectRatio(
                      aspectRatio: 2.0,
                      child: Container(color: Colors.transparent),
                    );
            },
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
            stops: [0.55, 0.95],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: img,
      ),
    );
  }
}