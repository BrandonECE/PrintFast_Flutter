import 'package:cloud_firestore/cloud_firestore.dart';

class HorderEntity {
  final DateTime? finalDate;
  final String format;
  final DateTime? initDate;
  final bool isColor;
  final String name;
  final int pages;
  final String pdfName;
  final String place;
  final double price;
  final String url;

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

    return HorderEntity(
      finalDate: toDate(map['finalDate']),
      format: map['format']?.toString() ?? '',
      initDate: toDate(map['initDate']),
      isColor: toBool(map['isColor']),
      name: map['name']?.toString() ?? '',
      pages: toInt(map['pages']),
      pdfName: map['pdfName']?.toString() ?? '',
      place: map['place']?.toString() ?? '',
      price: toDouble(map['price']),
      url: map['url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'finalDate': finalDate == null ? null : Timestamp.fromDate(finalDate!),
        'format': format,
        'initDate': initDate == null ? null : Timestamp.fromDate(initDate!),
        'isColor': isColor,
        'name': name,
        'pages': pages,
        'pdfName': pdfName,
        'place': place,
        'price': price,
        'url': url,
      };
}
