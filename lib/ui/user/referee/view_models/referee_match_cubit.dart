import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/data/repositories/match_repository.dart';
import 'package:tennis_cup/generated/l10n.dart';

part 'referee_match_state.dart';

class RefereeMatchCubit extends Cubit<RefereeMatchState> {
  final MatchRepository _repository;

  RefereeMatchCubit({required MatchRepository repository})
      : _repository = repository,
        super(RefereeMatchLoading());

  Future<void> load(int matchId) async {
    emit(RefereeMatchLoading());
    try {
      final match = await _repository.fetchMatchWithPlayers(matchId);
      if (isClosed) return;
      emit(RefereeMatchReady(match: match));
    } catch (e) {
      if (isClosed) return;
      emit(RefereeMatchError(e.toString()));
    }
  }

  Future<void> _reload() async {
    final current = state;
    if (current is! RefereeMatchReady) return;
    try {
      final match = await _repository.fetchMatchWithPlayers(current.match.id);
      if (isClosed) return;
      emit(current.copyWith(match: match));
    } catch (e) {
      if (isClosed) return;
      emit(RefereeMatchError(e.toString()));
    }
  }

  void setFirstServer(int id) {
    final s = state;
    if (s is! RefereeMatchReady) return;
    emit(s.copyWith(firstServerPlayerId: id));
  }

  Future<void> startMatch() async {
    final s = state;
    if (s is! RefereeMatchReady) return;
    if (s.firstServerPlayerId == null) {
      emit(s.copyWith(notification: S.current.selectFirstServer));
      return;
    }
    try {
      final startedMatch =
          await _repository.startMatch(s.match.id, s.firstServerPlayerId!);
      final firstPendingSetNumber = startedMatch.sets
              .where((set) => set.status == SetStatus.pending)
              .firstOrNull
              ?.number ??
          1;
      try {
        await _repository.startSet(s.match.id, firstPendingSetNumber);
      } catch (_) {
        // startSet may fail if server needs a moment; _reload will show the pending set
      }
      await _reload();
    } catch (e) {
      if (isClosed) return;
      emit(RefereeMatchError(e.toString()));
    }
  }

  Future<void> startSet(int setNumber) async {
    final s = state;
    if (s is! RefereeMatchReady) return;
    try {
      await _repository.startSet(s.match.id, setNumber);
      await _reload();
    } catch (e) {
      if (isClosed) return;
      emit(RefereeMatchError(e.toString()));
    }
  }

  Future<void> addPointBlue() => _addPoint(isBlue: true);
  Future<void> addPointRed() => _addPoint(isBlue: false);

  Future<void> _addPoint({required bool isBlue}) async {
    final s = state;
    if (s is! RefereeMatchReady) return;
    final activeSet =
        s.match.sets.where((st) => st.status == SetStatus.active).firstOrNull;
    if (activeSet == null) return;
    final newBlue = activeSet.blueScore + (isBlue ? 1 : 0);
    final newRed = activeSet.redScore + (isBlue ? 0 : 1);
    try {
      await _repository.updateScore(
          s.match.id, activeSet.number, newBlue, newRed);
      await _reload();
    } catch (e) {
      if (isClosed) return;
      emit(RefereeMatchError(e.toString()));
    }
  }

  Future<void> subtractPointBlue() => _subtractPoint(isBlue: true);
  Future<void> subtractPointRed() => _subtractPoint(isBlue: false);

  Future<void> _subtractPoint({required bool isBlue}) async {
    final s = state;
    if (s is! RefereeMatchReady) return;
    final activeSet =
        s.match.sets.where((st) => st.status == SetStatus.active).firstOrNull;
    if (activeSet == null) return;
    final newBlue = (activeSet.blueScore - (isBlue ? 1 : 0)).clamp(0, 999);
    final newRed = (activeSet.redScore - (isBlue ? 0 : 1)).clamp(0, 999);
    try {
      await _repository.updateScore(
          s.match.id, activeSet.number, newBlue, newRed);
      await _reload();
    } catch (e) {
      if (isClosed) return;
      emit(RefereeMatchError(e.toString()));
    }
  }

  Future<void> finishSet(int setNumber) async {
    final s = state;
    if (s is! RefereeMatchReady) return;
    try {
      await _repository.finishSet(s.match.id, setNumber);
      await _reload();
    } catch (e) {
      if (isClosed) return;
      emit(RefereeMatchError(e.toString()));
    }
  }

  Future<void> finishMatch() async {
    final s = state;
    if (s is! RefereeMatchReady) return;
    try {
      await _repository.finishMatch(s.match.id);
      await _reload();
    } catch (e) {
      if (isClosed) return;
      emit(RefereeMatchError(e.toString()));
    }
  }

  Future<void> finishSetAndMatch(int setNumber) async {
    final s = state;
    if (s is! RefereeMatchReady) return;
    try {
      await _repository.finishSet(s.match.id, setNumber);
      await _repository.finishMatch(s.match.id);
      await _reload();
    } catch (e) {
      if (isClosed) return;
      emit(RefereeMatchError(e.toString()));
    }
  }

  Future<void> technicalDefeatMatch(int loserId, {String? reason}) async {
    final s = state;
    if (s is! RefereeMatchReady) return;
    try {
      await _repository.technicalDefeatMatch(s.match.id, loserId,
          reason: reason);
      await _reload();
    } catch (e) {
      if (isClosed) return;
      emit(RefereeMatchError(e.toString()));
    }
  }

  Future<void> technicalDefeatSet(int setNumber, int loserId,
      {String? reason}) async {
    final s = state;
    if (s is! RefereeMatchReady) return;
    try {
      await _repository.technicalDefeatSet(s.match.id, setNumber, loserId,
          reason: reason);
      await _reload();
    } catch (e) {
      if (isClosed) return;
      emit(RefereeMatchError(e.toString()));
    }
  }

  Future<void> issueCard(int playerId, String cardType) async {
    final s = state;
    if (s is! RefereeMatchReady) return;
    try {
      await _repository.issueCard(s.match.id, playerId, cardType);
      await _reload();
    } catch (e) {
      if (isClosed) return;
      emit(RefereeMatchError(e.toString()));
    }
  }

  Future<void> revokeCard(int cardId) async {
    final s = state;
    if (s is! RefereeMatchReady) return;
    try {
      await _repository.revokeCard(s.match.id, cardId);
      await _reload();
    } catch (e) {
      if (isClosed) return;
      emit(RefereeMatchError(e.toString()));
    }
  }
}
