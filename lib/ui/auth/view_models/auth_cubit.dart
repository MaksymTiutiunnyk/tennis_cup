import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/utils/error_utils.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/core/utils/jwt_utils.dart';
import 'package:tennis_cup/data/auth/auth_token_store.dart';
import 'package:tennis_cup/data/models/user_role.dart';
import 'package:tennis_cup/data/services/rest/rest_auth_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final RestAuthService _authService;
  final AuthTokenStore _tokenStore;

  AuthCubit({
    required RestAuthService authService,
    required AuthTokenStore tokenStore,
  })  : _authService = authService,
        _tokenStore = tokenStore,
        super(AuthInitial());

  Future<void> checkAuthStatus() async {
    final token = await _tokenStore.getAccessToken();
    if (isClosed) return;
    if (token != null) {
      emit(AuthAuthenticated(
        userId: extractUserId(token),
        roles: extractRoles(token),
      ));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login({
    required String login,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      await _authService.login(login: login, password: password);
      final token = await _tokenStore.getAccessToken();
      if (isClosed) return;
      emit(AuthAuthenticated(
        userId: token != null ? extractUserId(token) : '',
        roles: token != null ? extractRoles(token) : [UserRole.player],
      ));
    } catch (e) {
      if (isClosed) return;
      emit(AuthError(_loginError(e)));
    }
  }

  String _loginError(Object e) {
    if (e is DioException && e.response?.statusCode == 401) {
      return S.current.errorInvalidCredentials;
    }
    return errorMessage(e);
  }

  Future<void> register({
    required String login,
    required String password,
    required String role,
    required String firstName,
    required String lastName,
    String? patronymicName,
    String? birthDate,
    String? gender,
    String? country,
    String? city,
  }) async {
    emit(AuthLoading());
    try {
      await _authService.register(
        login: login,
        password: password,
        role: role,
        firstName: firstName,
        lastName: lastName,
        patronymicName: patronymicName,
        birthDate: birthDate,
        gender: gender,
        country: country,
        city: city,
      );
      if (isClosed) return;
      emit(AuthUnauthenticated(message: S.current.registrationSubmitted));
    } catch (e) {
      if (isClosed) return;
      emit(AuthError(errorMessage(e)));
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (_) {}
    if (isClosed) return;
    emit(AuthUnauthenticated());
  }

}
