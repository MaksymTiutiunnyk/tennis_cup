import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/data_providers/match_api.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/data/repositories/match_repository.dart';

class LiveStreamMatchCubit extends Cubit<Match> {
  final matchRepository = const MatchRepository(matchApi: MatchApi());

  LiveStreamMatchCubit(super.match);

  void fetchLiveStreamMatch(String matchId) async {
    final match = await matchRepository.fetchMatchById(matchId: matchId);

    emit(match);
  }
}
