import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/features/auth/data/rest_auth_service.dart';

part 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final RestAuthService _authService;

  ChangePasswordCubit({required RestAuthService authService})
      : _authService = authService,
        super(ChangePasswordInitial());

  Future<void> submit({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(ChangePasswordSubmitting());
    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      emit(ChangePasswordSuccess());
    } on DioException catch (e) {
      emit(ChangePasswordFailure(_messageFromDio(e)));
    } catch (_) {
      emit(ChangePasswordFailure('Something went wrong. Please try again.'));
    }
  }

  String _messageFromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['error'] is String) return data['error'] as String;
    return switch (e.response?.statusCode) {
      400 => 'Current password is incorrect or new password is invalid.',
      401 => 'Current password is incorrect.',
      404 => 'User not found.',
      _ => 'Failed to change password.',
    };
  }
}
