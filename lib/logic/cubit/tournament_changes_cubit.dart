import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';

class TournamentChangesCubit extends Cubit<void> {
  final String tournamentId;
  final TournamentRepository tournamentRepository;
  late StreamSubscription subscription;

  TournamentChangesCubit({
    required this.tournamentId,
    required this.tournamentRepository,
  }) : super(null) {
    subscription = tournamentRepository
        .watchTournamentChanges(tournamentId)
        .listen((event) {
      emit(event);
    });
  }

  @override
  Future<void> close() {
    subscription.cancel();
    return super.close();
  }
}
