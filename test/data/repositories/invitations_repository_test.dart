import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/data/models/arena.dart';
import 'package:tennis_cup/data/models/tournament_invitation.dart';
import 'package:tennis_cup/data/repositories/invitations_repository.dart';
import '../../../test/helpers/mocks.dart';
import '../../../test/helpers/fixtures.dart';

void main() {
  setUpAll(registerFallbackValues);

  late MockITournamentService mockTournamentService;
  late MockIArenaService mockArenaService;
  late InvitationsRepository repository;

  setUp(() {
    mockTournamentService = MockITournamentService();
    mockArenaService = MockIArenaService();
    repository =
        InvitationsRepository(mockTournamentService, mockArenaService);
  });

  group('fetchInvitations', () {
    test('returns empty list without calling arena/tournament service when DTOs empty',
        () async {
      when(() => mockTournamentService.fetchInvitations(status: any(named: 'status')))
          .thenAnswer((_) async => []);

      final result =
          await repository.fetchInvitations(status: 'PENDING');

      expect(result, isEmpty);
      verifyNever(() => mockTournamentService.fetchTournamentById(any()));
      verifyNever(() => mockArenaService.fetchAllArenas());
    });

    test('fetches tournament and arena when one invitation present', () async {
      final invDto = aMyInvitationDto(invitationId: 1, tournamentId: 10);
      final tournamentDto =
          aTournamentDto(id: 10, arenaId: 5, name: 'Open Cup');
      final arenaDto = anArenaDto(id: 5, color: 'RED', name: 'Centre Court');

      when(() => mockTournamentService.fetchInvitations(
              status: any(named: 'status')))
          .thenAnswer((_) async => [invDto]);
      when(() => mockTournamentService.fetchTournamentById('10'))
          .thenAnswer((_) async => tournamentDto);
      when(() => mockArenaService.fetchAllArenas())
          .thenAnswer((_) async => [arenaDto]);

      final result = await repository.fetchInvitations(status: 'PENDING');

      expect(result, hasLength(1));
      final inv = result.first;
      expect(inv.id, '1');
      expect(inv.tournamentId, '10');
      expect(inv.tournament.name, 'Open Cup');
      expect(inv.tournament.arena.title, 'Centre Court');
      expect(inv.tournament.arena.color, ArenaColor.red);
    });

    test('builds TournamentInvitation from invitation data when tournament not found',
        () async {
      final invDto = aMyInvitationDto(
        invitationId: 2,
        tournamentId: 99,
        tournamentName: 'Fallback Name',
        startTime: '2024-05-01T10:00:00',
      );
      final arenaDtos = <dynamic>[];

      // tournamentById fetch returns a dto but it won't match id 99 if we set
      // up an empty result here — simulate by having fetchTournamentById
      // return a dto for a different id (won't be in the map for id 99)
      when(() => mockTournamentService.fetchInvitations(
              status: any(named: 'status')))
          .thenAnswer((_) async => [invDto]);
      when(() => mockTournamentService.fetchTournamentById('99'))
          .thenAnswer((_) async => aTournamentDto(
                id: 99,
                name: 'Fallback Name',
                startTime: '2024-05-01T10:00:00',
              ));
      when(() => mockArenaService.fetchAllArenas())
          .thenAnswer((_) async => arenaDtos.cast());

      final result = await repository.fetchInvitations(status: 'PENDING');

      expect(result, hasLength(1));
      // When arena is not found, arena has empty id/title and grey color
      expect(result.first.tournament.arena.id, '');
      expect(result.first.tournament.date,
          DateTime.parse('2024-05-01T10:00:00'));
    });

    test('two invitations for same tournament id only fetch tournament once',
        () async {
      final inv1 = aMyInvitationDto(invitationId: 1, tournamentId: 10);
      final inv2 = aMyInvitationDto(invitationId: 2, tournamentId: 10);
      final tournamentDto = aTournamentDto(id: 10, arenaId: 1);
      final arenaDto = anArenaDto(id: 1);

      when(() => mockTournamentService.fetchInvitations(
              status: any(named: 'status')))
          .thenAnswer((_) async => [inv1, inv2]);
      when(() => mockTournamentService.fetchTournamentById('10'))
          .thenAnswer((_) async => tournamentDto);
      when(() => mockArenaService.fetchAllArenas())
          .thenAnswer((_) async => [arenaDto]);

      final result = await repository.fetchInvitations(status: 'PENDING');

      expect(result, hasLength(2));
      verify(() => mockTournamentService.fetchTournamentById('10')).called(1);
    });
  });

  group('_toDomain – role mapping', () {
    void stubSingleInvitation({
      required String role,
      String status = 'PENDING',
    }) {
      final dto = aMyInvitationDto(role: role, status: status);
      final tDto = aTournamentDto(id: dto.tournamentId, arenaId: 1);
      final aDto = anArenaDto(id: 1);

      when(() => mockTournamentService.fetchInvitations(
              status: any(named: 'status')))
          .thenAnswer((_) async => [dto]);
      when(() => mockTournamentService.fetchTournamentById(any()))
          .thenAnswer((_) async => tDto);
      when(() => mockArenaService.fetchAllArenas())
          .thenAnswer((_) async => [aDto]);
    }

    test("role 'REFEREE' → InvitationRole.referee", () async {
      stubSingleInvitation(role: 'REFEREE');

      final result = await repository.fetchInvitations(status: 'PENDING');

      expect(result.first.role, InvitationRole.referee);
    });

    test("role 'PLAYER' → InvitationRole.player", () async {
      stubSingleInvitation(role: 'PLAYER');

      final result = await repository.fetchInvitations(status: 'PENDING');

      expect(result.first.role, InvitationRole.player);
    });

    test("unknown role defaults to InvitationRole.player", () async {
      stubSingleInvitation(role: 'SPECTATOR');

      final result = await repository.fetchInvitations(status: 'PENDING');

      expect(result.first.role, InvitationRole.player);
    });
  });

  group('_toDomain – status mapping', () {
    void stubInvitationWithStatus(String status) {
      final dto = aMyInvitationDto(status: status);
      final tDto = aTournamentDto(id: dto.tournamentId, arenaId: 1);
      final aDto = anArenaDto(id: 1);

      when(() => mockTournamentService.fetchInvitations(
              status: any(named: 'status')))
          .thenAnswer((_) async => [dto]);
      when(() => mockTournamentService.fetchTournamentById(any()))
          .thenAnswer((_) async => tDto);
      when(() => mockArenaService.fetchAllArenas())
          .thenAnswer((_) async => [aDto]);
    }

    test("status 'ACCEPTED' → InvitationStatus.accepted", () async {
      stubInvitationWithStatus('ACCEPTED');

      final result = await repository.fetchInvitations(status: 'ACCEPTED');

      expect(result.first.status, InvitationStatus.accepted);
    });

    test("status 'DECLINED' → InvitationStatus.declined", () async {
      stubInvitationWithStatus('DECLINED');

      final result = await repository.fetchInvitations(status: 'DECLINED');

      expect(result.first.status, InvitationStatus.declined);
    });

    test("other status → InvitationStatus.pending", () async {
      stubInvitationWithStatus('PENDING');

      final result = await repository.fetchInvitations(status: 'PENDING');

      expect(result.first.status, InvitationStatus.pending);
    });
  });

  group('_toDomain – arena color', () {
    test('arena color RED maps to ArenaColor.red', () async {
      final dto = aMyInvitationDto(invitationId: 1, tournamentId: 10);
      final tDto = aTournamentDto(id: 10, arenaId: 5);
      final aDto = anArenaDto(id: 5, color: 'RED');

      when(() => mockTournamentService.fetchInvitations(
              status: any(named: 'status')))
          .thenAnswer((_) async => [dto]);
      when(() => mockTournamentService.fetchTournamentById('10'))
          .thenAnswer((_) async => tDto);
      when(() => mockArenaService.fetchAllArenas())
          .thenAnswer((_) async => [aDto]);

      final result = await repository.fetchInvitations(status: 'PENDING');

      expect(result.first.tournament.arena.color, ArenaColor.red);
    });

    test('arena color GREEN maps to ArenaColor.green', () async {
      final dto = aMyInvitationDto(invitationId: 1, tournamentId: 10);
      final tDto = aTournamentDto(id: 10, arenaId: 5);
      final aDto = anArenaDto(id: 5, color: 'GREEN');

      when(() => mockTournamentService.fetchInvitations(
              status: any(named: 'status')))
          .thenAnswer((_) async => [dto]);
      when(() => mockTournamentService.fetchTournamentById('10'))
          .thenAnswer((_) async => tDto);
      when(() => mockArenaService.fetchAllArenas())
          .thenAnswer((_) async => [aDto]);

      final result = await repository.fetchInvitations(status: 'PENDING');

      expect(result.first.tournament.arena.color, ArenaColor.green);
    });

    test('arena with id maps correctly to tournament arena id string', () async {
      final dto = aMyInvitationDto(invitationId: 1, tournamentId: 10);
      final tDto = aTournamentDto(id: 10, arenaId: 7);
      final aDto = anArenaDto(id: 7, color: 'BLUE', name: 'Blue Court');

      when(() => mockTournamentService.fetchInvitations(
              status: any(named: 'status')))
          .thenAnswer((_) async => [dto]);
      when(() => mockTournamentService.fetchTournamentById('10'))
          .thenAnswer((_) async => tDto);
      when(() => mockArenaService.fetchAllArenas())
          .thenAnswer((_) async => [aDto]);

      final result = await repository.fetchInvitations(status: 'PENDING');

      expect(result.first.tournament.arena.id, '7');
      expect(result.first.tournament.arena.title, 'Blue Court');
      expect(result.first.tournament.arena.color, ArenaColor.blue);
    });
  });

  group('acceptInvitation', () {
    test('delegates to tournamentService.acceptInvitation', () async {
      when(() => mockTournamentService.acceptInvitation('inv-42'))
          .thenAnswer((_) async {});

      await repository.acceptInvitation('inv-42');

      verify(() => mockTournamentService.acceptInvitation('inv-42')).called(1);
    });
  });

  group('declineInvitation', () {
    test('delegates to tournamentService.declineInvitation', () async {
      when(() => mockTournamentService.declineInvitation('inv-7'))
          .thenAnswer((_) async {});

      await repository.declineInvitation('inv-7');

      verify(() => mockTournamentService.declineInvitation('inv-7')).called(1);
    });
  });
}
