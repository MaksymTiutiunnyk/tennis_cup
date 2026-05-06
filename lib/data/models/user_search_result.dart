class UserSearchResult {
  final int userId;
  final String firstName;
  final String lastName;

  const UserSearchResult({
    required this.userId,
    required this.firstName,
    required this.lastName,
  });

  String get fullName => '$firstName $lastName';
}
