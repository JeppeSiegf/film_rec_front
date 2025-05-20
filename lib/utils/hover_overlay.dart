import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// A widget that shows an overlay icon on hover (desktop) or on touch (mobile).
class HoverOverlay extends StatefulWidget {
  final Widget child;
  final IconData icon;
  final double iconSize;
  final Duration duration;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
 
  const HoverOverlay({
    Key? key,
    required this.child,
    this.icon = Icons.play_circle_outline,
    this.iconSize = 50.0,
    this.duration = const Duration(milliseconds: 300),
    this.borderRadius,
    this.onTap,
  }) : super(key: key);

  @override
  _HoverOverlayState createState() => _HoverOverlayState();
}

class _HoverOverlayState extends State<HoverOverlay> {
  bool _isHovered = false;
  bool _isTouched = false;
  bool _isDesktopOrWeb = false;

  @override
  void initState() {
    super.initState();
    // Determine if we're on desktop/web platforms
    _isDesktopOrWeb = kIsWeb || 
        Platform.isWindows || 
        Platform.isMacOS || 
        Platform.isLinux;
  }

  void _setHovered(bool hovered) {
    if (_isHovered != hovered) {
      setState(() => _isHovered = hovered);
    }
  }

  void _setTouched(bool touched) {
    if (_isTouched != touched) {
      setState(() => _isTouched = touched);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _isDesktopOrWeb ? _setHovered(true) : null,
      onExit: (_) => _isDesktopOrWeb ? _setHovered(false) : null,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.onTap,
        onTapDown: (_) {
          if (!_isDesktopOrWeb) _setTouched(true);
        },
        onTapUp: (_) {
          // Keep touch state for a moment before hiding overlay
          if (!_isDesktopOrWeb) {
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) _setTouched(false);
            });
          }
        },
        onTapCancel: () {
          if (!_isDesktopOrWeb) _setTouched(false);
        },
        // Handle long press for mobile devices
        onLongPress: () {
          if (!_isDesktopOrWeb) _setTouched(true);
        },
        onLongPressEnd: (_) {
          if (!_isDesktopOrWeb) {
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) _setTouched(false);
            });
          }
        },
        child: ClipRRect(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              widget.child,
              AnimatedOpacity(
                opacity: (_isDesktopOrWeb && _isHovered) || (!_isDesktopOrWeb && _isTouched) ? 1.0 : 0.0,
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