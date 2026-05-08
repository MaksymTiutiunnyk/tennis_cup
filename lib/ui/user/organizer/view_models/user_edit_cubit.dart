import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tennis_cup/data/models/player.dart';
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
      emit(UserEditLoaded(user: player));
    } catch (e) {
      emit(UserEditError('Failed to load user'));
    }
  }

  Future<void> saveUser(int userId, Map<String, dynamic> fields) async {
    final current = state;
    if (current is! UserEditLoaded) return;
    emit(UserEditLoaded(user: current.user, saving: true));
    try {
      await _playerRepository.updateProfile(userId, fields);
      emit(UserEditSuccess());
    } catch (e) {
      emit(UserEditLoaded(user: current.user));
      emit(UserEditError('Failed to save changes'));
    }
  }

  Future<void> uploadAvatar(int userId) async {
    final current = state;
    if (current is! UserEditLoaded) return;

    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    emit(UserEditLoaded(user: current.user, saving: true));
    try {
      final bytes = Uint8List.fromList(await picked.readAsBytes());
      await _playerRepository.uploadAvatar(userId, bytes);
      final updated = await _playerRepository.fetchPlayerById(userId);
      emit(UserEditLoaded(user: updated));
    } catch (e) {
      emit(UserEditLoaded(user: current.user));
      emit(UserEditError('Avatar upload failed'));
    }
  }
}
