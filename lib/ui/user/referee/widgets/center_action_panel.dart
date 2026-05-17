import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/user/referee/view_models/referee_match_cubit.dart';
import 'package:tennis_cup/ui/user/referee/widgets/action_button.dart';
import 'package:tennis_cup/ui/user/referee/widgets/card_chip.dart';
import 'package:tennis_cup/ui/user/referee/widgets/timeout_overlay.dart';

class CenterActionPanel extends StatefulWidget {
  final RefereeMatchReady state;
  final MatchSet activeSet;
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

  @override
  State<CenterActionPanel> createState() => _CenterActionPanelState();
}

class _CenterActionPanelState extends State<CenterActionPanel> {
  late final TextEditingController reasonCtrl;

  @override
  void initState() {
    super.initState();
    reasonCtrl = TextEditingController();
  }

  Future<bool> _confirm(BuildContext context, String title, String body) async {
    final s = S.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(s.confirm),
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
    final s = S.of(context);
    final blue = widget.state.bluePlayer;
    final red = widget.state.redPlayer;
    int? selectedId;

    reasonCtrl.text = '';

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
                if (eligibleIds.contains(player.id))
                  RadioListTile<int>(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text(player.fullName),
                    value: player.id,
                    groupValue: selectedId,
                    onChanged: (v) => setDialogState(() => selectedId = v),
                  ),
              if (withReason) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: reasonCtrl,
                  decoration: InputDecoration(
                    labelText: s.reasonOptional,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(s.cancel),
            ),
            FilledButton(
              onPressed:
                  selectedId == null ? null : () => Navigator.of(ctx).pop(true),
              child: Text(s.confirm),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || selectedId == null) return null;
    return (
      selectedId!,
      reasonCtrl.text.trim().isEmpty ? null : reasonCtrl.text.trim()
    );
  }

  Future<void> _onMedicalTimeout(BuildContext context) async {
    final s = S.of(context);
    final ok = await _confirm(
        context, s.medicalTimeoutTitle, s.medicalTimeoutContent);
    if (ok && context.mounted) {
      await TimeoutOverlay.show(context, TimeoutType.medical);
    }
  }

  Future<void> _onTechPause(BuildContext context) async {
    final s = S.of(context);
    final ok =
        await _confirm(context, s.technicalPauseTitle, s.technicalPauseContent);
    if (ok && context.mounted) {
      await TimeoutOverlay.show(context, TimeoutType.techPause);
    }
  }

  Future<void> _onTechDefeatMatch(BuildContext context) async {
    final s = S.of(context);
    final cubit = context.read<RefereeMatchCubit>();
    final result = await _selectPlayer(
      context,
      s.technicalDefeatMatch,
      [widget.state.bluePlayer.id, widget.state.redPlayer.id],
      withReason: true,
    );
    if (result != null && context.mounted) {
      final (loserId, reason) = result;
      cubit.technicalDefeatMatch(loserId, reason: reason);
    }
  }

  Future<void> _onFinishSet(BuildContext context) async {
    final s = S.of(context);
    final cubit = context.read<RefereeMatchCubit>();
    final ok = await _confirm(
        context, s.finishSet, s.finishSetConfirm(widget.activeSet.number));
    if (ok && context.mounted) {
      cubit.finishSet(widget.activeSet.number);
    }
  }

  Future<void> _onFinishSetAndMatch(BuildContext context) async {
    final s = S.of(context);
    final cubit = context.read<RefereeMatchCubit>();
    final ok = await _confirm(context, s.finishMatch,
        s.finishSetAndMatchConfirm(widget.activeSet.number));
    if (ok && context.mounted) {
      cubit.finishSetAndMatch(widget.activeSet.number);
    }
  }

  Future<void> _onFinishMatch(BuildContext context) async {
    final s = S.of(context);
    final cubit = context.read<RefereeMatchCubit>();
    final ok = await _confirm(context, s.finishMatch, s.finishMatchConfirm);
    if (ok && context.mounted) {
      cubit.finishMatch();
    }
  }

