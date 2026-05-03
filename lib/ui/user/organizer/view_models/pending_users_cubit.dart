import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/data/models/pending_user.dart';
import 'package:tennis_cup/data/repositories/admin_repository.dart';

part 'pending_users_state.dart';

class PendingUsersCubit extends Cubit<PendingUsersState> {
  final AdminRepository _repository;

  PendingUsersCubit({required AdminRepository repository})
      : _repository = repository,
        super(PendingUsersLoading()) {
    load();
  }

  Future<void> load() async {
    emit(PendingUsersLoading());
    try {
      final result = await _repository.fetchPendingUsers(
        const PageRequest(page: 0, size: 50),
      );
      emit(PendingUsersLoaded(result.items));
    } catch (e) {
      emit(PendingUsersError(_message(e)));
    }
  }

  Future<void> approve(int userId) async {
    final snapshot = _removeOptimistically(userId);
    try {
      await _repository.approveUser(userId);
    } catch (e) {
      if (snapshot != null) emit(PendingUsersLoaded(snapshot));
      emit(PendingUsersError(_message(e)));
    }
  }

  Future<void> reject(int userId, {String? reason}) async {
    final snapshot = _removeOptimistically(userId);
    try {
      await _repository.rejectUser(userId, reason: reason);
    } catch (e) {
      if (snapshot != null) emit(PendingUsersLoaded(snapshot));
      emit(PendingUsersError(_message(e)));
    }
  }

  List<PendingUser>? _removeOptimistically(int userId) {
    final current = state;
    if (current is! PendingUsersLoaded) return null;
    final snapshot = [...current.users];
    emit(PendingUsersLoaded(
        current.users.where((u) => u.id != userId).toList()));
    return snapshot;
  }

  static String _message(Object e) =>
      e is Exception ? e.toString().replaceFirst('Exception: ', '') : '$e';
}
