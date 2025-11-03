part of 'shopping_pay_method_bloc.dart';

enum DataMethodPayStatus { initial, loading, success, failure }

enum ActionMethodPayStatus { idle, loading, success, failure }

final class ShoppingPayMethodState extends Equatable {
  final List<CardPaymentMethodEntity> savedCards;
  final String? selectedMethodId;
  final double outstandingCharges;

  // estados separados
  final DataMethodPayStatus cardsStatus; // carga de tarjetas
  final ActionMethodPayStatus paymentStatus; // proceso de pago al presionar

  // mensajes de error separados
  final String? cardsError;
  final String? paymentError;

  const ShoppingPayMethodState({
    required this.savedCards,
    required this.selectedMethodId,
    required this.outstandingCharges,
    required this.cardsStatus,
    required this.paymentStatus,
    this.cardsError,
    this.paymentError,
  });

  ShoppingPayMethodState copyWith({
    List<CardPaymentMethodEntity>? savedCards,
    String? selectedMethodId,
    double? outstandingCharges,
    DataMethodPayStatus? cardsStatus,
    ActionMethodPayStatus? paymentStatus,
    String? cardsError,
    String? paymentError,
  }) {
    return ShoppingPayMethodState(
      savedCards: savedCards ?? this.savedCards,
      selectedMethodId: selectedMethodId ?? this.selectedMethodId,
      outstandingCharges: outstandingCharges ?? this.outstandingCharges,
      cardsStatus: cardsStatus ?? this.cardsStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      cardsError: cardsError ?? this.cardsError,
      paymentError: paymentError ?? this.paymentError,
    );
  }

  @override
  List<Object?> get props => [
    savedCards,
    selectedMethodId,
    outstandingCharges,
    cardsStatus,
    paymentStatus,
    cardsError,
    paymentError,
  ];
}

final class ShoppingPayMethodInitial extends ShoppingPayMethodState {
  const ShoppingPayMethodInitial()
    : super(
        savedCards: const <CardPaymentMethodEntity>[],
        selectedMethodId: null,
        outstandingCharges: 0.0,
        cardsStatus: DataMethodPayStatus.loading,
        paymentStatus: ActionMethodPayStatus.idle,
        cardsError: null,
        paymentError: null,
      );
}
