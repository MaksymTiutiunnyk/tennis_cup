part of 'ranking_players_cubit.dart';

class RankingPlayersState {
  final List<Player> players;
  final bool isLoading;
  final bool hasMore;
  final bool hasError;
  final bool isScrollFetching;

  const RankingPlayersState({
    this.players = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.hasError = false,
    this.isScrollFetching = false,
  });

  RankingPlayersState copyWith({
    List<Player>? players,
    bool? isLoading,
    bool? hasMore,
    bool? hasError,
    bool? isScrollFetching,
  }) {
    return RankingPlayersState(
      players: players ?? this.players,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      hasError: hasError ?? this.hasError,
      isScrollFetching: isScrollFetching ?? this.isScrollFetching
    );
  }
}
