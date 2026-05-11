import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/models/player.dart';
import 'package:tennis_cup/data/repositories/match_repository.dart';

part 'head_to_head_state.dart';

class HeadToHeadCubit extends Cubit<HeadToHeadState> {
  final MatchRepository matchRepository;
  final Player player1;
  final Player player2;
  PageRequest _currentPage = const PageRequest(page: 0, size: 10);
  bool _isLoading = false;

  HeadToHeadCubit(
    this.player1,
    this.player2, {
    required this.matchRepository,
  }) : super(const HeadToHeadLoading());

  Future<void> fetch() async {
    if (_isLoading) return;
    final current = state;
    if (current is HeadToHeadLoaded && !current.hasMore) return;

    _isLoading = true;
    try {
      final result = await matchRepository.fetchHeadToHead(
        userId1: player1.userId,
        userId2: player2.userId,
        page: _currentPage,
      );
      if (result.hasMore) _currentPage = _currentPage.next;

      final existing =
          current is HeadToHeadLoaded ? current.matches : <Match>[];
      emit(HeadToHeadLoaded(
        matches: [...existing, ...result.items],
        hasMore: result.hasMore,
      ));
    } catch (_) {
      emit(const HeadToHeadError('Error loading matches'));
    } finally {
      _isLoading = false;
    }
  }
}
