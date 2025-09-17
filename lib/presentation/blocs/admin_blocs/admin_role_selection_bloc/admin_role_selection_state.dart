part of 'admin_role_selection_bloc.dart';

enum AdminRoleSelectionStatus { loading, success, failure }

enum AdminRoleDestination { unknown, user, admin }

final class AdminRoleSelectionState extends Equatable {
  const AdminRoleSelectionState({
    required this.userEntity,
    required this.copyShopEntity,
    required this.adminRoleSelectionStatus,
    required this.adminRoleDestination,
  });
  final UserEntity? userEntity;
  final CopyShopEntity? copyShopEntity;
  final AdminRoleSelectionStatus adminRoleSelectionStatus;
  final AdminRoleDestination adminRoleDestination;

  AdminRoleSelectionState copyWith({
    UserEntity? userEntity,
    CopyShopEntity? copyShopEntity,
    AdminRoleSelectionStatus? adminRoleSelectionStatus,
    AdminRoleDestination? adminRoleDestination,
  }) {
    return AdminRoleSelectionState(
      userEntity: userEntity ?? this.userEntity,
      copyShopEntity: copyShopEntity ?? this.copyShopEntity,
      adminRoleSelectionStatus:
          adminRoleSelectionStatus ?? this.adminRoleSelectionStatus,
      adminRoleDestination: adminRoleDestination ?? this.adminRoleDestination,
    );
  }

  @override
  List<Object?> get props => [
    userEntity,
    copyShopEntity,
    adminRoleSelectionStatus,
    adminRoleDestination,
  ];
}

final class AdminRoleSelectionInitial extends AdminRoleSelectionState {
  const AdminRoleSelectionInitial()
    : super(
        copyShopEntity: null,
        userEntity: null,
        adminRoleSelectionStatus: AdminRoleSelectionStatus.loading,
        adminRoleDestination: AdminRoleDestination.unknown,
      );
}
