
part of 'connectivity_bloc.dart';

sealed class ConnectivityEvent {}

class ConnectivityStarted extends ConnectivityEvent {}

class ConnectivityStopped extends ConnectivityEvent {}

class ConnectivityChangedEvent extends ConnectivityEvent {
  final ConnectivityResult result;
  ConnectivityChangedEvent(this.result);
}

class ConnectivityCheckRequested extends ConnectivityEvent {}
