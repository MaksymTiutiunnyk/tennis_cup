import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/repositories/admin_repository.dart';
import 'package:tennis_cup/ui/user/organizer/view_models/user_creation_state.dart';

class UserCreationCubit extends Cubit<UserCreationState> {
  final AdminRepository _adminRepository;

  UserCreationCubit({required AdminRepository adminRepository})
      : _adminRepository = adminRepository,
        super(UserCreationIdle());

  void reset() => emit(UserCreationIdle());

  Future<void> createOrganizer({
    required String login,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    emit(UserCreationLoading());
    try {
      await _adminRepository.createOrganizer(
        login: login,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      emit(UserCreationSuccess('Organizer created successfully'));
    } catch (e) {
      emit(UserCreationError('Failed to create organizer'));
    }
  }

  Future<void> registerPlayer({
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
      await _adminRepository.registerUser(
        login: login,
        password: password,
        role: 'PLAYER',
        firstName: firstName,
        lastName: lastName,
        patronymicName: patronymicName,
        birthDate: birthDate,
        gender: gender,
        country: country,
        city: city,
      );
      emit(UserCreationSuccess('Player registered. Account pending approval.'));
    } catch (e) {
      emit(UserCreationError('Failed to register player'));
    }
  }

  Future<void> registerReferee({
    required String login,
    required String password,
    required String firstName,
    required String lastName,
    String? patronymicName,
    String? birthDate,
    String? gender,
  }) async {
    emit(UserCreationLoading());
    try {
      await _adminRepository.registerUser(
        login: login,
        password: password,
        role: 'REFEREE',
        firstName: firstName,
        lastName: lastName,
        patronymicName: patronymicName,
        birthDate: birthDate,
        gender: gender,
      );
      emit(UserCreationSuccess('Referee registered. Account pending approval.'));
    } catch (e) {
      emit(UserCreationError('Failed to register referee'));
    }
  }
}
