import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:printfast_rebuild/domain/entities/all_entities/card_payment_method_entity.dart';
import 'package:printfast_rebuild/domain/repositories/user_repository.dart';

part 'change_payment_method_event.dart';
part 'change_payment_method_state.dart';

class ChangePaymentMethodBloc
    extends Bloc<ChangePaymentMethodEvent, ChangePaymentMethodState> {
  final UserRepository userRepository;
  final String registration;
  final String currentPaymentMethodId;

  ChangePaymentMethodBloc({
    required this.userRepository,
    required this.registration,
    required this.currentPaymentMethodId,
  }) : super(ChangePaymentMethodInitial()) {
    on<LoadPaymentMethods>(_onLoadPaymentMethods);
    on<SelectPaymentMethod>(_onSelectPaymentMethod);
    on<ConfirmChange>(_onConfirmChange);
    on<ResetState>(_onResetState);
    on<ChangePaymentMethodActionStatusEvent>(
      _onChangePaymentMethodActionStatus,
    );
  }

  Future<void> _onLoadPaymentMethods(
    LoadPaymentMethods event,
    Emitter<ChangePaymentMethodState> emit,
  ) async {
    emit(ChangePaymentMethodInitial());
    await Future.delayed(const Duration(milliseconds: 50));

    try {
      // Cargar tarjetas reales desde la base de datos
      final List<CardPaymentMethodEntity> savedCards = await userRepository
          .getCards(registration);

      // Buscar el método actual en las tarjetas cargadas
      CardPaymentMethodEntity? currentMethodCard;
      if (currentPaymentMethodId != 'cash') {
        currentMethodCard = savedCards.firstWhere(
          (card) => card.token == currentPaymentMethodId,
          orElse: () => CardPaymentMethodEntity(
            token: '',
            last4: '',
            brand: '',
            expMonth: 0,
            expYear: 0,
            isDefault: false,
          ),
        );
      }

      // Filtrar tarjetas disponibles (excluyendo la actual si existe)
      final availableCards = savedCards
          .where((card) => card.token != currentPaymentMethodId)
          .toList();

      emit(
        state.copyWith(
          savedCards: availableCards, // Solo las tarjetas disponibles
          currentMethodId: currentPaymentMethodId,
          selectedMethodId: null, // Inicialmente no hay selección
          currentMethodCard: currentMethodCard?.token != ''
              ? currentMethodCard
              : null,
          status: ChangePaymentMethodStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ChangePaymentMethodStatus.failure,
          error: 'Error al cargar métodos de pago: ${e.toString()}',
        ),
      );
    }
  }

  void _onSelectPaymentMethod(
    SelectPaymentMethod event,
    Emitter<ChangePaymentMethodState> emit,
  ) {
    emit(state.copyWith(selectedMethodId: event.methodId));
  }

  Future<void> _onConfirmChange(
    ConfirmChange event,
    Emitter<ChangePaymentMethodState> emit,
  ) async {
    if (state.selectedMethodId == null) return;

    emit(state.copyWith(changeStatus: ChangePaymentMethodActionStatus.loading));

    // Simular proceso de cambio
    await Future.delayed(const Duration(seconds: 2));

    // En una implementación real, aquí actualizarías el método de pago en el backend
    try {
      await userRepository.changeOrderPaymentMethod(
        event.userRegistration,
        event.copyShopEmail,
        event.orderCode,
        state.selectedMethodId ?? '',
      );
      emit(
        state.copyWith(
          changeStatus: ChangePaymentMethodActionStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          changeStatus: ChangePaymentMethodActionStatus.failure,
          error: 'Error al cambiar método de pago: ${e.toString()}',
        ),
      );
    }
  }

  void _onResetState(ResetState event, Emitter<ChangePaymentMethodState> emit) {
    emit(
      state.copyWith(
        changeStatus: ChangePaymentMethodActionStatus.idle,
        error: null,
      ),
    );
  }

  void _onChangePaymentMethodActionStatus(
    ChangePaymentMethodActionStatusEvent event,
    Emitter<ChangePaymentMethodState> emit,
  ) {
    emit(state.copyWith(changeStatus: event.changePaymentMethodActionStatus));
  }
}
