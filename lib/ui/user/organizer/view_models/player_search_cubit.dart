import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/data/repositories/player_repository.dart';

class SelectedPlayer {
  final int id;
  final String name;
  final String? status;

  const SelectedPlayer({required this.id, required this.name, this.status});
}

class PlayerPickerState {
  final List<SelectedPlayer> selected;
  final List<User> searchResults;
  final bool isLoading;

  const PlayerPickerState({
    this.selected = const [],
    this.searchResults = const [],
    this.isLoading = false,
  });

  PlayerPickerState copyWith({
    List<SelectedPlayer>? selected,
    List<User>? searchResults,
    bool? isLoading,
  }) =>
      PlayerPickerState(
        selected: selected ?? this.selected,
        searchResults: searchResults ?? this.searchResults,
        isLoading: isLoading ?? this.isLoading,
      );
}

class PlayerPickerCubit extends Cubit<PlayerPickerState> {
  final PlayerRepository _playerRepository;

  PlayerPickerCubit({
    required PlayerRepository playerRepository,
    List<SelectedPlayer> initial = const [],
  })  : _playerRepository = playerRepository,
        super(PlayerPickerState(selected: initial));

  Future<void> search(String query, {String? gender}) async {
    if (query.trim().length < 2) {
      if (isClosed) return;
      emit(state.copyWith(searchResults: [], isLoading: false));
      return;
    }
    emit(state.copyWith(isLoading: true));
    try {
      final results = await _playerRepository.fetchPlayersBySubstring(
        query: query.trim(),
        gender: gender,
      );
      if (isClosed) return;
      final filtered =
          results.where((p) => !state.selected.any((s) => s.id == p.id)).toList();
      emit(state.copyWith(searchResults: filtered, isLoading: false));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(searchResults: [], isLoading: false));
    }
  }

  void clearSearch() =>
      emit(state.copyWith(searchResults: [], isLoading: false));

  void addPlayer(User player) {
    if (state.selected.any((s) => s.id == player.id)) return;
    final updated = [
      ...state.selected,
      SelectedPlayer(id: player.id, name: player.fullName),
    ];
    emit(state.copyWith(selected: updated, searchResults: []));
  }

  void removePlayer(int id) {
    final updated = state.selected.where((s) => s.id != id).toList();
    emit(state.copyWith(selected: updated));
  }

  void syncInitial(List<SelectedPlayer> initial) {
    final synced = state.selected.map((s) {
      final updated = initial.where((p) => p.id == s.id).firstOrNull;
      return updated ?? s;
    }).toList();
    emit(state.copyWith(selected: synced));
  }
}
