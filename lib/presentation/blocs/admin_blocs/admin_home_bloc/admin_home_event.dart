part of 'admin_home_bloc.dart';

sealed class AdminHomeEvent extends Equatable {
  const AdminHomeEvent();

  @override
  List<Object?> get props => [];
}

final class AdminHomeChangeIndexBottomNavigationBarEvent extends AdminHomeEvent {
  const AdminHomeChangeIndexBottomNavigationBarEvent({required this.currentIndex});
  final int currentIndex;

  @override
  List<Object> get props => [currentIndex];
}

final class AdminHomeUpdateUserEntityEvent extends AdminHomeEvent {
  const AdminHomeUpdateUserEntityEvent({required this.userEntity});
  final UserEntity userEntity;

  @override
  List<Object> get props => [userEntity];
}

final class AdminHomeUpdateCopyShopEntityEvent extends AdminHomeEvent {
  const AdminHomeUpdateCopyShopEntityEvent({required this.copyShopEntity});
  final CopyShopEntity copyShopEntity;

  @override
  List<Object> get props => [copyShopEntity];
}

final class AdminHomeUpdateSelectedOrderEvent extends AdminHomeEvent {
  const AdminHomeUpdateSelectedOrderEvent({required this.selectedOrder});
  final AorderEntity selectedOrder;

  @override
  List<Object> get props => [selectedOrder];
}

final class AdminHomeUpdateHomeLogOutStatusEvent extends AdminHomeEvent {
  const AdminHomeUpdateHomeLogOutStatusEvent({
    required this.adminHomeLogOutStatus,
    required this.messageError,
  });
  final AdminHomeLogOutStatus adminHomeLogOutStatus;
  final String? messageError;

  @override
  List<Object?> get props => [adminHomeLogOutStatus, messageError];
}

// --- Eventos para aorders ---
final class AdminHomeStartAordersListenerEvent extends AdminHomeEvent {
  const AdminHomeStartAordersListenerEvent({this.copyShopEmail});
  final String? copyShopEmail;

  @override
  List<Object?> get props => [copyShopEmail];
}

final class AdminHomeStopAordersListenerEvent extends AdminHomeEvent {
  const AdminHomeStopAordersListenerEvent();

  @override
  List<Object?> get props => [];
}

final class AdminHomeUpdateAordersEvent extends AdminHomeEvent {
  const AdminHomeUpdateAordersEvent({required this.aorders});
  final List<AorderEntity> aorders;

  @override
  List<Object?> get props => [aorders];
}

final class AdminHomeAordersErrorEvent extends AdminHomeEvent {
  const AdminHomeAordersErrorEvent({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}

// --- Eventos para notificaciones ---
final class AdminHomeStartNotificationsListenerEvent extends AdminHomeEvent {
  const AdminHomeStartNotificationsListenerEvent({this.copyShopEmail});
  final String? copyShopEmail;

  @override
  List<Object?> get props => [copyShopEmail];
}

final class AdminHomeStopNotificationsListenerEvent extends AdminHomeEvent {
  const AdminHomeStopNotificationsListenerEvent();

  @override
  List<Object?> get props => [];
}

final class AdminHomeUpdateUnseenNotificationsCountEvent extends AdminHomeEvent {
  const AdminHomeUpdateUnseenNotificationsCountEvent({required this.count});
  final int count;

  @override
  List<Object?> get props => [count];
}

final class AdminHomeNotificationsErrorEvent extends AdminHomeEvent {
  const AdminHomeNotificationsErrorEvent({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}

final class AdminHomeMarkAllNotificationsAsSeenEvent extends AdminHomeEvent {
  const AdminHomeMarkAllNotificationsAsSeenEvent();

  @override
  List<Object?> get props => [];
}

// --- Eventos para reception availability ---
final class AdminHomeStartReceptionListenerEvent extends AdminHomeEvent {
  const AdminHomeStartReceptionListenerEvent({this.copyShopEmail});
  final String? copyShopEmail;

  @override
  List<Object?> get props => [copyShopEmail];
}

final class AdminHomeUpdateDataBaseReceptionValueEvent extends AdminHomeEvent {
  const AdminHomeUpdateDataBaseReceptionValueEvent({required this.copyShopReceptionAvailabilityValue});
  final bool copyShopReceptionAvailabilityValue;

  @override
  List<Object?> get props => [copyShopReceptionAvailabilityValue];
}

final class AdminHomeStopReceptionListenerEvent extends AdminHomeEvent {
  const AdminHomeStopReceptionListenerEvent();

  @override
  List<Object?> get props => [];
}

final class AdminHomeUpdateReceptionValueEvent extends AdminHomeEvent {
  const AdminHomeUpdateReceptionValueEvent({required this.pauseReception});
  final bool pauseReception;

  @override
  List<Object?> get props => [pauseReception];
}

final class AdminHomeReceptionErrorEvent extends AdminHomeEvent {
  const AdminHomeReceptionErrorEvent({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}


final class AdminHomeUpdatePendingOrderDecisionEvent extends AdminHomeEvent {
  const AdminHomeUpdatePendingOrderDecisionEvent({required this.pendingOrderDecision});
  final PendingOrderDecision pendingOrderDecision;

  @override
  List<Object?> get props => [pendingOrderDecision];
}

final class AdminHomeMakePendingOrderDecisionEvent extends AdminHomeEvent {
  const AdminHomeMakePendingOrderDecisionEvent();

  @override
  List<Object?> get props => [];
}

final class AdminHomeUpdatePendingOrderStatusEvent extends AdminHomeEvent {
  const AdminHomeUpdatePendingOrderStatusEvent({required this.pendingOrderStatus});
  final PendingOrderStatus pendingOrderStatus;

  @override
  List<Object?> get props => [pendingOrderStatus];
}

final class AdminHomeUpdateSelectedPendingOrderCodeValueEvent extends AdminHomeEvent {
  const AdminHomeUpdateSelectedPendingOrderCodeValueEvent({required this.selectedPendingOrderCode});
  final String selectedPendingOrderCode;

  @override
  List<Object?> get props => [selectedPendingOrderCode];
}


final class AdminHomeUpdateAdminHomeActionsEvent extends AdminHomeEvent {
  const AdminHomeUpdateAdminHomeActionsEvent({required this.adminHomeActions});
  final AdminHomeActions adminHomeActions;

  @override
  List<Object?> get props => [adminHomeActions];
}

final class AdminHomeUpdateReceptionStatusEvent extends AdminHomeEvent {
  const AdminHomeUpdateReceptionStatusEvent({required this.adminReceptionStatus});
  final AdminReceptionStatus adminReceptionStatus;

  @override
  List<Object?> get props => [adminReceptionStatus];
}



