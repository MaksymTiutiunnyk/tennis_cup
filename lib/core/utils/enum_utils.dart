T enumFromString<T extends Enum>(List<T> values, String? s, T fallback) {
  if (s == null) return fallback;
  final normalized = s.replaceAll('_', '').toLowerCase();
  return values.firstWhere(
    (e) => e.name.toLowerCase() == normalized,
    orElse: () => fallback,
  );
}

T? enumFromStringOrNull<T extends Enum>(List<T> values, String? s) {
  if (s == null) return null;
  final normalized = s.replaceAll('_', '').toLowerCase();
  return values.where((e) => e.name.toLowerCase() == normalized).firstOrNull;
}
