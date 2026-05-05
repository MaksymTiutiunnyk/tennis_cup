import 'package:equatable/equatable.dart';

class PageResult<T> extends Equatable {
  final List<T> items;
  final bool hasMore;

  const PageResult({required this.items, required this.hasMore});

  @override
  List<Object?> get props => [items, hasMore];
}
