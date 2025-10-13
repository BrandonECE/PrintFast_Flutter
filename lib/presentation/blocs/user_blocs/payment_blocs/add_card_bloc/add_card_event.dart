part of 'add_card_bloc.dart';

sealed class AddCardEvent extends Equatable {
  const AddCardEvent();

  @override
  List<Object?> get props => [];
}

final class CardHolderChanged extends AddCardEvent {
  final String cardHolder;
  const CardHolderChanged({required this.cardHolder});

  @override
  List<Object?> get props => [cardHolder];
}

/// Evento que recibe los detalles del CardForm/CardField nativo de flutter_stripe
/// (CardFieldInputDetails contiene: complete, last4, expiryMonth, expiryYear, brand, number?, cvc?)
final class CardFormChanged extends AddCardEvent {
  final CardFieldInputDetails? details;
  const CardFormChanged({required this.details});

  @override
  List<Object?> get props => [details];
}

final class ToggleDefaultCard extends AddCardEvent {
  const ToggleDefaultCard();

  @override
  List<Object?> get props => [];
}

final class SubmitCard extends AddCardEvent {
  const SubmitCard();

  @override
  List<Object?> get props => [];
}

final class ResetForm extends AddCardEvent {
  const ResetForm();

  @override
  List<Object?> get props => [];
}

final class ChangeActionAddCardStatus extends AddCardEvent {
  final ActionAddCardStatus submitStatus;
  const ChangeActionAddCardStatus({required this.submitStatus});

  @override
  List<Object?> get props => [submitStatus];
}
