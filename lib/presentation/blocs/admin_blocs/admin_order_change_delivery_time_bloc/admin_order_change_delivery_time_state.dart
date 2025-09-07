part of 'admin_order_change_delivery_time_bloc.dart';

final class AdminOrderChangeDeliveryTimeState extends Equatable {
  const AdminOrderChangeDeliveryTimeState({
    required this.showDeliveryTimeBottomSheet,
    required this.deliveryTime,
  });
  final bool showDeliveryTimeBottomSheet;
  final DateTime deliveryTime;

  AdminOrderChangeDeliveryTimeState copyWith({
    bool? showDeliveryTimeBottomSheet,
    DateTime? deliveryTime,
  }) {
    return AdminOrderChangeDeliveryTimeState(
      showDeliveryTimeBottomSheet:
          showDeliveryTimeBottomSheet ?? this.showDeliveryTimeBottomSheet,
      deliveryTime: deliveryTime ?? this.deliveryTime,
    );
  }

  @override
  List<Object> get props => [showDeliveryTimeBottomSheet, deliveryTime];
}

final class AdminOrderChangeDeliveryTimeInitial
    extends AdminOrderChangeDeliveryTimeState {
  AdminOrderChangeDeliveryTimeInitial()
    : super(showDeliveryTimeBottomSheet: false, deliveryTime: DateTime.now());
}
