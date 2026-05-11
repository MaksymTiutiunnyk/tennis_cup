import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/repositories/player_repository.dart';

part 'player_search_state.dart';
part 'player_search_event.dart';

class PlayerSearchBloc extends Bloc<PlayerSearchEvent, PlayerSearchState> {
  final PlayerRepository playerRepository;

  PlayerSearchBloc({
    required this.playerRepository,
    required PlayerSearchState initialState,
  }) : super(initialState) {
    on<SearchFieldChanged>((event, emit) async {
      emit(PlayerSearchLoading());

      try {
        final players = await _searchPlayers(event.value);

        if (players.isEmpty) {
          emit(PlayersNotFound());
          return;
        }

        emit(PlayerSearchLoaded(players));
      } catch (e) {
        emit(PlayerSearchError(e));
      }
    });
  }

  Future<List<Player>> _searchPlayers(String value) async {
    final query = value.trim();
    if (query.isEmpty) return [];
    return playerRepository.fetchPlayersBySubstring(query: query);
  }
}
