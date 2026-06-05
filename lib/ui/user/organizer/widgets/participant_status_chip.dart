import 'package:flutter/material.dart';

/// A chip showing a selected participant's [label] (their name), tinted by their
/// invitation [status] (ACCEPTED / PENDING / DECLINED / CANCELLED).
///
/// The content color is derived from the resolved background so it stays
/// readable in any theme. When the status is unknown, both background and
/// content defer to the chip's theme defaults. Pass [onDeleted] to show the
/// delete affordance; leave it null for a read-only chip.
class ParticipantStatusChip extends StatelessWidget {
  final String label;
  final String? status;
  final VoidCallback? onDeleted;

  const ParticipantStatusChip({
    super.key,
    required this.label,
    this.status,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final background = switch (status?.toUpperCase()) {
      'ACCEPTED' => Colors.green[900],
      'PENDING' => Colors.blue[900],
      'DECLINED' => Colors.red[900],
      'CANCELLED' => Colors.grey[700],
      _ => null,
    };
    // No status-specific background: defer to theme defaults so content stays
    // readable in both light and dark themes. Otherwise pick a foreground that
    // contrasts with the resolved background.
    final foreground = background == null
        ? null
        : ThemeData.estimateBrightnessForColor(background) == Brightness.dark
            ? Colors.white
            : Colors.black;
    return Chip(
      label: Text(label, style: TextStyle(color: foreground)),
      backgroundColor: background,
      onDeleted: onDeleted,
      deleteIconColor: foreground,
    );
  }
}
