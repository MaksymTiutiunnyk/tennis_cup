part of 'head_to_head_cubit.dart';

sealed class HeadToHeadState {
  const HeadToHeadState();
}

final class HeadToHeadLoading extends HeadToHeadState {
  const HeadToHeadLoading();
}

final class HeadToHeadLoaded extends HeadToHeadState {
  final List<Match> matches;
  final bool hasMore;
  const HeadToHeadLoaded({required this.matches, required this.hasMore});
}

final class HeadToHeadError extends HeadToHeadState {
  final String message;
  const HeadToHeadError(this.message);
}
