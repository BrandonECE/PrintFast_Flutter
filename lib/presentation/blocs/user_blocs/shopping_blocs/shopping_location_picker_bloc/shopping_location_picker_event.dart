part of 'shopping_location_picker_bloc.dart';

sealed class ShoppingLocationPickerEvent extends Equatable {
  const ShoppingLocationPickerEvent();

  @override
  List<Object> get props => [];
}

class MapCreated extends ShoppingLocationPickerEvent {
  final GoogleMapController controller;
  const MapCreated(this.controller);

  @override
  List<Object> get props => [controller];
}

class NextLocation extends ShoppingLocationPickerEvent {
  const NextLocation();
}

class PreviousLocation extends ShoppingLocationPickerEvent {
  const PreviousLocation();
}

class SelectLocationIndex extends ShoppingLocationPickerEvent {
  final int index;
  const SelectLocationIndex(this.index);

  @override
  List<Object> get props => [index];
}

class FetchRouteForIndex extends ShoppingLocationPickerEvent {
  final int index;
  final LatLng? origin;
  const FetchRouteForIndex(this.index, {this.origin});

  @override
  List<Object> get props => [index, origin ?? const LatLng(0, 0)];
}

class SetPolylines extends ShoppingLocationPickerEvent {
  final Set<Polyline> polylines;
  const SetPolylines(this.polylines);

  @override
  List<Object> get props => [polylines];
}

class ClearPolylines extends ShoppingLocationPickerEvent {
  const ClearPolylines();
}

class UpdateShopDistanceInfo extends ShoppingLocationPickerEvent {
  final int index;
  final double distance;
  final int duration;
  const UpdateShopDistanceInfo(this.index, this.distance, this.duration);

  @override
  List<Object> get props => [index, distance, duration];
}

class SetLoadingState extends ShoppingLocationPickerEvent {
  final bool isLoading;
  const SetLoadingState(this.isLoading);

  @override
  List<Object> get props => [isLoading];
}

class SetFetchingRouteState extends ShoppingLocationPickerEvent {
  final bool isFetching;
  const SetFetchingRouteState(this.isFetching);

  @override
  List<Object> get props => [isFetching];
}

class SetErrorState extends ShoppingLocationPickerEvent {
  final String error;
  const SetErrorState(this.error);

  @override
  List<Object> get props => [error];
}

class GetCurrentLocation extends ShoppingLocationPickerEvent {
  const GetCurrentLocation();
}

class SetCurrentLocation extends ShoppingLocationPickerEvent {
  final LatLng currentLocation;
  const SetCurrentLocation(this.currentLocation);

  @override
  List<Object> get props => [currentLocation];
}

class UseCurrentLocationAsOrigin extends ShoppingLocationPickerEvent {
  final int index;
  const UseCurrentLocationAsOrigin(this.index);

  @override
  List<Object> get props => [index];
}

class CenterMapOnUser extends ShoppingLocationPickerEvent {
  const CenterMapOnUser();
}

class AdjustCameraToRoute extends ShoppingLocationPickerEvent {
  final LatLng origin;
  final LatLng destination;
  final List<LatLng> routePoints;
  const AdjustCameraToRoute(this.origin, this.destination, this.routePoints);

  @override
  List<Object> get props => [origin, destination, routePoints];
}

class LoadShopsData extends ShoppingLocationPickerEvent {
  const LoadShopsData();
}

class RetryLoading extends ShoppingLocationPickerEvent {
  const RetryLoading();
}

class RequestLocationPermission extends ShoppingLocationPickerEvent {
  const RequestLocationPermission();
}

class AllDataReady extends ShoppingLocationPickerEvent {
  const AllDataReady();
}

class ApplyMathematicalModel extends ShoppingLocationPickerEvent {
  const ApplyMathematicalModel();
}

class ResetAll extends ShoppingLocationPickerEvent {
  const ResetAll();
}