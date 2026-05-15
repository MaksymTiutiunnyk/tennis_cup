import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/routing/app_router.dart';
import 'package:tennis_cup/ui/view_only/home/view_models/live_match_cubit.dart';

DateFormat formatter = DateFormat('HH:mm');

class ScheduledMatch extends StatelessWidget {
  final Match match;
  const ScheduledMatch({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LiveMatchCubit(
        matchId: match.id.toString(),
        matchRepository: ServiceLocator.matchRepository,
        initialMatch: match,
      ),
      child: BlocBuilder<LiveMatchCubit, Match?>(
        builder: (context, live) => _ScheduledMatchBody(match: live ?? match),
      ),
    );
  }
}

class _ScheduledMatchBody extends StatelessWidget {
  final Match match;
  const _ScheduledMatchBody({required this.match});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatter.format(match.scheduledStart),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  IconButton(
                    onPressed: () => context.push(
                      AppRoutes.playersComparison(
                        match.bluePlayer.id.toString(),
                        match.redPlayer.id.toString(),
                      ),
                      extra: (p1: match.bluePlayer, p2: match.redPlayer),
                    ),
                    icon: const Icon(Icons.people),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => context.push(
                      AppRoutes.playerDetails(
                          match.bluePlayer.id.toString()),
                      extra: match.bluePlayer,
                    ),
                    child: Text(
                      match.bluePlayer.fullName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      match.isTechnicalDefeat
                          ? (match.winnerId == match.bluePlayer.id
                              ? 'W'
                              : 'L')
                          : match.blueScore.toString(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => context.push(
                      AppRoutes.playerDetails(
                          match.redPlayer.id.toString()),
                      extra: match.redPlayer,
                    ),
                    child: Text(
                      match.redPlayer.fullName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      match.isTechnicalDefeat
                          ? (match.winnerId == match.redPlayer.id
                              ? 'W'
                              : 'L')
                          : match.redScore.toString(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 2),
      ],
    );
  }
}
