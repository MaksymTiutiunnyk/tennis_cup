part of 'players_tournaments_cubit.dart';

class PlayersTournamentsState {
  final List<Tournament> tournaments;
  final bool isLoading;
  final String? errorMessage;

  PlayersTournamentsState({
    required this.tournaments,
    required this.isLoading,
    this.errorMessage,
  });

  PlayersTournamentsState copyWith({
    List<Tournament>? tournaments,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PlayersTournamentsState(
      tournaments: tournaments ?? this.tournaments,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
