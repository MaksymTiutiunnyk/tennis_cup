import 'package:flutter/material.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/user/referee/view_models/referee_match_cubit.dart';
import 'package:tennis_cup/ui/user/referee/widgets/server_tile.dart';

class CenterPanel extends StatelessWidget {
  final RefereeMatchReady state;
  final User blue;
  final User red;
  final void Function(int) onSelectServer;
  final VoidCallback onStartMatch;

  const CenterPanel({
    super.key,
    required this.state,
    required this.blue,
    required this.red,
    required this.onSelectServer,
    required this.onStartMatch,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            s.firstServer,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          ServerTile(
            player: red,
            color: const Color(0xFFC62828),
            isSelected: state.firstServerPlayerId == red.id,
            onTap: () => onSelectServer(red.id),
          ),
          const SizedBox(height: 8),
          ServerTile(
            player: blue,
            color: const Color(0xFF1565C0),
            isSelected: state.firstServerPlayerId == blue.id,
            onTap: () => onSelectServer(blue.id),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: state.firstServerPlayerId == null ? null : onStartMatch,
            icon: const Icon(Icons.play_arrow),
            label: Text(s.startMatch),
          ),
        ],
      ),
    );
  }
}
