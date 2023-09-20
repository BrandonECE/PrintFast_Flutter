import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'dart:math';

class myLocation extends StatelessWidget {
  myLocation({super.key, required this.userLat, required this.userLong});
  double userLat;
  double userLong;
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      width: MediaQuery.of(context).size.width * 0.95,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: myLocationGoogleMapsPrueba(userLat: userLat, userLong: userLong),
    ));
  }
}

class myAppBarLocation extends StatelessWidget {
  myAppBarLocation({super.key, required this.chindex});
  VoidCallback chindex;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Text(
                  "Ubicacion",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.location_on_rounded,
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

class myLocationGoogleMaps extends StatefulWidget {
  myLocationGoogleMaps({super.key});

  @override
  State<myLocationGoogleMaps> createState() => _myLocationGoogleMapsState();
}

class _myLocationGoogleMapsState extends State<myLocationGoogleMaps> {
  List<Marker> predefinedMarkers = [];

  void generateImageMarker(int sizee) async {
    ///MARKERS PRINTFAST

    final ByteData byteData =
        await rootBundle.load("assets/images/printfast_marker.png");
    Uint8List imageMarker = byteData.buffer.asUint8List();
    final codec =
        await ui.instantiateImageCodec(imageMarker, targetWidth: sizee);
    final frame = await codec.getNextFrame();
    final newByteData =
        await frame.image.toByteData(format: ui.ImageByteFormat.png);
    final newImageMarker = newByteData!.buffer.asUint8List();

    ///USER
    final ByteData byteDataUser =
        await rootBundle.load("assets/images/printfast_marker_user.png");
    Uint8List imageMarkerUser = byteDataUser.buffer.asUint8List();
    final codecUser =
        await ui.instantiateImageCodec(imageMarkerUser, targetWidth: sizee);
    final frameUser = await codecUser.getNextFrame();
    final newByteDataUser =
        await frameUser.image.toByteData(format: ui.ImageByteFormat.png);
    final newImageMarkerUser = newByteDataUser!.buffer.asUint8List();

    ///

    Marker myMarkerCustom(String id, double lat, double lng, String title) {
      return Marker(
        markerId: MarkerId(id),
        icon: BitmapDescriptor.fromBytes(newImageMarker),
        position: LatLng(lat, lng), // Latitud y longitud del marcador
        infoWindow: InfoWindow(title: title), // Información del marcador
      );
    }

    Marker myMarkerCustomUser(String id, double lat, double lng, String title) {
      return Marker(
        markerId: MarkerId(id),
        icon: BitmapDescriptor.fromBytes(newImageMarkerUser),
        position: LatLng(lat, lng), // Latitud y longitud del marcador
        infoWindow: InfoWindow(title: title), // Información del marcador
      );
    }

    setState(() {
      predefinedMarkers = [
        myMarkerCustomUser("0", 25.724900, -100.310910, "Tú"),
        myMarkerCustom("1", 25.724302, -100.308550, "24/7"),
        myMarkerCustom("2", 25.726362, -100.310358, "FACDYC"),
        myMarkerCustom("3", 25.725541, -100.313390, "FIME"),
        myMarkerCustom("4", 25.724547, -100.310398, "Bilbioteca de Rectoria"),
        myMarkerCustom("5", 25.725208, -100.312523, "Entre FIME Y FARQ"),
        myMarkerCustom("6", 25.725545, -100.31195, "FARQ"),
        // Añade más marcadores según tus necesidades
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
        mapType: MapType.normal,
        markers: Set.from(predefinedMarkers),
        onMapCreated: (GoogleMapController controller) {
          generateImageMarker(30);
        },
        initialCameraPosition: const CameraPosition(
            target: LatLng(25.720, -100.3126), zoom: 15.25));
  }
}

class myLocationGoogleMapsPrueba extends StatefulWidget {
  myLocationGoogleMapsPrueba(
      {super.key, required this.userLat, required this.userLong});
  double userLat;
  double userLong;
  @override
  State<myLocationGoogleMapsPrueba> createState() =>
      _myLocationGoogleMapsPruebaState();
}

class _myLocationGoogleMapsPruebaState
    extends State<myLocationGoogleMapsPrueba> {
  List<Marker> predefinedMarkers = [];

  void generateImageMarker(int sizee) async {
    ///MARKERS PRINTFAST

    final ByteData byteData =
        await rootBundle.load("assets/images/printfast_marker.png");
    Uint8List imageMarker = byteData.buffer.asUint8List();
    final codec =
        await ui.instantiateImageCodec(imageMarker, targetWidth: sizee);
    final frame = await codec.getNextFrame();
    final newByteData =
        await frame.image.toByteData(format: ui.ImageByteFormat.png);
    final newImageMarker = newByteData!.buffer.asUint8List();

    ///USER
    final ByteData byteDataUser =
        await rootBundle.load("assets/images/printfast_marker_user.png");
    Uint8List imageMarkerUser = byteDataUser.buffer.asUint8List();
    final codecUser =
        await ui.instantiateImageCodec(imageMarkerUser, targetWidth: sizee);
    final frameUser = await codecUser.getNextFrame();
    final newByteDataUser =
        await frameUser.image.toByteData(format: ui.ImageByteFormat.png);
    final newImageMarkerUser = newByteDataUser!.buffer.asUint8List();

    ///

    Marker myMarkerCustom(String id, double lat, double lng, String title) {
      return Marker(
        markerId: MarkerId(id),
        icon: BitmapDescriptor.fromBytes(newImageMarker),
        position: LatLng(lat, lng), // Latitud y longitud del marcador
        infoWindow: InfoWindow(title: title), // Información del marcador
      );
    }

    Marker myMarkerCustomUser(String id, double lat, double lng, String title) {
      return Marker(
        markerId: MarkerId(id),
        icon: BitmapDescriptor.fromBytes(newImageMarkerUser),
        position: LatLng(lat, lng), // Latitud y longitud del marcador
        infoWindow: InfoWindow(title: title), // Información del marcador
      );
    }

    double gradosARadianes(double grados) {
      return grados * pi / 180;
    }

    double calculateDistance(double lat, double userubicationLat, double lon,
        double userubicationLon) {
      const Radio = 6371;
      double diferenciaLat = gradosARadianes(lat - userubicationLat);
      double diferenciaLon = gradosARadianes(lon - userubicationLon);
      double a = sin(diferenciaLat / 2) * sin(diferenciaLat / 2) +
          cos(gradosARadianes(userubicationLat)) *
              cos(gradosARadianes(lat)) *
              sin(diferenciaLon / 2) *
              sin(diferenciaLon / 2);
      double c = 2 * atan2(sqrt(a), sqrt(1 - a));
      double distance = Radio * c;
      return distance * 1000;
    }

    Map<dynamic, dynamic> getInfoNearbyLocation(
        Map<dynamic, dynamic> mapDistances,
        Map<String, Map<String, String>> coordenadas) {
      Map nearbyLocationMap = {};
      ;
      double nearbyLocation = 0;
      String? nameNearbyLocation;

      mapDistances.forEach((place, distance) {
        if (nearbyLocation == 0 || nearbyLocation > distance) {
          nearbyLocation = distance;
          nameNearbyLocation = place;
        }
      });

      nearbyLocationMap["Location"] = nameNearbyLocation;
      nearbyLocationMap["Distance"] = nearbyLocation.toString();
      coordenadas.forEach((place, map) {
        if (place == nameNearbyLocation) {
          map.forEach((coordenadaType, value) {
            nearbyLocationMap[coordenadaType] = value;
          });
        }
      });

      return nearbyLocationMap;
    }

    setState(() {
      final coordenadas = {
        'Arriba': {
          'Lat': '2345.664891',
          'Lon': '-10340.183905',
        },
        'Medio': {
          'Lat': '2345.664802',
          'Lon': '-10340.183883',
        },
        'Lado': {
          'Lat': '2655.664763',
          'Lon': '-10340.183966',
        },
        'Lejos': {
          'Lat': '2245.664615',
          'Lon': '-12400.183795',
        },
      };
      final mapDistances = {};
      Map nearbyLocation = {};
      double userubicationLat = widget.userLat;
      double userubicationLon = widget.userLong;
      int cont = 1;
      predefinedMarkers
          .add(myMarkerCustomUser("0", widget.userLat, widget.userLong, "Tú"));
      coordenadas.forEach((title, map) {
        //
        String lugar = title;
        double? lat;
        double? lon;
        map.forEach((coordenadas, value) {
          //

          if (coordenadas == 'Lat') lat = double.parse(value);
          if (coordenadas == 'Lon') lon = double.parse(value);
        }); //

        mapDistances[lugar] =
            calculateDistance(lat!, userubicationLat, lon!, userubicationLon);
        predefinedMarkers
            .add(myMarkerCustom(cont.toString(), lat!, lon!, title));
        ++cont;
      }); //
      print(
          "COOOOOOOOOOOOOOOOOORDENADAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAS!!!!!!!!!");
      print(mapDistances);
      print(
          "COOOOOOOOOOOOOOOOOORDENADAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAS!!!!!!!!!");
      nearbyLocation = getInfoNearbyLocation(mapDistances, coordenadas);
      print(nearbyLocation);
      print("ALMACENADOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO!!!!!!!!!");
    });
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
        // myLocationEnabled: true,
        mapType: MapType.normal,
        markers: Set.from(predefinedMarkers),
        onMapCreated: (GoogleMapController controller) {
          generateImageMarker(30);
        },
        initialCameraPosition: const CameraPosition(
            target: LatLng(25.6650, -100.183840), zoom: 18));
  }
}

