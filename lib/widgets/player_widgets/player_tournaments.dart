import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/player.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/providers/player_tournaments_notifier.dart';
import 'package:tennis_cup/widgets/player_widgets/player_tournament.dart';

class PlayerTournaments extends ConsumerStatefulWidget {
  final Player player;

  const PlayerTournaments({super.key, required this.player});

  @override
  ConsumerState createState() => _PlayerTournamentsState();
}

class _PlayerTournamentsState extends ConsumerState<PlayerTournaments> {
  late StateNotifierProvider<PlayerTournamentsNotifier,
      AsyncValue<List<Tournament>>> _playerTournamentsProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _playerTournamentsProvider = StateNotifierProvider<
            PlayerTournamentsNotifier, AsyncValue<List<Tournament>>>(
        (ref) => PlayerTournamentsNotifier(widget.player));

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await ref.read(_playerTournamentsProvider.notifier).fetchTournaments();
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
      ref.read(_playerTournamentsProvider.notifier).fetchTournaments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerTournaments = ref.watch(_playerTournamentsProvider);

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
            child: playerTournaments.when(
              data: (playerTournaments) {
                if (playerTournaments.isEmpty) {
                  return const Center(child: Text('No tournaments found'));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  controller: _scrollController,
                  itemCount: playerTournaments.length,
                  itemBuilder: (ctx, index) => PlayerTournament(
                    tournament: playerTournaments[index],
                    player: widget.player,
                  ),
                );
              },
              error: (error, stackTrace) => const Center(
                child: Text('Ooops, something went wrong'),
              ),
              loading: () => const CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}
