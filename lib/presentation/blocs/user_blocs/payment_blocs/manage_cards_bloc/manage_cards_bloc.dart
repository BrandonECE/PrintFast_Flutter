// lib/presentation/blocs/user_blocs/shopping_blocs/manage_cards_bloc/manage_cards_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:printfast_rebuild/domain/repositories/user_repository.dart';
import 'package:printfast_rebuild/domain/entities/all_entities/card_payment_method_entity.dart';

part 'manage_cards_event.dart';
part 'manage_cards_state.dart';

class ManageCardsBloc extends Bloc<ManageCardsEvent, ManageCardsState> {
  final UserRepository userRepository;
  final String registration;

  ManageCardsBloc({required this.userRepository, required this.registration})
    : super(ManageCardsInitial()) {
    on<LoadUserCards>(_onLoadUserCards);
    on<SelectCardForAction>(_onSelectCardForAction);
    on<DeselectCardForAction>(_onDeselectCardForAction);
    on<SelectAllCards>(_onSelectAllCards);
    on<DeselectAllCards>(_onDeselectAllCards);
    on<SetCardAsDefault>(_onSetCardAsDefault);
    on<SetCashAsDefault>(_onSetCashAsDefault);
    on<SaveChanges>(_onSaveChanges);
    on<ResetChanges>(_onResetChanges);
    on<ChangeActionManageCardsStatusEvent>(_onChangeActionManageCardsStatus);
  }

  // ------------------ CARGAR TARJETAS ------------------
  Future<void> _onLoadUserCards(
    LoadUserCards event,
    Emitter<ManageCardsState> emit,
  ) async {
    emit(ManageCardsInitial());
    await Future.delayed(const Duration(milliseconds: 50));

    try {
      final List<CardPaymentMethodEntity> loadedCards = await userRepository
          .getCards(registration);

      // encontrar la tarjeta predeterminada actual (o 'cash' si no hay)
      final defaultCard = loadedCards.firstWhere(
        (card) => card.isDefault == true,
        orElse: () => CardPaymentMethodEntity(
          token: 'cash',
          last4: '',
          brand: '',
          expMonth: 0,
          expYear: 0,
          isDefault: false,
        ),
      );

      final String currentDefault = defaultCard.token;

      emit(
        state.copyWith(
          userCards: loadedCards,
          originalCards: List.from(loadedCards),
          originalDefaultCardId: currentDefault,
          currentDefaultCardId: currentDefault,
          pendingDefaultCardId: currentDefault,
          loadStatus: DataManageCardsStatus.success,
          hasChanges: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loadStatus: DataManageCardsStatus.failure,
          errorMessage: 'Error al cargar tarjetas: ${e.toString()}',
        ),
      );
    }
  }

  // ------------------ SELECCIONAR TARJETA PARA ACCIÓN ------------------
  void _onSelectCardForAction(
    SelectCardForAction event,
    Emitter<ManageCardsState> emit,
  ) {
    final updatedSelectedCards = {...state.selectedCards, event.cardId};

    // Si empezamos a seleccionar para eliminar, revertir cualquier pendingDefault
    final revertedPendingDefault =
        state.originalDefaultCardId ?? state.currentDefaultCardId;

    emit(
      state.copyWith(
        selectedCards: updatedSelectedCards,
        pendingDefaultCardId: revertedPendingDefault,
        hasChanges: _checkIfHasChanges(
          state.userCards,
          updatedSelectedCards,
          revertedPendingDefault,
          state.originalCards,
          state.originalDefaultCardId,
        ),
      ),
    );
  }

  // ------------------ DESELECCIONAR TARJETA ------------------
  void _onDeselectCardForAction(
    DeselectCardForAction event,
    Emitter<ManageCardsState> emit,
  ) {
    final updatedSelectedCards = {...state.selectedCards}..remove(event.cardId);

    // Si ya no quedan seleccionadas, dejamos pendingDefault como está
    emit(
      state.copyWith(
        selectedCards: updatedSelectedCards,
        hasChanges: _checkIfHasChanges(
          state.userCards,
          updatedSelectedCards,
          state.pendingDefaultCardId,
          state.originalCards,
          state.originalDefaultCardId,
        ),
      ),
    );
  }

  // ------------------ SELECCIONAR TODAS ------------------
  void _onSelectAllCards(SelectAllCards event, Emitter<ManageCardsState> emit) {
    final allCardIds = state.userCards.map((card) => card.token).toSet();

    // revertir pendingDefault al original (porque entramos a modo eliminar)
    final revertedPendingDefault =
        state.originalDefaultCardId ?? state.currentDefaultCardId;

    emit(
      state.copyWith(
        selectedCards: allCardIds,
        pendingDefaultCardId: revertedPendingDefault,
        hasChanges: _checkIfHasChanges(
          state.userCards,
          allCardIds,
          revertedPendingDefault,
          state.originalCards,
          state.originalDefaultCardId,
        ),
      ),
    );
  }

