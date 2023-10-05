// ignore_for_file: unused_local_variable

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:print_fast/dirScreens/placelocation.dart';
import '../firestore_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'dart:math';

// ignore: must_be_immutable
class myLocation extends StatefulWidget {
  myLocation(
      {super.key,
      required this.userLat,
      required this.userLong,
      required this.productosSeleccionados});
  double userLat;
  double userLong;
  Map productosSeleccionados;

  @override
  State<myLocation> createState() => _myLocationState();
}

class _myLocationState extends State<myLocation> {
  List<Marker> predefinedMarkers = [];
  Map mapDistances = {};
  Map mapTimeOrdersWaitingAditionTimeDistance = {};
  double placeLat = 0;
  double placeLong = 0;
  Map<String, Map<String, String>> nearbyLocationsInfoSort = {};
  List<myPlaceLocationInfo> placeLocation = [
    myPlaceLocationInfo("Cargando...", 0, 0, 0, 0)
  ];
  int indexPlaceLocation = 0;
  int indexPlaceLocationlimitStart = 0;
  int indexPlaceLocationlimitEnd = 0;
  late Widget msjRecomended;
  int indexIsThereAnyPlace = 0;

  void generateImageMarker(int sizee) async {
    ///MARKERS PRINTFAST

    Map<String, Map<String, String>> dyamictoMapStringMap(
        Map<dynamic, dynamic> mapDynamic) {
      Map<String, Map<String, String>> mapStriggMap = {};
      mapDynamic.forEach((place, map) {
        mapStriggMap[place.toString()] = Map<String, String>.from(map);
      });
      return mapStriggMap;
    }

    Map<dynamic, dynamic> dbMapDynamic = {};
    Map<String, Map<String, String>> dbMapLocations = {};
    
    Map<String, Map<String, String>> dbMapInventory = {};
    Map dbMapUsers = {};
    Map MapUser = {};

    dbMapDynamic = await getDB("ubicaciones");
    dbMapLocations = dyamictoMapStringMap(dbMapDynamic);
    dbMapDynamic = await getDB("inventarios");
    dbMapInventory = dyamictoMapStringMap(dbMapDynamic);

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
      double distance = (Radio * c) * 1000;
      distance = double.parse(distance.toStringAsFixed(1));
      return distance;
    }

    Map<dynamic, dynamic> getDistancesSort(Map<dynamic, dynamic> mapDistances) {
      List<MapEntry<dynamic, dynamic>> listaOrdenada =
          mapDistances.entries.toList();
      listaOrdenada.sort((a, b) => a.value.compareTo(b.value));
      Map<dynamic, dynamic> mapaOrdenado = Map.fromEntries(listaOrdenada);
      return mapaOrdenado;
    }

    Map<String, Map<String, String>> getNearbyLocationsInfo(
        Map<dynamic, dynamic> mapDistances,
        Map<String, Map<String, String>> dbMapLocations,
        Map mapTimeOrdersWaitingAditionTimeDistance) {
      Map<String, Map<String, String>> nearbyLocationsInfo = {};

      mapTimeOrdersWaitingAditionTimeDistance.forEach((placeAdit, timeTotal) {
        mapDistances.forEach((place, distance) {
            if(placeAdit == place){
                dbMapLocations.forEach((placeinfo, map) {
                if (place == placeinfo) {
                  Map<String, String> distanceInfo = {"Distance": "$distance"};
                  map.addAll(distanceInfo);
                  nearbyLocationsInfo[place] = map;
                }
              });

            }
        });

        
      });
      return nearbyLocationsInfo;
    }

    Map getMapTimeOrdersWaitingAditionTimeDistances(
        Map mapLocations, Map mapDistancesSort) {
      Map ordersWaiting = {};
      int minutetimeWaitperOrder = 1;
      int distancetimeWaitperOrder = 1 * 10;
      mapLocations.forEach((place, map) {
        mapDistances.forEach((placeDistance, distance) {
          if (placeDistance == place) {
            map.forEach((info, value) {
              if (info == "Ordenes") {
                String operation =
                    ((int.parse(value) * distancetimeWaitperOrder) + distance)
                        .toString();

                ordersWaiting.addAll({place: operation});
              }
            });
          }
        });
      });

      return ordersWaiting;
    }

