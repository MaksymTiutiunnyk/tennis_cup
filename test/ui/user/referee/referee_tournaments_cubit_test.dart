import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/ui/user/referee/view_models/referee_tournaments_cubit.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  setUpAll(registerFallbackValues);

  late MockRefereeRepository mockRepo;

  const testUserId = '42';

  setUp(() {
    mockRepo = MockRefereeRepository();
  });

  RefereeTournamentsCubit buildCubit() =>
      RefereeTournamentsCubit(repository: mockRepo, userId: testUserId);

  final tDto1 = aTournamentDto(id: 1, name: 'Tournament A', refereeId: 42);
  final tDto2 = aTournamentDto(id: 2, name: 'Tournament B', refereeId: 42);

  group('initial load', () {
    blocTest<RefereeTournamentsCubit, RefereeTournamentsState>(
      'success emits RefereeTournamentsLoaded with fetched tournaments',
      setUp: () {
        when(() => mockRepo.fetchActiveTournamentsForReferee(testUserId))
            .thenAnswer((_) async => [tDto1, tDto2]);
      },
      build: buildCubit,
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<RefereeTournamentsLoaded>()
            .having((s) => s.tournaments, 'tournaments', [tDto1, tDto2]),
      ],
    );

    blocTest<RefereeTournamentsCubit, RefereeTournamentsState>(
      'failure emits RefereeTournamentsError with correct message',
      setUp: () {
        when(() => mockRepo.fetchActiveTournamentsForReferee(testUserId))
            .thenAnswer((_) async => throw Exception('network error'));
      },
      build: buildCubit,
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<RefereeTournamentsError>()
            .having((s) => s.message, 'message', 'Failed to load tournaments'),
      ],
    );
  });

  group('reload', () {
    blocTest<RefereeTournamentsCubit, RefereeTournamentsState>(
      'emits [RefereeTournamentsLoading, RefereeTournamentsLoaded]',
      setUp: () {
        when(() => mockRepo.fetchActiveTournamentsForReferee(testUserId))
            .thenAnswer((_) async => [tDto1, tDto2]);
      },
      build: buildCubit,
      act: (cubit) async {
        // Let auto-init settle before calling reload
        await Future<void>.delayed(const Duration(milliseconds: 5));
        await cubit.reload();
      },
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<RefereeTournamentsLoaded>(), // from auto-init
        isA<RefereeTournamentsLoading>(), // reload resets to loading
        isA<RefereeTournamentsLoaded>()
            .having((s) => s.tournaments, 'tournaments', [tDto1, tDto2]),
      ],
    );
  });
}
