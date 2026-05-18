import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/utils/error_utils.dart';
import 'package:tennis_cup/data/repositories/admin_repository.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/users_search_state.dart';

class UsersSearchCubit extends Cubit<UsersSearchState> {
  final AdminRepository _adminRepository;

  String _lastQuery = '';

  UsersSearchCubit({required AdminRepository adminRepository})
      : _adminRepository = adminRepository,
        super(UsersSearchIdle());

  Future<void> search(String query) async {
    if (query.trim().length < 2) {
      emit(UsersSearchIdle());
      return;
    }
    _lastQuery = query.trim();
    emit(UsersSearchLoading());
    try {
      final users = await _adminRepository.searchAllUsers(_lastQuery);
      if (isClosed) return;
      emit(UsersSearchLoaded(users: users));
    } catch (e) {
      if (isClosed) return;
      emit(UsersSearchError(errorMessage(e)));
    }
  }

  Future<void> refresh() async {
    if (_lastQuery.isEmpty) return;
    await search(_lastQuery);
  }
}
