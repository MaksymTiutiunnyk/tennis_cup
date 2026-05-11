import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/repositories/admin_repository.dart';
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
      final roleName = role[0] + role.substring(1).toLowerCase();
      emit(UserCreationSuccess('$roleName created successfully'));
    } catch (e) {
      emit(UserCreationError('Failed to create user'));
    }
  }
}
