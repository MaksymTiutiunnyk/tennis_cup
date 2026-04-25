import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/repositories/match_repository.dart';

class MatchChangesCubit extends Cubit<void> {
  final Match match;
  final MatchRepository matchRepository;
  late StreamSubscription subscription;

  MatchChangesCubit(this.match, {required this.matchRepository}) : super(null) {
    subscription =
        matchRepository.watchMatchChanges(match.matchId).listen((event) {
      emit(event);
    });
  }

  @override
  Future<void> close() {
    subscription.cancel();
    return super.close();
  }
}
