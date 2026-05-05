import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/services/dto/match_dto.dart';
import 'package:tennis_cup/ui/user/referee/view_models/referee_match_cubit.dart';

class ActionBar extends StatelessWidget {
  final RefereeMatchReady state;
  final MatchSetDto activeSet;
  final int blueSetsWon;
  final int redSetsWon;

  const ActionBar({
    super.key,
    required this.state,
    required this.activeSet,
    required this.blueSetsWon,
    required this.redSetsWon,
  });

  Future<void> _showTechDefeatDialog(BuildContext context, bool isMatch) async {
    final cubit = context.read<RefereeMatchCubit>();
    int? selectedLoserId;
    final reasonCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Technical Defeat'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<int>(
                title: Text(
                    '${state.bluePlayer.name} ${state.bluePlayer.surname}'),
                value: int.tryParse(state.bluePlayer.playerId) ?? -1,
                groupValue: selectedLoserId,
                onChanged: (v) => setDialogState(() => selectedLoserId = v),
              ),
              RadioListTile<int>(
                title:
                    Text('${state.redPlayer.name} ${state.redPlayer.surname}'),
                value: int.tryParse(state.redPlayer.playerId) ?? -1,
                groupValue: selectedLoserId,
                onChanged: (v) => setDialogState(() => selectedLoserId = v),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(
                  labelText: 'Reason (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: selectedLoserId == null
                  ? null
                  : () => Navigator.of(ctx).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && selectedLoserId != null && context.mounted) {
      final reason =
          reasonCtrl.text.trim().isEmpty ? null : reasonCtrl.text.trim();
      if (isMatch) {
        cubit.technicalDefeatMatch(selectedLoserId!, reason: reason);
      } else {
        cubit.technicalDefeatSet(activeSet.number, selectedLoserId!,
            reason: reason);
      }
    }
    reasonCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RefereeMatchCubit>();
    final canUndo = state.scoreUndoStack.isNotEmpty;

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Finish Set, Tech Defeat Set, Undo
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () => cubit.finishSet(activeSet.number),
                  child: const Text('Finish Set'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showTechDefeatDialog(context, false),
                  child: const Text('Tech Defeat'),
                ),
              ),
              const SizedBox(width: 6),
              IconButton.outlined(
                onPressed: canUndo ? cubit.undoLastScore : null,
                icon: const Icon(Icons.undo),
                tooltip: 'Undo last point',
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Row 2: Medical Timeout, Tech Pause
          Row(
            children: [
              Expanded(
                child: Tooltip(
                  message: 'Not implemented yet',
                  child: OutlinedButton.icon(
                    onPressed: cubit.medicalTimeout,
                    icon: const Icon(Icons.medical_services_outlined),
                    label: const Text('Medical'),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Tooltip(
                  message: 'Not implemented yet',
                  child: OutlinedButton.icon(
                    onPressed: cubit.technicalPause,
                    icon: const Icon(Icons.pause_circle_outline),
                    label: const Text('Tech Pause'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Row 3: Finish Match / Tech Defeat Match
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () => _showTechDefeatDialog(context, true),
                  child: const Text('Tech Defeat Match'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: FilledButton(
                  onPressed: cubit.finishMatch,
                  child: const Text('Finish Match'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
