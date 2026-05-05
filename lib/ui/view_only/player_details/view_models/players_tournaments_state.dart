part of 'players_tournaments_cubit.dart';

sealed class PlayersTournamentsState {
  const PlayersTournamentsState();
}

final class PlayersTournamentsLoading extends PlayersTournamentsState {
  const PlayersTournamentsLoading();
}

final class PlayersTournamentsLoaded extends PlayersTournamentsState {
  final List<Tournament> tournaments;
  final bool hasMore;
  const PlayersTournamentsLoaded({required this.tournaments, required this.hasMore});
}

final class PlayersTournamentsError extends PlayersTournamentsState {
  final String message;
  const PlayersTournamentsError(this.message);
}
