part of 'live_tracking_bloc.dart';

sealed class LiveTrackingEvent extends Equatable {
  const LiveTrackingEvent();

  @override
  List<Object> get props => [];
}

class LiveTrackingMapCreated extends LiveTrackingEvent {
  final GoogleMapController controller;
  const LiveTrackingMapCreated(this.controller);

  @override
  List<Object> get props => [controller];
}

class LiveTrackingLoadData extends LiveTrackingEvent {
  const LiveTrackingLoadData();
}

class LiveTrackingUpdateUserLocation extends LiveTrackingEvent {
  final LatLng userLocation;
  const LiveTrackingUpdateUserLocation(this.userLocation);

  @override
  List<Object> get props => [userLocation];
}

class LiveTrackingFetchRoute extends LiveTrackingEvent {
  const LiveTrackingFetchRoute();
}

class LiveTrackingSetPolylines extends LiveTrackingEvent {
  final Set<Polyline> polylines;
  const LiveTrackingSetPolylines(this.polylines);

  @override
  List<Object> get props => [polylines];
}

class LiveTrackingSetErrorState extends LiveTrackingEvent {
  final String error;
  const LiveTrackingSetErrorState(this.error);

  @override
  List<Object> get props => [error];
}

class LiveTrackingRetry extends LiveTrackingEvent {
  const LiveTrackingRetry();
}

class LiveTrackingRequestPermission extends LiveTrackingEvent {
  const LiveTrackingRequestPermission();
}

class LiveTrackingCenterOnUser extends LiveTrackingEvent {
  const LiveTrackingCenterOnUser();
}

class LiveTrackingCancelOrder extends LiveTrackingEvent {
  const LiveTrackingCancelOrder();
}