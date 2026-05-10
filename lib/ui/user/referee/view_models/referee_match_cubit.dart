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
        scoreUndoStack: const [],
      ));
    } catch (e) {
      emit(RefereeMatchError(e.toString()));
    }
  }

  Future<void> _reload({List<({int blue, int red})>? preserveUndoStack}) async {
    final current = state;
    if (current is! RefereeMatchReady) return;
    try {
      final (:match, :blue, :red) =
          await _repository.fetchMatchWithPlayers(current.match.id);
      emit(current.copyWith(
        match: match,
        scoreUndoStack: preserveUndoStack ?? const [],
      ));
    } catch (e) {
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
      emit(s.copyWith(notification: 'Select the first server before starting'));
      return;
    }
    try {
      final startedMatch =
          await _repository.startMatch(s.match.id, s.firstServerPlayerId!);
      final firstPendingSetNumber = startedMatch.sets
              .where((set) => set.status == 'PENDING')
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
      await _repository.updateScore(
          s.match.id, activeSet.number, newBlue, newRed);
      // Reload to pick up any server-side side effects (e.g. red-card score penalty).
      // Preserve the undo stack so the revert button stays enabled.
      await _reload(preserveUndoStack: newStack);
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
      await _repository.updateScore(
          s.match.id, activeSet.number, prev.blue, prev.red);
      await _reload(preserveUndoStack: newStack);
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

  Future<void> finishSetAndMatch(int setNumber) async {
    final s = state;
    if (s is! RefereeMatchReady) return;
    try {
      await _repository.finishSet(s.match.id, setNumber);
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

  Future<void> issueCard(int playerId, String cardType) async {
    final s = state;
    if (s is! RefereeMatchReady) return;
    try {
      await _repository.issueCard(s.match.id, playerId, cardType);
      await _reload();
    } catch (e) {
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
      emit(RefereeMatchError(e.toString()));
    }
  }
}
