import 'package:printfast_rebuild/domain/entities/entities.dart';

class CopyShopEntity {
  final String copyShopName;
  final String lat;
  final String long;
  final bool pauseReception;
  final String copyShopEmail;
  final int queue;
  final double price;
  final bool isRecommended;
  final double distance;
  final int duration;
  final DateTime? estimatedDeliveryTime; //New Variable
  final Map<String, AorderEntity> aorders;

  CopyShopEntity({
    required this.copyShopName,
    required this.lat,
    required this.long,
    required this.pauseReception,
    required this.queue,
    required this.copyShopEmail,
    this.price = 0,
    this.isRecommended = false,
    this.distance = 0,
    this.duration = 0,
    this.estimatedDeliveryTime,
    this.aorders = const {},
  });

  // Constructor desde un Map
  factory CopyShopEntity.fromMap(Map<String, dynamic> map) {
    return CopyShopEntity(
      copyShopName: map['copyShopName'] as String,
      copyShopEmail: map['copyShopEmail'] as String,
      lat: map['lat'] as String,
      long: map['long'] as String,
      pauseReception: map['pauseReception'] as bool,
      queue: map['queue'] as int,
    );
  }

  // Convertir a Map
  Map<String, dynamic> toMap() {
    return {
      'copyShopName': copyShopName,
      'copyShopEmail': copyShopEmail,
      'lat': lat,
      'long': long,
      'pauseReception': pauseReception,
      'queue': queue,
    };
  }

  // Método copyWith para actualizar distancia y duración
  CopyShopEntity copyWith({
    String? copyShopName,
    String? lat,
    String? long,
    bool? pauseReception,
    int? queue,
    double? price,
    bool? isRecommended,
    double? distance,
    int? duration,
    DateTime? estimatedDeliveryTime,
    String? copyShopEmail,
    final Map<String, AorderEntity>? aorders,
  }) {
    return CopyShopEntity(
      copyShopName: copyShopName ?? this.copyShopName,
      lat: lat ?? this.lat,
      long: long ?? this.long,
      pauseReception: pauseReception ?? this.pauseReception,
      queue: queue ?? this.queue,
      price: price ?? this.price,
      isRecommended: isRecommended ?? this.isRecommended,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      copyShopEmail: copyShopEmail ?? this.copyShopEmail,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      aorders: aorders ?? this.aorders,
    );
  }

  static List<CopyShopEntity> exmapleUanl = [
    CopyShopEntity(
      copyShopName: '24/7',
      lat: '25.724302',
      long: '-100.308550',
      pauseReception: false,
      queue: 0,
      price: 17.0,
      isRecommended: true,
      copyShopEmail: "24.7@gmail.com",
    ),
    CopyShopEntity(
      copyShopName: 'BIBL. RECTORIA',
      lat: '25.724547',
      long: '-100.310398',
      pauseReception: false,
      queue: 0,
      price: 17.0,
      copyShopEmail: 'bibl.rectoria@gmail.com',
    ),
    CopyShopEntity(
      copyShopName: 'FACDYC',
      lat: '25.726362',
      long: '-100.310358',
      pauseReception: false,
      queue: 0,
      price: 17.0,
      copyShopEmail: 'facdyc@gmail.com',
    ),
    CopyShopEntity(
      copyShopName: 'FARQ',
      lat: '25.725545',
      long: '-100.31195',
      pauseReception: false,
      queue: 0,
      price: 17.0,
      copyShopEmail: 'farq@gmail.com',
    ),
    CopyShopEntity(
      copyShopName: 'FIME | x | FARQ',
      lat: '25.725208',
      long: '-100.312523',
      pauseReception: false,
      queue: 0,
      price: 17.0,
      copyShopEmail: 'fime.x.farq@gmail.com',
    ),
    CopyShopEntity(
      copyShopName: 'FIME',
      lat: '25.725541',
      long: '-100.313390',
      pauseReception: false,
      queue: 0,
      price: 17.0,
      copyShopEmail: 'fime@gmail.com',
    ),
  ];

  double get latDouble => double.tryParse(lat) ?? 0.0;
  double get longDouble => double.tryParse(long) ?? 0.0;
}
