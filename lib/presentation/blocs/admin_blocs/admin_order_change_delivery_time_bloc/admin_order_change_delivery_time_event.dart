part of 'admin_order_change_delivery_time_bloc.dart';

sealed class AdminOrderChangeDeliveryTimeEvent extends Equatable {
  const AdminOrderChangeDeliveryTimeEvent();

  @override
  List<Object> get props => [];
}


final class AdminOrderShowChangeDeliveryTimeEvent extends AdminOrderChangeDeliveryTimeEvent {
 const AdminOrderShowChangeDeliveryTimeEvent({
    required this.showDeliveryTimeBottomSheet,
  });
  final bool showDeliveryTimeBottomSheet;

  @override
  List<Object> get props => [showDeliveryTimeBottomSheet];
}