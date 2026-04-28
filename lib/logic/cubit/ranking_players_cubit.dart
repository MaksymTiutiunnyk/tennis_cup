import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/page_request.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/repositories/player_repository.dart';

part 'ranking_players_state.dart';

class RankingPlayersCubit extends Cubit<RankingPlayersState> {
  final PlayerRepository playerRepository;
  PageRequest _currentPage = const PageRequest(page: 0, size: 10);
  Sex _currentSex = Sex.All;

  RankingPlayersCubit({required this.playerRepository})
      : super(const RankingPlayersLoading());

  Future<void> fetchPlayers({required Sex sex, int size = 10}) async {
    _currentSex = sex;
    _currentPage = PageRequest(page: 0, size: size);
    emit(const RankingPlayersLoading());
    try {
      final result = await playerRepository.fetchRankingPlayers(
        page: _currentPage,
        sexFilter: sex,
      );
      if (result.hasMore) _currentPage = _currentPage.next;
      emit(RankingPlayersLoaded(players: result.items, hasMore: result.hasMore));
    } catch (_) {
      emit(const RankingPlayersError());
    }
  }

  Future<void> fetchPlayersWhenScrolled() async {
    final current = state;
    if (current is! RankingPlayersLoaded || !current.hasMore) return;

    emit(RankingPlayersLoadingMore(players: current.players));
    try {
      final result = await playerRepository.fetchRankingPlayers(
        page: _currentPage,
        sexFilter: _currentSex,
      );
      if (result.hasMore) _currentPage = _currentPage.next;
      emit(RankingPlayersLoaded(
        players: [...current.players, ...result.items],
        hasMore: result.hasMore,
      ));
    } catch (_) {
      emit(RankingPlayersLoaded(
        players: current.players,
        hasMore: current.hasMore,
      ));
    }
  }
}
