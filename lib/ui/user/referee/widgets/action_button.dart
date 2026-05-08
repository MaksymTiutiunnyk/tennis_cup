import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final bool filled;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.outlined = false,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    const style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(double.infinity, 36)),
      padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    if (filled) {
      return FilledButton.icon(
        style: style,
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12)),
      );
    }
    if (outlined) {
      return OutlinedButton.icon(
        style: style,
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12)),
      );
    }
    return TextButton.icon(
      style: style,
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
