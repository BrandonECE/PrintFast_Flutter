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

final class AdminHomeUpdateSelectedOrderEvent extends AdminHomeEvent {
  const AdminHomeUpdateSelectedOrderEvent({required this.selectedOrder});
  final AorderEntity selectedOrder;

  @override
  List<Object> get props => [selectedOrder];
}

final class AdminMonthOrderHistoryElementSelectedEvent extends AdminHomeEvent {
  const AdminMonthOrderHistoryElementSelectedEvent ({required this.monthOrderHistoryElementSelected});
  final Map<String, List<AorderEntity>> monthOrderHistoryElementSelected;

  @override
  List<Object> get props => [monthOrderHistoryElementSelected];
}


final class AdminHomeUpdateHomeLogOutStatusEvent extends AdminHomeEvent  {
  const AdminHomeUpdateHomeLogOutStatusEvent({
    required this.adminHomeLogOutStatus,
    required this.messageError,
  });
  final AdminHomeLogOutStatus adminHomeLogOutStatus;
  final String? messageError;

  @override
  List<Object?> get props => [adminHomeLogOutStatus, messageError];
}






// final class AdminHomeUpdateHomeStatusEvent extends AdminHomeEvent {
//   const AdminHomeUpdateHomeStatusEvent({required this.homeStatus, required this.messageError});
//   final HomeStatus homeStatus;
//   final String? messageError;

//   @override
//   List<Object?> get props => [homeStatus, messageError];
// }
