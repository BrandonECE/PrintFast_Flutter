import 'package:flutter/material.dart';

class myScreenLoad extends StatelessWidget {
  const myScreenLoad({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      height: double.infinity,
      width: MediaQuery.of(context).size.width * 0.95,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Container(height: 50, width:50, child: Center(child: const myLoadSimbol())),
    ));
  }
}

class myLoadSimbol extends StatelessWidget {
  const myLoadSimbol({super.key});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(strokeWidth: 6, semanticsLabel: "Cargando");
  }
}

// ignore: must_be_immutable
class myAppBarScreenLoad extends StatelessWidget {
  myAppBarScreenLoad({super.key, required this.chindex, required this.icon});
  VoidCallback chindex;
  IconData icon;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  "Cargando...",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 22,
                  ),
                )
              ],
            ),
            IconButton(
              onPressed: chindex,
              icon: const Icon(
                Icons.close_sharp,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
    
  }
}
