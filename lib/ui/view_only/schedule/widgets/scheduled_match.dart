import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/routing/app_router.dart';

DateFormat formatter = DateFormat('HH:mm');

class ScheduledMatch extends StatelessWidget {
  final Match match;
  const ScheduledMatch({super.key, required this.match});

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
                    formatter.format(match.dateTime),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  IconButton(
                    onPressed: () => context.push(
                      AppRoutes.playersComparison(
                        match.bluePlayer.userId.toString(),
                        match.redPlayer.userId.toString(),
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
                          match.bluePlayer.userId.toString()),
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
                      match.blueScore.toString(),
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
                          match.redPlayer.userId.toString()),
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
                      match.redScore.toString(),
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
