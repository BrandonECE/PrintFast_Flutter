class AorderEntity {
  final String email;
  final DateTime estimatedDeliveryTime;
  final String format;
  final DateTime initDate;
  final bool isColor;
  final int pages;
  final String pdfName;
  final String place;
  final String placeLat;
  final String placeLong;
  final double price;
  final String url;

  AorderEntity({
    required this.email,
    required this.estimatedDeliveryTime,
    required this.format,
    required this.initDate,
    required this.isColor,
    required this.pages,
    required this.pdfName,
    required this.place,
    required this.placeLat,
    required this.placeLong,
    required this.price,
    required this.url,
  });

  /// Convierte un documento de Firestore (Map) a una instancia de AorderEntity
  factory AorderEntity.fromMap(Map<String, dynamic> map) {
    return AorderEntity(
      email: map['email'] ?? '',
      estimatedDeliveryTime: map['estimatedDeliveryTime']?.toDate() ?? DateTime.now(),
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
      'email': email,
      'estimatedDeliveryTime': estimatedDeliveryTime,
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
    };
  }
}
