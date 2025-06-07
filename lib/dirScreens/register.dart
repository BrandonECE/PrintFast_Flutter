// ignore_for_file: prefer_is_empty

// ignore: unused_import
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:print_fast/firestore_service.dart';
import 'package:restart_app/restart_app.dart';

// ignore: must_be_immutable
class myRegister extends StatefulWidget {
  myRegister({super.key, required this.chIndexLogin});
  VoidCallback chIndexLogin;
  @override
  State<myRegister> createState() => _myRegisterState();
}

class _myRegisterState extends State<myRegister> {
  TextEditingController controllerMatriculaRegister = TextEditingController();
  TextEditingController controllerEmailRegister = TextEditingController();
  TextEditingController controllerPhoneRegister = TextEditingController();
  TextEditingController controllerNameRegister = TextEditingController();
  TextEditingController controllerPasswordRegisterFirst =
      TextEditingController();
  TextEditingController controllerPasswordRegisterSecond =
      TextEditingController();
  bool _obscureTextfirst = true;
  bool _obscureTextSecond = true;
  int _indexButtonsLogin = 0;
  int _indexAvertUserRegister = 0;
  int _indexadvertErrorPasword = 0;
  int _indexinfoToLoad = 0;

  @override
  Widget build(BuildContext context) {
    void userRegisterReadySistem() async {
      _indexinfoToLoad = 1;
      setState(() {});
      await Future.delayed(const Duration(seconds: 2), () {
        _indexinfoToLoad = 0;
        _indexAvertUserRegister = 1;
        controllerMatriculaRegister.text = "";
        if (controllerPasswordRegisterFirst.text !=
            controllerPasswordRegisterSecond.text) {
          _indexadvertErrorPasword = 1;
        }
        setState(() {
          Future.delayed(const Duration(seconds: 5), () {
            _indexAvertUserRegister = 0;
            _indexadvertErrorPasword = 0;
            setState(() {});
          });
        });
      });
    }

    void userRegisterSuccessful() async {
      _indexinfoToLoad = 1;
      setState(() {});
      await Future.delayed(const Duration(seconds: 3), () async {
        _indexinfoToLoad = 2;
        setState(() {});
        await Future.delayed(const Duration(milliseconds: 1500), () {
          _indexinfoToLoad = 0;
          Restart.restartApp();
          // widget.chIndexLogin.call();
        });
      });
    }

    void errorPasword() async {
      _indexinfoToLoad = 1;
      setState(() {});
      await Future.delayed(const Duration(seconds: 2), () {
        _indexadvertErrorPasword = 1;
        _indexinfoToLoad = 0;
        setState(() {
          Future.delayed(const Duration(seconds: 5), () {
            _indexadvertErrorPasword = 0;
            setState(() {});
          });
        });
      });
    }

    double sizespaceadvertence = 40;
    if (_indexAvertUserRegister == 1 || _indexadvertErrorPasword == 1) {
      sizespaceadvertence = 20;
    }

    if (controllerMatriculaRegister.text.length > 0 &&
        controllerEmailRegister.text.length > 0 &&
        controllerPhoneRegister.text.length > 0 &&
        controllerNameRegister.text.length > 0 &&
        controllerPasswordRegisterFirst.text.length > 0 &&
        controllerPasswordRegisterSecond.text.length > 0) {
      _indexButtonsLogin = 1;
    } else {
      _indexButtonsLogin = 0;
    }

    List<Widget> buttons = [
      Container(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              elevation: 0,
              fixedSize: Size(MediaQuery.of(context).size.width * 0.8, 60),
              backgroundColor: Colors.white60,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0))),
          onPressed: () {},
          child: Text(
            "Registrarse",
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
        ),
      ),
      Container(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              elevation: 0,
              fixedSize: Size(MediaQuery.of(context).size.width * 0.8, 60),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0))),
          onPressed: () async {
            try {
              // ignore: unused_local_variable
              Map user;
              user = await getDBUser(controllerMatriculaRegister.text);
              userRegisterReadySistem();
            } catch (e) {
              if (controllerPasswordRegisterFirst.text ==
                  controllerPasswordRegisterSecond.text) {
                await registeDBUser(
                    controllerNameRegister.text,
                    controllerMatriculaRegister.text,
                    controllerEmailRegister.text,
                    controllerPhoneRegister.text,
                    controllerPasswordRegisterFirst.text);
                userRegisterSuccessful();
              } else {
                errorPasword();
              }
            }
          },
          child: Text(
            "Registrarse",
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
        ),
      ),
    ];
    List<Widget> advertUserRegister = [
      const SizedBox(
        height: 0,
      ),
      Container(
        child: Container(
          // color: Colors.amber,
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width * 0.8,
          // margin: const EdgeInsets.only(bottom: 20, top: 20),
          child: const Text(
            "ERROR: Este usuario ya esta registrado.",
            style: TextStyle(
                decoration: TextDecoration.underline,
                decorationThickness: 2,
                decorationStyle: TextDecorationStyle
                    .solid, // Puedes usar 'dotted', 'dashed', etc.
                decorationColor: Colors.white, //
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      )
    ];
    List<Widget> advertErrorPasword = [
      const SizedBox(
        height: 0,
      ),
      Container(
        child: Container(
          // color: Colors.amber,
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width * 0.8,
          // margin: const EdgeInsets.only(bottom: 20, top: 20),
          child: const Text(
            "ERROR: Las contraseñas no coinciden.",
            style: TextStyle(
                decoration: TextDecoration.underline,
                decorationThickness: 2,
                decorationStyle: TextDecorationStyle
                    .solid, // Puedes usar 'dotted', 'dashed', etc.
                decorationColor: Colors.white, //
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      )
    ];
    List<Widget> infoToLoad = [
      Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border:
                  Border.all(color: Colors.white, width: 2), // Define el borde

              color: Colors.white, // Color de fondo
              borderRadius:
                  BorderRadius.circular(5.0), // Bordes redondeados (opcional)
            ),
            width: MediaQuery.of(context).size.width * 0.8,
            child: TextFormField(
              controller: controllerNameRegister,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
              keyboardType: TextInputType.text,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                hintText: 'Nombre y Apellido',

                hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold),
                border: InputBorder.none, // Elimina la línea inferior
                contentPadding:
                    const EdgeInsets.all(15.0), // Ajusta el espacio interior
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            decoration: BoxDecoration(
              border:
                  Border.all(color: Colors.white, width: 2), // Define el borde

              color: Colors.white, // Color de fondo
              borderRadius:
                  BorderRadius.circular(5.0), // Bordes redondeados (opcional)
            ),
            width: MediaQuery.of(context).size.width * 0.8,
            child: TextFormField(
              controller: controllerMatriculaRegister,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                hintText: 'Matricula',

                hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold),
                border: InputBorder.none, // Elimina la línea inferior
                contentPadding:
                    const EdgeInsets.all(15.0), // Ajusta el espacio interior
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            decoration: BoxDecoration(
              border:
                  Border.all(color: Colors.white, width: 2), // Define el borde

              color: Colors.white, // Color de fondo
              borderRadius:
                  BorderRadius.circular(5.0), // Bordes redondeados (opcional)
            ),
            width: MediaQuery.of(context).size.width * 0.8,
            child: TextFormField(
              controller: controllerEmailRegister,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
              keyboardType: TextInputType.text,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.email,
                  color: Theme.of(context).colorScheme.primary,
                ),
                hintText: 'E-mail',

                hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold),
                border: InputBorder.none, // Elimina la línea inferior
                contentPadding:
                    const EdgeInsets.all(15.0), // Ajusta el espacio interior
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            decoration: BoxDecoration(
              border:
                  Border.all(color: Colors.white, width: 2), // Define el borde

              color: Colors.white, // Color de fondo
              borderRadius:
                  BorderRadius.circular(5.0), // Bordes redondeados (opcional)
            ),
            width: MediaQuery.of(context).size.width * 0.8,
            child: TextFormField(
              controller: controllerPhoneRegister,
              onChanged: (value) => setState(() {}),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.phone,
                  color: Theme.of(context).colorScheme.primary,
                ),
                hintText: 'Telefono',

                hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold),
                border: InputBorder.none, // Elimina la línea inferior
                contentPadding:
                    const EdgeInsets.all(15.0), // Ajusta el espacio interior
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            decoration: BoxDecoration(
              border:
                  Border.all(color: Colors.white, width: 2), // Define el borde

              color: Colors.white, // Color de fondo
              borderRadius:
                  BorderRadius.circular(5.0), // Bordes redondeados (opcional)
            ),
            width: MediaQuery.of(context).size.width * 0.8,
            child: TextFormField(
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
              obscureText: _obscureTextfirst,
              onChanged: (value) => setState(() {}),
              controller: controllerPasswordRegisterFirst,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                suffixIcon: GestureDetector(
                  onTap: () {
                    _obscureTextfirst = !_obscureTextfirst;
                    setState(() {});
                  },
                  child: _obscureTextfirst
                      ? Icon(
                          Icons.visibility_off,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : Icon(
                          Icons.visibility,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                ),
                hintText: 'Contraseña',
                hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold),
                prefixIcon: Icon(
                  Icons.lock,
                  color: Theme.of(context).colorScheme.primary,
                ),
                border: InputBorder.none, // Elimina la línea inferior
                contentPadding:
                    const EdgeInsets.all(15.0), // Ajusta el espacio interior
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            decoration: BoxDecoration(
              border:
                  Border.all(color: Colors.white, width: 2), // Define el borde

              color: Colors.white, // Color de fondo
              borderRadius:
                  BorderRadius.circular(5.0), // Bordes redondeados (opcional)
            ),
            width: MediaQuery.of(context).size.width * 0.8,
            child: TextFormField(
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
              obscureText: _obscureTextSecond,
              onChanged: (value) => setState(() {}),
              controller: controllerPasswordRegisterSecond,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                suffixIcon: GestureDetector(
                  onTap: () {
                    _obscureTextSecond = !_obscureTextSecond;
                    setState(() {});
                  },
                  child: _obscureTextSecond
                      ? Icon(
                          Icons.visibility_off,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : Icon(
                          Icons.visibility,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                ),
                hintText: 'Repetir contraseña',
                hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold),
                prefixIcon: Icon(
                  Icons.lock,
                  color: Theme.of(context).colorScheme.primary,
                ),
                border: InputBorder.none, // Elimina la línea inferior
                contentPadding:
                    const EdgeInsets.all(15.0), // Ajusta el espacio interior
              ),
            ),
          ),
        ],
      ),
      Container(
        margin: EdgeInsets.only(bottom: 180, top: 180),
        width: MediaQuery.of(context).size.width * 0.95,
        decoration: const BoxDecoration(
            // color: Colors.amber,
            ),
        child: Container(
            height: 100,
            width: 100,
            child: const Center(
                child: CircularProgressIndicator(
              strokeWidth: 6,
              color: Colors.white,
            ))),
      ),
      Container(
          margin: EdgeInsets.only(bottom: 180, top: 180),
          width: MediaQuery.of(context).size.width * 0.95,
          decoration: const BoxDecoration(
              // color: Colors.amber,
              ),
          child: Container(
            height: 100,
            width: 100,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("¡Registro Exitoso! ",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                )
              ],
            ),
          ))
    ];

    return Center(
      child: SingleChildScrollView(
        child: Container(
          // color: Colors.amberAccent,
          alignment: Alignment.center,
          // color: Colors.purple,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                // color: Colors.blue,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: const BoxDecoration(),
                          alignment: Alignment.center,
                          child: const Text(
                            "REGISTRO",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.assignment_ind_rounded,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                    advertUserRegister[_indexAvertUserRegister],
                    advertErrorPasword[_indexadvertErrorPasword],
                    SizedBox(
                      height: sizespaceadvertence,
                    ),
                    infoToLoad[_indexinfoToLoad],
                    const SizedBox(
                      height: 60,
                    ),
                  ],
                ),
              ),
              buttons[_indexButtonsLogin],
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class myAppBarRegister extends StatelessWidget {
  myAppBarRegister({super.key, required this.chIndexRegisterToLogin});
  VoidCallback chIndexRegisterToLogin;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      // color: Colors.amber,
      child: Padding(
        padding: const EdgeInsets.only(right: 15),
        child: IconButton(
          onPressed: chIndexRegisterToLogin,
          icon: const Icon(
            Icons.close_sharp,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
