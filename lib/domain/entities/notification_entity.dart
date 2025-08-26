
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationEntity {
  final DateTime? dateTime;
  final String message;
  final bool seen;
  final String subject;

  NotificationEntity({
    required this.subject,
    required this.message,
    required this.dateTime,
    required this.seen,
  });

  /// Convierte varios tipos (Timestamp, DateTime, String) a DateTime?
  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    if (v is String) {
      // Intenta parse ISO; si usas otro formato legible necesitarás un parser custom
      return DateTime.tryParse(v);
    }
    return null;
  }

  static bool _parseBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true';
    if (v is num) return v != 0;
    return false;
  }

  factory NotificationEntity.fromMap(Map<String, dynamic> map) {
    return NotificationEntity(
      dateTime: _parseDate(map['dateTime']),
      message: map['message']?.toString() ?? '',
      seen: _parseBool(map['seen']),
      subject: map['subject']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateTime': dateTime == null ? null : Timestamp.fromDate(dateTime!),
      'message': message,
      'seen': seen,
      'subject': subject,
    };
  }
}
