class ConvertTime {
  ConvertTime();

  String getFecha() {
    final fecha =
        "${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}";
    return fecha;
  }

  String getHora() {
    String hora = "";
    String minutos = DateTime.now().minute.toString();
    int minutoInt = DateTime.now().minute;
    if(minutoInt < 10){
      minutos = "0${DateTime.now().minute.toString()}";
    }
    if (DateTime.now().hour >= 12 && DateTime.now().hour != 0) {
      if (DateTime.now().hour > 12)
        // ignore: curly_braces_in_flow_control_structures
        hora = "${DateTime.now().hour - 12}:${minutos} PM";
      else
        // ignore: curly_braces_in_flow_control_structures
        hora = "${DateTime.now().hour}:${minutos} PM";
    } else {
      if (DateTime.now().hour == 0)
        hora = "12:${minutos} AM";
      else
        hora = "${DateTime.now().hour}:${minutos} AM";
    }

    return hora;
  }
}
