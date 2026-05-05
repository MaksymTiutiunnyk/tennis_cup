part of 'player_search_bloc.dart';

abstract class PlayerSearchState {
  const PlayerSearchState();
}

class PlayerSearchLoading extends PlayerSearchState {}

class PlayersNotFound extends PlayerSearchState {}

class PlayerSearchLoaded extends PlayerSearchState {
  final List<Player> players;

  const PlayerSearchLoaded(this.players);
}

class PlayerSearchError extends PlayerSearchState {
  final Object e;

  const PlayerSearchError(this.e);
}