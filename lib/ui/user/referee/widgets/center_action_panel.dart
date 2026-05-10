import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/services/dto/match_dto.dart';
import 'package:tennis_cup/ui/user/referee/view_models/referee_match_cubit.dart';
import 'package:tennis_cup/ui/user/referee/widgets/action_button.dart';
import 'package:tennis_cup/ui/user/referee/widgets/card_chip.dart';
import 'package:tennis_cup/ui/user/referee/widgets/timeout_overlay.dart';

class CenterActionPanel extends StatelessWidget {
  final RefereeMatchReady state;
  final MatchSetDto activeSet;
  final int blueSetsWon;
  final int redSetsWon;
  final bool scoringLocked;
  final bool leftIsRed;
  final bool canFinishSet;
  final bool canFinishMatch;

  const CenterActionPanel({
    super.key,
    required this.state,
    required this.activeSet,
    required this.blueSetsWon,
    required this.redSetsWon,
    required this.scoringLocked,
    required this.leftIsRed,
    required this.canFinishSet,
    required this.canFinishMatch,
  });

  // ── Helpers ──────────────────────────────────────────────────────────────

  Future<bool> _confirm(BuildContext context, String title, String body) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result == true;
  }

  /// Returns (playerId, reason) or null if cancelled.
  Future<(int, String?)?> _selectPlayer(
    BuildContext context,
    String title,
    List<int> eligibleIds, {
    bool withReason = false,
  }) async {
    final blue = state.bluePlayer;
    final red = state.redPlayer;
    int? selectedId;
    final reasonCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(title),
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final player in [blue, red])
                if (eligibleIds.contains(player.userId))
                  RadioListTile<int>(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text(player.fullName),
                    value: player.userId,
                    groupValue: selectedId,
                    onChanged: (v) => setDialogState(() => selectedId = v),
                  ),
              if (withReason) ...[
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed:
                  selectedId == null ? null : () => Navigator.of(ctx).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );

    reasonCtrl.dispose();
    if (confirmed != true || selectedId == null) return null;
    return (
      selectedId!,
      reasonCtrl.text.trim().isEmpty ? null : reasonCtrl.text.trim()
    );
  }

  // ── Action handlers ───────────────────────────────────────────────────────

  Future<void> _onMedicalTimeout(BuildContext context) async {
    final ok = await _confirm(
        context, 'Medical Timeout', 'Start a 10-minute medical timeout?');
    if (ok && context.mounted) {
      await TimeoutOverlay.show(context, TimeoutType.medical);
    }
  }

  Future<void> _onTechPause(BuildContext context) async {
    final ok =
        await _confirm(context, 'Technical Pause', 'Start a technical pause?');
    if (ok && context.mounted) {
      await TimeoutOverlay.show(context, TimeoutType.techPause);
    }
  }

  Future<void> _onTechDefeatMatch(BuildContext context) async {
    final cubit = context.read<RefereeMatchCubit>();
    final result = await _selectPlayer(
      context,
      'Technical Defeat — Match',
      [state.bluePlayer.userId, state.redPlayer.userId],
      withReason: true,
    );
    if (result != null && context.mounted) {
      final (loserId, reason) = result;
      cubit.technicalDefeatMatch(loserId, reason: reason);
    }
  }

  Future<void> _onFinishSet(BuildContext context) async {
    final cubit = context.read<RefereeMatchCubit>();
    final ok = await _confirm(
        context, 'Finish Set', 'Finish set ${activeSet.number}?');
    if (ok && context.mounted) {
      cubit.finishSet(activeSet.number);
    }
  }

  Future<void> _onFinishSetAndMatch(BuildContext context) async {
    final cubit = context.read<RefereeMatchCubit>();
    final ok = await _confirm(context, 'Finish Match',
        'Finish set ${activeSet.number} and end the match?');
    if (ok && context.mounted) {
      cubit.finishSetAndMatch(activeSet.number);
    }
  }

  Future<void> _onFinishMatch(BuildContext context) async {
    final cubit = context.read<RefereeMatchCubit>();
    final ok = await _confirm(context, 'Finish Match', 'Finish the match?');
    if (ok && context.mounted) {
      cubit.finishMatch();
    }
  }

  Future<void> _onIssueCard(
      BuildContext context, String cardType, List<int> eligible) async {
    final cubit = context.read<RefereeMatchCubit>();
    final result = await _selectPlayer(
      context,
      'Issue ${_cardLabel(cardType)} Card',
      eligible,
    );
    if (result != null && context.mounted) {
      final (playerId, _) = result;
      await cubit.issueCard(playerId, cardType);
      // White card = timeout; show the 1-minute overlay after backend confirms.
      if (context.mounted && cardType == 'WHITE') {
        await TimeoutOverlay.show(context, TimeoutType.general);
      }
    }
  }

  String _cardLabel(String cardType) => switch (cardType) {
        'WHITE' => 'White (Timeout)',
        'YELLOW' => 'Yellow (Warning)',
        'RED' => 'Red (Penalty)',
        _ => cardType,
      };

  // ── Finish button logic ───────────────────────────────────────────────────

  // True when finishing this set would also decide the match (best of 5).
  bool get _wouldFinishMatch {
    if (!canFinishSet) return false;
    final blueLeads = activeSet.bluePlayerScore > activeSet.redPlayerScore;
    return blueLeads ? (blueSetsWon + 1 >= 3) : (redSetsWon + 1 >= 3);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RefereeMatchCubit>();

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Set number + match score
            Text(
              'Set ${activeSet.number}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Text(
              '${leftIsRed ? redSetsWon : blueSetsWon} – ${leftIsRed ? blueSetsWon : redSetsWon}',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Medical timeout — disabled when set/match can be finished
            ActionButton(
              icon: Icons.medical_services_outlined,
              label: 'Medical',
              onPressed:
                  scoringLocked ? null : () => _onMedicalTimeout(context),
            ),
            const SizedBox(height: 4),

            // Tech pause — disabled when set/match can be finished
            ActionButton(
              icon: Icons.pause_circle_outline,
              label: 'Tech Pause',
              onPressed: scoringLocked ? null : () => _onTechPause(context),
            ),
            const SizedBox(height: 4),

            // –1 point buttons (left player / right player)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: (leftIsRed
                                ? activeSet.redPlayerScore
                                : activeSet.bluePlayerScore) >
                            0
                        ? (leftIsRed
                            ? cubit.subtractPointRed
                            : cubit.subtractPointBlue)
                        : null,
                    child: const Text('–1'),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton(
                    onPressed: (leftIsRed
                                ? activeSet.bluePlayerScore
                                : activeSet.redPlayerScore) >
                            0
                        ? (leftIsRed
                            ? cubit.subtractPointBlue
                            : cubit.subtractPointRed)
                        : null,
                    child: const Text('–1'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Tech defeat match — disabled when set/match can be finished
            ActionButton(
              icon: Icons.close,
              label: 'TD Match',
              onPressed:
                  scoringLocked ? null : () => _onTechDefeatMatch(context),
              outlined: true,
            ),
            const SizedBox(height: 4),

            // Finish Set / Finish Match (contextual)
            if (canFinishMatch)
              ActionButton(
                icon: Icons.emoji_events,
                label: 'Finish Match',
                onPressed: () => _onFinishMatch(context),
                filled: true,
              )
            else if (_wouldFinishMatch)
              ActionButton(
                icon: Icons.emoji_events,
                label: 'Finish Match',
                onPressed: () => _onFinishSetAndMatch(context),
                filled: true,
              )
            else
              ActionButton(
                icon: Icons.check_circle_outline,
                label: 'Finish Set',
                onPressed: canFinishSet ? () => _onFinishSet(context) : null,
                filled: true,
              ),
            const SizedBox(height: 8),

            // Cards row — disabled when set/match can be finished
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: (!scoringLocked && state.canIssueWhite)
                      ? () => _onIssueCard(
                          context, 'WHITE', state.eligibleWhitePlayers)
                      : null,
                  child: CardChip(
                      cardType: 'WHITE',
                      enabled: !scoringLocked && state.canIssueWhite),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: (!scoringLocked && state.canIssueYellow)
                      ? () => _onIssueCard(
                          context, 'YELLOW', state.eligibleYellowPlayers)
                      : null,
                  child: CardChip(
                      cardType: 'YELLOW',
                      enabled: !scoringLocked && state.canIssueYellow),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: (!scoringLocked && state.canIssueRed)
                      ? () =>
                          _onIssueCard(context, 'RED', state.eligibleRedPlayers)
                      : null,
                  child: CardChip(
                      cardType: 'RED',
                      enabled: !scoringLocked && state.canIssueRed),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
