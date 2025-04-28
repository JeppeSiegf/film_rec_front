import 'package:flutter/material.dart';

class TagListUtils {

  static Widget buildTagList({
    required List<String> tags,
    required BuildContext context,
    Color? backgroundColor,
    TextStyle? textStyle,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    double spacing = 6.0,
    double runSpacing = 4.0,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    WrapAlignment alignment = WrapAlignment.start,
    Function(String)? onTagTap,
  }) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      alignment: alignment,
      children: tags.map((tag) {
        return GestureDetector(
          onTap: onTagTap != null ? () => onTagTap(tag) : null,
          child: IntrinsicWidth(
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: backgroundColor ?? Theme.of(context).colorScheme.secondary.withAlpha(25),
                borderRadius: borderRadius,
              ),
              child: Text(
                tag,
                style: textStyle ?? Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10.0,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}