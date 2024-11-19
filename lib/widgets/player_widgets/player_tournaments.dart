import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/player.dart';
import 'package:tennis_cup/providers/player_tournaments_provider.dart';
import 'package:tennis_cup/widgets/player_widgets/player_tournament.dart';

class PlayerTournaments extends ConsumerStatefulWidget {
  final Player player;

  const PlayerTournaments({super.key, required this.player});

  @override
  ConsumerState createState() => _PlayerTournamentsState();
}

class _PlayerTournamentsState extends ConsumerState<PlayerTournaments> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    ref
        .read(playerTournamentsProvider.notifier)
        .fetchTournaments(playerId: widget.player.id);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels != 0) {
      ref
          .read(playerTournamentsProvider.notifier)
          .fetchTournaments(playerId: widget.player.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerTournaments = ref.watch(playerTournamentsProvider);

    Widget content = ListView.builder(
      shrinkWrap: true,
      controller: _scrollController,
      itemCount: playerTournaments['tournaments'].length,
      itemBuilder: (ctx, index) => PlayerTournament(
        playerTournaments['tournaments'][index],
      ),
    );
    if (playerTournaments['isLoading'] &&
        playerTournaments['tournaments'].length == 0) {
      content = const CircularProgressIndicator();
    }
    if (!playerTournaments['isLoading'] &&
        playerTournaments['tournaments'].length == 0) {
      content = const Center(child: Text('No tournaments found'));
    }

    return Flexible(
      fit: FlexFit.loose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(8.0, 16, 8, 8),
            child: Row(
              children: [
                Icon(Icons.emoji_events),
                SizedBox(width: 8),
                Text('Tournaments'),
              ],
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: content,
          ),
        ],
      ),
    );
  }
}
