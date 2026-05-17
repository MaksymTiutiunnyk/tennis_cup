import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/services/dto/tournament_dto.dart';
import 'package:tennis_cup/ui/user/referee/view_models/referee_match_cubit.dart';
import 'package:tennis_cup/ui/user/referee/view_models/tournament_matches_cubit.dart';
import 'package:tennis_cup/ui/user/referee/widgets/match_management_screen.dart';
import 'package:tennis_cup/ui/user/referee/widgets/pending_match_view.dart';

class TournamentManagementScreen extends StatefulWidget {
  final TournamentDto tournament;

  const TournamentManagementScreen({
    super.key,
    required this.tournament,
  });

  @override
  State<TournamentManagementScreen> createState() =>
      _TournamentManagementScreenState();
}

class _TournamentManagementScreenState
    extends State<TournamentManagementScreen> {
  late final RefereeMatchCubit _matchCubit;
  late final TournamentMatchesCubit _matchesCubit;

  @override
  void initState() {
    super.initState();
    _matchCubit = RefereeMatchCubit(repository: ServiceLocator.matchRepository);
    _matchesCubit = TournamentMatchesCubit(
      repository: ServiceLocator.matchRepository,
      tournamentId: widget.tournament.id,
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _matchCubit.close();
    _matchesCubit.close();
    super.dispose();
  }

  void _triggerCurrentMatch(List<Match> matches) {
    final current = matches
        .where((m) =>
            m.status == MatchStatus.active || m.status == MatchStatus.pending)
        .firstOrNull;
    if (current != null) _matchCubit.load(current.id);
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _matchCubit),
        BlocProvider.value(value: _matchesCubit),
      ],
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(8, topInset + 4, 8, 4),
              child: SizedBox(
                height: 44,
                child: Row(
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 40,
                        height: 40,
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Back',
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.tournament.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 40,
                        height: 40,
                      ),
                      onPressed: _matchesCubit.load,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocConsumer<TournamentMatchesCubit, TournamentMatchesState>(
      listener: (context, state) {
        if (state is TournamentMatchesLoaded) {
          _triggerCurrentMatch(state.matches);
        }
      },
      builder: (context, matchesState) {
        if (matchesState is TournamentMatchesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (matchesState is TournamentMatchesError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(matchesState.message),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _matchesCubit.load,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final matches =
            (matchesState as TournamentMatchesLoaded).matches;

        if (matches.isEmpty) {
          return const Center(child: Text('No matches found'));
        }

        final allDone = matches.every((m) =>
            m.status == MatchStatus.finished ||
            m.status == MatchStatus.technicalDefeat);
        if (allDone) {
          return const Center(child: Text('Tournament complete'));
        }

        return BlocConsumer<RefereeMatchCubit, RefereeMatchState>(
          listenWhen: (prev, curr) {
            if (curr is! RefereeMatchReady) return false;
            final done = curr.match.status == MatchStatus.finished ||
                curr.match.status == MatchStatus.technicalDefeat;
            if (!done) return false;
            if (prev is! RefereeMatchReady) return true;
            return prev.match.status != curr.match.status;
          },
          listener: (context, state) => _matchesCubit.load(),
          builder: (context, matchState) {
            if (matchState is RefereeMatchLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (matchState is RefereeMatchReady &&
                matchState.match.status == MatchStatus.pending) {
              return PendingMatchView(
                state: matchState,
                onStartMatch: () async {
                  await context.read<RefereeMatchCubit>().startMatch();
                },
              );
            }

            if (matchState is RefereeMatchReady &&
                matchState.match.status == MatchStatus.active) {
              return const MatchManagementScreen();
            }

            if (matchState is RefereeMatchError) {
              return Center(child: Text(matchState.message));
            }

            return const Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }
}
