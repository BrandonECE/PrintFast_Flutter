part of 'live_tracking_bloc.dart';

enum LiveTrackingStatus { loading, success, failure, permissionDenied }

final class LiveTrackingState extends Equatable {
  final LiveTrackingStatus status;
  final String? error;
  final LatLng? userLocation;
  final Set<Polyline> polylines;
  final int remainingTime;
  final int remainingDistance;
  final bool isCanceling;
  final bool isCanceled;
  final bool isGettingLocation;
  final bool isFetchingRoute; // NUEVO: para controlar loading de ruta

  const LiveTrackingState({
    required this.status,
    this.error,
    this.userLocation,
    this.polylines = const {},
    this.remainingTime = 0,
    this.remainingDistance = 0,
    this.isCanceling = false,
    this.isCanceled = false,
    this.isGettingLocation = false,
    this.isFetchingRoute = false, // Inicializado en false
  });

  LiveTrackingState copyWith({
    LiveTrackingStatus? status,
    String? error,
    LatLng? userLocation,
    Set<Polyline>? polylines,
    int? remainingTime,
    int? remainingDistance,
    bool? isCanceling,
    bool? isCanceled,
    bool? isGettingLocation,
    bool? isFetchingRoute, // NUEVO en copyWith
  }) {
    return LiveTrackingState(
      status: status ?? this.status,
      error: error ?? this.error,
      userLocation: userLocation ?? this.userLocation,
      polylines: polylines ?? this.polylines,
      remainingTime: remainingTime ?? this.remainingTime,
      remainingDistance: remainingDistance ?? this.remainingDistance,
      isCanceling: isCanceling ?? this.isCanceling,
      isCanceled: isCanceled ?? this.isCanceled,
      isGettingLocation: isGettingLocation ?? this.isGettingLocation,
      isFetchingRoute: isFetchingRoute ?? this.isFetchingRoute,
    );
  }

  @override
  List<Object?> get props => [
        status,
        error,
        userLocation,
        polylines,
        remainingTime,
        remainingDistance,
        isCanceling,
        isCanceled,
        isGettingLocation,
        isFetchingRoute, // Agregar a props
      ];
}

final class LiveTrackingInitial extends LiveTrackingState {
  LiveTrackingInitial()
      : super(
          status: LiveTrackingStatus.loading,
          error: null,
          userLocation: null,
          polylines: const {},
          remainingTime: 0,
          remainingDistance: 0,
          isCanceling: false,
          isCanceled: false,
          isGettingLocation: false,
          isFetchingRoute: false,
        );
}