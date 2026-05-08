part of 'user_edit_cubit.dart';

sealed class UserEditState {}

class UserEditInitial extends UserEditState {}

class UserEditLoading extends UserEditState {}

class UserEditLoaded extends UserEditState {
  final Player user;
  final bool saving;

  UserEditLoaded({required this.user, this.saving = false});
}

class UserEditSuccess extends UserEditState {}

class UserEditError extends UserEditState {
  final String message;

  UserEditError(this.message);
}
