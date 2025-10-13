part of 'change_payment_method_bloc.dart';

enum ChangePaymentMethodStatus { initial, loading, success, failure }
enum ChangePaymentMethodActionStatus { idle, loading, success, failure }

final class ChangePaymentMethodState extends Equatable {
  final List<CardPaymentMethodEntity> savedCards;
  final String? currentMethodId;
  final String? selectedMethodId;
  final CardPaymentMethodEntity? currentMethodCard;
  final ChangePaymentMethodStatus status;
  final ChangePaymentMethodActionStatus changeStatus;
  final String? error;

  const ChangePaymentMethodState({
    required this.savedCards,
    required this.currentMethodId,
    required this.selectedMethodId,
    required this.currentMethodCard,
    required this.status,
    required this.changeStatus,
    this.error,
  });

  ChangePaymentMethodState copyWith({
    List<CardPaymentMethodEntity>? savedCards,
    String? currentMethodId,
    String? selectedMethodId,
    CardPaymentMethodEntity? currentMethodCard,
    ChangePaymentMethodStatus? status,
    ChangePaymentMethodActionStatus? changeStatus,
    String? error,
  }) {
    return ChangePaymentMethodState(
      savedCards: savedCards ?? this.savedCards,
      currentMethodId: currentMethodId ?? this.currentMethodId,
      selectedMethodId: selectedMethodId ?? this.selectedMethodId,
      currentMethodCard: currentMethodCard ?? this.currentMethodCard,
      status: status ?? this.status,
      changeStatus: changeStatus ?? this.changeStatus,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        savedCards,
        currentMethodId,
        selectedMethodId,
        currentMethodCard,
        status,
        changeStatus,
        error,
      ];
}

final class ChangePaymentMethodInitial extends ChangePaymentMethodState {
  const ChangePaymentMethodInitial()
      : super(
          savedCards: const [],
          currentMethodId: null,
          selectedMethodId: null,
          currentMethodCard: null,
          status: ChangePaymentMethodStatus.initial,
          changeStatus: ChangePaymentMethodActionStatus.idle,
        );
}