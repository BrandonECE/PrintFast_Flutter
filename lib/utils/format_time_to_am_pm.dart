/// Convierte un [DateTime] a formato de hora "hh:mm AM/PM"
String formatTimeToAmPm(DateTime date) {
  int hour = date.hour;
  final minute = date.minute.toString().padLeft(2, '0');
  final suffix = hour >= 12 ? 'PM' : 'AM';

  hour = hour % 12;
  if (hour == 0) hour = 12;

  return "$hour:$minute $suffix";
}