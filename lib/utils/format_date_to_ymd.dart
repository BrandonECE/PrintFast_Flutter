/// Convierte un [DateTime] al formato "YYYY-MM-DD"
String formatDateToYMD(DateTime date) {
  final year = date.year.toString();
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return "$year-$month-$day";
}

