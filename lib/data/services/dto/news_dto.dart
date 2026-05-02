class NewsDto {
  final int id;
  final String title;
  final String body;
  final DateTime newsTimestamp;
  final String? imageUrl;
  final String importance;

  const NewsDto({
    required this.id,
    required this.title,
    required this.body,
    required this.newsTimestamp,
    required this.importance,
    this.imageUrl,
  });

  factory NewsDto.fromJson(Map<String, dynamic> json) => NewsDto(
        id: (json['id'] as num).toInt(),
        title: json['title'] as String,
        body: json['body'] as String,
        newsTimestamp: DateTime.parse(json['newsTimestamp'] as String),
        imageUrl: json['imageUrl'] as String?,
        importance: json['importance'] as String,
      );
}
