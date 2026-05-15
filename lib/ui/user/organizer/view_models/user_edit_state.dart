part of 'user_edit_cubit.dart';

sealed class UserEditState {}

class UserEditInitial extends UserEditState {}

class UserEditLoading extends UserEditState {}

class UserEditLoaded extends UserEditState {
  final User user;
  final bool saving;
  final Uint8List? pendingAvatarBytes;
  final bool avatarRemoved;
  final List<UserRole> roles;

  UserEditLoaded({
    required this.user,
    required this.roles,
    this.saving = false,
    this.pendingAvatarBytes,
    this.avatarRemoved = false,
  });
}

class UserEditSuccess extends UserEditState {}

class UserEditError extends UserEditState {
  final String message;

  UserEditError(this.message);
}
