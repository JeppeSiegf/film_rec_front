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
    // Consider mobile if Android/iOS or web on a small screen
    return platform == TargetPlatform.android ||
        platform == TargetPlatform.iOS ||
        (!kIsWeb && MediaQuery.of(context).size.shortestSide < 600) ||
        (kIsWeb && MediaQuery.of(context).size.shortestSide < 600);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => !_isMobile ? _setHovered(true) : null,
      onExit: (_) => !_isMobile ? _setHovered(false) : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _isMobile ? (_) => _touchController.forward() : null,
        onTapUp: _isMobile ? (_) => _touchController.reverse() : null,
        onTapCancel: _isMobile ? () => _touchController.reverse() : null,
        onPanDown: _isMobile ? (_) => _touchController.forward() : null,
        onPanEnd: _isMobile ? (_) => _touchController.reverse() : null,
        onPanCancel: _isMobile ? () => _touchController.reverse() : null,
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
              // Touch effect for mobile
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
