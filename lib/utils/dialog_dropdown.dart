import 'package:film_rec_front/utils/dropdown_lists.dart';
import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatefulWidget {
  final List<T> items;
  final Map<T, roleInfo> iconMap;
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
  final offset = renderBox.localToGlobal(Offset.zero);
  final buttonSize = renderBox.size;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  return OverlayEntry(
    builder: (context) => GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _removeOverlay,
      child: Stack(
        children: [
          Positioned(
           right: MediaQuery.of(context).size.width - (offset.dx + buttonSize.width), // Align right edges
 
            top: offset.dy + buttonSize.height,
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 5),
                  ],
                ),
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: widget.items.map((item) => InkWell(
                      onTap: () {
                        widget.onItemSelected(item);
                        _removeOverlay();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                           
                            Text(
                              _capitalize(item.toString()),
                            
                              style: TextStyle(
                                
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(width: 5),
                             Icon(
                              widget.iconMap[item]?.icon ?? Icons.more_vert,
                              size: 18,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            
                          ],
                        ),
                      ),
                    )).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
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
              widget.iconMap[widget.selectedItem]?.icon ?? Icons.more_vert,
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