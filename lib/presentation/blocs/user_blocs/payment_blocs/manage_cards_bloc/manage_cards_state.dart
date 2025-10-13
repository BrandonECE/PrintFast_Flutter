// lib/presentation/blocs/user_blocs/shopping_blocs/manage_cards_bloc/manage_cards_state.dart
part of 'manage_cards_bloc.dart';

enum DataManageCardsStatus { initial, loading, success, failure }
enum ActionManageCardsStatus { idle, loading, success, failure }

final class ManageCardsState extends Equatable {
  final List<CardPaymentMethodEntity> userCards;
  final List<CardPaymentMethodEntity> originalCards;
  final Set<String> selectedCards;
  final String? currentDefaultCardId;
  final String? pendingDefaultCardId;
  final String? originalDefaultCardId;
  final DataManageCardsStatus loadStatus;
  final ActionManageCardsStatus saveStatus;
  final bool hasChanges;
  final String? errorMessage;

  const ManageCardsState({
    required this.userCards,
    required this.originalCards,
    required this.selectedCards,
    required this.currentDefaultCardId,
    required this.pendingDefaultCardId,
    required this.originalDefaultCardId,
    required this.loadStatus,
    required this.saveStatus,
    required this.hasChanges,
    this.errorMessage,
  });

  ManageCardsState copyWith({
    List<CardPaymentMethodEntity>? userCards,
    List<CardPaymentMethodEntity>? originalCards,
    Set<String>? selectedCards,
    String? currentDefaultCardId,
    String? pendingDefaultCardId,
    String? originalDefaultCardId,
    DataManageCardsStatus? loadStatus,
    ActionManageCardsStatus? saveStatus,
    bool? hasChanges,
    String? errorMessage,
  }) {
    return ManageCardsState(
      userCards: userCards ?? this.userCards,
      originalCards: originalCards ?? this.originalCards,
      selectedCards: selectedCards ?? this.selectedCards,
      currentDefaultCardId: currentDefaultCardId ?? this.currentDefaultCardId,
      pendingDefaultCardId: pendingDefaultCardId ?? this.pendingDefaultCardId,
      originalDefaultCardId: originalDefaultCardId ?? this.originalDefaultCardId,
      loadStatus: loadStatus ?? this.loadStatus,
      saveStatus: saveStatus ?? this.saveStatus,
      hasChanges: hasChanges ?? this.hasChanges,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        userCards,
        originalCards,
        selectedCards,
        currentDefaultCardId,
        pendingDefaultCardId,
        originalDefaultCardId,
        loadStatus,
        saveStatus,
        hasChanges,
        errorMessage,
      ];
}

final class ManageCardsInitial extends ManageCardsState {
  ManageCardsInitial()
      : super(
          userCards: const [],
          originalCards: const [],
          selectedCards: {},
          currentDefaultCardId: null,
          pendingDefaultCardId: null,
          originalDefaultCardId: null,
          loadStatus: DataManageCardsStatus.loading,
          saveStatus: ActionManageCardsStatus.idle,
          hasChanges: false,
        );
}
