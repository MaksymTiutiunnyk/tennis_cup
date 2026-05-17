import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/utils/error_utils.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';
import 'package:tennis_cup/data/services/dto/tournament_dto.dart';

part 'referee_tournaments_state.dart';

class RefereeTournamentsCubit extends Cubit<RefereeTournamentsState> {
  final TournamentRepository _repository;
  final String _userId;

  RefereeTournamentsCubit({
    required TournamentRepository repository,
    required String userId,
  })  : _repository = repository,
        _userId = userId,
        super(RefereeTournamentsLoading()) {
    _load();
  }

  Future<void> reload() async {
    emit(RefereeTournamentsLoading());
    await _load();
  }

  Future<void> _load() async {
    try {
      final tournaments =
          await _repository.fetchActiveTournamentsForReferee(_userId);
      if (isClosed) return;
      emit(RefereeTournamentsLoaded(tournaments));
    } catch (e) {
      if (isClosed) return;
      emit(RefereeTournamentsError(errorMessage(e)));
    }
  }
}
