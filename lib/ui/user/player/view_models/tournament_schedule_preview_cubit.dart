import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/utils/error_utils.dart';
import 'package:tennis_cup/data/models/scheduled_match_preview.dart';
import 'package:tennis_cup/data/repositories/match_repository.dart';

part 'tournament_schedule_preview_state.dart';

class TournamentSchedulePreviewCubit
    extends Cubit<TournamentSchedulePreviewState> {
  final MatchRepository _repository;
  final int _tournamentId;

  TournamentSchedulePreviewCubit({
    required MatchRepository repository,
    required int tournamentId,
  })  : _repository = repository,
        _tournamentId = tournamentId,
        super(TournamentSchedulePreviewLoading()) {
    _load();
  }

  Future<void> reload() async {
    emit(TournamentSchedulePreviewLoading());
    await _load();
  }

  Future<void> _load() async {
    try {
      final matches =
          await _repository.fetchTournamentSchedulePreview(_tournamentId);
      matches.sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));
      if (isClosed) return;
      emit(TournamentSchedulePreviewLoaded(matches));
    } catch (e) {
      if (isClosed) return;
      emit(TournamentSchedulePreviewError(errorMessage(e)));
    }
  }
}
