import 'package:dio/dio.dart';
import 'package:tennis_cup/core/pagination/page_request.dart';
import 'package:tennis_cup/core/pagination/page_result.dart';
import 'package:tennis_cup/data/services/abstract/i_admin_service.dart';
import 'package:tennis_cup/data/services/dto/admin_dto.dart';

class RestAdminService implements IAdminService {
  final Dio _dio;

  const RestAdminService(this._dio);

  @override
  Future<PageResult<PendingUserDto>> fetchPendingUsers(PageRequest page) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/admin/users/pending',
      queryParameters: {'page': page.page, 'size': page.size},
    );
    final data = response.data!;
    final content = (data['content'] as List<dynamic>)
        .map((e) => PendingUserDto.fromJson(e as Map<String, dynamic>))
        .toList();
    final totalPages = (data['totalPages'] as num?)?.toInt() ?? 1;
    return PageResult(
      items: content,
      hasMore: page.page + 1 < totalPages,
    );
  }

  @override
  Future<void> approveUser(int userId) async {
    await _dio.post<void>('/api/v1/admin/users/$userId/approve');
  }

  @override
  Future<void> rejectUser(int userId, {String? reason}) async {
    await _dio.post<void>(
      '/api/v1/admin/users/$userId/reject',
      data: reason != null ? {'reason': reason} : <String, dynamic>{},
    );
  }

  @override
  Future<void> createOrganizer(CreateOrganizerRequestDto dto) async {
    await _dio.post<void>(
      '/api/v1/admin/users',
      data: dto.toJson(),
    );
  }

  @override
  Future<void> deleteOrganizer(int organizerId) async {
    await _dio.delete<void>('/api/v1/admin/organizers/$organizerId');
  }

  @override
  Future<List<UserSearchDto>> searchUsers({
    required String query,
    List<String>? roles,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/users/search',
      queryParameters: {
        'query': query,
        'size': 20,
        if (roles != null && roles.isNotEmpty) 'roles': roles,
      },
    );
    final content = (response.data!['content'] as List<dynamic>);
    return content
        .map((e) => UserSearchDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> registerUser(RegisterUserRequestDto dto) async {
    await _dio.post<void>('/api/v1/auth/register', data: dto.toJson());
  }
}
