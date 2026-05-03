import 'package:flutter/material.dart';

class TournamentStatusChip extends StatelessWidget {
  final String status;

  const TournamentStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'ACTIVE' => ('Active', Colors.green),
      'FINISHED' => ('Finished', Colors.grey),
      'CANCELLED' => ('Cancelled', Colors.red),
      _ => ('Pending', Colors.orange),
    };
    return Chip(
      label: Text(label,
          style: const TextStyle(fontSize: 11, color: Colors.white)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
