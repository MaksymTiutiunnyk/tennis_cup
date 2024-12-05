import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/data_providers/tournament_api.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';

class TournamentChangesCubit extends Cubit<void> {
  final String tournamentId;
  late StreamSubscription subscription;
  final tournamentRepository =
      TournamentRepository(tournamentApi: TournamentApi());

  TournamentChangesCubit({required this.tournamentId}) : super(null) {
    subscription =
        tournamentRepository.watchMatchChanges(tournamentId).listen((event) {
      emit(event);
    });
  }

  @override
  Future<void> close() {
    subscription.cancel();
    return super.close();
  }
}
