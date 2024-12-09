import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/logic/cubit/players_tournaments_cubit.dart';
import 'package:tennis_cup/presentation/widgets/comparison_widgets.dart/players_intro.dart';
import 'package:tennis_cup/presentation/widgets/comparison_widgets.dart/players_matches.dart';
import 'package:tennis_cup/presentation/widgets/comparison_widgets.dart/players_statistics.dart';

class ScrollableBody extends StatefulWidget {
  final Player player1, player2;

  const ScrollableBody(
      {super.key, required this.player1, required this.player2});

  @override
  State<ScrollableBody> createState() {
    return _ScrollableBodyState();
  }
}

class _ScrollableBodyState extends State<ScrollableBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<PlayersTournamentsCubit>().fetchTournaments();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels != 0) {
      context.read<PlayersTournamentsCubit>().fetchTournaments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PlayersIntro(player1: widget.player1, player2: widget.player2),
          PlayersStatistics(player1: widget.player1, player2: widget.player2),
          PlayersMatches(player1: widget.player1, player2: widget.player2),
        ],
      ),
    );
  }
}
