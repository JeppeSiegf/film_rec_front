import 'package:flutter/material.dart';

class RatingsDisplay extends StatelessWidget {
  final double rating;
  final int maxRating;
  final String? serviceName;
  final Color starColor;
  final Color linkColor;
  final VoidCallback? onServiceTap;

  const RatingsDisplay({
    super.key,
    required this.rating,
    this.maxRating = 10,
    this.serviceName,
    this.starColor = Colors.amber,
    this.linkColor = const Color(0xFF6E7982), // default gray
    this.onServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    final double fillPercent = (rating / maxRating).clamp(0, 1);
    final int fullStars = (fillPercent * 5).floor();
    final bool hasHalfStar = (fillPercent * 5) - fullStars >= 0.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        

        const SizedBox(height: 6),

        // rating text
        Text(
          '${rating.toStringAsFixed(1)} / $maxRating',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 6),

        // stars row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            if (index < fullStars) {
              return Icon(Icons.star, size: 18, color: starColor);
            } else if (index == fullStars && hasHalfStar) {
              return Icon(Icons.star_half, size: 18, color: starColor);
            } else {
              return Icon(Icons.star_border, size: 18, color: starColor);
            }
          }),
        ),

        // service name + external-link icon (centered, gray by default)
        if (serviceName != null) ...[
          const SizedBox(height: 6),
          InkWell(
            onTap: onServiceTap ?? () => debugPrint('Open placeholder for $serviceName'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  serviceName!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: linkColor,
                    decoration: TextDecoration.underline,
                    decorationColor: linkColor,
                    decorationThickness: 1.0,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.open_in_new,
                  size: 8,
                  color: linkColor,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
