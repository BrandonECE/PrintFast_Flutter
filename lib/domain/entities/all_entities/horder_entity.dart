import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';

class HorderEntity {
  final DateTime finalDate;
  final String format;
  final DateTime initDate;
  final bool isColor;
  final String name;
  final int pages;
  final String pdfName;
  final String place;
  final double price;
  final String url;
  final String orderCode;
  final String copyShopName;
  final Object? paymentMethod;
  final bool hasItBeenCanceled;

  HorderEntity({
    required this.finalDate,
    required this.format,
    required this.initDate,
    required this.isColor,
    required this.name,
    required this.pages,
    required this.pdfName,
    required this.place,
    required this.price,
    required this.url,
    required this.paymentMethod,
    required this.orderCode,
    required this.copyShopName,
    required this.hasItBeenCanceled,
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
      return CardPaymentMethodEntity.fromMap(o as Map<String, dynamic>) as Object?;
    }

    return HorderEntity(
      finalDate: toDate(map['finalDate']) ?? DateTime.now(),
      format: map['format']?.toString() ?? '',
      initDate: toDate(map['initDate']) ?? DateTime.now(),
      isColor: toBool(map['isColor']),
      name: map['name']?.toString() ?? '',
      pages: toInt(map['pages']),
      pdfName: map['pdfName']?.toString() ?? '',
      place: map['place']?.toString() ?? '',
      price: toDouble(map['price']),
      url: map['url']?.toString() ?? '',
      paymentMethod: toPaymentMethodObject(map['paymentMethod']),
      copyShopName: map['copyShopName']?.toString() ?? '',
      orderCode: map['orderCode']?.toString() ?? '',
      hasItBeenCanceled: map['hasItBeenCanceledByUser'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'finalDate': finalDate,
    'format': format,
    'initDate': initDate,
    'isColor': isColor,
    'name': name,
    'pages': pages,
    'pdfName': pdfName,
    'place': place,
    'price': price,
    'url': url,
    'paymentMethod': paymentMethod,
    'copyShopName': copyShopName,
    'orderCode': orderCode,
    'hasItBeenCanceledByUser': hasItBeenCanceled,
  };

  static final List<HorderEntity> examples = [
    HorderEntity(
      finalDate: now.add(const Duration(minutes: 35)),
      format: "A4",
      initDate: now,
      isColor: true,
      name: "Trabajo Escolar",
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
    ),
    HorderEntity(
      finalDate: now.subtract(const Duration(hours: 1)),
      format: "Carta",
      initDate: now.subtract(const Duration(days: 1)),
      isColor: false,
      name: "Anexo",
      pages: 4,
      pdfName: "anexo.pdf",
      place: "CopyShop Norte",
      price: 15.00,
      url: "",
      paymentMethod: "cash", // efectivo
      copyShopName: "FARQ",
      orderCode: "G7IH",
      hasItBeenCanceled: true,
    ),
    HorderEntity(
      finalDate: now.subtract(const Duration(days: 2)),
      format: "A3",
      initDate: now.subtract(const Duration(days: 3)),
      isColor: true,
      name: "Poster Evento",
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
    ),
  ];

  static final HorderEntity empty = HorderEntity(
    finalDate: DateTime.now(),
    format: "",
    initDate: DateTime.now(),
    isColor: false,
    name: "",
    pages: 0,
    pdfName: "",
    place: "",
    price: 0.0,
    url: "",
    paymentMethod: "",
    copyShopName: "",
    orderCode: "",
    hasItBeenCanceled: false,
  );

  static get now => DateTime.now();
}
