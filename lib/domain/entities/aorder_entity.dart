class AorderEntity {
  final String place;
  final String userRegistration;
  final String userName;
  final String orderCode;
  final bool hasItBeenCanceledByUser;
  final bool hasItBeenAccepted;
  final DateTime? estimatedDeliveryTime;
  final String format;
  final DateTime initDate;
  final bool isColor;
  final int pages;
  final String pdfName;
  final String placeLat;
  final String placeLong;
  final double price;
  final String url;

  AorderEntity({
    required this.place,
    required this.userRegistration,
    required this.userName,
    required this.orderCode,
    required this.hasItBeenCanceledByUser,
    required this.estimatedDeliveryTime,
    required this.hasItBeenAccepted,
    required this.format,
    required this.initDate,
    required this.isColor,
    required this.pages,
    required this.pdfName,
    required this.placeLat,
    required this.placeLong,
    required this.price,
    required this.url,
  });

  /// Convierte un documento de Firestore (Map) a una instancia de AorderEntity
  factory AorderEntity.fromMap(Map<String, dynamic> map) {
    return AorderEntity(
      userRegistration: map['userRegistration'] ?? '',
      userName: map['userName'] ?? '',
      orderCode: map['orderCode'] ?? '',
      hasItBeenCanceledByUser: map['hasItBeenCanceledByUser:'] ?? false,
      hasItBeenAccepted: map['hasItBeenAccepted'] ?? false,
      estimatedDeliveryTime: map['estimatedDeliveryTime']?.toDate(),
      format: map['format'] ?? '',
      initDate: map['initDate']?.toDate() ?? DateTime.now(),
      isColor: map['isColor'] ?? false,
      pages: (map['pages'] ?? 0).toInt(),
      pdfName: map['pdfName'] ?? '',
      place: map['place'] ?? '',
      placeLat: map['placeLat'] ?? '',
      placeLong: map['placeLong'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      url: map['url'] ?? '',
    );
  }

  /// Convierte una instancia de AorderEntity a un Map para guardarlo en Firestore
  Map<String, dynamic> toMap() {
    return {
      'userRegistration': userRegistration,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'userName': userName,
      'orderCode': orderCode,
      'hasItBeenCanceledByUser': hasItBeenCanceledByUser,
      'format': format,
      'initDate': initDate,
      'isColor': isColor,
      'pages': pages,
      'pdfName': pdfName,
      'place': place,
      'placeLat': placeLat,
      'placeLong': placeLong,
      'price': price,
      'url': url,
      'hasItBeenAccepted': hasItBeenAccepted,
    };
  }

  static const String _urlExample = "";

  static final List<AorderEntity> acceptedOrdersExample = [
    AorderEntity(
      place: "Imprenta Central",
      userRegistration: "1974238",
      hasItBeenAccepted: true,
      estimatedDeliveryTime: DateTime.now().add(Duration(minutes: 40)),
      format: "Carta",
      initDate: DateTime.now().subtract(Duration(hours: 1, minutes: 20)),
      isColor: true,
      pages: 25,
      hasItBeenCanceledByUser: false,
      pdfName: "tesis_final.pdf",
      placeLat: "25.689210",
      placeLong: "-100.318900",
      price: 75,
      url: _urlExample,
      orderCode: "345",
      userName: "Brandon Cantu",
    ),
    AorderEntity(
      place: "Copias Norte",
      userRegistration: "1934563",
      hasItBeenAccepted: true,
      estimatedDeliveryTime: DateTime.now().add(Duration(minutes: 55)),
      format: "Oficio",
      initDate: DateTime.now().subtract(Duration(minutes: 30)),
      isColor: false,
      pages: 10,
      hasItBeenCanceledByUser: false,
      pdfName: "informe_cap2.pdf",
      placeLat: "25.692500",
      placeLong: "-100.305000",
      price: 30,
      url: _urlExample,
      orderCode: "346",
      userName: "María López",
    ),
    AorderEntity(
      place: "Papelería FIME",
      userRegistration: "1978899",
      hasItBeenAccepted: true,
      estimatedDeliveryTime: DateTime.now().add(
        Duration(hours: 1, minutes: 10),
      ),
      format: "Carta",
      initDate: DateTime.now().subtract(Duration(hours: 2)),
      isColor: true,
      pages: 40,
      hasItBeenCanceledByUser: false,
      pdfName: "proyecto_final.pdf",
      placeLat: "25.695000",
      placeLong: "-100.320000",
      price: 120,
      url: _urlExample,
      orderCode: "347",
      userName: "Luis Martínez",
    ),
  ];

  static final List<AorderEntity> pendingOrders = [
    AorderEntity(
      place: "Imprenta Central",
      userRegistration: "1924459",
      hasItBeenAccepted: false,
      estimatedDeliveryTime: DateTime.now().add(Duration(hours: 3)),
      format: "Carta",
      initDate: DateTime.now().subtract(Duration(minutes: 15)),
      isColor: true,
      pages: 12,
      hasItBeenCanceledByUser: false,
      pdfName: "resumen_cap1.pdf",
      placeLat: "25.689210",
      placeLong: "-100.318900",
      price: 24,
      url: _urlExample,
      orderCode: "448",
      userName: "Ana Gómez",
    ),
    AorderEntity(
      place: "Copias Sur",
      userRegistration: "5632456",
      hasItBeenAccepted: false,
      estimatedDeliveryTime: DateTime.now().add(
        Duration(hours: 2, minutes: 20),
      ),
      format: "Oficio",
      initDate: DateTime.now().subtract(Duration(hours: 1, minutes: 5)),
      isColor: false,
      pages: 6,
      hasItBeenCanceledByUser: false,
      pdfName: "documento_ensayo.pdf",
      placeLat: "25.688000",
      placeLong: "-100.322000",
      price: 18,
      url: _urlExample,
      orderCode: "449",
      userName: "Carlos Rivera",
    ),
    AorderEntity(
      place: "Papelería Central",
      userRegistration: "2344455",
      hasItBeenAccepted: false,
      estimatedDeliveryTime: DateTime.now().add(Duration(minutes: 90)),
      format: "Carta",
      initDate: DateTime.now().subtract(Duration(minutes: 5)),
      isColor: false,
      pages: 3,
      hasItBeenCanceledByUser: false,
      pdfName: "nota_actividad.pdf",
      placeLat: "25.690500",
      placeLong: "-100.310200",
      price: 6,
      url: _urlExample,
      orderCode: "450",
      userName: "Sofía Hernández",
    ),
  ];

  static final List<AorderEntity> historyOrders = [
    AorderEntity(
      place: "Imprenta Norte",
      userRegistration: "1954345",
      hasItBeenAccepted: true,
      estimatedDeliveryTime: DateTime(2025, 1, 2, 24),
      format: "Carta",
      initDate: DateTime(2025, 1, 2, 23),
      isColor: false,
      pages: 10,
      hasItBeenCanceledByUser: false,
      pdfName: "tarea1.pdf",
      placeLat: "25.693100",
      placeLong: "-100.315000",
      price: 20,
      url: _urlExample,
      orderCode: "501",
      userName: "Alejandro Pérez",
    ),

    AorderEntity(
      place: "Copias Facultad",
      userRegistration: "1906456",
      hasItBeenAccepted: true,
      estimatedDeliveryTime: DateTime(2025, 2, 2, 24),

      format: "Oficio",
      initDate: DateTime(2025, 2, 2, 23),
      isColor: true,
      pages: 25,
      hasItBeenCanceledByUser: true,
      pdfName: "proyecto_capitulo.pdf",
      placeLat: "25.687800",
      placeLong: "-100.320500",
      price: 75,
      url: _urlExample,
      orderCode: "452",
      userName: "Beatriz Flores",
    ),

    AorderEntity(
      place: "Papelería Central",
      userRegistration: "1906546",
      hasItBeenAccepted: true,
      estimatedDeliveryTime: DateTime(2025, 3, 2, 24),
      format: "Carta",
      initDate: DateTime(2025, 3, 2, 23),
      isColor: false,
      pages: 4,
      hasItBeenCanceledByUser: false,
      pdfName: "resumen_articulo.pdf",
      placeLat: "25.690200",
      placeLong: "-100.312300",
      price: 8,
      url: _urlExample,
      orderCode: "003",
      userName: "Carlos Mendoza",
    ),

    AorderEntity(
      place: "Imprenta Express",
      userRegistration: "1945654",
      hasItBeenAccepted: true,
      estimatedDeliveryTime: DateTime.now().add(Duration(hours: 2)),
      format: "Oficio",
      initDate: DateTime.now().subtract(Duration(minutes: 5)),
      isColor: true,
      pages: 60,
      hasItBeenCanceledByUser: true,
      pdfName: "tesis_entregable.pdf",
      placeLat: "25.691500",
      placeLong: "-100.318000",
      price: 180,
      url: _urlExample,
      orderCode: "004",
      userName: "Diana Rodríguez",
    ),
  ];

  static final AorderEntity aorderEntityExample = AorderEntity(
    place: "Imprenta Central",
    userRegistration: "1945567",
    hasItBeenAccepted: true,
    estimatedDeliveryTime: DateTime.now().add(Duration(minutes: 40)),
    format: "Carta",
    initDate: DateTime.now().subtract(Duration(hours: 1, minutes: 20)),
    isColor: true,
    pages: 25,
    hasItBeenCanceledByUser: false,
    pdfName: "ModeloMatematicoCom.pdf",
    placeLat: "25.689210",
    placeLong: "-100.318900",
    price: 75,
    url: _urlExample,
    orderCode: "345",
    userName: "UserTest",
  );
}

