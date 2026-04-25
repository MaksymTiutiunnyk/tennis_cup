class PageRequest {
  final int page;
  final int size;

  const PageRequest({required this.page, required this.size});

  PageRequest get next => PageRequest(page: page + 1, size: size);
}
