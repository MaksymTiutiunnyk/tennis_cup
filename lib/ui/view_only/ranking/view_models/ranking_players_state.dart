part of 'ranking_players_cubit.dart';

sealed class RankingPlayersState extends Equatable {
  const RankingPlayersState();
}

final class RankingPlayersLoading extends RankingPlayersState {
  const RankingPlayersLoading();

  @override
  List<Object?> get props => const [];
}

final class RankingPlayersLoaded extends RankingPlayersState {
  final List<User> players;
  final bool hasMore;
  const RankingPlayersLoaded({required this.players, required this.hasMore});

  @override
  List<Object?> get props => [players, hasMore];
}

final class RankingPlayersLoadingMore extends RankingPlayersState {
  final List<User> players;
  const RankingPlayersLoadingMore({required this.players});

  @override
  List<Object?> get props => [players];
}

final class RankingPlayersError extends RankingPlayersState {
  final String message;
  const RankingPlayersError(this.message);

  @override
  List<Object?> get props => [message];
}
