part of 'ranking_players_cubit.dart';

sealed class RankingPlayersState {
  const RankingPlayersState();
}

final class RankingPlayersLoading extends RankingPlayersState {
  const RankingPlayersLoading();
}

final class RankingPlayersLoaded extends RankingPlayersState {
  final List<User> players;
  final bool hasMore;
  const RankingPlayersLoaded({required this.players, required this.hasMore});
}

final class RankingPlayersLoadingMore extends RankingPlayersState {
  final List<User> players;
  const RankingPlayersLoadingMore({required this.players});
}

final class RankingPlayersError extends RankingPlayersState {
  const RankingPlayersError();
}
