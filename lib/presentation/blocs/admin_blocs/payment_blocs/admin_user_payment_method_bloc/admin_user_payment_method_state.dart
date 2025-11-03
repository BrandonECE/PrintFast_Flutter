part of 'admin_user_payment_method_bloc.dart';

enum AdminSeeUserPaymentMethodStatus { loading, success, failure }

class AdminSeeUserPaymentMethodState extends Equatable {
  final AdminSeeUserPaymentMethodStatus status;
  final String? paymentMethod; // 'cash', 'card', 'not_found'
  final CardPaymentMethodEntity? card;
  final String? error;

  const AdminSeeUserPaymentMethodState({
    required this.status,
    this.paymentMethod,
    this.card,
    this.error,
  });

  AdminSeeUserPaymentMethodState copyWith({
    AdminSeeUserPaymentMethodStatus? status,
    String? paymentMethod,
    CardPaymentMethodEntity? card,
    String? error,
  }) {
    return AdminSeeUserPaymentMethodState(
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      card: card ?? this.card,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, paymentMethod, card, error];
}

class AdminSeeUserPaymentMethodInitial extends AdminSeeUserPaymentMethodState {
  const AdminSeeUserPaymentMethodInitial()
      : super(
          status: AdminSeeUserPaymentMethodStatus.loading,
          paymentMethod: null,
          card: null,
          error: null,
        );
}