  // ------------------ DESELECCIONAR TODAS ------------------
  void _onDeselectAllCards(
    DeselectAllCards event,
    Emitter<ManageCardsState> emit,
  ) {
    emit(
      state.copyWith(
        selectedCards: {},
        hasChanges: _checkIfHasChanges(
          state.userCards,
          {},
          state.pendingDefaultCardId,
          state.originalCards,
          state.originalDefaultCardId,
        ),
      ),
    );
  }

  // ------------------ ESTABLECER TARJETA PREDETERMINADA ------------------
  void _onSetCardAsDefault(
    SetCardAsDefault event,
    Emitter<ManageCardsState> emit,
  ) {
    // si hay selecciones activas (modo eliminar) no permitimos cambiar predeterminado
    if (state.selectedCards.isNotEmpty) return;

    emit(
      state.copyWith(
        pendingDefaultCardId: event.cardId,
        hasChanges: _checkIfHasChanges(
          state.userCards,
          state.selectedCards,
          event.cardId,
          state.originalCards,
          state.originalDefaultCardId,
        ),
      ),
    );
  }

  // ------------------ ESTABLECER EFECTIVO PREDETERMINADO ------------------
  void _onSetCashAsDefault(
    SetCashAsDefault event,
    Emitter<ManageCardsState> emit,
  ) {
    if (state.selectedCards.isNotEmpty) return;

    emit(
      state.copyWith(
        pendingDefaultCardId: 'cash',
        hasChanges: _checkIfHasChanges(
          state.userCards,
          state.selectedCards,
          'cash',
          state.originalCards,
          state.originalDefaultCardId,
        ),
      ),
    );
  }

  // ------------------ GUARDAR CAMBIOS ------------------
  Future<void> _onSaveChanges(
    SaveChanges event,
    Emitter<ManageCardsState> emit,
  ) async {
    if (!state.hasChanges) return;

    emit(state.copyWith(saveStatus: ActionManageCardsStatus.loading));

    try {
      // Si hay seleccionadas => proceso DE ELIMINACIÓN (no cambiar predet)
      if (state.selectedCards.isNotEmpty) {
        // Llamamos a la nueva función que elimina múltiples tokens en una sola transacción
        final List<String> tokensToRemove = state.selectedCards
            .where((t) => t != 'cash')
            .toList();
        if (tokensToRemove.isNotEmpty) {
          print("REMOVEEEEEEE: $tokensToRemove{}");
          await userRepository.removeCards(registration, tokensToRemove);
        }
      } else {
        print(
          "CAMBIANDO EL PENDING",
        ); // No hay eliminaciones => sólo aplicar cambio de predeterminado (si cambió)
        if (state.pendingDefaultCardId != state.originalDefaultCardId) {
          // Si pendingDefaultCardId == 'cash' -> quitar predet de todas (implementado en servicio)
          await userRepository.setDefaultCard(
            registration,
            state.pendingDefaultCardId ?? 'cash',
          );
        }
      }

      // Recargar tarjetas desde server

      emit(state.copyWith(saveStatus: ActionManageCardsStatus.success));
    } catch (e) {
      print("error");
      emit(
        state.copyWith(
          saveStatus: ActionManageCardsStatus.failure,
          errorMessage: 'Error al guardar cambios: ${e.toString()}',
        ),
      );
    }
  }

  // ------------------ REINICIAR CAMBIOS ------------------
  void _onResetChanges(ResetChanges event, Emitter<ManageCardsState> emit) {
    emit(
      state.copyWith(
        selectedCards: {},
        pendingDefaultCardId: state.currentDefaultCardId,
        hasChanges: false,
      ),
    );
  }

  // ------------------ VERIFICAR SI HAY CAMBIOS ------------------
  bool _checkIfHasChanges(
    List<CardPaymentMethodEntity> currentCards,
    Set<String> selectedCards,
    String? pendingDefault,
    List<CardPaymentMethodEntity> originalCards,
    String? originalDefault,
  ) {
    // Si hay selecciones -> hay cambios (el usuario quiere eliminar)
    final hasSelectedCards = selectedCards.isNotEmpty;

    // Cambió la tarjeta predeterminada (null-safe compare)
    final defaultChanged = pendingDefault != originalDefault;

    return hasSelectedCards || defaultChanged;
  }

  void _onChangeActionManageCardsStatus(
    ChangeActionManageCardsStatusEvent event,
    Emitter<ManageCardsState> emit,
  ) {
    emit(state.copyWith(saveStatus: event.saveStatus));
  }
}
