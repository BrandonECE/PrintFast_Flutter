import 'package:flutter/material.dart';
import 'package:print_fast/firestore_service.dart';

// ignore: must_be_immutable
class myLogin extends StatefulWidget {
  myLogin(
      {super.key,
      required this.chIndexMenu,
      required this.chIndexRegister,
      required this.functionInfoUser});
  VoidCallback chIndexMenu;
  VoidCallback chIndexRegister;
  Function(Map) functionInfoUser;
  @override
  State<myLogin> createState() => _myLoginState();
}

class _myLoginState extends State<myLogin> {
  bool _obscureText = true;

  int _indexButtonsLogin = 0;
  int _indexAvert = 0;
  int _indexFormToLoad = 0;
  TextEditingController controllerPassword = TextEditingController();
  TextEditingController controllerMatricula = TextEditingController();

  @override
  Widget build(BuildContext context) {

    // Future.delayed(Duration(seconds: 1), () {
    //   _indexFormToLoad = 0;
    //   setState(() {
        
    //   });
    // });


    void loadLoginCorrect(Map infouser) async {
      setState(() {
        _indexFormToLoad = 1;
      });
      await Future.delayed(const Duration(seconds: 3), () async {
        _indexFormToLoad = 0;
        await widget.functionInfoUser(infouser);
        widget.chIndexMenu.call();
      });
    }

    void loadLoginInorrect() async {
      setState(() {
        _indexFormToLoad = 1;
      });
      await Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          controllerPassword.text = "";
          controllerMatricula.text = "";
          _indexAvert = 1;
          _indexFormToLoad = 0;

          Future.delayed(const Duration(seconds: 5), () {
            _indexAvert = 0;
            setState(() {});
          });
        });
      });
    }

    if (controllerPassword.text.length > 0 &&
        controllerMatricula.text.length > 0) {
      _indexButtonsLogin = 1;
    } else {
      _indexButtonsLogin = 0;
    }

    List<Widget> buttons = [
      ElevatedButton(
        style: ElevatedButton.styleFrom(
            elevation: 0,
            fixedSize: Size(MediaQuery.of(context).size.width * 0.8, 60),
            backgroundColor: Colors.white60,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0))),
        onPressed: () {},
        child: Text(
          "Iniciar sesión",
          style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
            elevation: 0,
            fixedSize: Size(MediaQuery.of(context).size.width * 0.8, 60),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0))),
        onPressed: () async {
          Map user;
          try {
            user = await getDBUser(controllerMatricula.text);

            user.forEach((info, value) {
              if (info == "Contrasena") {
                if (value == controllerPassword.text) {
                  loadLoginCorrect(user);
                } else {
                  throw Exception('Contra incorrecta');
                }
              }
            });
          } catch (e) {
            print("No se encontro usuario alguno");
            print(e);
            loadLoginInorrect();
          }
        },
        child: Text(
          "Iniciar sesión",
          style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
    ];

    List<Widget> advert = [
      const SizedBox(
        height: 40,
      ),
      Container(
        child: Container(
          // color: Colors.amber,
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width * 0.8,
          margin: const EdgeInsets.only(bottom: 20, top: 20),
          child: const Text(
            "ERROR: Parece que su matricula y contraseña no coinciden o no existen. Inténtelo de nuevo.",
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

    List<Widget> formtoload = [
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
              onChanged: (value) {
                setState(() {});
              },
              controller: controllerMatricula,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
              keyboardType: TextInputType.number,
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
              onChanged: (value) {
                setState(() {});
              },
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
              obscureText: _obscureText,
              controller: controllerPassword,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                suffixIcon: GestureDetector(
                  onTap: () {
                    _obscureText = !_obscureText;
                    setState(() {});
                  },
                  child: _obscureText
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
            height: 70,
          ),
        ],
      ),
      Container(
        margin: EdgeInsets.only(bottom: 80),
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
      )
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
                    Container(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: Image.asset(
                            'assets/images/printfast_logoLogin.png',
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: const Text(
                            "PrintFast",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 30),
                          ),
                        ),
                      ],
                    )),
                    const SizedBox(
                      height: 40,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: const BoxDecoration(),
                          alignment: Alignment.center,
                          child: const Text(
                            "BIENVENIDO",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.waving_hand_rounded,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                    advert[_indexAvert],
                    formtoload[_indexFormToLoad],
                  ],
                ),
              ),
              Container(
                // color: Colors.blue,
                child: Column(
                  children: [
                    buttons[_indexButtonsLogin],
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          fixedSize:
                              Size(MediaQuery.of(context).size.width * 0.8, 60),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0))),
                      onPressed: widget.chIndexRegister,
                      child: const Text(
                        "Registrarse",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class myAppBarLogin extends StatelessWidget {
  const myAppBarLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 15),
        child: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.help_outline,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
