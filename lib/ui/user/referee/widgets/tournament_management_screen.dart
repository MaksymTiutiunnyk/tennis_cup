import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/di/service_locator.dart';
import 'package:tennis_cup/data/services/dto/match_dto.dart';
import 'package:tennis_cup/data/services/dto/tournament_dto.dart';
import 'package:tennis_cup/ui/user/referee/view_models/referee_match_cubit.dart';
import 'package:tennis_cup/ui/user/referee/widgets/match_management_screen.dart';
import 'package:tennis_cup/ui/user/referee/widgets/pending_match_view.dart';

class TournamentManagementScreen extends StatefulWidget {
  final TournamentDto tournament;
  const TournamentManagementScreen({super.key, required this.tournament});

  @override
  State<TournamentManagementScreen> createState() =>
      _TournamentManagementScreenState();
}

class _TournamentManagementScreenState
    extends State<TournamentManagementScreen> {
  late final RefereeMatchCubit _matchCubit;
  List<MatchDto>? _matches;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _matchCubit =
        RefereeMatchCubit(repository: ServiceLocator.refereeRepository);
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    _loadMatches();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _matchCubit.close();
    super.dispose();
  }

  Future<void> _loadMatches() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final matches = await ServiceLocator.refereeRepository
          .fetchMatchesForTournament(widget.tournament.id);
      // Sort ACTIVE first, then PENDING by scheduled time
      int matchRank(MatchDto m) => m.status == 'ACTIVE'
          ? 0
          : m.status == 'PENDING'
              ? 1
              : 2;
      matches.sort((a, b) {
        final r = matchRank(a).compareTo(matchRank(b));
        if (r != 0) return r;
        return a.scheduledStart.compareTo(b.scheduledStart);
      });
      setState(() {
        _matches = matches;
        _loading = false;
      });
      _triggerCurrentMatch(matches);
    } catch (e) {
      setState(() {
        _error = 'Failed to load matches';
        _loading = false;
      });
    }
  }

  void _triggerCurrentMatch(List<MatchDto> matches) {
    final current = matches
        .where((m) => m.status == 'ACTIVE' || m.status == 'PENDING')
        .firstOrNull;
    if (current != null) _matchCubit.load(current.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _matchCubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.tournament.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadMatches,
            ),
          ],
        ),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            TextButton(onPressed: _loadMatches, child: const Text('Retry')),
          ],
        ),
      );
    }

    final matches = _matches ?? [];
    if (matches.isEmpty) {
      return const Center(child: Text('No matches found'));
    }

    final allDone = matches
        .every((m) => m.status == 'FINISHED' || m.status == 'TECHNICAL_DEFEAT');
    if (allDone) {
      return const Center(child: Text('Tournament complete'));
    }

    return BlocBuilder<RefereeMatchCubit, RefereeMatchState>(
      builder: (context, matchState) {
        if (matchState is RefereeMatchLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (matchState is RefereeMatchReady &&
            matchState.match.status == 'PENDING') {
          return PendingMatchView(
            state: matchState,
            onStartMatch: () async {
              await context.read<RefereeMatchCubit>().startMatch();
              _loadMatches();
            },
          );
        }

        if (matchState is RefereeMatchReady &&
            matchState.match.status == 'ACTIVE') {
          return const MatchManagementScreen();
        }

        if (matchState is RefereeMatchError) {
          return Center(child: Text(matchState.message));
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
