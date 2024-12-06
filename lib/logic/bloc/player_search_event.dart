part of 'player_search_bloc.dart';

abstract class PlayerSearchEvent {}

class SearchFieldChanged extends PlayerSearchEvent {
  final String value;

  SearchFieldChanged(this.value);
}
