// lib/presentation/blocs/user_blocs/history_bloc/history_event.dart
part of 'history_bloc.dart';

abstract class HistoryEvent {}

class LoadHistory extends HistoryEvent {}

class SelectHistoryOrder extends HistoryEvent {
  final HorderEntity order;
  SelectHistoryOrder({required this.order});
}

class ClearSelectedHistoryOrder extends HistoryEvent {}