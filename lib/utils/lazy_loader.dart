import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class LazyLoad extends StatefulWidget {
  final WidgetBuilder builder;
  final double preloadOffset; // fraction of the widget height to trigger early load
  final Duration fadeDuration;
  final Widget? placeholder;

  const LazyLoad({
    Key? key,
      required this.builder,
      this.preloadOffset = 1.5, // start loading when half the widget away from viewport
    this.fadeDuration = const Duration(milliseconds: 300),
    this.placeholder,
  }) : super(key: key);

  @override
  _LazyLoadState createState() => _LazyLoadState();
}

class _LazyLoadState extends State<LazyLoad> {
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    if (_loaded) {
      return AnimatedSwitcher(
        duration: widget.fadeDuration,
        child: widget.builder(context),
      );
    }

    return VisibilityDetector(
      key: UniqueKey(),
      onVisibilityChanged: (info) {
        if (!_loaded && info.visibleFraction + widget.preloadOffset >= 1.0) {
          // start loading before fully visible
          setState(() => _loaded = true);
        }
      },
      child: widget.placeholder ??
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Center(child: CircularProgressIndicator()),
          ),
    );
  }
}
