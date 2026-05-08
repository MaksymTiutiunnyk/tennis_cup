import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/models/pending_user.dart';
import 'package:tennis_cup/data/models/user_role.dart';
import 'package:tennis_cup/data/models/user_search_result.dart';
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
  }) =>
      _service.createUser(CreateUserRequestDto(
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
      ));

  Future<void> deleteOrganizer(int organizerId) =>
      _service.deleteOrganizer(organizerId);


  Future<List<UserSearchResult>> searchReferees(String query) async {
    final dtos = await _service.searchUsers(query: query, roles: ['REFEREE']);
    return dtos.map(_toUserSearchResult).toList();
  }

  Future<List<UserSearchResult>> searchAllUsers(String query) async {
    final dtos = await _service.searchUsers(query: query);
    return dtos.map(_toUserSearchResult).toList();
  }

  static UserSearchResult _toUserSearchResult(UserSearchDto d) {
    final roles = d.roles
        .map(userRoleFromString)
        .whereType<UserRole>()
        .toList();
    return UserSearchResult(
      userId: d.userId,
      firstName: d.firstName,
      lastName: d.lastName,
      roles: roles,
      avatarUrl: d.avatarUrl,
    );
  }

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
