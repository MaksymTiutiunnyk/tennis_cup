import 'package:tennis_cup/data/models/combined_user.dart';

sealed class UsersSearchState {}

class UsersSearchIdle extends UsersSearchState {}

class UsersSearchLoading extends UsersSearchState {}

class UsersSearchLoaded extends UsersSearchState {
  final List<CombinedUser> users;
  final CombinedUser? pendingDelete;

  UsersSearchLoaded({required this.users, this.pendingDelete});
}

class UsersSearchError extends UsersSearchState {
  final String message;
  UsersSearchError(this.message);
}
