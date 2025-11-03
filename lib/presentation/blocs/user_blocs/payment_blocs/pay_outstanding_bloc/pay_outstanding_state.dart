part of 'pay_outstanding_bloc.dart';

enum DataOutstandingStatus { initial, loading, success, failure }
enum ActionOutstandingStatus { idle, loading, success, failure }

final class PayOutstandingState extends Equatable {
  final List<CardPaymentMethodEntity> savedCards;
  final String? selectedCardId;
  
  final DataOutstandingStatus cardsStatus;
  final ActionOutstandingStatus paymentStatus;
  
  final String? cardsError;
  final String? paymentError;

  const PayOutstandingState({
    required this.savedCards,
    required this.selectedCardId,
    required this.cardsStatus,
    required this.paymentStatus,
    this.cardsError,
    this.paymentError,
  });

  PayOutstandingState copyWith({
    List<CardPaymentMethodEntity>? savedCards,
    String? selectedCardId,
    DataOutstandingStatus? cardsStatus,
    ActionOutstandingStatus? paymentStatus,
    String? cardsError,
    String? paymentError,
  }) {
    return PayOutstandingState(
      savedCards: savedCards ?? this.savedCards,
      selectedCardId: selectedCardId ?? this.selectedCardId,
      cardsStatus: cardsStatus ?? this.cardsStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      cardsError: cardsError ?? this.cardsError,
      paymentError: paymentError ?? this.paymentError,
    );
  }

  @override
  List<Object?> get props => [
    savedCards,
    selectedCardId,
    cardsStatus,
    paymentStatus,
    cardsError,
    paymentError,
  ];
}

final class PayOutstandingInitial extends PayOutstandingState {
  const PayOutstandingInitial()
    : super(
        savedCards: const <CardPaymentMethodEntity>[],
        selectedCardId: null,
        cardsStatus: DataOutstandingStatus.loading,
        paymentStatus: ActionOutstandingStatus.idle,
        cardsError: null,
        paymentError: null,
      );
}