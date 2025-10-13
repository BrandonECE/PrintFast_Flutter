// lib/presentation/blocs/user_blocs/history_bloc/history_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/domain/repositories/user_repository.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final UserRepository userRepository;
  final String registration;

  HistoryBloc({required this.userRepository, required this.registration})
    : super(HistoryInitial()) {
    on<LoadHistory>(_onLoadHistory);
    on<SelectHistoryOrder>(_onSelectHistoryOrder);
    on<ClearSelectedHistoryOrder>(_onClearSelectedHistoryOrder);
  }

  Future<void> _onLoadHistory(
    LoadHistory event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(status: HistoryStatus.loading, errorMessage: null));

    try {
      await Future.delayed(const Duration(milliseconds: 50));
      
      final List<HorderEntity> horders = await userRepository.getHOrders(registration);

      horders.sort((a, b) {
        final aTime = a.initDate.millisecondsSinceEpoch;
        final bTime = b.initDate.millisecondsSinceEpoch;
        return bTime.compareTo(aTime);
      });

      emit(
        state.copyWith(
          status: HistoryStatus.success,
          historyOrders: horders,
          errorMessage: null,
        ),
      );
    } catch (e) {
      print(e);
      emit(
        state.copyWith(
          status: HistoryStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onSelectHistoryOrder(
    SelectHistoryOrder event,
    Emitter<HistoryState> emit,
  ) {
    emit(state.copyWith(selectedOrder: event.order));
  }

  void _onClearSelectedHistoryOrder(
    ClearSelectedHistoryOrder event,
    Emitter<HistoryState> emit,
  ) {
    emit(state.copyWith(selectedOrder: null));
  }
}