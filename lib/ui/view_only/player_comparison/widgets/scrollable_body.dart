import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/ui/view_only/player_comparison/view_models/head_to_head_cubit.dart';
import 'package:tennis_cup/ui/view_only/player_comparison/widgets/players_intro.dart';
import 'package:tennis_cup/ui/view_only/player_comparison/widgets/players_matches.dart';
import 'package:tennis_cup/ui/view_only/player_comparison/widgets/players_statistics.dart';

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
    context.read<HeadToHeadCubit>().fetch();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels != 0) {
      context.read<HeadToHeadCubit>().fetch();
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
