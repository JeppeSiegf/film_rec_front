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
  final Function()? onTap;
 
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

class _HoverOverlayState extends State<HoverOverlay> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isDesktopOrWeb = false;
  
  // For mobile touch feedback
  late AnimationController _touchController;
  late Animation<double> _touchAnimation;

  @override
  void initState() {
    super.initState();
    // Determine if we're on desktop/web platforms
    _isDesktopOrWeb = kIsWeb || 
        Platform.isWindows || 
        Platform.isMacOS || 
        Platform.isLinux;
    
    // Initialize animation controller for touch feedback
    _touchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _touchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _touchController,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOut,
      ),
    );
    
    _touchController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _touchController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _touchController.dispose();
    super.dispose();
  }

  void _setHovered(bool hovered) {
    if (_isHovered != hovered) {
      setState(() => _isHovered = hovered);
    }
  }

  void _handleTap() {
    // Show brief overlay effect on mobile
    if (!_isDesktopOrWeb) {
      _touchController.forward();
    }
    
    // Call the original onTap if provided
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: ClipRRect(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              widget.child,
              // For desktop hover effect
              if (_isDesktopOrWeb)
                AnimatedOpacity(
                  opacity: _isHovered ? 1.0 : 0.0,
                  duration: widget.duration,
                  curve: Curves.easeInOut,
                  child: _buildOverlay(),
                ),
              // For mobile touch effect
              if (!_isDesktopOrWeb)
                AnimatedBuilder(
                  animation: _touchAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _touchAnimation.value,
                      child: _buildOverlay(),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildOverlay() {
    return Container(
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
}