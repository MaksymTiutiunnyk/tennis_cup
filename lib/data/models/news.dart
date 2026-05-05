import 'package:equatable/equatable.dart';

class News extends Equatable {
  final int id;
  final String title;
  final String text;
  final DateTime date;
  final bool isInteresting;
  final String imageUrl;

  const News({
    required this.id,
    required this.title,
    required this.text,
    required this.date,
    required this.isInteresting,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [id, title, text, date, isInteresting, imageUrl];
}
