import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/data/models/match.dart';
import 'package:tennis_cup/ui/view_only/home/view_models/live_match_cubit.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  setUpAll(registerFallbackValues);

  late MockMatchRepository mockRepo;

  final player1 = aUser(id: 1);
  final player2 = aUser(id: 2);

  Match makeMatch(String label) => Match(
        id: label.hashCode.abs(),
        bluePlayer: player1,
        redPlayer: player2,
        scheduledStart: DateTime(2024, 1, 15),
      );

  setUp(() {
    mockRepo = MockMatchRepository();
  });

  group('LiveMatchCubit', () {
    test('with initialMatch provided — initial state is that match', () {
      final initial = makeMatch('m1');
      // stub watchMatchChanges to return an empty stream so no extra events fire
      when(() => mockRepo.watchMatchChanges('m1'))
          .thenAnswer((_) => const Stream.empty());

      final cubit = LiveMatchCubit(
        matchId: 'm1',
        matchRepository: mockRepo,
        initialMatch: initial,
      );

      expect(cubit.state, initial);
      verifyNever(() => mockRepo.fetchMatchById(matchId: any(named: 'matchId')));
      cubit.close();
    });

    test('without initialMatch — fetches via fetchMatchById and emits result',
        () async {
      final fetched = makeMatch('m2');
      when(() => mockRepo.watchMatchChanges('m2'))
          .thenAnswer((_) => const Stream.empty());
      when(() => mockRepo.fetchMatchById(matchId: 'm2'))
          .thenAnswer((_) async => fetched);

      final cubit = LiveMatchCubit(
        matchId: 'm2',
        matchRepository: mockRepo,
      );

      // Wait for the async _fetch to complete
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(cubit.state, fetched);
      verify(() => mockRepo.fetchMatchById(matchId: 'm2')).called(1);
      cubit.close();
    });

    test('WebSocket stream emitting a match updates cubit state', () async {
      final controller = StreamController<Match>();
      final wsMatch = makeMatch('m3-ws');

      when(() => mockRepo.watchMatchChanges('m3'))
          .thenAnswer((_) => controller.stream);
      when(() => mockRepo.fetchMatchById(matchId: 'm3'))
          .thenAnswer((_) async => makeMatch('m3'));

      final cubit = LiveMatchCubit(
        matchId: 'm3',
        matchRepository: mockRepo,
      );

      // Let initial fetch settle
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Emit via WebSocket
      controller.add(wsMatch);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(cubit.state, wsMatch);

      await cubit.close();
      await controller.close();
    });

    test('close() cancels stream subscription without throwing', () async {
      final controller = StreamController<Match>();

      when(() => mockRepo.watchMatchChanges('m4'))
          .thenAnswer((_) => controller.stream);
      when(() => mockRepo.fetchMatchById(matchId: 'm4'))
          .thenAnswer((_) async => makeMatch('m4'));

      final cubit = LiveMatchCubit(
        matchId: 'm4',
        matchRepository: mockRepo,
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Should complete without error
      await expectLater(cubit.close(), completes);

      // Emitting after close should not crash
      controller.add(makeMatch('m4-after-close'));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await controller.close();
    });
  });
}
