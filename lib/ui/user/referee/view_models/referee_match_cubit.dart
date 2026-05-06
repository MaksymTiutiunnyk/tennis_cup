import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/repositories/referee_repository.dart';
import 'package:tennis_cup/data/services/dto/match_dto.dart';

part 'referee_match_state.dart';

class RefereeMatchCubit extends Cubit<RefereeMatchState> {
  final RefereeRepository _repository;

  RefereeMatchCubit({required RefereeRepository repository})
      : _repository = repository,
        super(RefereeMatchLoading());

  Future<void> load(int matchId) async {
    emit(RefereeMatchLoading());
    try {
      final (:match, :blue, :red) =
          await _repository.fetchMatchWithPlayers(matchId);
      emit(RefereeMatchReady(
        match: match,
        bluePlayer: blue,
        redPlayer: red,
        blueIssuedCards: const {},
        redIssuedCards: const {},
        scoreUndoStack: const [],
      ));
    } catch (e) {
      emit(RefereeMatchError(e.toString()));
    }
  }

  Future<void> _reload() async {
    final current = state;
    if (current is! RefereeMatchReady) return;
    try {
      final (:match, :blue, :red) =
          await _repository.fetchMatchWithPlayers(current.match.id);
      emit(current.copyWith(match: match, scoreUndoStack: const []));
    } catch (e) {
      emit(RefereeMatchError(e.toString()));
    }
  }

  void setFirstServer(int playerId) {
    final s = state;
    if (s is! RefereeMatchReady) return;
    emit(s.copyWith(firstServerPlayerId: playerId));
  }

  Future<void> startMatch() async {
    final s = state;
    if (s is! RefereeMatchReady) return;
    if (s.firstServerPlayerId == null) {
      emit(s.copyWith(notification: 'Select the first server before starting'));
      return;
    }

    try {
      final startedMatch = await _repository.startMatch(s.match.id);
      var current = s.copyWith(
        match: startedMatch,
        scoreUndoStack: const [],
      );
      emit(current);

      final firstPendingSet = startedMatch.sets
              .where((set) => set.status == 'PENDING')
              .firstOrNull
              ?.number ??
          1;

      MatchSetDto? startedSet;
      for (var attempt = 0; attempt < 2; attempt++) {
        try {
          startedSet = await _repository.startSet(s.match.id, firstPendingSet);
          break;
        } catch (e) {
          await Future<void>.delayed(const Duration(milliseconds: 250));
        }
      }

      if (startedSet != null) {
        final updatedSets = current.match.sets
            .map((set) => set.number == startedSet!.number ? startedSet : set)
            .toList();
        current = current.copyWith(
          match: _matchWithSets(current.match, updatedSets),
        );
        emit(current);
        await _reload();
        return;
      }

      emit(current.copyWith(
        notification:
            'Match started, but the first set did not start automatically. Start it manually.',
      ));
    } catch (e) {
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
      emit(RefereeMatchError(e.toString()));
    }
  }

  Future<void> addPointBlue() => _addPoint(isBlue: true);
  Future<void> addPointRed() => _addPoint(isBlue: false);

  Future<void> _addPoint({required bool isBlue}) async {
    final s = state;
    if (s is! RefereeMatchReady) return;
    final activeSet =
        s.match.sets.where((st) => st.status == 'ACTIVE').firstOrNull;
    if (activeSet == null) return;
    final newBlue = activeSet.bluePlayerScore + (isBlue ? 1 : 0);
    final newRed = activeSet.redPlayerScore + (isBlue ? 0 : 1);
    final newStack = [
      ...s.scoreUndoStack,
      (blue: activeSet.bluePlayerScore, red: activeSet.redPlayerScore),
    ];
    try {
      final updatedSet = await _repository.updateScore(
          s.match.id, activeSet.number, newBlue, newRed);
      final updatedSets = s.match.sets
          .map((st) => st.number == updatedSet.number ? updatedSet : st)
          .toList();
      emit(s.copyWith(
        match: _matchWithSets(s.match, updatedSets),
        scoreUndoStack: newStack,
      ));
    } catch (e) {
      emit(RefereeMatchError(e.toString()));
    }
  }

  Future<void> undoLastScore() async {
    final s = state;
    if (s is! RefereeMatchReady) return;
    if (s.scoreUndoStack.isEmpty) return;
    final activeSet =
        s.match.sets.where((st) => st.status == 'ACTIVE').firstOrNull;
    if (activeSet == null) return;
    final prev = s.scoreUndoStack.last;
    final newStack = s.scoreUndoStack.sublist(0, s.scoreUndoStack.length - 1);
    try {
      final updatedSet = await _repository.updateScore(
          s.match.id, activeSet.number, prev.blue, prev.red);
      final updatedSets = s.match.sets
          .map((st) => st.number == updatedSet.number ? updatedSet : st)
          .toList();
      emit(s.copyWith(
        match: _matchWithSets(s.match, updatedSets),
        scoreUndoStack: newStack,
      ));
    } catch (e) {
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
      emit(RefereeMatchError(e.toString()));
    }
  }

  void toggleCard(bool isBlue, MatchCard card) {
    final s = state;
    if (s is! RefereeMatchReady) return;
    if (isBlue) {
      final updated = Set<MatchCard>.from(s.blueIssuedCards);
      updated.contains(card) ? updated.remove(card) : updated.add(card);
      emit(s.copyWith(blueIssuedCards: updated));
    } else {
      final updated = Set<MatchCard>.from(s.redIssuedCards);
      updated.contains(card) ? updated.remove(card) : updated.add(card);
      emit(s.copyWith(redIssuedCards: updated));
    }
  }

  void medicalTimeout() {
    final s = state;
    if (s is! RefereeMatchReady) return;
    emit(s.copyWith(notification: 'Medical timeout: not implemented yet'));
  }

  void technicalPause() {
    final s = state;
    if (s is! RefereeMatchReady) return;
    emit(s.copyWith(notification: 'Technical pause: not implemented yet'));
  }

  // Rebuilds a MatchDto with a replaced sets list.
  static MatchDto _matchWithSets(MatchDto match, List<MatchSetDto> sets) =>
      MatchDto(
        id: match.id,
        tournamentId: match.tournamentId,
        refereeId: match.refereeId,
        status: match.status,
        bluePlayerId: match.bluePlayerId,
        redPlayerId: match.redPlayerId,
        winnerId: match.winnerId,
        scheduledStart: match.scheduledStart,
        scheduledEnd: match.scheduledEnd,
        actualStart: match.actualStart,
        actualEnd: match.actualEnd,
        sets: sets,
      );
}
