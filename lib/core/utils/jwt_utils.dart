import 'dart:convert';

import 'package:tennis_cup/data/models/user_role.dart';

Map<String, dynamic> _decodeJwtPayload(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return {};
    final payload = base64Url.normalize(parts[1]);
    final decoded = utf8.decode(base64Url.decode(payload));
    return jsonDecode(decoded) as Map<String, dynamic>;
  } catch (_) {
    return {};
  }
}

String extractUserId(String token) {
  final payload = _decodeJwtPayload(token);
  return payload['sub']?.toString() ?? '';
}

List<UserRole> extractRoles(String token) {
  final payload = _decodeJwtPayload(token);
  final raw = payload['roles'];
  if (raw is! List) return [UserRole.player];
  final roles = raw
      .map((e) => userRoleFromString(e.toString()))
      .whereType<UserRole>()
      .toList();
  return roles.isEmpty ? [UserRole.player] : roles;
}
