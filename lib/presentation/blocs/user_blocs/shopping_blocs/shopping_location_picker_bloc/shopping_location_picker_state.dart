part of 'shopping_location_picker_bloc.dart';

enum ShoppingLocationPickerStatus { 
  loading, 
  success, 
  failure, 
  permissionDenied,
  empty 
}

final class ShoppingLocationPickerState extends Equatable {
  final List<CopyShopEntity> shops;
  final int index;
  final bool loading;
  final String? error;
  final Set<Polyline> polylines;
  final bool isFetchingRoute;
  final LatLng? currentLocation;
  final bool isGettingLocation;
  final ShoppingLocationPickerStatus status;

  const ShoppingLocationPickerState({
    required this.shops,
    required this.index,
    this.loading = false,
    this.error,
    this.polylines = const {},
    this.isFetchingRoute = false,
    this.currentLocation,
    this.isGettingLocation = false,
    this.status = ShoppingLocationPickerStatus.loading,
  });

  ShoppingLocationPickerState copyWith({
    List<CopyShopEntity>? shops,
    int? index,
    bool? loading,
    String? error,
    Set<Polyline>? polylines,
    bool? isFetchingRoute,
    LatLng? currentLocation,
    bool? isGettingLocation,
    ShoppingLocationPickerStatus? status,
  }) {
    return ShoppingLocationPickerState(
      shops: shops ?? this.shops,
      index: index ?? this.index,
      loading: loading ?? this.loading,
      error: error ?? this.error,
      polylines: polylines ?? this.polylines,
      isFetchingRoute: isFetchingRoute ?? this.isFetchingRoute,
      currentLocation: currentLocation ?? this.currentLocation,
      isGettingLocation: isGettingLocation ?? this.isGettingLocation,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        shops,
        index,
        loading,
        error,
        polylines,
        isFetchingRoute,
        currentLocation,
        isGettingLocation,
        status,
      ];
}

final class ShoppingLocationPickerInitial extends ShoppingLocationPickerState {
  ShoppingLocationPickerInitial()
      : super(
          shops: [],
          index: 0,
          loading: false,
          error: null,
          polylines: const {},
          isFetchingRoute: false,
          currentLocation: null,
          isGettingLocation: false,
          status: ShoppingLocationPickerStatus.loading,
        );
}