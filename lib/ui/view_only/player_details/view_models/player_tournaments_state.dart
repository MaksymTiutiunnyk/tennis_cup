part of 'player_tournaments_cubit.dart';

sealed class PlayerTournamentsState {
  const PlayerTournamentsState();
}

final class PlayerTournamentsLoading extends PlayerTournamentsState {
  const PlayerTournamentsLoading();
}

final class PlayerTournamentsLoaded extends PlayerTournamentsState {
  final List<Tournament> tournaments;
  final bool hasMore;
  const PlayerTournamentsLoaded({required this.tournaments, required this.hasMore});
}

final class PlayerTournamentsError extends PlayerTournamentsState {
  final String message;
  const PlayerTournamentsError(this.message);
}
