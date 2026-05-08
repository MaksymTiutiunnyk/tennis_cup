import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tennis_cup/data/repositories/admin_repository.dart';

part 'organizer_management_state.dart';

class OrganizerManagementCubit extends Cubit<OrganizerManagementState> {
  final AdminRepository _repository;

  OrganizerManagementCubit({required AdminRepository repository})
      : _repository = repository,
        super(OrgManagementIdle());

  void reset() => emit(OrgManagementIdle());

  Future<void> createOrganizer({
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
    emit(OrgManagementLoading());
    try {
      await _repository.createUser(
        role: 'ORGANIZER',
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
      emit(OrgManagementSuccess('Organizer created successfully'));
    } catch (e) {
      emit(OrgManagementError(_message(e)));
    }
  }

  Future<void> deleteOrganizer(int organizerId) async {
    emit(OrgManagementLoading());
    try {
      await _repository.deleteOrganizer(organizerId);
      emit(OrgManagementSuccess('Organizer deleted'));
    } catch (e) {
      emit(OrgManagementError(_message(e)));
    }
  }

  static String _message(Object e) =>
      e is Exception ? e.toString().replaceFirst('Exception: ', '') : '$e';
}
