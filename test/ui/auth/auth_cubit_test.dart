import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/data/models/user_role.dart';
import 'package:tennis_cup/data/services/rest/rest_auth_service.dart';
import 'package:tennis_cup/ui/auth/view_models/auth_cubit.dart';

import '../../helpers/mocks.dart';

// JWT with sub='42', roles=['PLAYER']
// Header: {"alg":"HS256"}, Payload: {"sub":"42","roles":["PLAYER"]}
const _testJwt =
    'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI0MiIsInJvbGVzIjpbIlBMQVlFUiJdfQ.sig';

void main() {
  setUpAll(registerFallbackValues);

  late MockRestAuthService mockAuthService;
  late MockAuthTokenStore mockTokenStore;

  setUp(() {
    mockAuthService = MockRestAuthService();
    mockTokenStore = MockAuthTokenStore();
  });

  AuthCubit buildCubit() => AuthCubit(
        authService: mockAuthService,
        tokenStore: mockTokenStore,
      );

  test('initial state is AuthInitial', () {
    expect(buildCubit().state, isA<AuthInitial>());
  });

  group('checkAuthStatus', () {
    blocTest<AuthCubit, AuthState>(
      'emits AuthAuthenticated when token is present in store',
      setUp: () {
        when(() => mockTokenStore.getAccessToken())
            .thenAnswer((_) async => _testJwt);
      },
      build: buildCubit,
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [
        isA<AuthAuthenticated>()
            .having((s) => s.userId, 'userId', '42')
            .having((s) => s.roles, 'roles', [UserRole.player]),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits AuthUnauthenticated when token is null',
      setUp: () {
        when(() => mockTokenStore.getAccessToken())
            .thenAnswer((_) async => null);
      },
      build: buildCubit,
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [isA<AuthUnauthenticated>()],
    );
  });

  group('login', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on success',
      setUp: () {
        when(() => mockAuthService.login(
              login: any(named: 'login'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => const TokenResponse(
              accessToken: _testJwt,
              refreshToken: 'refresh',
            ));
        when(() => mockTokenStore.getAccessToken())
            .thenAnswer((_) async => _testJwt);
      },
      build: buildCubit,
      act: (cubit) => cubit.login(login: 'user@test.com', password: 'pass123'),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>()
            .having((s) => s.userId, 'userId', '42')
            .having((s) => s.roles, 'roles', [UserRole.player]),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] with stripped message on Exception',
      setUp: () {
        when(() => mockAuthService.login(login: any(named: 'login'), password: any(named: 'password')))
            .thenThrow(Exception('Login failed'));
      },
      build: buildCubit,
      act: (cubit) => cubit.login(login: 'user@test.com', password: 'wrong'),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having((s) => s.message, 'message', 'Login failed'),
      ],
    );
  });

  group('register', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] with approval message on success',
      setUp: () {
        when(() => mockAuthService.register(
              login: any(named: 'login'),
              password: any(named: 'password'),
              role: any(named: 'role'),
              firstName: any(named: 'firstName'),
              lastName: any(named: 'lastName'),
              patronymicName: any(named: 'patronymicName'),
              birthDate: any(named: 'birthDate'),
              gender: any(named: 'gender'),
              country: any(named: 'country'),
              city: any(named: 'city'),
            )).thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (cubit) => cubit.register(
        login: 'new@test.com',
        password: 'secret',
        role: 'PLAYER',
        firstName: 'Ivan',
        lastName: 'Petrov',
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthUnauthenticated>().having(
          (s) => s.message,
          'message',
          'Registration submitted. Waiting for admin approval.',
        ),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      setUp: () {
        when(() => mockAuthService.register(
              login: any(named: 'login'),
              password: any(named: 'password'),
              role: any(named: 'role'),
              firstName: any(named: 'firstName'),
              lastName: any(named: 'lastName'),
              patronymicName: any(named: 'patronymicName'),
              birthDate: any(named: 'birthDate'),
              gender: any(named: 'gender'),
              country: any(named: 'country'),
              city: any(named: 'city'),
            )).thenThrow(Exception('Email taken'));
      },
      build: buildCubit,
      act: (cubit) => cubit.register(
        login: 'taken@test.com',
        password: 'secret',
        role: 'PLAYER',
        firstName: 'Ivan',
        lastName: 'Petrov',
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having((s) => s.message, 'message', 'Email taken'),
      ],
    );
  });

  group('logout', () {
    blocTest<AuthCubit, AuthState>(
      'emits AuthUnauthenticated on success',
      setUp: () {
        when(() => mockAuthService.logout()).thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (cubit) => cubit.logout(),
      expect: () => [isA<AuthUnauthenticated>()],
    );

    blocTest<AuthCubit, AuthState>(
      'emits AuthUnauthenticated even when service throws (finally block)',
      setUp: () {
        when(() => mockAuthService.logout()).thenThrow(Exception('Network'));
      },
      build: buildCubit,
      act: (cubit) => cubit.logout(),
      expect: () => [isA<AuthUnauthenticated>()],
    );
  });
}
