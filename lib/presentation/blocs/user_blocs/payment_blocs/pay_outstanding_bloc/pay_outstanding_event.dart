part of 'pay_outstanding_bloc.dart';

sealed class PayOutstandingEvent extends Equatable {
  const PayOutstandingEvent();

  @override
  List<Object?> get props => [];
}

class LoadCardsForOutstanding extends PayOutstandingEvent {
  const LoadCardsForOutstanding();
}

class SelectCardForOutstanding extends PayOutstandingEvent {
  final String cardId;
  const SelectCardForOutstanding({required this.cardId});

  @override
  List<Object?> get props => [cardId];
}

class PayOutstandingAmount extends PayOutstandingEvent {
  final double amount;
  final String userRegistration;
  const PayOutstandingAmount({
    required this.amount,
    required this.userRegistration,
  });

  @override
  List<Object?> get props => [amount, userRegistration];
}

class ChangePayOutstandingStatus extends PayOutstandingEvent {
  final ActionOutstandingStatus paymentStatus;
  const ChangePayOutstandingStatus({required this.paymentStatus});

  @override
  List<Object?> get props => [paymentStatus];
}