part of 'admin_role_selection_bloc.dart';

sealed class AdminRoleSelectionEvent extends Equatable {
  const AdminRoleSelectionEvent();

  @override
  List<Object?> get props => [];
}

final class AdminRoleSelectionUserUpdated extends AdminRoleSelectionEvent {
  const AdminRoleSelectionUserUpdated({ required this.userEntity});

  final UserEntity? userEntity;

  @override
  List<Object?> get props => [userEntity];
}

final class AdminRoleSelectionCopyShopUpdated extends AdminRoleSelectionEvent {
  const AdminRoleSelectionCopyShopUpdated({required this.copyShopEntity});

  final CopyShopEntity? copyShopEntity;

  @override
  List<Object?> get props => [copyShopEntity];
}

final class AdminRoleSelectionStatusUpdated extends AdminRoleSelectionEvent {
  const AdminRoleSelectionStatusUpdated({required this.adminRoleSelectionStatus});

  final AdminRoleSelectionStatus adminRoleSelectionStatus;

  @override
  List<Object?> get props => [adminRoleSelectionStatus];
}

final class ChangeAdminRoleDestinationEvent extends AdminRoleSelectionEvent {
  final AdminRoleDestination adminRoleDestination;

  const ChangeAdminRoleDestinationEvent(this.adminRoleDestination);

  @override
  List<Object?> get props => [adminRoleDestination];
}

final class ChangeAdminRoleResetEvent extends AdminRoleSelectionEvent {

  const ChangeAdminRoleResetEvent();

  @override
  List<Object?> get props => [];
}