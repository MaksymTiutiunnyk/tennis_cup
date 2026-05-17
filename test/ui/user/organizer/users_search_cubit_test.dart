import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/users_search_cubit.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/users_search_state.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  setUpAll(registerFallbackValues);

  late MockAdminRepository mockRepo;

  setUp(() {
    mockRepo = MockAdminRepository();
  });

  UsersSearchCubit buildCubit() =>
      UsersSearchCubit(adminRepository: mockRepo);

  group('initial state', () {
    test('is UsersSearchIdle', () {
      expect(buildCubit().state, isA<UsersSearchIdle>());
    });
  });

  group('search — short / blank query', () {
    blocTest<UsersSearchCubit, UsersSearchState>(
      'empty string emits [UsersSearchIdle]',
      build: buildCubit,
      act: (cubit) => cubit.search(''),
      expect: () => [isA<UsersSearchIdle>()],
    );

    blocTest<UsersSearchCubit, UsersSearchState>(
      'single character emits [UsersSearchIdle]',
      build: buildCubit,
      act: (cubit) => cubit.search('a'),
      expect: () => [isA<UsersSearchIdle>()],
    );

    blocTest<UsersSearchCubit, UsersSearchState>(
      'whitespace-only string emits [UsersSearchIdle]',
      build: buildCubit,
      act: (cubit) => cubit.search('  '),
      expect: () => [isA<UsersSearchIdle>()],
    );
  });

  group('search', () {
    final user1 = aUser(id: 1, firstName: 'Ivan', lastName: 'Petrov');
    final user2 = aUser(id: 2, firstName: 'Anna', lastName: 'Koval');

    blocTest<UsersSearchCubit, UsersSearchState>(
      'success emits [UsersSearchLoading, UsersSearchLoaded] with mapped users',
      setUp: () {
        when(() => mockRepo.searchAllUsers(any()))
            .thenAnswer((_) async => [user1, user2]);
      },
      build: buildCubit,
      act: (cubit) => cubit.search('ivan'),
      expect: () => [
        isA<UsersSearchLoading>(),
        isA<UsersSearchLoaded>().having(
          (s) => s.users.map((u) => u.id).toList(),
          'userIds',
          [1, 2],
        ),
      ],
      verify: (_) {
        verify(() => mockRepo.searchAllUsers('ivan')).called(1);
      },
    );

    blocTest<UsersSearchCubit, UsersSearchState>(
      'failure emits [UsersSearchLoading, UsersSearchError]',
      setUp: () {
        when(() => mockRepo.searchAllUsers(any()))
            .thenThrow(Exception('network error'));
      },
      build: buildCubit,
      act: (cubit) => cubit.search('ivan'),
      expect: () => [
        isA<UsersSearchLoading>(),
        isA<UsersSearchError>().having(
          (s) => s.message,
          'message',
          'Failed to search users',
        ),
      ],
    );
  });

  group('refresh', () {
    blocTest<UsersSearchCubit, UsersSearchState>(
      'when _lastQuery is empty: no state change',
      build: buildCubit,
      act: (cubit) => cubit.refresh(),
      expect: () => const [],
      verify: (_) {
        verifyNever(() => mockRepo.searchAllUsers(any()));
      },
    );

    blocTest<UsersSearchCubit, UsersSearchState>(
      'after prior search repeats the same query',
      setUp: () {
        when(() => mockRepo.searchAllUsers(any()))
            .thenAnswer((_) async => [aUser(id: 1)]);
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.search('ivan');
        await cubit.refresh();
      },
      skip: 2,
      expect: () => [
        isA<UsersSearchLoading>(),
        isA<UsersSearchLoaded>(),
      ],
      verify: (_) {
        verify(() => mockRepo.searchAllUsers('ivan')).called(2);
      },
    );
  });

  group('_toCombinedUser', () {
    blocTest<UsersSearchCubit, UsersSearchState>(
      'avatarUrl null in result → avatarUrl empty string in CombinedUser',
      setUp: () {
        when(() => mockRepo.searchAllUsers(any()))
            .thenAnswer((_) async => [aUser(imageUrl: '')]);
      },
      build: buildCubit,
      act: (cubit) => cubit.search('ivan'),
      expect: () => [
        isA<UsersSearchLoading>(),
        isA<UsersSearchLoaded>().having(
          (s) => s.users.first.imageUrl,
          'imageUrl',
          '',
        ),
      ],
    );
  });
}
