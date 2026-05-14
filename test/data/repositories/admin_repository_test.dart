import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/models/pending_user.dart';
import 'package:tennis_cup/data/models/user_role.dart';
import 'package:tennis_cup/data/repositories/admin_repository.dart';
import 'package:tennis_cup/data/services/dto/admin_dto.dart';
import '../../../test/helpers/mocks.dart';
import '../../../test/helpers/fixtures.dart';

void main() {
  setUpAll(registerFallbackValues);

  late MockIAdminService mockAdminService;
  late AdminRepository repository;

  setUp(() {
    mockAdminService = MockIAdminService();
    repository = AdminRepository(mockAdminService);
  });

  group('fetchPendingUsers', () {
    test('delegates to service and maps DTOs to PendingUser', () async {
      final dto = aPendingUserDto(
        id: 1,
        login: 'user@test.com',
        roles: ['PLAYER'],
        createdAt: '2024-01-01T10:00:00',
      );
      final pageResult = PageResult(items: [dto], hasMore: false);
      const page = PageRequest(page: 0, size: 20);

      when(() => mockAdminService.fetchPendingUsers(page))
          .thenAnswer((_) async => pageResult);

      final result = await repository.fetchPendingUsers(page);

      expect(result.items, hasLength(1));
      expect(result.hasMore, isFalse);
      expect(result.items.first.id, 1);
      expect(result.items.first.login, 'user@test.com');
      verify(() => mockAdminService.fetchPendingUsers(page)).called(1);
    });

    test('preserves hasMore from service result', () async {
      final dto = aPendingUserDto();
      final pageResult = PageResult(items: [dto], hasMore: true);

      when(() => mockAdminService.fetchPendingUsers(any()))
          .thenAnswer((_) async => pageResult);

      final result =
          await repository.fetchPendingUsers(const PageRequest(page: 0, size: 10));

      expect(result.hasMore, isTrue);
    });
  });

  group('_toPendingUser', () {
    test("roles ['PLAYER'] → [UserRole.player]", () async {
      final dto = aPendingUserDto(roles: ['PLAYER']);
      final pageResult = PageResult(items: [dto], hasMore: false);

      when(() => mockAdminService.fetchPendingUsers(any()))
          .thenAnswer((_) async => pageResult);

      final result =
          await repository.fetchPendingUsers(const PageRequest(page: 0, size: 10));

      expect(result.items.first.roles, [UserRole.player]);
    });

    test("roles ['REFEREE'] → [UserRole.referee]", () async {
      final dto = aPendingUserDto(roles: ['REFEREE']);
      final pageResult = PageResult(items: [dto], hasMore: false);

      when(() => mockAdminService.fetchPendingUsers(any()))
          .thenAnswer((_) async => pageResult);

      final result =
          await repository.fetchPendingUsers(const PageRequest(page: 0, size: 10));

      expect(result.items.first.roles, [UserRole.referee]);
    });

    test('unknown role string is skipped via whereType', () async {
      final dto = aPendingUserDto(roles: ['UNKNOWN_ROLE']);
      final pageResult = PageResult(items: [dto], hasMore: false);

      when(() => mockAdminService.fetchPendingUsers(any()))
          .thenAnswer((_) async => pageResult);

      final result =
          await repository.fetchPendingUsers(const PageRequest(page: 0, size: 10));

      expect(result.items.first.roles, isEmpty);
    });

    test('createdAt is parsed to DateTime', () async {
      final dto = aPendingUserDto(createdAt: '2024-03-15T08:30:00');
      final pageResult = PageResult(items: [dto], hasMore: false);

      when(() => mockAdminService.fetchPendingUsers(any()))
          .thenAnswer((_) async => pageResult);

      final result =
          await repository.fetchPendingUsers(const PageRequest(page: 0, size: 10));

      expect(result.items.first.createdAt, DateTime.parse('2024-03-15T08:30:00'));
    });

    test('invalid createdAt string → DateTime(0)', () async {
      final dto = aPendingUserDto(createdAt: 'not-a-date');
      final pageResult = PageResult(items: [dto], hasMore: false);

      when(() => mockAdminService.fetchPendingUsers(any()))
          .thenAnswer((_) async => pageResult);

      final result =
          await repository.fetchPendingUsers(const PageRequest(page: 0, size: 10));

      expect(result.items.first.createdAt, DateTime(0));
    });

    test('returns correct PendingUser type', () async {
      final dto = aPendingUserDto();
      final pageResult = PageResult(items: [dto], hasMore: false);

      when(() => mockAdminService.fetchPendingUsers(any()))
          .thenAnswer((_) async => pageResult);

      final result =
          await repository.fetchPendingUsers(const PageRequest(page: 0, size: 10));

      expect(result.items.first, isA<PendingUser>());
    });
  });

  group('approveUser', () {
    test('delegates to service.approveUser', () async {
      when(() => mockAdminService.approveUser(5)).thenAnswer((_) async {});

      await repository.approveUser(5);

      verify(() => mockAdminService.approveUser(5)).called(1);
    });
  });

  group('rejectUser', () {
    test('delegates to service.rejectUser without reason', () async {
      when(() => mockAdminService.rejectUser(3, reason: null))
          .thenAnswer((_) async {});

      await repository.rejectUser(3);

      verify(() => mockAdminService.rejectUser(3, reason: null)).called(1);
    });

    test('delegates to service.rejectUser with reason', () async {
      when(() => mockAdminService.rejectUser(3, reason: 'Spam'))
          .thenAnswer((_) async {});

      await repository.rejectUser(3, reason: 'Spam');

      verify(() => mockAdminService.rejectUser(3, reason: 'Spam')).called(1);
    });
  });

  group('createUser', () {
    test('builds CreateUserRequestDto and delegates to service', () async {
      when(() => mockAdminService.createUser(any()))
          .thenAnswer((_) async {});

      await repository.createUser(
        role: 'PLAYER',
        login: 'john@example.com',
        password: 'secret',
        firstName: 'John',
        lastName: 'Doe',
        patronymicName: 'Jr',
        birthDate: '1990-01-01',
        gender: 'MALE',
        country: 'UA',
        city: 'Kyiv',
      );

      final captured = verify(() => mockAdminService.createUser(captureAny()))
          .captured
          .single as CreateUserRequestDto;

      expect(captured.role, 'PLAYER');
      expect(captured.login, 'john@example.com');
      expect(captured.password, 'secret');
      expect(captured.firstName, 'John');
      expect(captured.lastName, 'Doe');
      expect(captured.patronymicName, 'Jr');
      expect(captured.birthDate, '1990-01-01');
      expect(captured.gender, 'MALE');
      expect(captured.country, 'UA');
      expect(captured.city, 'Kyiv');
    });

    test('optional fields passed as null when not provided', () async {
      when(() => mockAdminService.createUser(any()))
          .thenAnswer((_) async {});

      await repository.createUser(
        role: 'REFEREE',
        login: 'ref@example.com',
        password: 'pass',
        firstName: 'Anna',
        lastName: 'Smith',
      );

      final captured = verify(() => mockAdminService.createUser(captureAny()))
          .captured
          .single as CreateUserRequestDto;

      expect(captured.patronymicName, isNull);
      expect(captured.birthDate, isNull);
      expect(captured.gender, isNull);
      expect(captured.country, isNull);
      expect(captured.city, isNull);
    });
  });

  group('searchReferees', () {
    test("calls service with roles=['REFEREE'] and maps to UserSearchResult",
        () async {
      final dto = aUserSearchDto(
        userId: 3,
        firstName: 'Maria',
        lastName: 'Ref',
        roles: ['REFEREE'],
      );

      when(() => mockAdminService.searchUsers(
            query: 'Maria',
            roles: ['REFEREE'],
          )).thenAnswer((_) async => [dto]);

      final result = await repository.searchReferees('Maria');

      expect(result, hasLength(1));
      expect(result.first.userId, 3);
      expect(result.first.firstName, 'Maria');
      expect(result.first.roles, [UserRole.referee]);
      verify(() => mockAdminService.searchUsers(
            query: 'Maria',
            roles: ['REFEREE'],
          )).called(1);
    });
  });

  group('searchAllUsers', () {
    test('calls service without roles filter and maps results', () async {
      final dto = aUserSearchDto(userId: 7, roles: ['PLAYER', 'REFEREE']);

      when(() => mockAdminService.searchUsers(
            query: 'test',
          )).thenAnswer((_) async => [dto]);

      final result = await repository.searchAllUsers('test');

      expect(result, hasLength(1));
      expect(result.first.roles, [UserRole.player, UserRole.referee]);
      verify(() => mockAdminService.searchUsers(query: 'test')).called(1);
    });
  });

  group('getUserById', () {
    test('calls service and maps UserProfileDto to UserProfile', () async {
      final dto = aUserProfileDto(
        userId: 9,
        firstName: 'Alex',
        lastName: 'Koval',
        roles: ['ADMIN'],
        gender: 'MALE',
        avatarUrl: 'https://img.example.com/9.jpg',
      );

      when(() => mockAdminService.getUserById(9))
          .thenAnswer((_) async => dto);

      final result = await repository.getUserById(9);

      expect(result.userId, 9);
      expect(result.firstName, 'Alex');
      expect(result.lastName, 'Koval');
      expect(result.roles, [UserRole.admin]);
      expect(result.gender, 'MALE');
      expect(result.avatarUrl, 'https://img.example.com/9.jpg');
    });

    test('unknown roles in UserProfileDto are skipped', () async {
      final dto = aUserProfileDto(roles: ['UNKNOWN', 'PLAYER']);

      when(() => mockAdminService.getUserById(any()))
          .thenAnswer((_) async => dto);

      final result = await repository.getUserById(1);

      expect(result.roles, [UserRole.player]);
    });
  });

  group('_toUserSearchResult', () {
    test(
        "roles ['PLAYER', 'REFEREE'] → [UserRole.player, UserRole.referee]",
        () async {
      final dto = aUserSearchDto(roles: ['PLAYER', 'REFEREE']);

      when(() => mockAdminService.searchUsers(
            query: any(named: 'query'),
          )).thenAnswer((_) async => [dto]);

      final result = await repository.searchAllUsers('');

      expect(result.first.roles, [UserRole.player, UserRole.referee]);
    });

    test('unknown role string is skipped', () async {
      final dto = aUserSearchDto(roles: ['UNKNOWN']);

      when(() => mockAdminService.searchUsers(
            query: any(named: 'query'),
          )).thenAnswer((_) async => [dto]);

      final result = await repository.searchAllUsers('');

      expect(result.first.roles, isEmpty);
    });

    test('avatarUrl is preserved when present', () async {
      final dto =
          aUserSearchDto(avatarUrl: 'https://cdn.example.com/avatar.jpg');

      when(() => mockAdminService.searchUsers(
            query: any(named: 'query'),
          )).thenAnswer((_) async => [dto]);

      final result = await repository.searchAllUsers('');

      expect(result.first.avatarUrl, 'https://cdn.example.com/avatar.jpg');
    });

    test('avatarUrl is null when not provided', () async {
      final dto = aUserSearchDto(avatarUrl: null);

      when(() => mockAdminService.searchUsers(
            query: any(named: 'query'),
          )).thenAnswer((_) async => [dto]);

      final result = await repository.searchAllUsers('');

      expect(result.first.avatarUrl, isNull);
    });
  });
}
