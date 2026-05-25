part of 'my_tournaments_cubit.dart';

sealed class MyTournamentsState {}

class MyTournamentsLoading extends MyTournamentsState {}

class MyTournamentsLoaded extends MyTournamentsState {
  final List<Tournament> tournaments;
  MyTournamentsLoaded(this.tournaments);
}

class MyTournamentsError extends MyTournamentsState {
  final String message;
  MyTournamentsError(this.message);
}
