class News {
  final String title;
  final String text;
  final DateTime date;
  final bool isInteresting;
  final String imageUrl;

  News({this.title = 'Attention!', required this.text, required this.date, required this.imageUrl})
      : isInteresting = title != 'Attention!';
}
