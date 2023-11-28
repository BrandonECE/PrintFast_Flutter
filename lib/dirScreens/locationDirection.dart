import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:print_fast/apikeygoogle.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:print_fast/sharedviewmodel.dart';

// ignore: must_be_immutable, camel_case_types
class myLocationDirections extends StatefulWidget {
  myLocationDirections(
      {super.key,
      required this.placeLat,
      required this.placeLong,
      required this.userLat,
      required this.userLong,
      required this.namePlace,
      required this.sharedChangeNotifier});
  SharedChangeNotifier sharedChangeNotifier;
  String namePlace;
  String placeLat;
  String placeLong;
  double userLat;
  double userLong;
  @override
  State<myLocationDirections> createState() => _myLocationDirectionsState();
}

// ignore: camel_case_types
class _myLocationDirectionsState extends State<myLocationDirections> {
  GoogleMapController? controllerNew;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = API_KEY_GOOGLE;
  List<Marker> predefinedMarkers = [];
  int contPoly = 0;
  String distance = "0";
  String timeS = "0 min";
  late Timer bucleActualizar;

  @override
  void dispose() {
    print("DESMONTANDO WIDGET");
    bucleActualizar.cancel();
    super.dispose();
  }

  Future<Position> determinatePosition() async {
    return await Geolocator.getCurrentPosition();
  }

  Future<void> actualizarUbicacionDirection() async {
    Position position;
    position = await determinatePosition();
    print("@@@@@@@@@@@COORDENADAS DE USUARIOOOOOOOOOOOOOO@@@@@@@@@@@@@@@@");
    print("LAT: ${widget.userLat},LONG: ${widget.userLong}");
    print("@@@@@@@@@@@COORDENADAS DE USUARIOOOOOOOOOOOOOO@@@@@@@@@@@@@@@@");
    widget.userLat = position.latitude;
    widget.userLong = position.longitude;
  }

  void generateImageMarker(int sizee) async {
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

    try {

      bucleActualizar =
          Timer.periodic(const Duration(seconds: 2), (timer) async {
        double distanceDouble = 0;
        predefinedMarkers.clear();
        print("ACTUALIZADO");
        await actualizarUbicacionDirection();
        predefinedMarkers.clear();
        predefinedMarkers.add(myMarkerCustom("0", double.parse(widget.placeLat),
            double.parse(widget.placeLong), widget.namePlace));
        predefinedMarkers.add(
            myMarkerCustomUser("1", widget.userLat, widget.userLong, "Yo"));
        _updateCameraPosition();
        distanceDouble = calculateDistance(double.parse(widget.placeLat),
            widget.userLat, double.parse(widget.placeLong), widget.userLong);
        distance = distanceDouble.toString();

          double time = widget.sharedChangeNotifier.sharedTime.value.toDouble();

      if (time < 1 && time > 0) {
        timeS = "${time.toInt()} seg";
      } else if (time < 60) {
        timeS = "${time.toInt()} min";
      } else {
        timeS = "${(time / 60).toStringAsFixed(1)} h";
      }

        if (this.mounted) {
          print("WIDGET MONTADO");
          setState(() {});
        } else {
          print("WIDGET NO MONTADO (NO ACTUALIZAR)");
        }
      });
    } catch (e) {
      print("ERROR EN LA ACTUALIZACION DE UBICACION 2");
      print(e);
      bucleActualizar.cancel();
    }
  }

  _addPolyLine() {
    ++contPoly;
    PolylineId id = PolylineId("$contPoly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Theme.of(context).colorScheme.primary,
        points: polylineCoordinates);
    polylines.clear();
    polylines[id] = polyline;

    // setState(() {});
  }

  _getPolyline() async {
    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        PointLatLng(widget.userLat, widget.userLong),
        PointLatLng(
            double.parse(widget.placeLat), double.parse(widget.placeLong)),
        travelMode: TravelMode.walking,
      );
      if (result.points.isNotEmpty) {
        polylineCoordinates.clear();
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      }
      _addPolyLine();
    } catch (e) {
      print(e);
      print("ERROR");
    }
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
    double distance = (Radio * c) * 1000;
    distance = double.parse(distance.toStringAsFixed(1));
    return distance;
  }

  double gradosARadianes(double grados) {
    return grados * pi / 180;
  }

  void _updatePolylines() {
    _getPolyline();
  }

  void _updateCameraPosition() {
    if (controllerNew != null) {
      controllerNew!.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(widget.userLat, widget.userLong), 19));
      _updatePolylines();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      width: MediaQuery.of(context).size.width * 0.95,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Stack(
        children: [
          GoogleMap(
              polylines: Set<Polyline>.of(polylines.values),
              mapType: MapType.normal,
              markers: Set.from(predefinedMarkers),
              onMapCreated: (GoogleMapController controller) {
                controllerNew = controller;
                generateImageMarker.call(30);
              },
              initialCameraPosition: CameraPosition(
                  target: LatLng(widget.userLat, widget.userLong), zoom: 100)),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(children: [
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: Theme.of(context).colorScheme.inverseSurface,
                          ),
                        ),
                        Text(
                          widget.namePlace,
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inverseSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        )
                      ],
                    )),
                const SizedBox(
                  height: 15,
                ),
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(27),
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30))),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(
                                Icons.directions_run_rounded,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inverseSurface,
                                size: 22,
                              ),
                            ),
                            Text(
                              "Distancia: $distance m",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(
                                Icons.access_time,
                                color: Colors.grey.shade500,
                                size: 18,
                              ),
                            ),
                            Text(
                              "Espera: ${timeS}",
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            )
                          ],
                        ),
                      ],
                    )),
              ]))
        ],
      ),
    ));
  }
}

// ignore: must_be_immutable
class myAppBarLocationDirections extends StatelessWidget {
  myAppBarLocationDirections({super.key, required this.chindex});
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
                  "Direccion",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.directions,
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
