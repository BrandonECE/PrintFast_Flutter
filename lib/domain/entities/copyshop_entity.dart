class CopyShopEntity {
  final String copyShopName;
  final String lat;
  final String long;
  final bool pauseReception;
  final int queue;

  CopyShopEntity({
    required this.copyShopName,
    required this.lat,
    required this.long,
    required this.pauseReception,
    required this.queue,
  });

  // Constructor desde un Map
  factory CopyShopEntity.fromMap(Map<String, dynamic> map) {
    return CopyShopEntity(
      copyShopName: map['copyShopName'] as String,
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
      'lat': lat,
      'long': long,
      'pauseReception': pauseReception,
      'queue': queue,
    };
  }
}
