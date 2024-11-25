import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/player.dart';
import 'package:tennis_cup/model/match.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/providers/players_tournaments_notifier.dart';
import 'package:tennis_cup/widgets/comparison_widgets.dart/players_match.dart';

class PlayersMatches extends ConsumerStatefulWidget {
  final Player player1, player2;
  const PlayersMatches(
      {super.key, required this.player1, required this.player2});

  @override
  ConsumerState<PlayersMatches> createState() {
    return _PlayersMatchesState();
  }
}

class _PlayersMatchesState extends ConsumerState<PlayersMatches> {
  late StateNotifierProvider<PlayersTournamentsNotifier,
      AsyncValue<List<Tournament>>> _playersTournamentsProvider;

  List<PlayersMatch> _getPlayersMatches(Tournament tournament) {
    final List<PlayersMatch> playersMatches = [];

    for (Match match in tournament.matches!) {
      if ((match.bluePlayer.playerId == widget.player1.playerId ||
              match.redPlayer.playerId == widget.player1.playerId) &&
          (match.bluePlayer.playerId == widget.player2.playerId ||
              match.redPlayer.playerId == widget.player2.playerId)) {
        playersMatches.add(PlayersMatch(
          player1: widget.player1,
          player2: widget.player2,
          match: match,
          tournament: tournament,
        ));
      }
    }

    return playersMatches;
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _playersTournamentsProvider = StateNotifierProvider<
            PlayersTournamentsNotifier, AsyncValue<List<Tournament>>>(
        (ref) => PlayersTournamentsNotifier(
              player1: widget.player1,
              player2: widget.player2,
            ));

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await ref.read(_playersTournamentsProvider.notifier).fetchTournaments();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels != 0) {
      ref.read(_playersTournamentsProvider.notifier).fetchTournaments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final playersTournaments = ref.watch(_playersTournamentsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(
            children: [
              const Icon(Icons.people),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  "Players' matches: ${widget.player1.fullName} vs ${widget.player2.fullName}",
                  softWrap: true,
                ),
              ),
            ],
          ),
        ),
        Flexible(
          fit: FlexFit.loose,
          child: playersTournaments.when(
            data: (playersTournaments) {
              final playersMatches = [];
              for (Tournament tournament in playersTournaments) {
                playersMatches.addAll(_getPlayersMatches(tournament));
              }
              if (playersMatches.isEmpty) {
                return const Center(child: Text('No matches found'));
              }
              return ListView.builder(
                shrinkWrap: true,
                controller: _scrollController,
                itemCount: playersMatches.length,
                itemBuilder: (context, index) => playersMatches[index],
              );
            },
            error: (error, stackTrace) =>
                const Center(child: Text('Unexpacted error')),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }
}
