import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/repositories/match_repository.dart';

// TODO: move logic to other cubit

class PlayersMatchCubit extends Cubit<Match?> {
  final MatchRepository matchRepository;

  PlayersMatchCubit({required this.matchRepository}) : super(null);

  void fetchPlayersMatch(String matchId) async {
    final match = await matchRepository.fetchMatchById(matchId: matchId);
    emit(match);
  }
}
