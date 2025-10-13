import 'dart:typed_data';

class AorderEntity {
  final String copyShopName;
  final String copyShopEmail;
  final String userRegistration;
  final String userName;
  final String orderCode;
  final bool hasItBeenCanceledByUser;
  final bool? hasItBeenAccepted;
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
  final Uint8List? pdfFileBytes;
  final String paymentMethod;
  final String verificationCode; //Son 5 numeros

  AorderEntity({
    required this.copyShopName,
    required this.copyShopEmail,
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
    this.pdfFileBytes,
    required this.paymentMethod,
    required this.verificationCode,
  });

  /// Convierte un documento de Firestore (Map) a una instancia de AorderEntity
  factory AorderEntity.fromMap(Map<String, dynamic> map) {
    return AorderEntity(
      userRegistration: map['userRegistration'] ?? '',
      userName: map['userName'] ?? '',
      orderCode: map['orderCode'] ?? '',
      hasItBeenCanceledByUser: map['hasItBeenCanceledByUser:'] ?? false,
      hasItBeenAccepted: map['hasItBeenAccepted'],
      estimatedDeliveryTime: map['estimatedDeliveryTime']?.toDate(),
      format: map['format'] ?? '',
      initDate: map['initDate']?.toDate() ?? DateTime.now(),
      isColor: map['isColor'] ?? false,
      pages: (map['pages'] ?? 0).toInt(),
      pdfName: map['pdfName'] ?? '',
      copyShopName: map['copyShopName'] ?? '',
      copyShopEmail: map['copyShopEmail'] ?? '',
      placeLat: map['placeLat'] ?? '',
      placeLong: map['placeLong'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      url: map['url'] ?? '',
      paymentMethod: map['isCardPayment'] ?? '',
      verificationCode: map['verificationCode'] ?? '',
    );
  }

  /// Convierte una instancia de AorderEntity a un Map para guardarlo en Firestore
  Map<String, dynamic> toMap() {
    return {
      'userRegistration': userRegistration,
      'userName': userName,
      'orderCode': orderCode,
      'hasItBeenCanceledByUser': hasItBeenCanceledByUser,
      'hasItBeenAccepted': hasItBeenAccepted,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'format': format,
      'initDate': initDate,
      'isColor': isColor,
      'pages': pages,
      'pdfName': pdfName,
      'copyShopName': copyShopName,
      'copyShopEmail': copyShopEmail,
      'placeLat': placeLat,
      'placeLong': placeLong,
      'price': price,
      'url': url,
      'verificationCode': verificationCode,
      'isCardPayment': paymentMethod,
    };
  }

  static const String _urlExample = "";

  static final List<AorderEntity> acceptedOrdersExample = [
    AorderEntity(
      copyShopName: "Imprenta Central",
      copyShopEmail: "facdyc@gmail.com",
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
      paymentMethod: 'cash',
      verificationCode: "34524",
    ),
    AorderEntity(
      copyShopName: "Copias Norte",
      copyShopEmail: "facdyc@gmail.com",
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
       paymentMethod: 'cash',
      verificationCode: "67843",
    ),
    AorderEntity(
      copyShopName: "Papelería FIME",
      copyShopEmail: "facdyc@gmail.com",
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
      paymentMethod: 'cash',
      verificationCode: "12467",
    ),
  ];

  static final List<AorderEntity> pendingOrders = [
    AorderEntity(
      copyShopName: "Imprenta Central",
      copyShopEmail: "facdyc@gmail.com",
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
       paymentMethod: 'cash',
      verificationCode: "12467",
    ),
    AorderEntity(
      copyShopName: "Copias Sur",
      copyShopEmail: "facdyc@gmail.com",
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
       paymentMethod: 'cash',
      verificationCode: "12467",
    ),
    AorderEntity(
      copyShopName: "Papelería Central",
      copyShopEmail: "facdyc@gmail.com",
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
       paymentMethod: 'cash',
      verificationCode: "12467",
    ),
  ];

  static final List<AorderEntity> historyOrders = [
    AorderEntity(
      copyShopName: "Imprenta Norte",
      copyShopEmail: "facdyc@gmail.com",
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
       paymentMethod: 'cash',
      verificationCode: "12467",
    ),

    AorderEntity(
      copyShopName: "Copias Facultad",
      copyShopEmail: "facdyc@gmail.com",
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
       paymentMethod: 'cash',
      verificationCode: "12467",
    ),

    AorderEntity(
      copyShopName: "Papelería Central",
      copyShopEmail: "facdyc@gmail.com",
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
       paymentMethod: 'cash',
      verificationCode: "12467",
    ),

    AorderEntity(
      copyShopName: "Imprenta Express",
      copyShopEmail: "facdyc@gmail.com",
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
       paymentMethod: 'cash',
      verificationCode: "12467",
    ),
  ];

  static final AorderEntity aorderEntityExample = AorderEntity(
    copyShopName: "Imprenta Central",
    userRegistration: "1945567",
    copyShopEmail: "facdyc@gmail.com",
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
    paymentMethod: 'cash',
    verificationCode: "12467",
  );
}
