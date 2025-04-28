import 'package:flutter/material.dart';

class BasePopupDialog extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final double maxHeight;

  const BasePopupDialog({
    Key? key, 
    required this.child,
    this.maxWidth = 400,
    this.maxHeight = 600,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        ),
        child: child,
      ),
    );
  }
}


void showAppPopup<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
}) {
  showDialog<T>(
    context: context,
    builder: builder,
  );
}
