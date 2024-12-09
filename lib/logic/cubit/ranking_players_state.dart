part of 'ranking_players_cubit.dart';

class RankingPlayersState {
  final List<Player> players;
  final bool isLoading;
  final bool hasMore;

  const RankingPlayersState({
    this.players = const [],
    this.isLoading = false,
    this.hasMore = true,
  });

  RankingPlayersState copyWith({
    List<Player>? players,
    bool? isLoading,
    bool? hasMore,
  }) {
    return RankingPlayersState(
      players: players ?? this.players,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}