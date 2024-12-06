part of 'player_search_bloc.dart';

abstract class PlayerSearchState {}

class PlayerSearchLoading extends PlayerSearchState {}

class PlayersNotFound extends PlayerSearchState {}

class PlayerSearchLoaded extends PlayerSearchState {
  final List<Player> players;

  PlayerSearchLoaded(this.players);
}