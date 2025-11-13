import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/domain/repositories/admin_repository.dart';

part 'admin_reports_event.dart';
part 'admin_reports_state.dart';

class AdminReportsBloc extends Bloc<AdminReportsEvent, AdminReportsState> {
  final AdminRepository adminRepository;
  final String emailCopyShop;

  AdminReportsBloc({required this.emailCopyShop, required this.adminRepository})
    : super(AdminReportsInitial()) {
    on<LoadAdminReports>(_onLoadAdminReports);
    on<UpdateAdminReportsDateRange>(_onUpdateAdminReportsDateRange);
  }

  Future<void> _onLoadAdminReports(
    LoadAdminReports event,
    Emitter<AdminReportsState> emit,
  ) async {
    emit(
      state.copyWith(status: AdminReportsStatus.loading, errorMessage: null),
    );

    try {
      await Future.delayed(const Duration(milliseconds: 200));

      // Obtener todas las órdenes históricas
      final List<HorderEntity> allHorders = await adminRepository
          .getCopyShopHOrders(emailCopyShop);
      final now = DateTime.now();
      // Filtrar órdenes por el rango de fechas
      final filteredHorders = allHorders.where((order) {
        return order.initDate.isAfter(event.startDate) &&
            (order.initDate.isBefore(event.endDate) || (order.initDate.day == now.day && order.initDate.month == now.month && order.initDate.year == now.year) );
      }).toList();

      print(filteredHorders.length);

      // Crear el reporte
      final report = ReportEntity.fromHorders(
        filteredHorders,
        event.startDate,
        event.endDate,
      );

      print(report);

      emit(
        state.copyWith(
          status: AdminReportsStatus.success,
          report: report,
          errorMessage: null,
        ),
      );
    } catch (e) {
      print(e);
      emit(
        state.copyWith(
          status: AdminReportsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onUpdateAdminReportsDateRange(
    UpdateAdminReportsDateRange event,
    Emitter<AdminReportsState> emit,
  ) {
    // Solo actualiza las fechas sin recargar los datos
    final updatedReport = ReportEntity(
      earnings: state.report.earnings,
      totalOrders: state.report.totalOrders,
      completedOrders: state.report.completedOrders,
      canceledOrders: state.report.canceledOrders,
      pagesUsed: state.report.pagesUsed,
      averageTime: state.report.averageTime,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    emit(state.copyWith(report: updatedReport));
  }
}