  Future<void> _onIssueCard(
      BuildContext context, String cardType, List<int> eligible) async {
    final s = S.of(context);
    final cubit = context.read<RefereeMatchCubit>();
    final result = await _selectPlayer(
      context,
      s.issueCardTitle(_cardLabel(cardType, s)),
      eligible,
    );
    if (result != null && context.mounted) {
      final (playerId, _) = result;
      await cubit.issueCard(playerId, cardType);
      if (context.mounted && cardType == 'WHITE') {
        await TimeoutOverlay.show(context, TimeoutType.general);
      }
    }
  }

  String _cardLabel(String cardType, S s) => switch (cardType) {
        'WHITE' => s.whiteCard,
        'YELLOW' => s.yellowCard,
        'RED' => s.redCard,
        _ => cardType,
      };

  bool get _wouldFinishMatch {
    if (!widget.canFinishSet) return false;
    final blueLeads =
        widget.activeSet.blueScore > widget.activeSet.redScore;
    return blueLeads
        ? (widget.blueSetsWon + 1 >= widget.state.match.setsToWin)
        : (widget.redSetsWon + 1 >= widget.state.match.setsToWin);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final cubit = context.read<RefereeMatchCubit>();

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              s.setNumber(widget.activeSet.number),
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Text(
              '${widget.leftIsRed ? widget.redSetsWon : widget.blueSetsWon} – ${widget.leftIsRed ? widget.blueSetsWon : widget.redSetsWon}',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            ActionButton(
              icon: Icons.medical_services_outlined,
              label: s.medicalButton,
              onPressed: widget.scoringLocked
                  ? null
                  : () => _onMedicalTimeout(context),
            ),
            const SizedBox(height: 2),

            ActionButton(
              icon: Icons.pause_circle_outline,
              label: s.techPauseButton,
              onPressed:
                  widget.scoringLocked ? null : () => _onTechPause(context),
            ),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(2),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: (widget.leftIsRed
                                ? widget.activeSet.redScore
                                : widget.activeSet.blueScore) >
                            0
                        ? (widget.leftIsRed
                            ? cubit.subtractPointRed
                            : cubit.subtractPointBlue)
                        : null,
                    child: Text(s.undoPoint),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(2),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: (widget.leftIsRed
                                ? widget.activeSet.blueScore
                                : widget.activeSet.redScore) >
                            0
                        ? (widget.leftIsRed
                            ? cubit.subtractPointBlue
                            : cubit.subtractPointRed)
                        : null,
                    child: Text(s.undoPoint),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            ActionButton(
              icon: Icons.close,
              label: s.tdMatchButton,
              onPressed: widget.scoringLocked
                  ? null
                  : () => _onTechDefeatMatch(context),
              outlined: true,
            ),
            const SizedBox(height: 8),

            if (widget.canFinishMatch)
              ActionButton(
                icon: Icons.emoji_events,
                label: s.finishMatch,
                onPressed: () => _onFinishMatch(context),
                filled: true,
              )
            else if (_wouldFinishMatch)
              ActionButton(
                icon: Icons.emoji_events,
                label: s.finishMatch,
                onPressed: () => _onFinishSetAndMatch(context),
                filled: true,
              )
            else
              ActionButton(
                icon: Icons.check_circle_outline,
                label: s.finishSet,
                onPressed:
                    widget.canFinishSet ? () => _onFinishSet(context) : null,
                filled: true,
              ),
            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: (!widget.scoringLocked && widget.state.canIssueWhite)
                      ? () => _onIssueCard(
                          context, 'WHITE', widget.state.eligibleWhitePlayers)
                      : null,
                  child: CardChip(
                      cardType: 'WHITE',
                      enabled:
                          !widget.scoringLocked && widget.state.canIssueWhite),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: (!widget.scoringLocked && widget.state.canIssueYellow)
                      ? () => _onIssueCard(
                          context, 'YELLOW', widget.state.eligibleYellowPlayers)
                      : null,
                  child: CardChip(
                      cardType: 'YELLOW',
                      enabled:
                          !widget.scoringLocked && widget.state.canIssueYellow),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: (!widget.scoringLocked && widget.state.canIssueRed)
                      ? () => _onIssueCard(
                          context, 'RED', widget.state.eligibleRedPlayers)
                      : null,
                  child: CardChip(
                      cardType: 'RED',
                      enabled:
                          !widget.scoringLocked && widget.state.canIssueRed),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    reasonCtrl.dispose();
    super.dispose();
  }
}
