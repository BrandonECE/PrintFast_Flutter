part of 'change_payment_method_bloc.dart';

sealed class ChangePaymentMethodEvent extends Equatable {
  const ChangePaymentMethodEvent();

  @override
  List<Object?> get props => [];
}

class LoadPaymentMethods extends ChangePaymentMethodEvent {
  final String currentPaymentMethodId;
  const LoadPaymentMethods({required this.currentPaymentMethodId});

  @override
  List<Object?> get props => [currentPaymentMethodId];
}

class SelectPaymentMethod extends ChangePaymentMethodEvent {
  final String methodId;
  const SelectPaymentMethod(this.methodId);

  @override
  List<Object?> get props => [methodId];
}

class ConfirmChange extends ChangePaymentMethodEvent {
  const ConfirmChange();
}

class ResetState extends ChangePaymentMethodEvent {
  const ResetState();
}


class ChangePaymentMethodActionStatusEvent extends ChangePaymentMethodEvent {
  final ChangePaymentMethodActionStatus changePaymentMethodActionStatus;
  const ChangePaymentMethodActionStatusEvent({required this.changePaymentMethodActionStatus});

  @override
  List<Object?> get props => [changePaymentMethodActionStatus];
}

