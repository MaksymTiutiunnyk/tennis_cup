import 'package:flutter/material.dart';
import 'package:tennis_cup/data/models/tournament.dart';

class TournamentStatusChip extends StatelessWidget {
  final TournamentStatus status;

  const TournamentStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      TournamentStatus.active => ('Active', Colors.green),
      TournamentStatus.finished => ('Finished', Colors.grey),
      TournamentStatus.pending => ('Pending', Colors.orange),
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
