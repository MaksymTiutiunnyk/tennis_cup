part of 'pending_users_cubit.dart';

sealed class PendingUsersState {}

class PendingUsersLoading extends PendingUsersState {}

class PendingUsersLoaded extends PendingUsersState {
  final List<PendingUser> users;
  PendingUsersLoaded(this.users);
}

class PendingUsersError extends PendingUsersState {
  final String message;
  PendingUsersError(this.message);
}
