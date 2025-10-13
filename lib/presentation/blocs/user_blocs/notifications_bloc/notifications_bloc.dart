// lib/presentation/blocs/user_blocs/notifications_bloc/notifications_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:printfast_rebuild/domain/entities/all_entities/notification_entity.dart';
import 'package:printfast_rebuild/domain/repositories/user_repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

// lib/presentation/blocs/user_blocs/notifications_bloc/notifications_bloc.dart

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final UserRepository userRepository;
  final String registration;

  NotificationsBloc({required this.userRepository, required this.registration})
    : super(const NotificationsInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<RefreshNotifications>(_onRefreshNotifications);

    // carga inicial al crear el bloc
    add(const LoadNotifications());
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(
      state.copyWith(status: NotificationsStatus.loading, errorMessage: null),
    );
    await Future.delayed(Duration(milliseconds: 50));
    try {
      final List notifications = await userRepository.getNotifications(
        registration,
      );

      // Ordenar por dateTime descendente (más reciente primero).
      // Protegemos contra dateTime nulos: si nulo tratamos como epoch muy antiguo.
      final epoch = DateTime.fromMillisecondsSinceEpoch(0);
      final sorted = List.of(notifications);
      sorted.sort((a, b) {
        final DateTime da = (a.dateTime ?? epoch);
        final DateTime db = (b.dateTime ?? epoch);
        return db.compareTo(da); // db - da => descendente
      });

      emit(
        state.copyWith(
          status: NotificationsStatus.success,
          notifications: List<NotificationEntity>.from(sorted),
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onRefreshNotifications(
    RefreshNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(
      state.copyWith(status: NotificationsStatus.loading, errorMessage: null),
    );
    try {
      final List notifications = await userRepository.getNotifications(
        registration,
      );

      final epoch = DateTime.fromMillisecondsSinceEpoch(0);
      final sorted = List.of(notifications);
      sorted.sort((a, b) {
        final DateTime da = (a.dateTime ?? epoch);
        final DateTime db = (b.dateTime ?? epoch);
        return db.compareTo(da);
      });

      emit(
        state.copyWith(
          status: NotificationsStatus.success,
          notifications: List<NotificationEntity>.from(sorted),
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
