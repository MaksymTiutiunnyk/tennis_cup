import 'package:equatable/equatable.dart';

class News extends Equatable {
  final String title;
  final String text;
  final DateTime date;
  final bool isInteresting;
  final String imageUrl;

  const News({this.title = 'Attention!', required this.text, required this.date, required this.imageUrl})
      : isInteresting = title != 'Attention!';

  @override
  List<Object?> get props => [title, text, date, isInteresting, imageUrl];
}
