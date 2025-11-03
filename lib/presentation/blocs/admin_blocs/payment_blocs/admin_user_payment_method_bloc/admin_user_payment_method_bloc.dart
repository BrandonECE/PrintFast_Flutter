import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:printfast_rebuild/domain/entities/all_entities/card_payment_method_entity.dart';
import 'package:printfast_rebuild/domain/repositories/admin_repository.dart';

part 'admin_user_payment_method_event.dart';
part 'admin_user_payment_method_state.dart';

class AdminSeeUserPaymentMethodBloc
    extends Bloc<AdminSeeUserPaymentMethodEvent, AdminSeeUserPaymentMethodState> {
  final AdminRepository adminRepository;
  final String registration;
  final String paymentMethodId;

  AdminSeeUserPaymentMethodBloc({
    required this.adminRepository,
    required this.registration,
    required this.paymentMethodId,
  }) : super(AdminSeeUserPaymentMethodInitial()) {
    on<LoadUserPaymentMethod>(_onLoadUserPaymentMethod);
  }

  Future<void> _onLoadUserPaymentMethod(
    LoadUserPaymentMethod event,
    Emitter<AdminSeeUserPaymentMethodState> emit,
  ) async {
    emit(state.copyWith(status: AdminSeeUserPaymentMethodStatus.loading));
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      // Si el paymentMethodId es 'cash', entonces es efectivo
      if (paymentMethodId == 'cash') {
        emit(state.copyWith(
          status: AdminSeeUserPaymentMethodStatus.success,
          paymentMethod: 'cash',
          card: null,
          error: null,
        ));
      } else {
        // Si no, es una tarjeta, entonces la cargamos
        final CardPaymentMethodEntity? card = await adminRepository.getUserCard(registration, paymentMethodId);
        if (card != null) {
          emit(state.copyWith(
            status: AdminSeeUserPaymentMethodStatus.success,
            paymentMethod: 'card',
            card: card,
            error: null,
          ));
        } else {
          // Si no se encuentra la tarjeta, mostramos el estado de no encontrado
          emit(state.copyWith(
            status: AdminSeeUserPaymentMethodStatus.success,
            paymentMethod: 'not_found',
            card: null,
            error: null,
          ));
        }
      }
    } catch (e) {
      emit(state.copyWith(
        status: AdminSeeUserPaymentMethodStatus.failure,
        error: 'Error al cargar el método de pago: ${e.toString()}',
      ));
    }
  }
}