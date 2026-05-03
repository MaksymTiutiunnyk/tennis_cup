import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament.dart';
import 'package:tennis_cup/data/repositories/tournament_repository.dart';

export 'package:tennis_cup/data/services/dto/tournament_dto.dart'
    show CreateTournamentRequestDto, UpdateTournamentRequestDto;

part 'organizer_tournaments_state.dart';

class OrganizerTournamentsCubit extends Cubit<OrganizerTournamentsState> {
  final TournamentRepository _repository;

  DateTime? _date;
  Arena? _arena;
  Time? _time;

  OrganizerTournamentsCubit({required TournamentRepository repository})
      : _repository = repository,
        super(OrgTournamentsLoading());

  Future<void> load({
    required DateTime date,
    required Arena arena,
    required Time time,
  }) async {
    _date = date;
    _arena = arena;
    _time = time;
    emit(OrgTournamentsLoading());
    try {
      final tournaments = await _repository.fetchScheduledTournament(
        tournamentDate: date,
        tournamentArena: arena,
        tournamentTime: time,
      );
      emit(OrgTournamentsLoaded(tournaments));
    } catch (e) {
      emit(OrgTournamentsError(_message(e)));
    }
  }

  Future<void> create(CreateTournamentRequestDto dto) async {
    try {
      await _repository.createTournament(dto);
      await _reload();
    } catch (e) {
      emit(OrgTournamentsError(_message(e)));
    }
  }

  Future<void> update(int id, UpdateTournamentRequestDto dto) async {
    try {
      await _repository.updateTournament(id, dto);
      await _reload();
    } catch (e) {
      emit(OrgTournamentsError(_message(e)));
    }
  }

  Future<void> delete(int id) async {
    final current = state;
    if (current is OrgTournamentsLoaded) {
      emit(OrgTournamentsLoaded(current.tournaments
          .where((t) => t.tournamentId != id.toString())
          .toList()));
    }
    try {
      await _repository.deleteTournament(id);
    } catch (e) {
      if (current is OrgTournamentsLoaded) emit(current);
      emit(OrgTournamentsError(_message(e)));
    }
  }

  Future<void> start(int id) async {
    try {
      await _repository.startTournament(id);
      await _reload();
    } catch (e) {
      emit(OrgTournamentsError(_message(e)));
    }
  }

  Future<void> finish(int id) async {
    try {
      await _repository.finishTournament(id);
      await _reload();
    } catch (e) {
      emit(OrgTournamentsError(_message(e)));
    }
  }

  Future<void> addPlayers(int tournamentId, List<int> playerIds) async {
    try {
      await _repository.addPlayers(tournamentId, playerIds);
      await _reload();
    } catch (e) {
      emit(OrgTournamentsError(_message(e)));
    }
  }

  Future<void> removePlayers(int tournamentId, List<int> playerIds) async {
    try {
      await _repository.removePlayers(tournamentId, playerIds);
      await _reload();
    } catch (e) {
      emit(OrgTournamentsError(_message(e)));
    }
  }

  Future<void> _reload() async {
    if (_date == null || _arena == null || _time == null) return;
    await load(date: _date!, arena: _arena!, time: _time!);
  }

  static String _message(Object e) =>
      e is Exception ? e.toString().replaceFirst('Exception: ', '') : '$e';
}
