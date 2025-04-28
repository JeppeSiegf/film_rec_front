import 'package:film_rec_front/data/models.dart';
import 'package:film_rec_front/theme/theme_manager.dart';
import 'package:flutter/material.dart';

/// Utility class for handling movie titles and text elements
class MovieTextUtils {
  static double calculateTextWidth(TextSpan text, BuildContext context) {
    final tp = TextPainter(
      text: text,
      textDirection: Directionality.of(context),
    )..layout();
    return tp.width;
  }

  static Widget buildMovieTitle({
    required Film film,
    required BuildContext context,
    bool includeYear = true,
    TextAlign textAlign = TextAlign.start,
    bool animateLocaleChanges = true,
    int? maxLines,
    TextStyle? titleStyle,
    TextStyle? yearStyle,
    bool useOppositeLanguage = false, // New parameter
  }) {
    final locale = LocalizationManager.locale.languageCode;
    final title = useOppositeLanguage
        ? (locale == 'local' ? film.originalTitle : film.title)
        : (locale == 'local' ? film.title : film.originalTitle);
    
    Widget titleWidget = Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: title,
            style: titleStyle ?? Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (includeYear) TextSpan(
            text: ' (${film.releaseYear})',
            style: yearStyle ?? Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 12.0,
            ),
          ),
        ],
      ),
      textAlign: textAlign,
      maxLines: maxLines ?? 2,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
    );
    
    if (animateLocaleChanges) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: KeyedSubtree(
          key: ValueKey<String>(locale + title),
          child: titleWidget,
        ),
      );
    } else {
      return titleWidget;
    }
  }
}