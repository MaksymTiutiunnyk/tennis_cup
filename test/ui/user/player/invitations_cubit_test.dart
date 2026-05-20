import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/ui/user/player/view_models/invitations_cubit.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  setUpAll(registerFallbackValues);

  late MockInvitationsRepository mockRepo;

  const testStatus = 'PENDING';

  setUp(() {
    mockRepo = MockInvitationsRepository();
  });

  InvitationsCubit buildCubit() =>
      InvitationsCubit(repository: mockRepo, status: testStatus);

  final inv1 = aTournamentInvitation(id: 'inv-1');
  final inv2 = aTournamentInvitation(id: 'inv-2');

  // ── load (auto-init from constructor) ──────────────────────────────────────
  // The constructor fires _load asynchronously. We use `wait` so blocTest
  // keeps observing until the Future resolves.

  group('load (auto-init)', () {
    blocTest<InvitationsCubit, InvitationsState>(
      'success emits InvitationsLoaded with fetched items',
      setUp: () {
        when(() => mockRepo.fetchInvitations(status: testStatus))
            .thenAnswer((_) async => [inv1, inv2]);
      },
      build: buildCubit,
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<InvitationsLoaded>()
            .having((s) => s.items, 'items', [inv1, inv2]),
      ],
    );

    blocTest<InvitationsCubit, InvitationsState>(
      'failure emits InvitationsError with correct message',
      setUp: () {
        // Use thenAnswer so the throw is inside an async future, matching
        // how the cubit awaits it.
        when(() => mockRepo.fetchInvitations(status: testStatus))
            .thenAnswer((_) async => throw Exception('network error'));
      },
      build: buildCubit,
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<InvitationsError>()
            .having((s) => s.message, 'message', 'network error'),
      ],
    );
  });

  // ── reload ─────────────────────────────────────────────────────────────────
  // Seed with an already-loaded state so the constructor's async _load fires
  // but emits a state equal to the seed (blocTest deduplicates consecutive
  // equal states only if they are identical objects; here Loaded([inv1, inv2])
  // is a fresh instance each time, so we capture both). Use a completer to
  // pause the auto-init and only let the reload through cleanly:
  // simplest approach — stub returns same data and we capture both emissions,
  // then verify the last one has the right content.

  group('reload', () {
    blocTest<InvitationsCubit, InvitationsState>(
      're-fetches and emits InvitationsLoaded',
      setUp: () {
        when(() => mockRepo.fetchInvitations(status: testStatus))
            .thenAnswer((_) async => [inv1, inv2]);
      },
      build: buildCubit,
      act: (cubit) async {
        // Wait for auto-init to settle, then reload
        await Future<void>.delayed(const Duration(milliseconds: 5));
        await cubit.reload();
      },
      wait: const Duration(milliseconds: 10),
      expect: () => [
        // auto-init result
        isA<InvitationsLoaded>(),
        // reload result
        isA<InvitationsLoaded>()
            .having((s) => s.items, 'items', [inv1, inv2]),
      ],
    );
  });

  // ── accept / decline ───────────────────────────────────────────────────────
  // Wait for auto-init, then call the action. Both the auto-init emission and
  // the action emission are captured in order.

  group('accept', () {
    blocTest<InvitationsCubit, InvitationsState>(
      'success removes accepted item from loaded list',
      setUp: () {
        when(() => mockRepo.fetchInvitations(status: testStatus))
            .thenAnswer((_) async => [inv1, inv2]);
        when(() => mockRepo.acceptInvitation('inv-1'))
            .thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (cubit) async {
        await Future<void>.delayed(const Duration(milliseconds: 5));
        await cubit.accept('inv-1');
      },
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<InvitationsLoaded>(), // auto-init
        isA<InvitationsLoaded>()
            .having((s) => s.items, 'items without inv-1', [inv2]),
      ],
    );

    blocTest<InvitationsCubit, InvitationsState>(
      'failure emits InvitationsError with update message',
      setUp: () {
        when(() => mockRepo.fetchInvitations(status: testStatus))
            .thenAnswer((_) async => [inv1, inv2]);
        when(() => mockRepo.acceptInvitation('inv-1'))
            .thenAnswer((_) async => throw Exception('server error'));
      },
      build: buildCubit,
      act: (cubit) async {
        await Future<void>.delayed(const Duration(milliseconds: 5));
        await cubit.accept('inv-1');
      },
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<InvitationsLoaded>(), // auto-init
        isA<InvitationsError>()
            .having((s) => s.message, 'message', 'server error'),
      ],
    );

    blocTest<InvitationsCubit, InvitationsState>(
      'no-op when state is not InvitationsLoaded',
      setUp: () {
        when(() => mockRepo.fetchInvitations(status: testStatus))
            .thenAnswer((_) async => throw Exception('fail'));
      },
      build: buildCubit,
      act: (cubit) async {
        await Future<void>.delayed(const Duration(milliseconds: 5));
        await cubit.accept('inv-1');
      },
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<InvitationsError>(), // from auto-init (state is Error, not Loaded)
        // accept is a no-op — no further state change
      ],
    );
  });

  group('decline', () {
    blocTest<InvitationsCubit, InvitationsState>(
      'success removes declined item from loaded list',
      setUp: () {
        when(() => mockRepo.fetchInvitations(status: testStatus))
            .thenAnswer((_) async => [inv1, inv2]);
        when(() => mockRepo.declineInvitation('inv-2'))
            .thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (cubit) async {
        await Future<void>.delayed(const Duration(milliseconds: 5));
        await cubit.decline('inv-2');
      },
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<InvitationsLoaded>(), // auto-init
        isA<InvitationsLoaded>()
            .having((s) => s.items, 'items without inv-2', [inv1]),
      ],
    );

    blocTest<InvitationsCubit, InvitationsState>(
      'failure emits InvitationsError with update message',
      setUp: () {
        when(() => mockRepo.fetchInvitations(status: testStatus))
            .thenAnswer((_) async => [inv1, inv2]);
        when(() => mockRepo.declineInvitation('inv-2'))
            .thenAnswer((_) async => throw Exception('server error'));
      },
      build: buildCubit,
      act: (cubit) async {
        await Future<void>.delayed(const Duration(milliseconds: 5));
        await cubit.decline('inv-2');
      },
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<InvitationsLoaded>(), // auto-init
        isA<InvitationsError>()
            .having((s) => s.message, 'message', 'server error'),
      ],
    );

    blocTest<InvitationsCubit, InvitationsState>(
      'no-op when state is not InvitationsLoaded',
      setUp: () {
        when(() => mockRepo.fetchInvitations(status: testStatus))
            .thenAnswer((_) async => throw Exception('fail'));
      },
      build: buildCubit,
      act: (cubit) async {
        await Future<void>.delayed(const Duration(milliseconds: 5));
        await cubit.decline('inv-2');
      },
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<InvitationsError>(), // from auto-init
        // decline is a no-op — no further state change
      ],
    );
  });
}
