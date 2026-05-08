import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/combined_user.dart';
import 'package:tennis_cup/data/models/user_search_result.dart';
import 'package:tennis_cup/data/repositories/admin_repository.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/users_search_state.dart';

class UsersSearchCubit extends Cubit<UsersSearchState> {
  final AdminRepository _adminRepository;

  CombinedUser? _deletedUser;
  int? _deletedIndex;
  Timer? _deleteTimer;
  String _lastQuery = '';

  UsersSearchCubit({required AdminRepository adminRepository})
      : _adminRepository = adminRepository,
        super(UsersSearchIdle());

  @override
  Future<void> close() {
    _deleteTimer?.cancel();
    return super.close();
  }

  Future<void> search(String query) async {
    // Flush pending delete before loading fresh results so it can't reappear.
    final pendingId = _flushPendingDelete();

    if (query.trim().length < 2) {
      emit(UsersSearchIdle());
      return;
    }
    _lastQuery = query.trim();
    emit(UsersSearchLoading());
    try {
      final users = await _adminRepository.searchAllUsers(_lastQuery);
      var combined = users.map(_toCombinedUser).toList();
      // Filter out the item that was just committed but may not yet be gone
      // from the server response (race between our delete call and the search).
      if (pendingId != null) {
        combined = combined.where((u) => u.userId != pendingId).toList();
      }
      emit(UsersSearchLoaded(users: combined));
    } catch (e) {
      emit(UsersSearchError('Failed to search users'));
    }
  }

  Future<void> refresh() async {
    if (_lastQuery.isEmpty) return;
    await search(_lastQuery);
  }

  static CombinedUser _toCombinedUser(UserSearchResult user) => CombinedUser(
        userId: user.userId,
        firstName: user.firstName,
        lastName: user.lastName,
        avatarUrl: user.avatarUrl ?? '',
        roles: user.roles,
      );

  void softDelete(CombinedUser user) {
    final current = state;
    if (current is! UsersSearchLoaded) return;

    _deletedUser = user;
    _deletedIndex = current.users.indexWhere((u) => u.userId == user.userId);
    _deleteTimer?.cancel();

    final updated =
        current.users.where((u) => u.userId != user.userId).toList();
    emit(UsersSearchLoaded(users: updated, pendingDelete: user));

    _deleteTimer = Timer(const Duration(seconds: 4), _commitDelete);
  }

  void undoDelete() {
    _deleteTimer?.cancel();
    _deleteTimer = null;

    final current = state;
    if (current is! UsersSearchLoaded || _deletedUser == null) return;

    final restored = List<CombinedUser>.from(current.users);
    final index = _deletedIndex ?? restored.length;
    restored.insert(index.clamp(0, restored.length), _deletedUser!);
    _deletedUser = null;
    _deletedIndex = null;
    emit(UsersSearchLoaded(users: restored));
  }

  /// Cancels the pending-delete timer and fires the API call immediately.
  /// Returns the ID of the user being deleted (for filtering from search results).
  int? _flushPendingDelete() {
    if (_deletedUser == null) return null;
    _deleteTimer?.cancel();
    _deleteTimer = null;
    final id = _deletedUser!.userId;
    _commitDelete(); // fire and forget — errors handled inside
    return id;
  }

  Future<void> _commitDelete() async {
    final user = _deletedUser;
    _deletedUser = null;
    _deletedIndex = null;
    if (user == null) return;
    try {
      await _adminRepository.deleteOrganizer(user.userId);
    } catch (e) {
      final current = state;
      if (current is UsersSearchLoaded) {
        emit(UsersSearchLoaded(
          users: [...current.users, user],
          deleteError: true,
        ));
      }
    }
  }
}
