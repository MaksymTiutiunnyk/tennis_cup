import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/routing/app_router.dart';
import 'package:tennis_cup/ui/view_only/player_details/view_models/player_tournaments_cubit.dart';
import 'package:tennis_cup/ui/view_only/player_details/widgets/player_info.dart';
import 'package:tennis_cup/ui/view_only/player_details/widgets/player_tournaments.dart';
import 'package:tennis_cup/ui/view_only/player_search/widgets/player_search.dart';

class ScrollableBody extends StatefulWidget {
  final User player;
  const ScrollableBody(this.player, {super.key});

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

  void _comparePlayers(BuildContext context, User player) {
    ScaffoldMessenger.of(context).clearSnackBars();
    if (widget.player == player) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(S.of(context).cannotCompareToSelf),
        ),
      );
      return;
    }
    context.pushReplacement(
      AppRoutes.playersComparison(
          widget.player.id.toString(), player.id.toString()),
    );
  }

  void _showSearchField() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => Scaffold(
        body: PlayerSearch(onSelectPlayer: _comparePlayers),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
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
                    _showSearchField();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text(s.participantToCompare),
                  ),
                ),
              ),
              PlayerTournaments(player: widget.player),
            ],
          ),
          Positioned(
            top: 365,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .shadow
                        .withValues(alpha: 0.25),
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
                child: const Text(
                  'VS',
                  style: TextStyle(height: 0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
