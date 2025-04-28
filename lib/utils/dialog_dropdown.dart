import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatefulWidget {
  final List<T> items;
  final Map<T, IconData> iconMap;
  final T selectedItem;
  final void Function(T) onItemSelected;

  const CustomDropdown({
    Key? key,
    required this.items,
    required this.iconMap,
    required this.selectedItem,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  _CustomDropdownState<T> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isMenuOpen = false;

  void _toggleDropdown() {
    if (_isMenuOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context)!.insert(_overlayEntry!);
    setState(() {
      _isMenuOpen = true;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isMenuOpen = false;
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size buttonSize = renderBox.size;
    final theme = Theme.of(context);

    return OverlayEntry(
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _removeOverlay,
          child: Stack(
            children: [
              Positioned(
                left: offset.dx,
                top: offset.dy + buttonSize.height,
                child: CompositedTransformFollower(
                  link: _layerLink,
                  offset: Offset(0, buttonSize.height),
                  showWhenUnlinked: false,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey[850]
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: IntrinsicWidth(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: widget.items.map((T item) {
                            return InkWell(
                              borderRadius: BorderRadius.zero,
                              onTap: () {
                                widget.onItemSelected(item);
                                _removeOverlay();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      widget.iconMap[item] ?? Icons.more_vert,
                                      size: 18,
                                      color: theme.brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _capitalize(item.toString()),
                                      style: TextStyle(
                                        color: theme.brightness == Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          padding: const EdgeInsets.all(6),
          // Wrap the icon in AnimatedSwitcher for smooth transitions
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Icon(
              widget.iconMap[widget.selectedItem] ?? Icons.more_vert,
              // Adding a key to ensure AnimatedSwitcher detects the change
              key: ValueKey<T>(widget.selectedItem),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}