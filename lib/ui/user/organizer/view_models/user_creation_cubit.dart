import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/core/utils/error_utils.dart';
import 'package:tennis_cup/data/repositories/admin_repository.dart';
import 'package:tennis_cup/generated/l10n.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/user_creation_state.dart';

class UserCreationCubit extends Cubit<UserCreationState> {
  final AdminRepository _adminRepository;

  UserCreationCubit({required AdminRepository adminRepository})
      : _adminRepository = adminRepository,
        super(UserCreationIdle());

  Future<void> createUser({
    required String role,
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
    emit(UserCreationLoading());
    try {
      await _adminRepository.createUser(
        role: role,
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
      if (isClosed) return;
      emit(UserCreationSuccess(
          S.current.userCreatedSuccessfully(_localizedRole(role))));
    } catch (e) {
      if (isClosed) return;
      emit(UserCreationError(errorMessage(e)));
    }
  }

  String _localizedRole(String role) => switch (role.toUpperCase()) {
        'PLAYER' => S.current.rolePlayer,
        'REFEREE' => S.current.roleReferee,
        'ORGANIZER' => S.current.roleOrganizer,
        'ADMIN' => S.current.roleAdmin,
        _ => role[0] + role.substring(1).toLowerCase(),
      };
}
