import 'package:tennis_cup/data/models/combined_user.dart';

sealed class UsersSearchState {}

class UsersSearchIdle extends UsersSearchState {}

class UsersSearchLoading extends UsersSearchState {}

class UsersSearchLoaded extends UsersSearchState {
  final List<CombinedUser> users;
  final CombinedUser? pendingDelete;
  final bool deleteError;

  UsersSearchLoaded({
    required this.users,
    this.pendingDelete,
    this.deleteError = false,
  });
}

class UsersSearchError extends UsersSearchState {
  final String message;
  UsersSearchError(this.message);
}
