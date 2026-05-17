import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/models/pending_user.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/pending_users_cubit.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  setUpAll(registerFallbackValues);

  late MockAdminRepository mockRepo;

  setUp(() {
    mockRepo = MockAdminRepository();
    // Stall constructor's auto-load so it never completes and doesn't
    // interfere with seed-based or act-based tests.
    when(() => mockRepo.fetchPendingUsers(any()))
        .thenAnswer((_) => Completer<PageResult<PendingUser>>().future);
  });

  PendingUsersCubit buildCubit() => PendingUsersCubit(repository: mockRepo);

  group('load', () {
    blocTest<PendingUsersCubit, PendingUsersState>(
      'success emits [PendingUsersLoading, PendingUsersLoaded([])]',
      build: buildCubit,
      act: (cubit) async {
        when(() => mockRepo.fetchPendingUsers(any()))
            .thenAnswer((_) async => const PageResult(items: [], hasMore: false));
        await cubit.load();
      },
      expect: () => [
        isA<PendingUsersLoading>(),
        isA<PendingUsersLoaded>()
            .having((s) => s.users, 'users', isEmpty),
      ],
    );

    blocTest<PendingUsersCubit, PendingUsersState>(
      'failure emits [PendingUsersLoading, PendingUsersError]',
      build: buildCubit,
      act: (cubit) async {
        when(() => mockRepo.fetchPendingUsers(any()))
            .thenThrow(Exception('server error'));
        await cubit.load();
      },
      expect: () => [
        isA<PendingUsersLoading>(),
        isA<PendingUsersError>()
            .having((s) => s.message, 'message', isNotEmpty),
      ],
    );
  });

  group('approve', () {
    final user1 = aPendingUser(id: 1);
    final user2 = aPendingUser(id: 2);

    blocTest<PendingUsersCubit, PendingUsersState>(
      'success: optimistically removes user, approve service called',
      setUp: () {
        when(() => mockRepo.approveUser(any())).thenAnswer((_) async {});
      },
      build: buildCubit,
      seed: () => PendingUsersLoaded([user1, user2]),
      act: (cubit) => cubit.approve(1),
      expect: () => [
        isA<PendingUsersLoaded>()
            .having((s) => s.users, 'users after removal', [user2]),
      ],
      verify: (_) {
        verify(() => mockRepo.approveUser(1)).called(1);
      },
    );

    blocTest<PendingUsersCubit, PendingUsersState>(
      'failure: restores snapshot, emits error',
      setUp: () {
        when(() => mockRepo.approveUser(any()))
            .thenThrow(Exception('approve failed'));
      },
      build: buildCubit,
      seed: () => PendingUsersLoaded([user1, user2]),
      act: (cubit) => cubit.approve(1),
      expect: () => [
        isA<PendingUsersLoaded>()
            .having((s) => s.users, 'after optimistic removal', [user2]),
        isA<PendingUsersLoaded>()
            .having((s) => s.users, 'restored', [user1, user2]),
        isA<PendingUsersError>(),
      ],
    );

    blocTest<PendingUsersCubit, PendingUsersState>(
      'when state is not PendingUsersLoaded: no state change',
      setUp: () {
        when(() => mockRepo.approveUser(any())).thenAnswer((_) async {});
      },
      build: buildCubit,
      seed: () => PendingUsersLoading(),
      act: (cubit) => cubit.approve(1),
      expect: () => const [],
    );
  });

  group('reject', () {
    final user1 = aPendingUser(id: 1);
    final user2 = aPendingUser(id: 2);

    blocTest<PendingUsersCubit, PendingUsersState>(
      'success: removes user',
      setUp: () {
        when(() => mockRepo.rejectUser(any(), reason: any(named: 'reason')))
            .thenAnswer((_) async {});
      },
      build: buildCubit,
      seed: () => PendingUsersLoaded([user1, user2]),
      act: (cubit) => cubit.reject(1, reason: 'spam'),
      expect: () => [
        isA<PendingUsersLoaded>()
            .having((s) => s.users, 'users after removal', [user2]),
      ],
      verify: (_) {
        verify(() => mockRepo.rejectUser(1, reason: 'spam')).called(1);
      },
    );

    blocTest<PendingUsersCubit, PendingUsersState>(
      'failure: restores snapshot, emits error',
      setUp: () {
        when(() => mockRepo.rejectUser(any(), reason: any(named: 'reason')))
            .thenThrow(Exception('reject failed'));
      },
      build: buildCubit,
      seed: () => PendingUsersLoaded([user1, user2]),
      act: (cubit) => cubit.reject(1),
      expect: () => [
        isA<PendingUsersLoaded>()
            .having((s) => s.users, 'after optimistic removal', [user2]),
        isA<PendingUsersLoaded>()
            .having((s) => s.users, 'restored', [user1, user2]),
        isA<PendingUsersError>(),
      ],
    );

    blocTest<PendingUsersCubit, PendingUsersState>(
      'when state is not PendingUsersLoaded: no state change',
      setUp: () {
        when(() => mockRepo.rejectUser(any(), reason: any(named: 'reason')))
            .thenAnswer((_) async {});
      },
      build: buildCubit,
      seed: () => PendingUsersLoading(),
      act: (cubit) => cubit.reject(1),
      expect: () => const [],
    );
  });
}
