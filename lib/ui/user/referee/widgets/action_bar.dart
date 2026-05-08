import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/services/dto/match_dto.dart';
import 'package:tennis_cup/ui/user/referee/view_models/referee_match_cubit.dart';

class ActionBar extends StatelessWidget {
  final RefereeMatchReady state;
  final MatchSetDto activeSet;
  final int blueSetsWon;
  final int redSetsWon;
  final bool compact;

  const ActionBar({
    super.key,
    required this.state,
    required this.activeSet,
    required this.blueSetsWon,
    required this.redSetsWon,
    this.compact = false,
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
          scrollable: true,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<int>(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: Text(
                    '${state.bluePlayer.name} ${state.bluePlayer.surname}',
                  ),
                  value: state.bluePlayer.userId,
                  groupValue: selectedLoserId,
                  onChanged: (v) => setDialogState(() => selectedLoserId = v),
                ),
                RadioListTile<int>(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: Text(
                    '${state.redPlayer.name} ${state.redPlayer.surname}',
                  ),
                  value: state.redPlayer.userId,
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
        cubit.technicalDefeatSet(
          activeSet.number,
          selectedLoserId!,
          reason: reason,
        );
      }
    }
    reasonCtrl.dispose();
  }

  Widget _scrollingRow({
    required List<Widget> children,
    double? height,
  }) {
    return SizedBox(
      height: height,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: children),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RefereeMatchCubit>();
    final canUndo = state.scoreUndoStack.isNotEmpty;
    final buttonWidth = compact ? 132.0 : 168.0;
    final buttonHeight = compact ? 40.0 : 44.0;
    final compactDensity =
        compact ? VisualDensity.compact : VisualDensity.standard;

    final filledStyle = FilledButton.styleFrom(
      minimumSize: Size(buttonWidth, buttonHeight),
      visualDensity: compactDensity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 16,
        vertical: compact ? 10 : 14,
      ),
    );
    final tonalStyle = FilledButton.styleFrom(
      minimumSize: Size(buttonWidth, buttonHeight),
      visualDensity: compactDensity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 16,
        vertical: compact ? 10 : 14,
      ),
    );
    final outlinedStyle = OutlinedButton.styleFrom(
      minimumSize: Size(buttonWidth, buttonHeight),
      visualDensity: compactDensity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 16,
        vertical: compact ? 10 : 14,
      ),
    );

    return SafeArea(
      top: false,
      child: Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        padding: EdgeInsets.all(compact ? 6 : 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _scrollingRow(
              height: buttonHeight,
              children: [
                FilledButton(
                  style: filledStyle,
                  onPressed: () => cubit.finishSet(activeSet.number),
                  child: const Text('Finish Set'),
                ),
                const SizedBox(width: 6),
                OutlinedButton(
                  style: outlinedStyle,
                  onPressed: () => _showTechDefeatDialog(context, false),
                  child: const Text('Tech Defeat'),
                ),
                const SizedBox(width: 6),
                IconButton.outlined(
                  onPressed: canUndo ? cubit.undoLastScore : null,
                  icon: const Icon(Icons.undo),
                  tooltip: 'Undo last point',
                  visualDensity: compactDensity,
                ),
              ],
            ),
            const SizedBox(height: 6),
            _scrollingRow(
              height: buttonHeight,
              children: [
                OutlinedButton.icon(
                  style: outlinedStyle,
                  onPressed: cubit.medicalTimeout,
                  icon: const Icon(Icons.medical_services_outlined),
                  label: const Text('Medical'),
                ),
                const SizedBox(width: 6),
                OutlinedButton.icon(
                  style: outlinedStyle,
                  onPressed: cubit.technicalPause,
                  icon: const Icon(Icons.pause_circle_outline),
                  label: const Text('Tech Pause'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _scrollingRow(
              height: buttonHeight,
              children: [
                FilledButton.tonal(
                  style: tonalStyle,
                  onPressed: () => _showTechDefeatDialog(context, true),
                  child: const Text('Tech Defeat Match'),
                ),
                const SizedBox(width: 6),
                FilledButton(
                  style: filledStyle,
                  onPressed: cubit.finishMatch,
                  child: const Text('Finish Match'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
