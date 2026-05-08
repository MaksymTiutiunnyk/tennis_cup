import 'package:flutter/material.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/ui/view_only/player_comparison/widgets/players_comparison.dart';

class PlayersComparisonRoute extends StatefulWidget {
  final String userId1;
  final String userId2;

  const PlayersComparisonRoute({
    super.key,
    required this.userId1,
    required this.userId2,
  });

  @override
  State<PlayersComparisonRoute> createState() => _PlayersComparisonRouteState();
}

class _PlayersComparisonRouteState extends State<PlayersComparisonRoute> {
  late Future<(Player, Player)> _future;

  @override
  void initState() {
    super.initState();
    _future = Future.wait([
      ServiceLocator.playerRepository
          .fetchPlayerById(int.parse(widget.userId1)),
      ServiceLocator.playerRepository
          .fetchPlayerById(int.parse(widget.userId2)),
    ]).then((list) => (list[0], list[1]));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(Player, Player)>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Players not found')),
          );
        }
        final (p1, p2) = snapshot.data!;
        return PlayersComparison(player1: p1, player2: p2);
      },
    );
  }
}
