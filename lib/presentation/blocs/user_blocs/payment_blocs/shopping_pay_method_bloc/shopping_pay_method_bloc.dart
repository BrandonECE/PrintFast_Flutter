import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:printfast_rebuild/domain/repositories/user_repository.dart';
import 'package:printfast_rebuild/domain/entities/all_entities/card_payment_method_entity.dart';

part 'shopping_pay_method_event.dart';
part 'shopping_pay_method_state.dart';

class ShoppingPayMethodBloc
    extends Bloc<ShoppingPayMethodEvent, ShoppingPayMethodState> {
  final UserRepository userRepository;
  final String registration; // nuevo: registro del usuario a cargar

  ShoppingPayMethodBloc({
    required this.userRepository,
    required this.registration,
  }) : super(const ShoppingPayMethodInitial()) {
    on<LoadSavedCards>(_onLoadSavedCards);
    on<SelectPaymentMethod>(_onSelectPaymentMethod);
    on<SetDefaultCard>(_onSetDefaultCard);
    on<ConfirmPayment>(_onConfirmPayment);
    on<ChangeActionMethodPayStatusEvent>(_onChangeStatus);
  }

  // ------------------ LOAD SAVED CARDS (REAL) ------------------
  Future<void> _onLoadSavedCards(
    LoadSavedCards event,
    Emitter<ShoppingPayMethodState> emit,
  ) async {

    emit(ShoppingPayMethodInitial(),);

    await Future.delayed(const Duration(milliseconds: 50));

    try {
      final List<CardPaymentMethodEntity> loaded = await userRepository
          .getCards(registration);

      // Selecciona la tarjeta por defecto si existe; si no hay tarjetas -> 'cash'
      String? selected;
      if (loaded.isNotEmpty) {
        final defaultCard = loaded.firstWhere(
          (c) => c.isDefault == true,
          orElse: () => loaded.first.copyWith(token: 'cash'),
        );
        selected = defaultCard.token;
      } else {
        // Si no hay tarjetas -> seleccionar 'cash' por defecto
        selected = 'cash';
      }

      emit(
        state.copyWith(
          savedCards: loaded,
          selectedMethodId: selected,
          cardsStatus: DataMethodPayStatus.success,
          cardsError: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          savedCards: const <CardPaymentMethodEntity>[],
          selectedMethodId: null,
          cardsStatus: DataMethodPayStatus.failure,
          cardsError: 'Error al cargar tarjetas: ${e.toString()}',
        ),
      );
    }
  }

  // ------------------ seleccion de método ------------------
  void _onSelectPaymentMethod(
    SelectPaymentMethod event,
    Emitter<ShoppingPayMethodState> emit,
  ) {
    emit(state.copyWith(selectedMethodId: event.methodId, paymentError: null));
  }

  // ------------------ marcar default en UI (local) ------------------
  void _onSetDefaultCard(
    SetDefaultCard event,
    Emitter<ShoppingPayMethodState> emit,
  ) {
    final updated = state.savedCards.map((card) {
      return card.copyWith(isDefault: card.token == event.cardId);
    }).toList();

    emit(state.copyWith(savedCards: updated, selectedMethodId: event.cardId));
    // Nota: si quieres persistir el cambio a Firestore, llama a userRepository.addCard(...) o implementa setDefault en repo.
  }

  // ------------------ ConfirmPayment y ChangeActionStatus (mismo) ------------------
  Future<void> _onConfirmPayment(
    ConfirmPayment event,
    Emitter<ShoppingPayMethodState> emit,
  ) async {
    if (state.selectedMethodId == null) {
      emit(
        state.copyWith(
          paymentStatus: ActionMethodPayStatus.failure,
          paymentError: 'Por favor selecciona un método de pago',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        paymentStatus: ActionMethodPayStatus.loading,
        paymentError: null,
      ),
    );

    try {
      if (state.selectedMethodId != 'cash') {
        final selectedMethodId = state.selectedMethodId;

        // 1) Llamar a tu Firebase Function para obtener el clientSecret
        final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
        final callable = functions.httpsCallable('createPaymentIntent');
        final result = await callable.call(<String, dynamic>{
          'amount': 1000, // poner aquí el monto real en centavos
          'currency': 'mxn',
        });

        final clientSecret = result.data['clientSecret'] as String;

        // 2) Confirmar el pago con Stripe
        await Stripe.instance.confirmPayment(
          paymentIntentClientSecret: clientSecret,
          data: PaymentMethodParams.cardFromMethodId(
            paymentMethodData: PaymentMethodDataCardFromMethod(
              paymentMethodId: selectedMethodId!,
            ),
          ),
        );
      }

      // --- Pago exitoso ---
      emit(
        state.copyWith(
          paymentStatus: ActionMethodPayStatus.success,
          paymentError: null,
        ),
      );
    } catch (e) {
      print(e);
      emit(
        state.copyWith(
          paymentStatus: ActionMethodPayStatus.failure,
          paymentError:
              'Error procesando pago: ${e.toString().replaceAll(RegExp(r'\r?\n'), ' ')}',
        ),
      );
    }
  }

  Future<void> _onChangeStatus(
    ChangeActionMethodPayStatusEvent event,
    Emitter<ShoppingPayMethodState> emit,
  ) async {
    emit(state.copyWith(paymentStatus: event.paymentStatus));
  }
}
