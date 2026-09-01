import 'package:flutter/material.dart';

/// Кругла іконкова кнопка у стилі Material Elevated.
class AppElevatedIconButton extends StatelessWidget {
  const AppElevatedIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  final Widget icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(12),
          minimumSize: const Size.square(40),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: IconTheme.merge(
          data: const IconThemeData(size: 22),
          child: icon,
        ),
      ),
    );
  }
}
