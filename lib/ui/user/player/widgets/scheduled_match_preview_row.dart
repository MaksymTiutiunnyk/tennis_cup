import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/models/scheduled_match_preview.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/generated/l10n.dart';

final DateFormat _formatter = DateFormat('HH:mm');

class ScheduledMatchPreviewRow extends StatelessWidget {
  final ScheduledMatchPreview match;
  const ScheduledMatchPreviewRow({super.key, required this.match});

  Widget _playerText(BuildContext context, User? player) {
    final theme = Theme.of(context);
    if (player == null) {
      return Text(
        S.of(context).notDefined,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontStyle: FontStyle.italic,
          color: theme.disabledColor,
        ),
      );
    }
    return Text(player.fullName, style: theme.textTheme.bodyMedium);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatter.format(match.scheduledStart),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _playerText(context, match.bluePlayer),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _playerText(context, match.redPlayer),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 2),
      ],
    );
  }
}
