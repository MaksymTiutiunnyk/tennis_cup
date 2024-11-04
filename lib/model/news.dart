class News {
  final String title;
  final String text;
  final DateTime date;
  final bool isInteresting;

  News({this.title = 'Attention!', required this.text, required this.date})
      : isInteresting = title != 'Attention!';
}
