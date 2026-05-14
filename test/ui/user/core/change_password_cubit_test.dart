import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tennis_cup/ui/user/core/view_models/change_password_cubit.dart';

import '../../../helpers/mocks.dart';

void main() {
  setUpAll(registerFallbackValues);

  late MockRestAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockRestAuthService();
  });

  ChangePasswordCubit buildCubit() =>
      ChangePasswordCubit(authService: mockAuthService);

  test('initial state is ChangePasswordInitial', () {
    expect(buildCubit().state, isA<ChangePasswordInitial>());
  });

  group('submit', () {
    blocTest<ChangePasswordCubit, ChangePasswordState>(
      'success emits [ChangePasswordSubmitting, ChangePasswordSuccess]',
      setUp: () {
        when(() => mockAuthService.changePassword(
              currentPassword: any(named: 'currentPassword'),
              newPassword: any(named: 'newPassword'),
            )).thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (cubit) => cubit.submit(
        currentPassword: 'oldPass',
        newPassword: 'newPass',
      ),
      expect: () => [
        isA<ChangePasswordSubmitting>(),
        isA<ChangePasswordSuccess>(),
      ],
    );

    blocTest<ChangePasswordCubit, ChangePasswordState>(
      'DioException status 400 emits [ChangePasswordSubmitting, ChangePasswordFailure] '
      'with incorrect-password message',
      setUp: () {
        when(() => mockAuthService.changePassword(
              currentPassword: any(named: 'currentPassword'),
              newPassword: any(named: 'newPassword'),
            )).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            data: <String, dynamic>{},
            statusCode: 400,
            requestOptions: RequestOptions(path: ''),
          ),
          type: DioExceptionType.badResponse,
        ));
      },
      build: buildCubit,
      act: (cubit) =>
          cubit.submit(currentPassword: 'wrong', newPassword: 'new'),
      expect: () => [
        isA<ChangePasswordSubmitting>(),
        isA<ChangePasswordFailure>().having(
          (s) => s.message,
          'message',
          'Current password is incorrect or new password is invalid.',
        ),
      ],
    );

    blocTest<ChangePasswordCubit, ChangePasswordState>(
      'DioException status 401 emits failure with 401 message',
      setUp: () {
        when(() => mockAuthService.changePassword(
              currentPassword: any(named: 'currentPassword'),
              newPassword: any(named: 'newPassword'),
            )).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            data: <String, dynamic>{},
            statusCode: 401,
            requestOptions: RequestOptions(path: ''),
          ),
          type: DioExceptionType.badResponse,
        ));
      },
      build: buildCubit,
      act: (cubit) =>
          cubit.submit(currentPassword: 'wrong', newPassword: 'new'),
      expect: () => [
        isA<ChangePasswordSubmitting>(),
        isA<ChangePasswordFailure>().having(
          (s) => s.message,
          'message',
          'Current password is incorrect.',
        ),
      ],
    );

    blocTest<ChangePasswordCubit, ChangePasswordState>(
      "DioException with data['error'] emits failure with that custom message",
      setUp: () {
        when(() => mockAuthService.changePassword(
              currentPassword: any(named: 'currentPassword'),
              newPassword: any(named: 'newPassword'),
            )).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            data: <String, dynamic>{'error': 'Custom error'},
            statusCode: 400,
            requestOptions: RequestOptions(path: ''),
          ),
          type: DioExceptionType.badResponse,
        ));
      },
      build: buildCubit,
      act: (cubit) =>
          cubit.submit(currentPassword: 'wrong', newPassword: 'new'),
      expect: () => [
        isA<ChangePasswordSubmitting>(),
        isA<ChangePasswordFailure>().having(
          (s) => s.message,
          'message',
          'Custom error',
        ),
      ],
    );

    blocTest<ChangePasswordCubit, ChangePasswordState>(
      'non-Dio exception emits failure with generic message',
      setUp: () {
        when(() => mockAuthService.changePassword(
              currentPassword: any(named: 'currentPassword'),
              newPassword: any(named: 'newPassword'),
            )).thenThrow(Exception('Network'));
      },
      build: buildCubit,
      act: (cubit) =>
          cubit.submit(currentPassword: 'old', newPassword: 'new'),
      expect: () => [
        isA<ChangePasswordSubmitting>(),
        isA<ChangePasswordFailure>().having(
          (s) => s.message,
          'message',
          'Something went wrong. Please try again.',
        ),
      ],
    );
  });
}
