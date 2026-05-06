import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/services/dto/admin_dto.dart';

abstract interface class IAdminService {
  Future<PageResult<PendingUserDto>> fetchPendingUsers(PageRequest page);
  Future<void> approveUser(int userId);
  Future<void> rejectUser(int userId, {String? reason});
  Future<void> createOrganizer(CreateOrganizerRequestDto dto);
  Future<void> deleteOrganizer(int organizerId);
  Future<List<UserSearchDto>> searchUsers({
    required String query,
    List<String>? roles,
  });
  Future<void> registerUser(RegisterUserRequestDto dto);
}
