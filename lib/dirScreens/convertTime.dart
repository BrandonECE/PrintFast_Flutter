class ConvertTime {
  ConvertTime();

  String getFecha() {
    final fecha =
        "${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}";
    return fecha;
  }

  String getHora() {
    String hora = "";
    if (DateTime.now().hour >= 12 && DateTime.now().hour != 0) {

      if (DateTime.now().hour > 12)
        // ignore: curly_braces_in_flow_control_structures
        hora = "${DateTime.now().hour - 12}:${DateTime.now().minute} PM";
      else
        // ignore: curly_braces_in_flow_control_structures
        hora = "${DateTime.now().hour}:${DateTime.now().minute} PM";
    } else {

      if(DateTime.now().hour == 0) hora = "12:${DateTime.now().minute} AM";
      else hora = "${DateTime.now().hour}:${DateTime.now().minute} AM";

    }

    return hora;
  }
}
