part of 'admin_user_payment_method_bloc.dart';

sealed class AdminSeeUserPaymentMethodEvent extends Equatable {
  const AdminSeeUserPaymentMethodEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserPaymentMethod extends AdminSeeUserPaymentMethodEvent {
  const LoadUserPaymentMethod();

  @override
  List<Object?> get props => [];
}