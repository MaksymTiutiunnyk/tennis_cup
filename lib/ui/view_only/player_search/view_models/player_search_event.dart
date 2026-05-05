part of 'player_search_bloc.dart';

abstract class PlayerSearchEvent {
  const PlayerSearchEvent();
}

class SearchFieldChanged extends PlayerSearchEvent {
  final String value;

  const SearchFieldChanged(this.value);
}
