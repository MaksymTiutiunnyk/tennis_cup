sealed class UserCreationState {}

class UserCreationIdle extends UserCreationState {}

class UserCreationLoading extends UserCreationState {}

class UserCreationSuccess extends UserCreationState {
  final String message;
  UserCreationSuccess(this.message);
}

class UserCreationError extends UserCreationState {
  final String message;
  UserCreationError(this.message);
}
