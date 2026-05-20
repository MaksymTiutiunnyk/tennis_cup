class PlayerSearchResultDto {
  final int userId;
  final String firstName;
  final String lastName;
  final List<String> roles;
  final String? city;
  final String? country;
  final String? avatarUrl;

  const PlayerSearchResultDto({
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.roles = const [],
    this.city,
    this.country,
    this.avatarUrl,
  });

  factory PlayerSearchResultDto.fromJson(Map<String, dynamic> json) =>
      PlayerSearchResultDto(
        userId: (json['userId'] as num).toInt(),
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        roles: (json['roles'] as List<dynamic>? ?? const [])
            .map((e) => e as String)
            .toList(),
        city: json['city'] as String?,
        country: json['country'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
      );
}
