import 'dart:typed_data';

class AorderEntity {
  final String copyShopName;
  final String copyShopEmail;
  final String userRegistration;
  final String userName;
  final String orderCode;
  final bool hasItBeenCanceledByUser;
  final bool? hasItBeenAccepted;
  final bool hasItBeenCompleted;
  final DateTime? estimatedDeliveryTime;
  final bool hasTheEstimatedDeliveryTimeChanged;
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
  final DateTime? printDate;

  AorderEntity({
    required this.copyShopName,
    required this.copyShopEmail,
    required this.userRegistration,
    required this.userName,
    required this.orderCode,
    required this.hasItBeenCanceledByUser,
    required this.estimatedDeliveryTime,
    required this.hasTheEstimatedDeliveryTimeChanged,
    required this.hasItBeenAccepted,
    required this.hasItBeenCompleted,
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
    required this.printDate,
  });

  AorderEntity copyWith({
    String? copyShopName,
    String? copyShopEmail,
    String? userRegistration,
    String? userName,
    String? orderCode,
    bool? hasItBeenCanceledByUser,
    bool?
    hasItBeenAccepted, // si pasas null explícito significa querer mantener el mismo valor
    bool? hasItBeenCompleted,
    DateTime? estimatedDeliveryTime,
    bool? hasTheEstimatedDeliveryTimeChanged,
    String? format,
    DateTime? initDate,
    bool? isColor,
    int? pages,
    String? pdfName,
    String? placeLat,
    String? placeLong,
    double? price,
    String? url,
    Uint8List? pdfFileBytes,
    String? paymentMethod,
    String? verificationCode,
    DateTime? printDate,
  }) {
    return AorderEntity(
      copyShopName: copyShopName ?? this.copyShopName,
      copyShopEmail: copyShopEmail ?? this.copyShopEmail,
      userRegistration: userRegistration ?? this.userRegistration,
      userName: userName ?? this.userName,
      orderCode: orderCode ?? this.orderCode,
      hasItBeenCanceledByUser:
          hasItBeenCanceledByUser ?? this.hasItBeenCanceledByUser,
      hasItBeenAccepted: hasItBeenAccepted ?? this.hasItBeenAccepted,
      estimatedDeliveryTime:
          estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      hasTheEstimatedDeliveryTimeChanged:
          hasTheEstimatedDeliveryTimeChanged ??
          this.hasTheEstimatedDeliveryTimeChanged,
      hasItBeenCompleted: hasItBeenCompleted ?? this.hasItBeenCompleted,
      format: format ?? this.format,
      initDate: initDate ?? this.initDate,
      isColor: isColor ?? this.isColor,
      pages: pages ?? this.pages,
      pdfName: pdfName ?? this.pdfName,
      placeLat: placeLat ?? this.placeLat,
      placeLong: placeLong ?? this.placeLong,
      price: price ?? this.price,
      url: url ?? this.url,
      pdfFileBytes: pdfFileBytes ?? this.pdfFileBytes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      verificationCode: verificationCode ?? this.verificationCode,
      printDate: printDate ?? this.printDate,
    );
  }

  /// Convierte un documento de Firestore (Map) a una instancia de AorderEntity
  factory AorderEntity.fromMap(Map<String, dynamic> map) {
    return AorderEntity(
      userRegistration: map['userRegistration'] ?? '',
      userName: map['userName'] ?? '',
      orderCode: map['orderCode'] ?? '',
      hasItBeenCanceledByUser: map['hasItBeenCanceledByUser'] ?? false,
      hasItBeenAccepted: map['hasItBeenAccepted'],
      hasItBeenCompleted: map['hasItBeenCompleted'],
      estimatedDeliveryTime: map['estimatedDeliveryTime']?.toDate(),
      hasTheEstimatedDeliveryTimeChanged:
          map['hasTheEstimatedDeliveryTimeChanged'] ?? false,
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
      paymentMethod: map['paymentMethod'] ?? '',
      verificationCode: map['verificationCode'] ?? '',
      printDate: map['printDate']?.toDate(),
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
      'hasItBeenCompleted': hasItBeenCompleted,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'hasTheEstimatedDeliveryTimeChanged': hasTheEstimatedDeliveryTimeChanged,
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
      'paymentMethod': paymentMethod,
      'printDate': printDate,
    };
  }

