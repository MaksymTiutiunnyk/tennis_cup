import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/data_providers/match_api.dart';
import 'package:tennis_cup/data/repositories/match_repository.dart';
import 'package:tennis_cup/data/models/match.dart';

class MatchChangesCubit extends Cubit<void> {
  final Match match;
  late StreamSubscription subscription;
  final matchRepository = const MatchRepository(matchApi: MatchApi());

  MatchChangesCubit(this.match) : super(null) {
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
