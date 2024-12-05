import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/logic/cubit/player_tournaments_cubit.dart';
import 'package:tennis_cup/presentation/screens/players_comparison.dart';
import 'package:tennis_cup/presentation/widgets/player_search.dart';
import 'package:tennis_cup/presentation/widgets/player_widgets/player_info.dart';
import 'package:tennis_cup/presentation/widgets/player_widgets/player_tournaments.dart';

class PlayerDetailsScrollable extends StatefulWidget {
  final Player player;
  const PlayerDetailsScrollable(this.player, {super.key});

  @override
  State<PlayerDetailsScrollable> createState() {
    return _PlayerDetailsScrollableState();
  }
}

class _PlayerDetailsScrollableState extends State<PlayerDetailsScrollable> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<PlayerTournamentsCubit>().fetchTournaments();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels != 0) {
      context.read<PlayerTournamentsCubit>().fetchTournaments();
    }
  }

  void _comparePlayers(BuildContext context, Player player) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => PlayersComparison(
        player1: widget.player,
        player2: player,
      ),
    ));
  }

  void _showSearchField(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => PlayerSearch(onSelectPlayer: _comparePlayers),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PlayerInfo(widget.player),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showSearchField(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(18.0),
                    child: Text('Participant to compare'),
                  ),
                ),
              ),
              PlayerTournaments(player: widget.player),
            ],
          ),
          Positioned(
            top: 367,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.25),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 25,
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                child: const Text('VS'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
