/// Convierte un [DateTime] a formato de hora "hh:mm AM/PM"
String formatTimeToAmPm(
  DateTime date, {
  bool uppercaseSuffix = true,
  bool spaceBetween = true,
}) {
  int hour = date.hour;
  final minute = date.minute.toString().padLeft(2, '0');
  final am = uppercaseSuffix ? "AM" : "am";
  final pm = uppercaseSuffix ? "PM" : "pm";
  final suffix = hour >= 12 ? am : pm;

  hour = hour % 12;
  if (hour == 0) hour = 12;

  final space = spaceBetween ? " " : "";

  return "$hour:$minute$space$suffix";
}
