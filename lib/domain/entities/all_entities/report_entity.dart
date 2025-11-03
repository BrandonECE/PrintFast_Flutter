import 'package:printfast_rebuild/domain/entities/entities.dart';

class ReportEntity {
  final double earnings;
  final int totalOrders;
  final int completedOrders;
  final int canceledOrders;
  final int pagesUsed;
  final double averageTime; // en minutos
  final DateTime startDate;
  final DateTime endDate;

  const ReportEntity({
    required this.earnings,
    required this.totalOrders,
    required this.completedOrders,
    required this.canceledOrders,
    required this.pagesUsed,
    required this.averageTime,
    required this.startDate,
    required this.endDate,
  });

  factory ReportEntity.fromHorders(List<HorderEntity> orders, DateTime startDate, DateTime endDate) {
    double earnings = 0;
    int totalOrders = orders.length;
    int completedOrders = 0;
    int canceledOrders = 0;
    int pagesUsed = 0;
    double totalTime = 0;

    for (final order in orders) {
      earnings += order.price;
      pagesUsed += order.pages;

      if (order.hasItBeenCanceled) {
        canceledOrders++;
      } else {
        completedOrders++;
      }

      // Calcular tiempo promedio (diferencia entre fecha final e inicial en minutos)
      final duration = order.finalDate.difference(order.initDate);
      totalTime += duration.inMinutes.toDouble();
    }

    double averageTime = totalOrders > 0 ? totalTime / totalOrders : 0;

    return ReportEntity(
      earnings: earnings,
      totalOrders: totalOrders,
      completedOrders: completedOrders,
      canceledOrders: canceledOrders,
      pagesUsed: pagesUsed,
      averageTime: averageTime,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Empty report
  static ReportEntity empty() {
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    return ReportEntity(
      earnings: 0,
      totalOrders: 0,
      completedOrders: 0,
      canceledOrders: 0,
      pagesUsed: 0,
      averageTime: 0,
      startDate: oneWeekAgo,
      endDate: now,
    );
  }

  // Para formatear el rango de fechas
  String get formattedDateRange {
    final start = '${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}';
    final end = '${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  // Para el texto del rango
  String get dateRangeText {
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    
    if (startDate.day == oneWeekAgo.day && 
        startDate.month == oneWeekAgo.month &&
        endDate.day == now.day &&
        endDate.month == now.month) {
      return 'Última semana';
    }
    return 'Personalizado';
  }
}