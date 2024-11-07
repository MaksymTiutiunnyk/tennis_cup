import 'package:flutter/material.dart';

class PlayersStatistic extends StatelessWidget {
  final String label;
  final String player1, player2;
  const PlayersStatistic({
    required this.label,
    required this.player1,
    required this.player2,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.loose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Row(
            children: [
              Expanded(
                child: Card(
                  margin: const EdgeInsets.all(0),
                  shape: const RoundedRectangleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      player1,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  margin: const EdgeInsets.all(0),
                  shape: const RoundedRectangleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      player2,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
