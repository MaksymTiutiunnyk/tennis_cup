import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/models/pending_user.dart';
import 'package:tennis_cup/data/models/user_role.dart';
import 'package:tennis_cup/data/services/abstract/i_admin_service.dart';
import 'package:tennis_cup/data/services/dto/admin_dto.dart';

class AdminRepository {
  final IAdminService _service;

  const AdminRepository(this._service);

  Future<PageResult<PendingUser>> fetchPendingUsers(PageRequest page) async {
    final result = await _service.fetchPendingUsers(page);
    return PageResult(
      items: result.items.map(_toPendingUser).toList(),
      hasMore: result.hasMore,
    );
  }

  Future<void> approveUser(int userId) => _service.approveUser(userId);

  Future<void> rejectUser(int userId, {String? reason}) =>
      _service.rejectUser(userId, reason: reason);

  Future<void> createOrganizer({
    required String login,
    required String password,
    required String firstName,
    required String lastName,
  }) =>
      _service.createOrganizer(CreateOrganizerRequestDto(
        login: login,
        password: password,
        firstName: firstName,
        lastName: lastName,
      ));

  Future<void> deleteOrganizer(int organizerId) =>
      _service.deleteOrganizer(organizerId);

  static PendingUser _toPendingUser(PendingUserDto dto) {
    final roles = dto.roles
        .map(userRoleFromString)
        .whereType<UserRole>()
        .toList();
    return PendingUser(
      id: dto.id,
      login: dto.login,
      roles: roles,
      createdAt: DateTime.tryParse(dto.createdAt) ?? DateTime(0),
    );
  }
}
