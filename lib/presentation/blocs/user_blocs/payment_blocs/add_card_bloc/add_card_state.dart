part of 'add_card_bloc.dart';

enum DataAddCardStatus { initial, loading, success, failure }
enum ActionAddCardStatus { idle, loading, success, failure }

final class AddCardState extends Equatable {
  final String cardHolder;

  // info que obtenemos desde CardForm (secure-managed)
  final String last4;
  final int expiryMonth;
  final int expiryYear;
  final String brand;
  final bool cardComplete;

  final bool isDefault;
  final bool isValid;

  final DataAddCardStatus formStatus;
  final ActionAddCardStatus submitStatus;

  final String? formError;
  final String? submitError;

  const AddCardState({
    required this.cardHolder,
    required this.last4,
    required this.expiryMonth,
    required this.expiryYear,
    required this.brand,
    required this.cardComplete,
    required this.isDefault,
    required this.isValid,
    required this.formStatus,
    required this.submitStatus,
    this.formError,
    this.submitError,
  });

  AddCardState copyWith({
    String? cardHolder,
    String? last4,
    int? expiryMonth,
    int? expiryYear,
    String? brand,
    bool? cardComplete,
    bool? isDefault,
    bool? isValid,
    DataAddCardStatus? formStatus,
    ActionAddCardStatus? submitStatus,
    String? formError,
    String? submitError,
  }) {
    return AddCardState(
      cardHolder: cardHolder ?? this.cardHolder,
      last4: last4 ?? this.last4,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      brand: brand ?? this.brand,
      cardComplete: cardComplete ?? this.cardComplete,
      isDefault: isDefault ?? this.isDefault,
      isValid: isValid ?? this.isValid,
      formStatus: formStatus ?? this.formStatus,
      submitStatus: submitStatus ?? this.submitStatus,
      formError: formError ?? this.formError,
      submitError: submitError ?? this.submitError,
    );
  }

  // helper para mostrar últimos 4 en la vista previa
  String get displayLastFour {
    if (last4.isEmpty) return '0000';
    final cleaned = last4.replaceAll(RegExp(r'[^0-9]'), '');
    return cleaned.padLeft(4, '0');
  }

  @override
  List<Object?> get props => [
        cardHolder,
        last4,
        expiryMonth,
        expiryYear,
        brand,
        cardComplete,
        isDefault,
        isValid,
        formStatus,
        submitStatus,
        formError,
        submitError,
      ];
}

final class AddCardInitial extends AddCardState {
  const AddCardInitial()
      : super(
          cardHolder: '',
          last4: '',
          expiryMonth: 0,
          expiryYear: 0,
          brand: '',
          cardComplete: false,
          isDefault: false,
          isValid: false,
          formStatus: DataAddCardStatus.initial,
          submitStatus: ActionAddCardStatus.idle,
          formError: null,
          submitError: null,
        );
}
