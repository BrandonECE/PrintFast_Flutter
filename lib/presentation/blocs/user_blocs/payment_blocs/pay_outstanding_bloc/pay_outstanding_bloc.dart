import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:printfast_rebuild/domain/repositories/user_repository.dart';
import 'package:printfast_rebuild/domain/entities/all_entities/card_payment_method_entity.dart';

part 'pay_outstanding_event.dart';
part 'pay_outstanding_state.dart';

class PayOutstandingBloc
    extends Bloc<PayOutstandingEvent, PayOutstandingState> {
  final UserRepository userRepository;
  final String registration;

  PayOutstandingBloc({required this.userRepository, required this.registration})
    : super(const PayOutstandingInitial()) {
    on<LoadCardsForOutstanding>(_onLoadCardsForOutstanding);
    on<SelectCardForOutstanding>(_onSelectCardForOutstanding);
    on<PayOutstandingAmount>(_onPayOutstandingAmount);
    on<ChangePayOutstandingStatus>(_onChangePayOutstandingStatus);
  }

  // ------------------ CARGAR TARJETAS ------------------
  Future<void> _onLoadCardsForOutstanding(
    LoadCardsForOutstanding event,
    Emitter<PayOutstandingState> emit,
  ) async {
    emit(const PayOutstandingInitial());

    await Future.delayed(const Duration(milliseconds: 50));

    try {
      final List<CardPaymentMethodEntity> loadedCards = await userRepository
          .getCards(registration);

      // Seleccionar la tarjeta predeterminada si existe
      String? selected;
      if (loadedCards.isNotEmpty) {
        final defaultCard = loadedCards.firstWhere(
          (c) => c.isDefault == true,
          orElse: () => loadedCards.first,
        );
        selected = defaultCard.token;
      }

      emit(
        state.copyWith(
          savedCards: loadedCards,
          selectedCardId: selected,
          cardsStatus: DataOutstandingStatus.success,
          cardsError: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          savedCards: const <CardPaymentMethodEntity>[],
          selectedCardId: null,
          cardsStatus: DataOutstandingStatus.failure,
          cardsError: 'Error al cargar tarjetas: ${e.toString()}',
        ),
      );
    }
  }

  // ------------------ SELECCIONAR TARJETA ------------------
  void _onSelectCardForOutstanding(
    SelectCardForOutstanding event,
    Emitter<PayOutstandingState> emit,
  ) {
    emit(state.copyWith(selectedCardId: event.cardId, paymentError: null));
  }

  // ------------------ PROCESAR PAGO DEL SALDO ------------------
  Future<void> _onPayOutstandingAmount(
    PayOutstandingAmount event,
    Emitter<PayOutstandingState> emit,
  ) async {
    if (state.selectedCardId == null) {
      emit(
        state.copyWith(
          paymentStatus: ActionOutstandingStatus.failure,
          paymentError: 'Por favor selecciona una tarjeta para pagar',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        paymentStatus: ActionOutstandingStatus.loading,
        paymentError: null,
      ),
    );

    try {
      // 1) Llamar a Firebase Function para obtener el clientSecret
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      final callable = functions.httpsCallable('createPaymentIntent');
      final result = await callable.call(<String, dynamic>{
        'amount':
            (event.amount * 100) //Se necesita almenos una cantidad de 10.00 mxn
                    .round() >
                1000
            ? (event.amount * 100).round()
            : 1000, // convertir a centavos
        'currency': 'mxn',
      });

      final clientSecret = result.data['clientSecret'] as String;
                 print("TODO BIENNNNNNNNNNNNNNNNNNNN ID STATE: ${state.selectedCardId}");
      print("TODO BIENNNNNNNNNNNNNNNNNNNN: $clientSecret");
           print("TODO BIENNNNNNNNNNNNNNNNNNNN ID: ${result.data['paymentIntentId'] as String}");
      // 2) Confirmar el pago con Stripe
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.cardFromMethodId(
          paymentMethodData: PaymentMethodDataCardFromMethod(
            paymentMethodId: state.selectedCardId!,
          ),
        ),
      );

      // 3) Actualizar el saldo pendiente a 0 en Firestore
      await userRepository.payOutstandingCharges(event.userRegistration);

      // --- Pago exitoso ---
      emit(
        state.copyWith(
          paymentStatus: ActionOutstandingStatus.success,
          paymentError: null,
        ),
      );
    } catch (e) {
      print(
        'Error procesando pago: ${e.toString().replaceAll(RegExp(r'\r?\n'), ' ')}',
      );
      emit(
        state.copyWith(
          paymentStatus: ActionOutstandingStatus.failure,
          paymentError:
              'Error procesando pago: ${e.toString().replaceAll(RegExp(r'\r?\n'), ' ')}',
        ),
      );
    }
  }

  void _onChangePayOutstandingStatus(
    ChangePayOutstandingStatus event,
    Emitter<PayOutstandingState> emit,
  ) {
    emit(state.copyWith(paymentStatus: event.paymentStatus));
  }
}
