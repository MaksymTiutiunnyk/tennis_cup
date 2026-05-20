class RatingRecordDto {
  final int id;
  final int userId;
  final String firstName;
  final String lastName;
  final String? date;
  final double ratingValue;
  final String? gender;
  final String? city;
  final String? country;
  final String? birthDate;
  final String? avatarUrl;

  const RatingRecordDto({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.ratingValue,
    this.date,
    this.gender,
    this.city,
    this.country,
    this.birthDate,
    this.avatarUrl,
  });

  factory RatingRecordDto.fromJson(Map<String, dynamic> json) =>
      RatingRecordDto(
        id: (json['id'] as num).toInt(),
        userId: (json['userId'] as num).toInt(),
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        date: json['date'] as String?,
        ratingValue: (json['ratingValue'] as num?)?.toDouble() ?? 0,
        gender: json['gender'] as String?,
        city: json['city'] as String?,
        country: json['country'] as String?,
        birthDate: json['birthDate'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
      );
}
