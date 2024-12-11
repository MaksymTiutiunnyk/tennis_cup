part of 'ranking_players_cubit.dart';

class RankingPlayersState {
  final List<Player> players;
  final bool isLoading;
  final bool hasMore;
  final bool hasError;

  const RankingPlayersState({
    this.players = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.hasError = false,
  });

  RankingPlayersState copyWith({
    List<Player>? players,
    bool? isLoading,
    bool? hasMore,
    bool? hasError,
  }) {
    return RankingPlayersState(
      players: players ?? this.players,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      hasError: hasError ?? this.hasError,
    );
  }
}
