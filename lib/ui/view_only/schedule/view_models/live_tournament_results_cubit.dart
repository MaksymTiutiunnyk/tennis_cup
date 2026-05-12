import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/repositories/match_repository.dart';

class LiveTournamentResultsCubit extends Cubit<Tournament> {
  final MatchRepository _matchRepository;
  final List<StreamSubscription<Match>> _subs = [];

  LiveTournamentResultsCubit({
    required Tournament initial,
    required MatchRepository matchRepository,
  })  : _matchRepository = matchRepository,
        super(initial) {
    _subscribeAll(initial);
  }

  void _subscribeAll(Tournament tournament) {
    for (final match in tournament.matches ?? []) {
      final sub = _matchRepository
          .watchMatchChanges(match.matchId)
          .listen(_onMatchUpdate);
      _subs.add(sub);
    }
  }

  void _onMatchUpdate(Match updated) {
    final matches = state.matches?.map((m) {
      return m.matchId == updated.matchId ? updated : m;
    }).toList();
    emit(Tournament(
      tournamentId: state.tournamentId,
      name: state.name,
      gender: state.gender,
      status: state.status,
      players: state.players,
      matches: matches,
      date: state.date,
      arena: state.arena,
      time: state.time,
      points: state.points,
      places: state.places,
      isFinished: state.isFinished,
      refereeId: state.refereeId,
      setsToWin: state.setsToWin,
      requiredPlayersCount: state.requiredPlayersCount,
      matchDurationMinutes: state.matchDurationMinutes,
      participantInvitations: state.participantInvitations,
      refereeInvitations: state.refereeInvitations,
    ));
  }

  @override
  Future<void> close() {
    for (final sub in _subs) {
      sub.cancel();
    }
    return super.close();
  }
}
