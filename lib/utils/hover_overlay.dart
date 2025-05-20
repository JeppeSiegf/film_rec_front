import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb

/// A widget that shows an overlay icon on hover (desktop/web) or on touch (mobile).
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

class _HoverOverlayState extends State<HoverOverlay>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _touchController;
  late Animation<double> _touchAnimation;

  @override
  void initState() {
    super.initState();
    _touchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _touchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _touchController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _touchController.dispose();
    super.dispose();
  }

  void _setHovered(bool hovered) {
    if (_isHovered != hovered) setState(() => _isHovered = hovered);
  }

  bool get _isMobile {
    final platform = Theme.of(context).platform;
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    // On web, just use shortestSide for mobile detection (no window/userAgent)
    return platform == TargetPlatform.android ||
        platform == TargetPlatform.iOS ||
        shortestSide < 600;
  }

  @override
  Widget build(BuildContext context) {
    // Use GestureDetector for all platforms, and always show overlay on tap down for mobile (including mobile browsers)
    return Listener(
      onPointerDown: _isMobile ? (_) => _touchController.forward() : null,
      onPointerUp: _isMobile ? (_) => _touchController.reverse() : null,
      onPointerCancel: _isMobile ? (_) => _touchController.reverse() : null,
      child: MouseRegion(
        onEnter: (_) => !_isMobile ? _setHovered(true) : null,
        onExit: (_) => !_isMobile ? _setHovered(false) : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                widget.child,
                // Hover effect for desktop/web
                if (!_isMobile)
                  AnimatedOpacity(
                    opacity: _isHovered ? 1 : 0,
                    duration: widget.duration,
                    curve: Curves.easeInOut,
                    child: _buildOverlay(),
                  ),
                // Touch effect for mobile (including mobile browsers)
                if (_isMobile)
                  AnimatedBuilder(
                    animation: _touchAnimation,
                    builder: (context, child) => Opacity(
                      opacity: _touchAnimation.value,
                      child: _buildOverlay(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay() => Container(
        color: const Color.fromARGB(146, 216, 209, 209),
        child: Center(
          child: Icon(
            widget.icon,
            size: widget.iconSize,
            color: const Color.fromARGB(225, 61, 59, 61),
          ),
        ),
      );
}
