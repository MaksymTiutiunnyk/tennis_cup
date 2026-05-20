import 'package:flutter/material.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/generated/l10n.dart';

class TournamentStatusChip extends StatelessWidget {
  final TournamentStatus status;

  const TournamentStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final (label, color) = switch (status) {
      TournamentStatus.active => (s.statusActive, Colors.green),
      TournamentStatus.finished => (s.statusFinished, Colors.grey),
      TournamentStatus.pending => (s.statusPending, Colors.orange),
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
