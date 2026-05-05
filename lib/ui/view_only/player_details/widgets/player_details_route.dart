import 'package:flutter/material.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/ui/view_only/player_details/widgets/player_details.dart';

class PlayerDetailsRoute extends StatefulWidget {
  final String playerId;
  final Player? cached;

  const PlayerDetailsRoute({super.key, required this.playerId, this.cached});

  @override
  State<PlayerDetailsRoute> createState() => _PlayerDetailsRouteState();
}

class _PlayerDetailsRouteState extends State<PlayerDetailsRoute> {
  late Future<Player> _future;

  @override
  void initState() {
    super.initState();
    final cached = widget.cached;
    if (cached != null && cached.playerId == widget.playerId) {
      _future = Future.value(cached);
    } else {
      // TODO: replace with cubit
      _future =
          ServiceLocator.playerRepository.fetchPlayerById(widget.playerId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Player>(
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
            body: const Center(child: Text('Player not found')),
          );
        }
        return PlayerDetails(player: snapshot.data!);
      },
    );
  }
}
