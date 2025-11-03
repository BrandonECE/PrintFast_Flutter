import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:printfast_rebuild/domain/entities/all_entities/notification_entity.dart';
import 'package:printfast_rebuild/domain/repositories/admin_repository.dart';

part 'admin_notifications_event.dart';
part 'admin_notifications_state.dart';

class AdminNotificationsBloc
    extends Bloc<AdminNotificationsEvent, AdminNotificationsState> {
  final AdminRepository adminRepository;
  final String copyShopEmail;

  AdminNotificationsBloc({
    required this.adminRepository,
    required this.copyShopEmail,
  }) : super(const AdminNotificationsInitial()) {
    on<LoadAdminNotifications>(_onLoadAdminNotifications);

    // Carga inicial al crear el bloc
    add(const LoadAdminNotifications());
  }

  Future<void> _onLoadAdminNotifications(
    LoadAdminNotifications event,
    Emitter<AdminNotificationsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AdminNotificationsStatus.loading,
        errorMessage: null,
      ),
    );
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      final List notifications = await adminRepository.getCopyShopNotifications(
        copyShopEmail,
      );

      // Ordenar por dateTime descendente (más reciente primero)
      final epoch = DateTime.fromMillisecondsSinceEpoch(0);
      final sorted = List.of(notifications);
      sorted.sort((a, b) {
        final DateTime da = (a.dateTime ?? epoch);
        final DateTime db = (b.dateTime ?? epoch);
        return db.compareTo(da); // db - da => descendente
      });

      emit(
        state.copyWith(
          status: AdminNotificationsStatus.success,
          notifications: List<NotificationEntity>.from(sorted),
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AdminNotificationsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
