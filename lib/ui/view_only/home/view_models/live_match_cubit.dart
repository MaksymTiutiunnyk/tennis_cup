import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/repositories/match_repository.dart';

class LiveMatchCubit extends Cubit<Match?> {
  final MatchRepository matchRepository;
  final String _matchId;
  late final StreamSubscription<Match> _sub;

  LiveMatchCubit({
    required String matchId,
    required this.matchRepository,
    Match? initialMatch,
  })  : _matchId = matchId,
        super(initialMatch) {
    if (initialMatch == null) _fetch();
    _sub = matchRepository.watchMatchChanges(matchId).listen(emit);
  }

  void _fetch() async {
    final match = await matchRepository.fetchMatchById(matchId: _matchId);
    emit(match);
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