  static const String _urlExample =
      "gs://printfastofficial2025.firebasestorage.app/1974238/printFastTest.pdf";

  static final List<AorderEntity> acceptedOrdersExample = [
    AorderEntity(
      copyShopName: "Imprenta Central",
      copyShopEmail: "facdyc@gmail.com",
      userRegistration: "1974238",
      hasItBeenAccepted: true,
      hasItBeenCompleted: false,
      estimatedDeliveryTime: DateTime.now().add(Duration(minutes: 40)),
      format: "Carta",
      initDate: DateTime.now().subtract(Duration(hours: 1, minutes: 20)),
      hasTheEstimatedDeliveryTimeChanged: false,
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
      printDate: DateTime.now().add(Duration(minutes: 20)),
    ),
    AorderEntity(
      copyShopName: "Copias Norte",
      copyShopEmail: "facdyc@gmail.com",
      userRegistration: "1934563",
      hasItBeenAccepted: true,
      hasItBeenCompleted: false,
      estimatedDeliveryTime: DateTime.now().add(Duration(minutes: 55)),
      format: "Oficio",
      initDate: DateTime.now().subtract(Duration(minutes: 30)),
      hasTheEstimatedDeliveryTimeChanged: false,
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
      printDate: DateTime.now().add(Duration(minutes: 40)),
    ),
    AorderEntity(
      copyShopName: "Papelería FIME",
      copyShopEmail: "facdyc@gmail.com",
      userRegistration: "1978899",
      hasItBeenAccepted: true,
      hasItBeenCompleted: false,
      estimatedDeliveryTime: DateTime.now().add(
        Duration(hours: 1, minutes: 10),
      ),
      format: "Carta",
      initDate: DateTime.now().subtract(Duration(hours: 2)),
      hasTheEstimatedDeliveryTimeChanged: false,
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
      printDate: DateTime.now().add(Duration(minutes: 59)),
    ),
  ];

  static final List<AorderEntity> pendingOrders = [
    AorderEntity(
      copyShopName: "Imprenta Central",
      copyShopEmail: "facdyc@gmail.com",
      userRegistration: "1924459",
      hasItBeenAccepted: false,
      hasItBeenCompleted: false,
      estimatedDeliveryTime: DateTime.now().add(Duration(hours: 3)),
      format: "Carta",
      initDate: DateTime.now().subtract(Duration(minutes: 15)),
      hasTheEstimatedDeliveryTimeChanged: false,
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
      printDate: DateTime.now().add(Duration(hours: 2)),
    ),
    AorderEntity(
      copyShopName: "Copias Sur",
      copyShopEmail: "facdyc@gmail.com",
      userRegistration: "5632456",
      hasItBeenAccepted: false,
      hasItBeenCompleted: false,
      estimatedDeliveryTime: DateTime.now().add(
        Duration(hours: 2, minutes: 20),
      ),
      format: "Oficio",
      initDate: DateTime.now().subtract(Duration(hours: 1, minutes: 5)),
      hasTheEstimatedDeliveryTimeChanged: false,
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
      printDate: DateTime.now().add(Duration(minutes: 20)),
    ),
    AorderEntity(
      copyShopName: "Papelería Central",
      copyShopEmail: "facdyc@gmail.com",
      userRegistration: "2344455",
      hasItBeenAccepted: false,
      hasItBeenCompleted: false,
      estimatedDeliveryTime: DateTime.now().add(Duration(minutes: 90)),
      format: "Carta",
      initDate: DateTime.now().subtract(Duration(minutes: 5)),
      hasTheEstimatedDeliveryTimeChanged: false,
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
      printDate: DateTime.now().add(Duration(minutes: 70)),
    ),
  ];

  static final AorderEntity aorderEntityEmpty = AorderEntity(
    copyShopName: "",
    userRegistration: "",
    copyShopEmail: "",
    hasItBeenAccepted: null,
    hasItBeenCompleted: false,
    estimatedDeliveryTime: DateTime.now(),
    hasTheEstimatedDeliveryTimeChanged: false,
    format: "",
    initDate: DateTime.now(),
    isColor: false,
    pages: 0,
    hasItBeenCanceledByUser: false,
    pdfName: "",
    placeLat: "",
    placeLong: "",
    price: 0,
    url: "",
    orderCode: "",
    userName: "",
    paymentMethod: "",
    verificationCode: "",
    printDate: null,
  );
}
