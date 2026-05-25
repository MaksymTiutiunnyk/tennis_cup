import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/utils/error_utils.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/models/tournament_invitation.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';

part 'my_tournaments_state.dart';

class MyTournamentsCubit extends Cubit<MyTournamentsState> {
  final TournamentRepository _repository;
  final String _userId;
  final InvitationRole _role;

  MyTournamentsCubit({
    required TournamentRepository repository,
    required String userId,
    required InvitationRole role,
  })  : _repository = repository,
        _userId = userId,
        _role = role,
        super(MyTournamentsLoading()) {
    _load();
  }

  Future<void> reload() async {
    emit(MyTournamentsLoading());
    await _load();
  }

  Future<void> _load() async {
    try {
      final tournaments = _role == InvitationRole.referee
          ? await _repository.fetchMyTournamentsAsReferee(_userId)
          : await _repository.fetchMyTournamentsAsPlayer(_userId);
      if (isClosed) return;
      emit(MyTournamentsLoaded(tournaments));
    } catch (e) {
      if (isClosed) return;
      emit(MyTournamentsError(errorMessage(e)));
    }
  }
}
