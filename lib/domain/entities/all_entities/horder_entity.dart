import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';

class HorderEntity {
  final String copyShopName;
  final String userRegistration;
  final String userName;
  final DateTime finalDate;
  final String format;
  final DateTime initDate;
  final bool isColor;
  final int pages;
  final String pdfName;
  final String place;
  final double price;
  final String url;
  final String orderCode;
  final Object? paymentMethod;
  final bool hasItBeenCanceled;
  final String copyShopEmail;

  HorderEntity({
    required this.copyShopName,
    required this.userRegistration,
    required this.userName,
    required this.finalDate,
    required this.format,
    required this.initDate,
    required this.isColor,
    required this.pages,
    required this.pdfName,
    required this.place,
    required this.price,
    required this.url,
    required this.paymentMethod,
    required this.orderCode,
    required this.hasItBeenCanceled,
    required this.copyShopEmail
  });

  factory HorderEntity.fromMap(Map<String, dynamic> map) {
    DateTime? toDate(dynamic v) {
      if (v == null) return null;
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      if (v is String) {
        final parsed = DateTime.tryParse(v);
        return parsed;
      }
      return null;
    }

    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    bool toBool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      if (v is String) return v.toLowerCase() == 'true';
      if (v is num) return v != 0;
      return false;
    }

    Object? toPaymentMethodObject(Object? o) {
      if (o is String) return o as Object?;
      return CardPaymentMethodEntity.fromMap(o as Map<String, dynamic>)
          as Object?;
    }

    return HorderEntity(
      copyShopName: map['copyShopName']?.toString() ?? '',
      userName: map['userName']?.toString() ?? '',
      userRegistration: map['userRegistration']?.toString() ?? '',
      finalDate: toDate(map['finalDate']) ?? DateTime.now(),
      format: map['format']?.toString() ?? '',
      initDate: toDate(map['initDate']) ?? DateTime.now(),
      isColor: toBool(map['isColor']),
      pages: toInt(map['pages']),
      pdfName: map['pdfName']?.toString() ?? '',
      place: map['place']?.toString() ?? '',
      price: toDouble(map['price']),
      url: map['url']?.toString() ?? '',
      paymentMethod: toPaymentMethodObject(map['paymentMethod']),
      orderCode: map['orderCode']?.toString() ?? '',
      hasItBeenCanceled: map['hasItBeenCanceledByUser'] ?? false,
      copyShopEmail: map['copyShopEmail'] ?? ''
    );
  }

  Map<String, dynamic> toMap() => {
    'finalDate': finalDate,
    'format': format,
    'initDate': initDate,
    'isColor': isColor,
    'pages': pages,
    'pdfName': pdfName,
    'place': place,
    'price': price,
    'url': url,
    'paymentMethod': paymentMethod,
    'copyShopName': copyShopName,
    'orderCode': orderCode,
    'hasItBeenCanceledByUser': hasItBeenCanceled,
    'copyShopEmail': copyShopEmail
  };

  static final List<HorderEntity> examples = [
    HorderEntity(
      userName: "Brandon Cantu",
      userRegistration: "1974238",
      finalDate: now.add(const Duration(minutes: 35)),
      format: "A4",
      initDate: now,
      isColor: true,
      pages: 12,
      pdfName: "trabajo_escolar.pdf",
      place: "CopyShop Central",
      price: 42.50,
      url:
          "gs://printfastofficial2025.firebasestorage.app/1974238/printFastTest.pdf",
      paymentMethod: "pm_1Example", // tarjeta
      copyShopName: "FIME",
      orderCode: "F345",
      hasItBeenCanceled: false,
      copyShopEmail: '8123423455'
    ),
    HorderEntity(
      userName: "Brandon Cantu",
      userRegistration: "1974238",
      finalDate: now.subtract(const Duration(hours: 1)),
      format: "Carta",
      initDate: now.subtract(const Duration(days: 1)),
      isColor: false,
      pages: 4,
      pdfName: "anexo.pdf",
      place: "CopyShop Norte",
      price: 15.00,
      url: "",
      paymentMethod: "cash", // efectivo
      copyShopName: "FARQ",
      orderCode: "G7IH",
      hasItBeenCanceled: true,
      copyShopEmail: '8183323411'

    ),
    HorderEntity(
      userName: "Brandon Cantu",
      userRegistration: "1974238",
      finalDate: now.subtract(const Duration(days: 2)),
      format: "A3",
      initDate: now.subtract(const Duration(days: 3)),
      isColor: true,
      pages: 2,
      pdfName: "poster.pdf",
      place: "CopyShop Sur",
      price: 120.00,
      url:
          "gs://printfastofficial2025.firebasestorage.app/1974238/ModeloMatematicoCom.pdf",
      paymentMethod: "pm_2Example", // tarjeta
      copyShopName: "24/7",
      orderCode: "G764",
      hasItBeenCanceled: false,
      copyShopEmail: '8126723425'

    ),
  ];

  static final HorderEntity empty = HorderEntity(
    userName: "",
    userRegistration: "",
    finalDate: DateTime.now(),
    format: "",
    initDate: DateTime.now(),
    isColor: false,
    pages: 0,
    pdfName: "",
    place: "",
    price: 0.0,
    url: "",
    paymentMethod: "",
    copyShopName: "",
    orderCode: "",
    hasItBeenCanceled: false,
    copyShopEmail: ''
  );

  static get now => DateTime.now();
}
