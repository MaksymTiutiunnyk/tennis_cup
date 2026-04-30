import 'package:equatable/equatable.dart';

class PageRequest extends Equatable {
  final int page;
  final int size;

  const PageRequest({required this.page, required this.size});

  PageRequest get next => PageRequest(page: page + 1, size: size);

  @override
  List<Object?> get props => [page, size];
}
