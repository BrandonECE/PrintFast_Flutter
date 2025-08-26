String firstName(String fullName) {
  final s = fullName.trim();
  if (s.isEmpty) return '';

  // split usando regex para ignorar múltiples espacios, tabs, newlines...
  final parts = s.split(RegExp(r'\s+'));
  return parts.first;
}