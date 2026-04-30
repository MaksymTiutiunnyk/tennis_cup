import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/auth/auth_token_store.dart';
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
    if (token != null) {
      emit(AuthAuthenticated(''));
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
      emit(AuthAuthenticated(''));
    } catch (e) {
      emit(AuthError(_parseError(e)));
    }
  }

  Future<void> register({
    required String login,
    required String password,
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
        firstName: firstName,
        lastName: lastName,
        patronymicName: patronymicName,
        birthDate: birthDate,
        gender: gender,
        country: country,
        city: city,
      );
      emit(AuthUnauthenticated(
        message: 'Registration submitted. Waiting for admin approval.',
      ));
    } catch (e) {
      emit(AuthError(_parseError(e)));
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (_) {
    } finally {
      emit(AuthUnauthenticated());
    }
  }

  String _parseError(Object e) {
    if (e is Exception) return e.toString().replaceFirst('Exception: ', '');
    return 'An error occurred';
  }
}
