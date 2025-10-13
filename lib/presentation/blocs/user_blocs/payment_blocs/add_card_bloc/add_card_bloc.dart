import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:printfast_rebuild/domain/repositories/user_repository.dart';
import '../../../../../domain/entities/entities.dart';

part 'add_card_event.dart';
part 'add_card_state.dart';

class AddCardBloc extends Bloc<AddCardEvent, AddCardState> {
  final UserRepository userRepository;
  final String registration;

  AddCardBloc({required this.userRepository, required this.registration})
      : super(const AddCardInitial()) {
    on<CardHolderChanged>(_onCardHolderChanged);
    on<CardFormChanged>(_onCardFormChanged);
    on<ToggleDefaultCard>(_onToggleDefaultCard);
    on<SubmitCard>(_onSubmitCard);
    on<ResetForm>(_onResetForm);
    on<ChangeActionAddCardStatus>(_onChangeActionStatus);
  }

  FutureOr<void> _onChangeActionStatus(
    ChangeActionAddCardStatus event,
    Emitter<AddCardState> emit,
  ) {
    emit(state.copyWith(submitStatus: event.submitStatus));
  }

  void _onCardHolderChanged(
    CardHolderChanged event,
    Emitter<AddCardState> emit,
  ) {
    final isValid = _validateForm(
      event.cardHolder,
      state.cardComplete,
    );

    emit(state.copyWith(
      cardHolder: event.cardHolder,
      isValid: isValid,
      formStatus: DataAddCardStatus.success,
    ));
  }

  void _onCardFormChanged(
    CardFormChanged event,
    Emitter<AddCardState> emit,
  ) {
    final details = event.details;

    // details can be null (initial)
    final last4 = details?.last4 ?? '';
    final expiryMonth = details?.expiryMonth ?? 0;
    final expiryYear = details?.expiryYear ?? 0;
    final brand = details?.brand ?? '';
    final complete = details?.complete ?? false;

    final isValid = _validateForm(state.cardHolder, complete);

    emit(state.copyWith(
      last4: last4,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      brand: brand,
      cardComplete: complete,
      isValid: isValid,
      formStatus: DataAddCardStatus.success,
    ));
  }

  void _onToggleDefaultCard(
    ToggleDefaultCard event,
    Emitter<AddCardState> emit,
  ) {
    emit(state.copyWith(isDefault: !state.isDefault));
  }
Future<void> _onSubmitCard(
  SubmitCard event,
  Emitter<AddCardState> emit,
) async {
  if (!state.isValid || state.submitStatus == ActionAddCardStatus.loading) {
    return;
  }

  emit(state.copyWith(
    submitStatus: ActionAddCardStatus.loading,
    submitError: null,
  ));

  try {
    // 0) Validar si la tarjeta ya existe en Firestore
    final last4 = state.last4.isNotEmpty ? state.last4 : '0000';
    final brand = state.brand.isNotEmpty ? state.brand : 'Unknown';
    final expMonth = state.expiryMonth;
    int expYear = state.expiryYear;
    if (expYear > 0 && expYear < 100) expYear += 2000;

    final existingCards = await userRepository.getCards(registration);

    final isDuplicate = existingCards.any((card) =>
        card.last4 == last4 &&
        card.brand.toLowerCase() == brand.toLowerCase() &&
        card.expMonth == expMonth &&
        card.expYear == expYear);

    if (isDuplicate) {
      emit(state.copyWith(
        submitStatus: ActionAddCardStatus.failure,
        submitError: 'Ya has registrado esta tarjeta anteriormente.',
      ));
      return;
    }

    // 1) Crear PaymentMethod en Stripe (cliente). CardFormField ya recogió la tarjeta.
    final paymentMethod = await Stripe.instance.createPaymentMethod(
      params: PaymentMethodParams.card(
        paymentMethodData: PaymentMethodData(
          billingDetails: BillingDetails(name: state.cardHolder),
        ),
      ),
    );

    final pmId = paymentMethod.id;
    if (pmId.isEmpty) {
      throw Exception('No se pudo generar paymentMethod en Stripe.');
    }

    // 2) Construir entidad con la info disponible (últimos 4 / brand / expiry)
    final cardEntity = CardPaymentMethodEntity(
      token: pmId,
      last4: last4,
      brand: brand,
      expMonth: expMonth,
      expYear: expYear,
      isDefault: state.isDefault,
      createdAt: null,
    );

    // 3) Guardar en Firestore vía repo (addCardPaymentMethod hace la transacción atómica)
    await userRepository.addCardPaymentMethod(registration, cardEntity);

    emit(state.copyWith(submitStatus: ActionAddCardStatus.success));
  } catch (e) {
    emit(state.copyWith(
      submitStatus: ActionAddCardStatus.failure,
      submitError: e.toString(),
    ));
  }
}


  void _onResetForm(ResetForm event, Emitter<AddCardState> emit) {
    emit(const AddCardInitial());
  }

  bool _validateForm(String cardHolder, bool cardComplete) {
    if (cardHolder.trim().isEmpty) return false;
    if (!cardComplete) return false;
    return true;
  }
}