    setState(() {
      predefinedMarkers.clear();
      nearbyLocationsInfoSort.clear();

      double userubicationLat = widget.userLat;
      double userubicationLon = widget.userLong;
      int cont = 1; //ID
      predefinedMarkers
          .add(myMarkerCustomUser("0", widget.userLat, widget.userLong, "Tú"));
      dbMapLocations.forEach((title, map) {
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

      mapDistances = getDistancesSort(mapDistances);
      mapTimeOrdersWaitingAditionTimeDistance =
          getMapTimeOrdersWaitingAditionTimeDistances(
              dbMapLocations, mapDistances);
      mapTimeOrdersWaitingAditionTimeDistance =
          getDistancesSort(mapTimeOrdersWaitingAditionTimeDistance);

      nearbyLocationsInfoSort = getNearbyLocationsInfo(mapDistances,
          dbMapLocations, mapTimeOrdersWaitingAditionTimeDistance);

      placeLocation.clear();
      Map productosSeleccionados = widget.productosSeleccionados;

      nearbyLocationsInfoSort.forEach((place, map) {
        String Place = place;
        int Ordenes = 0;
        double Lon = 0;
        double Lat = 0;
        double Distance = 0;
        bool addplace = true;
        dbMapInventory.forEach((placeInventario, inventario) {
          if (placeInventario == place) {
            inventario.forEach((producto, cantidadDisponible) {
              productosSeleccionados
                  .forEach((productoUser, cantidadProductoUser) {
                if (producto == productoUser) {
                  if (int.parse(cantidadProductoUser) != 0 &&
                      int.parse(cantidadDisponible) <
                          int.parse(cantidadProductoUser)) {
                    addplace = false;
                    print("###################################");
                    print("$placeInventario no cuenta con $productoUser");
                    print("###################################");
                  }
                }
              });
            });
          }
        });

        if (addplace == true) {
          map.forEach((info, value) {
            if (info == "Lon") Lon = double.parse(value);
            if (info == "Ordenes") Ordenes = int.parse(value);
            if (info == "Lat") Lat = double.parse(value);
            if (info == "Distance") Distance = double.parse(value);
            if (map.keys.last == info)
              placeLocation
                  .add(myPlaceLocationInfo(Place, Ordenes, Distance, Lat, Lon));
          });
        }
      });

      if (placeLocation.length != 0) {
        placeLat = placeLocation[0].lat;
        placeLong = placeLocation[0].lon;
        indexIsThereAnyPlace = 0;

        if (placeLat != 0 || placeLong != 0) {
          _updateCameraPosition();
        }

        if (placeLocation.length > 1) {
          indexPlaceLocationlimitEnd = 1;
        }
      } else {
        indexIsThereAnyPlace = 1;
        placeLocation.add(myPlaceLocationInfo("Cargando...", 0, 0, 0, 0));
      }
    });
  }

  void arrowLeft(double newLat, double newLong) {
    if (placeLocation.length > 1) {
      if ((indexPlaceLocation - 1) >= 0) {
        placeLat = newLat;
        placeLong = newLong;
        print(placeLat);
        print(placeLong);
        --indexPlaceLocation;
        _updateCameraPosition();
      }
      if (indexPlaceLocation < 1) {
        indexPlaceLocationlimitStart = 0;
        indexPlaceLocationlimitEnd = 1;
      } else {
        indexPlaceLocationlimitEnd = 1;
        indexPlaceLocationlimitStart = 1;
      }
      actualizar();
    }
  }

  void arrowRight(double newLat, double newLong) {
    if (placeLocation.length > 1) {
      if ((indexPlaceLocation + 1) != placeLocation.length) {
        placeLat = newLat;
        placeLong = newLong;
        print(placeLat);
        print(placeLong);
        ++indexPlaceLocation;
        _updateCameraPosition();
      }
      if (placeLocation.length - 1 == indexPlaceLocation) {
        indexPlaceLocationlimitEnd = 0;
        indexPlaceLocationlimitStart = 1;
      } else {
        indexPlaceLocationlimitStart = 1;
        indexPlaceLocationlimitEnd = 1;
      }
      actualizar();
    }
  }

  void actualizar() {
    setState(() {});
  }

  GoogleMapController? controllerNew;

  void _updateCameraPosition() {
    if (controllerNew != null) {
      controllerNew!.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(placeLat, placeLong), 18));
    }
  }

  @override
  Widget build(BuildContext context) {
    String distanciacon = "Distancia: ---";
    String tiempocon = "Tiempo: ---";
    String ordenescon = "Fila: ---";

    if (indexIsThereAnyPlace == 0) {
      double distance = placeLocation[indexPlaceLocation].distance;
      double time = (double.parse(
          ((placeLocation[indexPlaceLocation].distance) / 10)
              .toStringAsFixed(1)));

      if (placeLocation[indexPlaceLocation].distance < 1000) {
        distanciacon = "Distancia: $distance m";
      } else {
        distanciacon = "Distancia: ${(distance / 1000).toStringAsFixed(1)} Km";
      }

      if (time < 60) {
        tiempocon = "Tiempo: $time Minutos";
      } else {
        tiempocon = "Tiempo: ${(time / 60).toStringAsFixed(1)} Horas";
      }

      ordenescon = "Fila: ${placeLocation[indexPlaceLocation].orders} Ordenes";
    }

    if (indexPlaceLocation == 0 && indexIsThereAnyPlace == 0) {
      msjRecomended = const myLocationMsjRecomended();
    } else {
      msjRecomended = const SizedBox(height: 0);
    }

    List myButtons = const [
      myLocationsButton(),
      myLocationsButtonDisabled(),
    ];
    List myDashBoardAnyPlace = [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          myButtonsArrowChangePlace(
            icon: Icons.arrow_left,
            changePlace: () => arrowLeft(
                placeLocation[indexPlaceLocation - indexPlaceLocationlimitStart]
                    .lat,
                placeLocation[indexPlaceLocation - indexPlaceLocationlimitStart]
                    .lon),
          ),
          Text(
            placeLocation[indexPlaceLocation].place,
            style: TextStyle(
                color: Theme.of(context).colorScheme.inverseSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
          myButtonsArrowChangePlace(
            icon: Icons.arrow_right,
            changePlace: () => arrowRight(
                placeLocation[indexPlaceLocation + indexPlaceLocationlimitEnd]
                    .lat,
                placeLocation[indexPlaceLocation + indexPlaceLocationlimitEnd]
                    .lon),
          )
        ],
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        child: Text(
          "Lo sentimos, al parecer en este momento no hay algun lugar que cuente con todo lo que necesites.",
          style: TextStyle(
              color: Theme.of(context).colorScheme.inverseSurface,
              fontWeight: FontWeight.bold,
              fontSize: 12),
        ),
      ),
    ];

    return Center(
        child: Container(
      width: MediaQuery.of(context).size.width * 0.95,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Stack(
        children: [
          GoogleMap(
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
            child: Column(
              children: [
                msjRecomended,
                const SizedBox(
                  height: 10,
                ),
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: myDashBoardAnyPlace[indexIsThereAnyPlace]),
                const SizedBox(
                  height: 15,
                ),
                Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(30),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              distanciacon,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                            Row(
                              children: [
                                Text(
                                  tiempocon,
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 3),
                                  child: Icon(
                                    Icons.directions_run_rounded,
                                    color: Colors.grey.shade500,
                                    size: 15,
                                  ),
                                )
                              ],
                            ),
                            Text(
                              ordenescon,
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                        myButtons[indexIsThereAnyPlace]
                      ],
                    )),
              ],
            ),
          )
        ],
      ),
    ));
  }
}

// ignore: must_be_immutable
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

class myLocationsButton extends StatelessWidget {
  const myLocationsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      // ignore: sort_child_properties_last
      child: const Text(
        "Comprar",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.greenAccent.shade400,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class myLocationsButtonDisabled extends StatelessWidget {
  const myLocationsButtonDisabled({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      // ignore: sort_child_properties_last
      child: const Text(
        "Comprar",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.greenAccent.shade100,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class myButtonsArrowChangePlace extends StatelessWidget {
  myButtonsArrowChangePlace(
      {super.key, required this.icon, required this.changePlace});
  IconData icon;
  VoidCallback changePlace;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: changePlace,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: CircleBorder(),
        ),
        child: Icon(
          icon,
          size: 30,
          color: Theme.of(context).colorScheme.inverseSurface,
        ));
  }
}

class myLocationMsjRecomended extends StatelessWidget {
  const myLocationMsjRecomended({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Recomendada",
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.inverseSurface,
                fontWeight: FontWeight.bold),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 5, bottom: 1),
            child: Icon(
              Icons.star,
              size: 15,
              color: Colors.amber,
            ),
          )
        ],
      ),
    );
  }
}
