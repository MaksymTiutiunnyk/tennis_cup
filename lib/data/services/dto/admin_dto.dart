class UserSearchDto {
  final int userId;
  final String firstName;
  final String lastName;
  final List<String> roles;

  const UserSearchDto({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.roles,
  });

  factory UserSearchDto.fromJson(Map<String, dynamic> json) => UserSearchDto(
        userId: (json['userId'] as num).toInt(),
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        roles: (json['roles'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
}

class PendingUserDto {
  final int id;
  final String login;
  final String status;
  final List<String> roles;
  final String createdAt;

  const PendingUserDto({
    required this.id,
    required this.login,
    required this.status,
    required this.roles,
    required this.createdAt,
  });

  factory PendingUserDto.fromJson(Map<String, dynamic> json) => PendingUserDto(
        id: (json['id'] as num).toInt(),
        login: json['login'] as String? ?? '',
        status: json['status'] as String? ?? '',
        roles: (json['roles'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        createdAt: json['createdAt'] as String? ?? '',
      );
}

class CreateOrganizerRequestDto {
  final String login;
  final String password;
  final String firstName;
  final String lastName;

  const CreateOrganizerRequestDto({
    required this.login,
    required this.password,
    required this.firstName,
    required this.lastName,
  });

  Map<String, dynamic> toJson() => {
        'login': login,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      };
}
