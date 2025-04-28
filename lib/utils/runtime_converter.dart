import 'package:flutter/material.dart';

class RunTimeConverter {
  
  static String formatRuntime(
    int runTimeMinutes, {
    bool expandedText = false,
    bool omitZeroUnits = true,
  }) {
    final hours = runTimeMinutes ~/ 60;
    final minutes = runTimeMinutes % 60;
    final parts = <String>[];

    if (!omitZeroUnits || hours > 0) {
      if (expandedText) {
        parts.add('$hours ${hours == 1 ? "hour" : "hours"}');
      } else {
        parts.add('${hours}h');
      }
    }
    if (!omitZeroUnits || minutes > 0) {
      if (expandedText) {
        parts.add('$minutes ${minutes == 1 ? "minute" : "minutes"}');
      } else {
        parts.add('${minutes}m');
      }
    }

   
    if (parts.isEmpty) {
      return expandedText ? '0 minutes' : '0m';
    }

    return parts.join(' ');
  }

  static Widget buildRuntimeText(
    int runTimeMinutes, {
    required BuildContext context,
    TextStyle? style,
    bool expandedText = false,
    bool omitZeroUnits = true,
    TextAlign? textAlign,
  }) {
    final txt = formatRuntime(
      runTimeMinutes,
      expandedText: expandedText,
      omitZeroUnits: omitZeroUnits,
    );
    return Text(
      txt,
      style: style ?? Theme.of(context).textTheme.bodySmall,
      textAlign: textAlign,
    );
  }
}
