part of 'organizer_management_cubit.dart';

sealed class OrganizerManagementState {}

class OrgManagementIdle extends OrganizerManagementState {}

class OrgManagementLoading extends OrganizerManagementState {}

class OrgManagementSuccess extends OrganizerManagementState {
  final String message;
  OrgManagementSuccess(this.message);
}

class OrgManagementError extends OrganizerManagementState {
  final String message;
  OrgManagementError(this.message);
}
