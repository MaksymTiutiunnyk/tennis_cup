class UserBriefDto {
  final int id;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final String? gender;
  final String? city;
  final String? country;
  final String? birthDate;

  const UserBriefDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.gender,
    this.city,
    this.country,
    this.birthDate,
  });

  factory UserBriefDto.fromJson(Map<String, dynamic> json) => UserBriefDto(
        id: (json['id'] as num).toInt(),
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String?,
        gender: json['gender'] as String?,
        city: json['city'] as String?,
        country: json['country'] as String?,
        birthDate: json['birthDate'] as String?,
      );
}
