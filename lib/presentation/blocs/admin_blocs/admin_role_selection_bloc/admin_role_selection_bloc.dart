import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/domain/entities/all_entities/user_entity.dart';
import 'package:printfast_rebuild/domain/repositories/admin_repository.dart';

part 'admin_role_selection_event.dart';
part 'admin_role_selection_state.dart';

class AdminRoleSelectionBloc
    extends Bloc<AdminRoleSelectionEvent, AdminRoleSelectionState> {
  final AdminRepository copyshopRepository;
  AdminRoleSelectionBloc({required this.copyshopRepository})
    : super(AdminRoleSelectionInitial()) {
    on<AdminRoleSelectionUserUpdated>((event, emit) {
      emit(state.copyWith(userEntity: event.userEntity));
    });

    on<AdminRoleSelectionCopyShopUpdated>((event, emit) {
      emit(state.copyWith(copyShopEntity: event.copyShopEntity));
    });

    on<AdminRoleSelectionStatusUpdated>((event, emit) {
      emit(
        state.copyWith(
          adminRoleSelectionStatus: event.adminRoleSelectionStatus,
        ),
      );
    });

    on<ChangeAdminRoleDestinationEvent>((event, emit) {
      emit(state.copyWith(adminRoleDestination: event.adminRoleDestination));
    });

    on<ChangeAdminRoleResetEvent>((event, emit) {
      emit(AdminRoleSelectionInitial());
    });
  }

  Future<void> selectRole(AdminRoleDestination adminRoleDestination) async {
    add(
      AdminRoleSelectionStatusUpdated(
        adminRoleSelectionStatus: AdminRoleSelectionStatus.loading,
      ),
    );
    await Future.delayed(const Duration(milliseconds: 1200));
    add(ChangeAdminRoleDestinationEvent(adminRoleDestination));
  }

  Future<void> getAdminData({UserEntity? userEntityParameter}) async {
    add(
      AdminRoleSelectionStatusUpdated(
        adminRoleSelectionStatus: AdminRoleSelectionStatus.loading,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1200));

    try {
      // Usa el que ya esté en el state o el que venga como parámetro
      final userEntity = state.userEntity ?? userEntityParameter;

      if (userEntity == null) {
        throw Exception("UserEntity no disponible");
      }

      print(userEntity.adminLocationByEmail);

      final copyShopEntity = await copyshopRepository.getCopyShopInfo(
        userEntity.adminLocationByEmail,
      );

      // Actualizamos el userEntity si no estaba
      if (state.userEntity == null) {
        add(AdminRoleSelectionUserUpdated(userEntity: userEntity));
      }

      // Actualizamos la info del copyshop
      add(AdminRoleSelectionCopyShopUpdated(copyShopEntity: copyShopEntity));

      // Marcamos success
      add(
        AdminRoleSelectionStatusUpdated(
          adminRoleSelectionStatus: AdminRoleSelectionStatus.success,
        ),
      );
    } catch (e) {
      print("PRINT ERROR :$e");
      add(
        AdminRoleSelectionStatusUpdated(
          adminRoleSelectionStatus: AdminRoleSelectionStatus.failure,
        ),
      );
    }
  }
}
