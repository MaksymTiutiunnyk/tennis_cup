import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tennis_cup/data/models/combined_user.dart';
import 'package:tennis_cup/data/models/user_search_result.dart';
import 'package:tennis_cup/data/repositories/admin_repository.dart';
import 'package:tennis_cup/data/repositories/player_repository.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/users_search_state.dart';

class UsersSearchCubit extends Cubit<UsersSearchState> {
  final AdminRepository _adminRepository;
  final PlayerRepository _playerRepository;

  CombinedUser? _deletedUser;
  Timer? _deleteTimer;

  UsersSearchCubit({
    required AdminRepository adminRepository,
    required PlayerRepository playerRepository,
  })  : _adminRepository = adminRepository,
        _playerRepository = playerRepository,
        super(UsersSearchIdle());

  @override
  Future<void> close() {
    _deleteTimer?.cancel();
    return super.close();
  }

  Future<void> search(String query) async {
    if (query.trim().length < 2) {
      emit(UsersSearchIdle());
      return;
    }
    emit(UsersSearchLoading());
    try {
      final users = await _adminRepository.searchAllUsers(query.trim());
      emit(UsersSearchLoaded(users: users.map(_toCombinedUser).toList()));
    } catch (e) {
      emit(UsersSearchError('Failed to search users'));
    }
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

    final restored = [...current.users, _deletedUser!];
    _deletedUser = null;
    emit(UsersSearchLoaded(users: restored));
  }

  Future<void> _commitDelete() async {
    final user = _deletedUser;
    _deletedUser = null;
    if (user == null) return;
    try {
      await _adminRepository.deleteOrganizer(user.userId);
    } catch (_) {
      // Silently ignore — user already removed from UI
    }
  }

  Future<void> updateUser(int id, Map<String, dynamic> fields) async {
    await _playerRepository.updateProfile(id, fields);
    final current = state;
    if (current is UsersSearchLoaded) {
      final updated = current.users.map((u) {
        return CombinedUser(
          userId: u.userId,
          firstName: fields['firstName'] as String? ?? u.firstName,
          lastName: fields['lastName'] as String? ?? u.lastName,
          avatarUrl: u.avatarUrl,
          roles: u.roles,
        );
      }).toList();
      emit(UsersSearchLoaded(
          users: updated, pendingDelete: current.pendingDelete));
    }
  }

  Future<String?> uploadAvatar(int id) async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return null;

    final bytes = Uint8List.fromList(await picked.readAsBytes());
    final avatarUrl = await _playerRepository.uploadAvatar(id, bytes);

    final current = state;
    if (current is UsersSearchLoaded) {
      final updated = current.users.map((u) {
        return u.userId == id ? u.copyWith(avatarUrl: avatarUrl) : u;
      }).toList();
      emit(UsersSearchLoaded(
          users: updated, pendingDelete: current.pendingDelete));
    }
    return avatarUrl;
  }
}
