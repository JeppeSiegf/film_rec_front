import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';


class LazyLoad extends StatefulWidget {

  final WidgetBuilder builder;
  final double visibilityThreshold;

  const LazyLoad({
    Key? key,
    required this.builder,
    this.visibilityThreshold = 0.1,
  }) : super(key: key);

  @override
  _LazyLoadState createState() => _LazyLoadState();
}

class _LazyLoadState extends State<LazyLoad> {
  bool _visibleOnce = false;

  @override
  Widget build(BuildContext context) {
    if (_visibleOnce) {
      
      return widget.builder(context);
    }

    return VisibilityDetector(
      key: UniqueKey(),
      onVisibilityChanged: (info) {
        if (!_visibleOnce && info.visibleFraction >= widget.visibilityThreshold) {
          setState(() => _visibleOnce = true);
        }
      },
      child: SizedBox(
        
        width: double.infinity,
        height: double.infinity,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
