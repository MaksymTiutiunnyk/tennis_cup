class ArenaDto {
  final int id;
  final String name;
  final String color;
  final String? city;

  const ArenaDto({
    required this.id,
    required this.name,
    required this.color,
    this.city,
  });

  factory ArenaDto.fromJson(Map<String, dynamic> json) => ArenaDto(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String? ?? '',
        color: json['color'] as String? ?? '',
        city: json['city'] as String?,
      );
}
