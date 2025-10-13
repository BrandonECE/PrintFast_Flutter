import 'package:cloud_firestore/cloud_firestore.dart';

/// Entidad que representa un método de pago (tarjeta) para guardar en Firestore.
class CardPaymentMethodEntity {
  final String token;      // ej. pm_1Pv5abcxyz
  final String last4;      // ej. "4242"
  final String brand;      // ej. "Visa"
  final int expMonth;      // ej. 12
  final int expYear;       // ej. 2027
  final bool isDefault;
  final DateTime? createdAt; // puede ser null hasta que Firestore ponga serverTimestamp

  const CardPaymentMethodEntity({
    required this.token,
    required this.last4,
    required this.brand,
    required this.expMonth,
    required this.expYear,
    this.isDefault = false,
    this.createdAt,
  });

  /// Convierte la entidad a Map para guardar en Firestore.
  /// Si [useServerTimestamp] es true guardará FieldValue.serverTimestamp()
  /// en el campo createdAt (útil al crear).
  Map<String, dynamic> toMap({bool useServerTimestamp = false}) {
    return {
      'token': token,
      'last4': last4,
      'brand': brand,
      'expMonth': expMonth,
      'expYear': expYear,
      'isDefault': isDefault,
      'createdAt': useServerTimestamp
          ? FieldValue.serverTimestamp()
          : (createdAt?.toUtc()),
    };
  }

  /// Crea la entidad a partir de un Map proveniente de Firestore u otra fuente.
  /// Maneja Timestamp (Firestore), String ISO, o int (msEpoch).
  factory CardPaymentMethodEntity.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) {
      throw ArgumentError('map para CardPaymentMethodEntity está vacío');
    }

    DateTime? parseCreatedAt(dynamic raw) {
      if (raw == null) return null;
      if (raw is Timestamp) return raw.toDate();
      if (raw is DateTime) return raw;
      if (raw is String) return DateTime.tryParse(raw);
      if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
      return null;
    }

    return CardPaymentMethodEntity(
      token: map['token'] as String,
      last4: map['last4'] as String,
      brand: map['brand'] as String,
      expMonth: (map['expMonth'] is int) ? map['expMonth'] as int : int.parse(map['expMonth'].toString()),
      expYear: (map['expYear'] is int) ? map['expYear'] as int : int.parse(map['expYear'].toString()),
      isDefault: map['isDefault'] is bool ? map['isDefault'] as bool : (map['isDefault'] == true),
      createdAt: parseCreatedAt(map['createdAt']),
    );
  }

  /// Crea la entidad a partir de un DocumentSnapshot de Firestore.
  factory CardPaymentMethodEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CardPaymentMethodEntity.fromMap(data);
  }

  CardPaymentMethodEntity copyWith({
    String? token,
    String? last4,
    String? brand,
    int? expMonth,
    int? expYear,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return CardPaymentMethodEntity(
      token: token ?? this.token,
      last4: last4 ?? this.last4,
      brand: brand ?? this.brand,
      expMonth: expMonth ?? this.expMonth,
      expYear: expYear ?? this.expYear,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'CardPaymentMethodEntity(token: $token, last4: $last4, brand: $brand, exp: $expMonth/$expYear, isDefault: $isDefault, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CardPaymentMethodEntity &&
        other.token == token &&
        other.last4 == last4 &&
        other.brand == brand &&
        other.expMonth == expMonth &&
        other.expYear == expYear &&
        other.isDefault == isDefault &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(token, last4, brand, expMonth, expYear, isDefault, createdAt);
  }
}
