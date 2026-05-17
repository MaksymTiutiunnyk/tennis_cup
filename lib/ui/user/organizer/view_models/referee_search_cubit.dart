import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/data/repositories/admin_repository.dart';

class SelectedReferee {
  final int id;
  final String name;
  final String? status;

  const SelectedReferee({required this.id, required this.name, this.status});
}

class RefereePickerState {
  final List<SelectedReferee> selected;
  final List<User> searchResults;
  final bool isLoading;

  const RefereePickerState({
    this.selected = const [],
    this.searchResults = const [],
    this.isLoading = false,
  });

  RefereePickerState copyWith({
    List<SelectedReferee>? selected,
    List<User>? searchResults,
    bool? isLoading,
  }) =>
      RefereePickerState(
        selected: selected ?? this.selected,
        searchResults: searchResults ?? this.searchResults,
        isLoading: isLoading ?? this.isLoading,
      );
}

class RefereePickerCubit extends Cubit<RefereePickerState> {
  final AdminRepository _adminRepository;

  RefereePickerCubit({
    required AdminRepository adminRepository,
    List<SelectedReferee> initial = const [],
  })  : _adminRepository = adminRepository,
        super(RefereePickerState(selected: initial));

  Future<void> search(String query) async {
    if (query.trim().length < 2) {
      if (isClosed) return;
      emit(state.copyWith(searchResults: [], isLoading: false));
      return;
    }
    emit(state.copyWith(isLoading: true));
    try {
      final results = await _adminRepository.searchReferees(query.trim());
      if (isClosed) return;
      final filtered =
          results.where((r) => !state.selected.any((s) => s.id == r.id)).toList();
      emit(state.copyWith(searchResults: filtered, isLoading: false));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(searchResults: [], isLoading: false));
    }
  }

  void clearSearch() =>
      emit(state.copyWith(searchResults: [], isLoading: false));

  void addReferee(User referee) {
    if (state.selected.any((s) => s.id == referee.id)) return;
    final updated = [
      ...state.selected,
      SelectedReferee(id: referee.id, name: referee.fullName),
    ];
    emit(state.copyWith(selected: updated, searchResults: []));
  }

  void removeReferee(int id) {
    final updated = state.selected.where((s) => s.id != id).toList();
    emit(state.copyWith(selected: updated));
  }

  void syncInitial(List<SelectedReferee> initial) {
    final synced = state.selected.map((s) {
      final updated = initial.where((r) => r.id == s.id).firstOrNull;
      return updated ?? s;
    }).toList();
    emit(state.copyWith(selected: synced));
  }
}
