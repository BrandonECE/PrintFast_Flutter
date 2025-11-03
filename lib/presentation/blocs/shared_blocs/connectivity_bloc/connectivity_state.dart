part of 'connectivity_bloc.dart';


final class ConnectivityState {
  final bool hasInternet;
  final bool isChecking;
  final ConnectivityResult? lastResult;

  ConnectivityState({
    required this.hasInternet,
    required this.isChecking,
    this.lastResult,
  });

  ConnectivityState copyWith({
    bool? hasInternet,
    bool? isChecking,
    ConnectivityResult? lastResult,
  }) {
    return ConnectivityState(
      hasInternet: hasInternet ?? this.hasInternet,
      isChecking: isChecking ?? this.isChecking,
      lastResult: lastResult ?? this.lastResult,
    );
  }

  @override
  String toString() =>
      'ConnectivityState(hasInternet: $hasInternet, isChecking: $isChecking, lastResult: $lastResult)';
}
