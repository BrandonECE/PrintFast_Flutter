  import 'dart:ui';

Color mixColors(Color foreground, Color background, double opacity) {
  return Color.fromARGB(
    255,
    ((1 - opacity) * background.red + opacity * foreground.red).toInt(),
    ((1 - opacity) * background.green + opacity * foreground.green).toInt(),
    ((1 - opacity) * background.blue + opacity * foreground.blue).toInt(),
  );
}
