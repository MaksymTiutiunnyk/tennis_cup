import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tennis_cup/core/utils/error_utils.dart';
import 'package:tennis_cup/data/models/user.dart';
import 'package:tennis_cup/data/models/user_role.dart';
import 'package:tennis_cup/data/repositories/player_repository.dart';

part 'user_edit_state.dart';

class UserEditCubit extends Cubit<UserEditState> {
  final PlayerRepository _playerRepository;

  UserEditCubit({required PlayerRepository playerRepository})
      : _playerRepository = playerRepository,
        super(UserEditInitial());

  Future<void> loadUser(int userId) async {
    emit(UserEditLoading());
    try {
      final player = await _playerRepository.fetchPlayerById(userId);
      if (isClosed) return;
      emit(UserEditLoaded(user: player, roles: List.from(player.roles)));
    } catch (e) {
      if (isClosed) return;
      emit(UserEditError(errorMessage(e)));
    }
  }

  Future<void> pickAvatar() async {
    final current = state;
    if (current is! UserEditLoaded || current.saving) return;

    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    final bytes = Uint8List.fromList(await picked.readAsBytes());
    if (isClosed) return;
    emit(UserEditLoaded(
      user: current.user,
      roles: current.roles,
      pendingAvatarBytes: bytes,
      avatarRemoved: false,
    ));
  }

  void removeAvatar() {
    final current = state;
    if (current is! UserEditLoaded || current.saving) return;
    emit(UserEditLoaded(
      user: current.user,
      roles: current.roles,
      pendingAvatarBytes: null,
      avatarRemoved: true,
    ));
  }

  void toggleRole(UserRole role) {
    final current = state;
    if (current is! UserEditLoaded || current.saving) return;
    final updated = List<UserRole>.from(current.roles);
    if (updated.contains(role)) {
      if (updated.length <= 1) return;
      updated.remove(role);
    } else {
      updated.add(role);
    }
    emit(UserEditLoaded(
      user: current.user,
      roles: updated,
      pendingAvatarBytes: current.pendingAvatarBytes,
      avatarRemoved: current.avatarRemoved,
    ));
  }

  Future<void> saveUser(int userId, Map<String, dynamic> profileFields) async {
    final current = state;
    if (current is! UserEditLoaded) return;

    emit(UserEditLoaded(
      user: current.user,
      roles: current.roles,
      saving: true,
      pendingAvatarBytes: current.pendingAvatarBytes,
      avatarRemoved: current.avatarRemoved,
    ));
    try {
      if (current.pendingAvatarBytes != null) {
        await _playerRepository.uploadAvatar(
            userId, current.pendingAvatarBytes!);
      } else if (current.avatarRemoved) {
        await _playerRepository.removeAvatar(userId);
      }

      final fields = Map<String, dynamic>.from(profileFields);
      fields['roles'] = current.roles.map((r) => r.name.toUpperCase()).toList();

      await _playerRepository.updateProfile(userId, fields);
      if (isClosed) return;
      emit(UserEditSuccess());
    } catch (e) {
      if (isClosed) return;
      emit(UserEditLoaded(
        user: current.user,
        roles: current.roles,
        pendingAvatarBytes: current.pendingAvatarBytes,
        avatarRemoved: current.avatarRemoved,
      ));
      emit(UserEditError(errorMessage(e)));
    }
  }
}
