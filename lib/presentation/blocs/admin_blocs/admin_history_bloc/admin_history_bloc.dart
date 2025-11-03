import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/domain/repositories/admin_repository.dart';

part 'admin_history_event.dart';
part 'admin_history_state.dart';

class AdminHistoryBloc extends Bloc<AdminHistoryEvent, AdminHistoryState> {
  final AdminRepository adminRepository;
  final String emailCopyShop;

  AdminHistoryBloc({required this.emailCopyShop, required this.adminRepository})
      : super(AdminHistoryInitial()) {
    on<LoadAdminHistory>(_onLoadAdminHistory);
    on<SelectAdminHistoryOrder>(_onSelectAdminHistoryOrder);
    on<ClearSelectedAdminHistoryOrder>(_onClearSelectedAdminHistoryOrder);
    on<AdminMonthOrderHistoryElementSelectedEvent>(_onMonthOrderHistoryElementSelected);
  }

  Future<void> _onLoadAdminHistory(
    LoadAdminHistory event,
    Emitter<AdminHistoryState> emit,
  ) async {
    emit(state.copyWith(status: AdminHistoryStatus.loading, errorMessage: null));

    try {
      await Future.delayed(const Duration(milliseconds: 50));
      
      final List<HorderEntity> horders = await adminRepository.getCopyShopHOrders(emailCopyShop);

      horders.sort((a, b) {
        final aTime = a.initDate.millisecondsSinceEpoch;
        final bTime = b.initDate.millisecondsSinceEpoch;
        return bTime.compareTo(aTime);
      });

      // Agrupar órdenes por mes y año
      final monthOrderHistoryMap = _groupOrdersByMonth(horders);

      emit(
        state.copyWith(
          status: AdminHistoryStatus.success,
          historyOrders: horders,
          monthOrderHistoryMap: monthOrderHistoryMap,
          errorMessage: null,
        ),
      );
    } catch (e) {
      print(e);
      emit(
        state.copyWith(
          status: AdminHistoryStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Map<String, List<HorderEntity>> _groupOrdersByMonth(List<HorderEntity> orders) {
    final map = <String, List<HorderEntity>>{};
    for (final order in orders) {
      final monthYear = '${_getMonthName(order.initDate.month)} ${order.initDate.year}';
      if (!map.containsKey(monthYear)) {
        map[monthYear] = [];
      }
      map[monthYear]!.add(order);
    }
    return map;
  }

  String _getMonthName(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }

  void _onSelectAdminHistoryOrder(
    SelectAdminHistoryOrder event,
    Emitter<AdminHistoryState> emit,
  ) {
    emit(state.copyWith(selectedOrder: event.order));
  }

  void _onClearSelectedAdminHistoryOrder(
    ClearSelectedAdminHistoryOrder event,
    Emitter<AdminHistoryState> emit,
  ) {
    emit(state.copyWith(selectedOrder: HorderEntity.empty));
  }

  void _onMonthOrderHistoryElementSelected(
    AdminMonthOrderHistoryElementSelectedEvent event,
    Emitter<AdminHistoryState> emit,
  ) {
    emit(
      state.copyWith(
        monthOrderHistoryElementSelected: event.monthOrderHistoryElementSelected,
      ),
    );
  }
}