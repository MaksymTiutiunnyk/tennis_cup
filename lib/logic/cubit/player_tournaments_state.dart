part of 'player_tournaments_cubit.dart';

class PlayerTournamentsState {
  final List<Tournament> tournaments;
  final bool isLoading;
  final String? errorMessage;

  PlayerTournamentsState({
    required this.tournaments,
    required this.isLoading,
    this.errorMessage,
  });

  PlayerTournamentsState copyWith({
    List<Tournament>? tournaments,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PlayerTournamentsState(
      tournaments: tournaments ?? this.tournaments,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
