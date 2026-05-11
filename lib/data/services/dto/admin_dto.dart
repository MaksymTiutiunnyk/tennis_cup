class UserProfileDto {
  final int userId;
  final String firstName;
  final String lastName;
  final String? patronymicName;
  final List<String> roles;
  final String? birthDate;
  final String? country;
  final String? city;
  final String? gender;
  final String? avatarUrl;

  const UserProfileDto({
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.patronymicName,
    required this.roles,
    this.birthDate,
    this.country,
    this.city,
    this.gender,
    this.avatarUrl,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) => UserProfileDto(
        userId: (json['id'] as num).toInt(),
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        patronymicName: json['patronymicName'] as String?,
        roles: (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        birthDate: json['birthDate'] as String?,
        country: json['country'] as String?,
        city: json['city'] as String?,
        gender: json['gender'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
      );
}

class UserSearchDto {
  final int userId;
  final String firstName;
  final String lastName;
  final List<String> roles;
  final String? avatarUrl;

  const UserSearchDto({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.roles,
    this.avatarUrl,
  });

  factory UserSearchDto.fromJson(Map<String, dynamic> json) => UserSearchDto(
        userId: (json['userId'] as num).toInt(),
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        roles: (json['roles'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        avatarUrl: json['avatarUrl'] as String?,
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

class CreateUserRequestDto {
  final String login;
  final String password;
  final String role;
  final String firstName;
  final String lastName;
  final String? patronymicName;
  final String? birthDate;
  final String? gender;
  final String? country;
  final String? city;

  const CreateUserRequestDto({
    required this.login,
    required this.password,
    required this.role,
    required this.firstName,
    required this.lastName,
    this.patronymicName,
    this.birthDate,
    this.gender,
    this.country,
    this.city,
  });

  Map<String, dynamic> toJson() => {
        'login': login,
        'password': password,
        'role': role,
        'firstName': firstName,
        'lastName': lastName,
        if (patronymicName != null) 'patronymicName': patronymicName,
        if (birthDate != null) 'birthDate': birthDate,
        if (gender != null) 'gender': gender,
        if (country != null) 'country': country,
        if (city != null) 'city': city,
      };
}
