import 'package:flutter/material.dart';

class mySettings extends StatelessWidget {
  mySettings({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      height: double.infinity,
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width * 0.95,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Container(
        // color: Colors.amber,
        margin: const EdgeInsets.only(top: 20, bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Container(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Container(
                      padding: const EdgeInsets.all(20),
                      width: MediaQuery.of(context).size.width * 0.83,
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: const Offset(0, 0),
                            ),
                          ],
                          color: Colors.white,
                          borderRadius: const BorderRadius.all(Radius.circular(20))),
                      child: Row(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 4),
                                color: Colors.white,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(100))),
                            child: Icon(
                              Icons.person,
                              color: Theme.of(context).colorScheme.primary,
                              size: 25,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Brandon Cantu",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inverseSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                Text(
                                  "1974238",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inverseSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(top: 20),
                    width: MediaQuery.of(context).size.width * 0.83,
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: const Offset(0, 0),
                          ),
                        ],
                        color: Colors.white,
                        borderRadius: const BorderRadius.all(Radius.circular(20))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 10, top: 5),
                          child: Row(
                            children: [
                              Text(
                                "Detalles",
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.inverseSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 2),
                                child: Icon(Icons.arrow_drop_down),
                              )
                            ],
                          ),
                        ),
                       

                        myDetailsUser(title: "Nombre", value: "Brandon Cantu",),
                        myDetailsUser(title: "Matricula", value: "1974238",),
                        myDetailsUser(title: "E-mail", value: "*****@gmail.com",),
                        myDetailsUser(title: "Telefono", value: "********3805",),
                        const SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
            ,Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                        boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                    offset: const Offset(0, 0),
                                  ),
                                ],),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          fixedSize: Size(MediaQuery.of(context).size.width * 0.7, 60),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)
                          )
                        ),
                      onPressed: (){}, 
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                                "Cerrar sesión",
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                          Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(Icons.logout, color: Colors.redAccent,
                            size: 22,),
                          )
                        ],
                      ),
                      ),
                    ),
                  ),
                  Text(
                              "Universidad Autónoma de Nuevo León",
                              style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 12),)
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }
}

// ignore: must_be_immutable
class myDetailsUser extends StatelessWidget {
  myDetailsUser({super.key, required this.title, required this.value});
  String title;
  String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inverseSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              Text(
                value,
                style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Bordes redondeados
                    )),
                child: const Text(
                  "Editar",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                )),
          )
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class myAppBarSettings extends StatelessWidget {
  ///PRUEBA

  myAppBarSettings(this.chindex);
  VoidCallback chindex;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        // margin: const EdgeInsets.only(top: 33), //HABILITAR SOLO PARA EL CELULAR
        // padding: const EdgeInsets.only(top: 33),
        // color: Colors.red,
        width: MediaQuery.of(context).size.width * 0.9,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Text(
                  "Opciones",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 22,
                  ),
                )
              ],
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.help_outline,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
