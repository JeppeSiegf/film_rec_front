import 'package:flutter/material.dart';

/// A widget that shows an overlay icon on hover (desktop) or on touch down (mobile).
class HoverOverlay extends StatefulWidget {
  final Widget child;
  final IconData icon;
  final double iconSize;
  final Duration duration;
  final BorderRadius? borderRadius;
  
  const HoverOverlay({
    Key? key,
    required this.child,
    this.icon = Icons.play_circle_outline,
    this.iconSize = 50.0,
    this.duration = const Duration(milliseconds: 300),
    this.borderRadius,
  }) : super(key: key);

  @override
  _HoverOverlayState createState() => _HoverOverlayState();
}

class _HoverOverlayState extends State<HoverOverlay> {
  bool _isHovered = false;

  void _setHovered(bool hovered) {
    if (_isHovered != hovered) {
      setState(() => _isHovered = hovered);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (_) => _setHovered(true),
        onTapUp: (_) => _setHovered(false),
        onTapCancel: () => _setHovered(false),
        child: ClipRRect(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              widget.child,
              AnimatedOpacity(
                opacity: _isHovered ? 1.0 : 0.0,
                duration: widget.duration,
                curve: Curves.easeInOut,
                child: Container(
                  color: const Color.fromARGB(146, 216, 209, 209),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      size: widget.iconSize,
                      color: const Color.fromARGB(225, 61, 59, 61),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}