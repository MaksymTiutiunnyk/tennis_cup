import 'package:flutter/material.dart';

class NoActiveSetView extends StatelessWidget {
  final int blueSetsWon;
  final int redSetsWon;
  final int? pendingSetNumber;
  final bool canFinish;
  final VoidCallback? onStartSet;
  final VoidCallback onFinish;

  const NoActiveSetView({
    super.key,
    required this.blueSetsWon,
    required this.redSetsWon,
    required this.canFinish,
    required this.onFinish,
    this.pendingSetNumber,
    this.onStartSet,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sets: $blueSetsWon – $redSetsWon',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (pendingSetNumber != null && onStartSet != null)
                FilledButton.icon(
                  onPressed: onStartSet,
                  icon: const Icon(Icons.play_arrow),
                  label: Text('Start Set $pendingSetNumber'),
                ),
              if (canFinish) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: onFinish,
                  icon: const Icon(Icons.flag),
                  label: const Text('Finish Match'),
                ),
              ],
            ],
          ),
        ),
    );
  }
}
