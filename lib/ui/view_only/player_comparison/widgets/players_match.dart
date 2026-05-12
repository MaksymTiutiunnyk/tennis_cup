import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/routing/app_router.dart';
import 'package:tennis_cup/ui/view_only/home/view_models/live_match_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/arena_filter_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/schedule_date_cubit.dart';
import 'package:tennis_cup/ui/view_only/schedule/view_models/time_filter_cubit.dart';

final _dateTimeFormatter = DateFormat('yyyy-MM-dd, HH:mm');

class PlayersMatch extends StatelessWidget {
  final Player player1, player2;
  final Match match;

  const PlayersMatch({
    super.key,
    required this.player1,
    required this.player2,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LiveMatchCubit(
        matchId: match.matchId,
        matchRepository: ServiceLocator.matchRepository,
        initialMatch: match,
      ),
      child: BlocBuilder<LiveMatchCubit, Match?>(
        builder: (context, live) => _PlayersMatchBody(
          player1: player1,
          player2: player2,
          match: live ?? match,
        ),
      ),
    );
  }
}

class _PlayersMatchBody extends StatelessWidget {
  final Player player1, player2;
  final Match match;

  const _PlayersMatchBody({
    required this.player1,
    required this.player2,
    required this.match,
  });

  Future<void> _onTap(BuildContext context) async {
    final tournament =
        await ServiceLocator.tournamentRepository.fetchTournamentById(
      tournamentId: match.tournamentId,
      withPlayers: false,
      withMatches: false,
    );
    if (!context.mounted) return;
    context.read<ScheduleDateCubit>().selectDate(tournament.date);
    context.read<ArenaFilterCubit>().selectArena(tournament.arena);
    context.read<TimeFilterCubit>().selectTime(tournament.time);
    context.go(AppRoutes.viewSchedule);
  }

  @override
  Widget build(BuildContext context) {
    final bool isPlayer1Blue = match.bluePlayer == player1;

    final int player1Score = isPlayer1Blue ? match.blueScore : match.redScore;
    final int player2Score = isPlayer1Blue ? match.redScore : match.blueScore;

    final List<int> player1SetScores =
        isPlayer1Blue ? match.blueSetScores : match.redSetScores;
    final List<int> player2SetScores =
        isPlayer1Blue ? match.redSetScores : match.blueSetScores;

    final displayedSetScores = List.generate(
      player1SetScores.length,
      (i) => '${player1SetScores[i]}-${player2SetScores[i]}',
    );

    return InkWell(
      onTap: () => _onTap(context),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _dateTimeFormatter.format(match.dateTime),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                match.isTechnicalDefeat
                    ? (match.winnerId == player1.userId ? 'W : L' : 'L : W')
                    : '$player1Score : $player2Score',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              if (!match.isTechnicalDefeat)
                Text(
                  '(${displayedSetScores.join(', ')})',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
