// lib/presentation/blocs/user_blocs/shopping_blocs/manage_cards_bloc/manage_cards_event.dart
part of 'manage_cards_bloc.dart';

sealed class ManageCardsEvent extends Equatable {
  const ManageCardsEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserCards extends ManageCardsEvent {
  const LoadUserCards();
}

class SelectCardForAction extends ManageCardsEvent {
  final String cardId;
  const SelectCardForAction({required this.cardId});

  @override
  List<Object?> get props => [cardId];
}

class DeselectCardForAction extends ManageCardsEvent {
  final String cardId;
  const DeselectCardForAction({required this.cardId});

  @override
  List<Object?> get props => [cardId];
}

class SelectAllCards extends ManageCardsEvent {
  const SelectAllCards();
}

class DeselectAllCards extends ManageCardsEvent {
  const DeselectAllCards();
}

class SetCardAsDefault extends ManageCardsEvent {
  final String cardId;
  const SetCardAsDefault({required this.cardId});

  @override
  List<Object?> get props => [cardId];
}

class SetCashAsDefault extends ManageCardsEvent {
  const SetCashAsDefault();
}

class SaveChanges extends ManageCardsEvent {
  const SaveChanges();
}

class ResetChanges extends ManageCardsEvent {
  const ResetChanges();
}

class ChangeActionManageCardsStatusEvent extends ManageCardsEvent {
  final ActionManageCardsStatus saveStatus;
  const ChangeActionManageCardsStatusEvent({required this.saveStatus});

  @override
  List<Object?> get props => [saveStatus];
}
