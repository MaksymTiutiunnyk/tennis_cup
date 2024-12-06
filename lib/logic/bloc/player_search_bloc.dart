import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/data_providers/player_api.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/repositories/player_repository.dart';

part 'player_search_state.dart';
part 'player_search_event.dart';

class PlayerSearchBloc extends Bloc<PlayerSearchEvent, PlayerSearchState> {
  final playerRepository = const PlayerRepository(playerApi: PlayerApi());

  PlayerSearchBloc(super.initialState) {
    on<SearchFieldChanged>((event, emit) async {
      emit(PlayerSearchLoading());

      final players = await _searchPlayers(event.value);

      emit(PlayerSearchLoaded(players));
    });
  }

  Future<List<Player>> _searchPlayers(String value) async {
    final query = value.trim();

    if (query.isEmpty) {
      return [];
    }

    final players = <Player>{};
    final playersByName =
        await playerRepository.fetchPlayersBySubstring(substring: query);
    final playersBySurname = await playerRepository.fetchPlayersBySubstring(
        substring: query, isSurname: true);

    players.addAll(playersByName);
    players.addAll(playersBySurname);

    return players.toList();
  }
}
