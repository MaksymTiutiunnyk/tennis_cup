import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/user_creation_cubit.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/user_creation_state.dart';

import '../../../helpers/mocks.dart';

void main() {
  setUpAll(registerFallbackValues);

  late MockAdminRepository mockRepo;

  setUp(() {
    mockRepo = MockAdminRepository();
  });

  UserCreationCubit buildCubit() =>
      UserCreationCubit(adminRepository: mockRepo);

  group('initial state', () {
    test('is UserCreationIdle', () {
      expect(buildCubit().state, isA<UserCreationIdle>());
    });
  });

  group('createUser', () {
    void stubSuccess() {
      when(() => mockRepo.createUser(
            role: any(named: 'role'),
            login: any(named: 'login'),
            password: any(named: 'password'),
            firstName: any(named: 'firstName'),
            lastName: any(named: 'lastName'),
            patronymicName: any(named: 'patronymicName'),
            birthDate: any(named: 'birthDate'),
            gender: any(named: 'gender'),
            country: any(named: 'country'),
            city: any(named: 'city'),
          )).thenAnswer((_) async {});
    }

    blocTest<UserCreationCubit, UserCreationState>(
      'PLAYER role → [UserCreationLoading, UserCreationSuccess("Player created successfully")]',
      setUp: stubSuccess,
      build: buildCubit,
      act: (cubit) => cubit.createUser(
        role: 'PLAYER',
        login: 'u',
        password: 'p',
        firstName: 'F',
        lastName: 'L',
      ),
      expect: () => [
        isA<UserCreationLoading>(),
        isA<UserCreationSuccess>()
            .having((s) => s.message, 'message', 'Player created successfully.'),
      ],
    );

    blocTest<UserCreationCubit, UserCreationState>(
      'REFEREE role → message "Referee created successfully"',
      setUp: stubSuccess,
      build: buildCubit,
      act: (cubit) => cubit.createUser(
        role: 'REFEREE',
        login: 'u',
        password: 'p',
        firstName: 'F',
        lastName: 'L',
      ),
      expect: () => [
        isA<UserCreationLoading>(),
        isA<UserCreationSuccess>().having(
          (s) => s.message,
          'message',
          'Referee created successfully.',
        ),
      ],
    );

    blocTest<UserCreationCubit, UserCreationState>(
      'ORGANIZER role → message "Organizer created successfully"',
      setUp: stubSuccess,
      build: buildCubit,
      act: (cubit) => cubit.createUser(
        role: 'ORGANIZER',
        login: 'u',
        password: 'p',
        firstName: 'F',
        lastName: 'L',
      ),
      expect: () => [
        isA<UserCreationLoading>(),
        isA<UserCreationSuccess>().having(
          (s) => s.message,
          'message',
          'Organizer created successfully.',
        ),
      ],
    );

    blocTest<UserCreationCubit, UserCreationState>(
      'ADMIN role → message "Admin created successfully"',
      setUp: stubSuccess,
      build: buildCubit,
      act: (cubit) => cubit.createUser(
        role: 'ADMIN',
        login: 'u',
        password: 'p',
        firstName: 'F',
        lastName: 'L',
      ),
      expect: () => [
        isA<UserCreationLoading>(),
        isA<UserCreationSuccess>().having(
          (s) => s.message,
          'message',
          'Admin created successfully.',
        ),
      ],
    );

    blocTest<UserCreationCubit, UserCreationState>(
      'failure → [UserCreationLoading, UserCreationError("Failed to create user")]',
      setUp: () {
        when(() => mockRepo.createUser(
              role: any(named: 'role'),
              login: any(named: 'login'),
              password: any(named: 'password'),
              firstName: any(named: 'firstName'),
              lastName: any(named: 'lastName'),
              patronymicName: any(named: 'patronymicName'),
              birthDate: any(named: 'birthDate'),
              gender: any(named: 'gender'),
              country: any(named: 'country'),
              city: any(named: 'city'),
            )).thenThrow(Exception('network error'));
      },
      build: buildCubit,
      act: (cubit) => cubit.createUser(
        role: 'PLAYER',
        login: 'u',
        password: 'p',
        firstName: 'F',
        lastName: 'L',
      ),
      expect: () => [
        isA<UserCreationLoading>(),
        isA<UserCreationError>()
            .having((s) => s.message, 'message', 'network error'),
      ],
    );
  });
}
