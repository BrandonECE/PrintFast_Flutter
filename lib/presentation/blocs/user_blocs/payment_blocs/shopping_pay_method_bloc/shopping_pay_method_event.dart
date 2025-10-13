part of 'shopping_pay_method_bloc.dart';

sealed class ShoppingPayMethodEvent extends Equatable {
  const ShoppingPayMethodEvent();

  @override
  List<Object?> get props => [];
}

class LoadSavedCards extends ShoppingPayMethodEvent {
  const LoadSavedCards();
}

class SelectPaymentMethod extends ShoppingPayMethodEvent {
  final String methodId;
  const SelectPaymentMethod({required this.methodId});

  @override
  List<Object?> get props => [methodId];
}

class SetDefaultCard extends ShoppingPayMethodEvent {
  final String cardId;
  const SetDefaultCard({required this.cardId});

  @override
  List<Object?> get props => [cardId];
}

class ConfirmPayment extends ShoppingPayMethodEvent {
  const ConfirmPayment();
}

class ChangeActionMethodPayStatusEvent extends ShoppingPayMethodEvent {
  final ActionMethodPayStatus paymentStatus;
  const ChangeActionMethodPayStatusEvent({required this.paymentStatus});

  @override
  List<Object?> get props => [paymentStatus];
}
