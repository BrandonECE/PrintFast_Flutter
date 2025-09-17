import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/domain/repositories/auth_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AuthRepository authRepository;
  HomeBloc({required this.authRepository}) : super(HomeInitial()) {
    on<HomeChangeIndexBottomNavigationBarEvent>((event, emit) {
      emit(state.copyWith(currentIndex: event.currentIndex));
    });

    on<HomeUpdateUserEntityEvent>((event, emit) {
      emit(state.copyWith(userEntity: event.userEntity));
    });

    on<HomeUpdateSelectedOrderEvent>((event, emit) {
      emit(state.copyWith(selectedOrder: event.selectedOrder));
    });

    on<HomeUpdateHomeLogOutStatusEvent>((event, emit) {
      emit(
        state.copyWith(
          homeLogOutStatus: event.homeLogOutStatus,
          messageError: event.messageError,
        ),
      );
    });
  }

  Future<void> signOut() async {
    add(
      HomeUpdateHomeLogOutStatusEvent(
        homeLogOutStatus: HomeLogOutStatus.loading,
        messageError: null,
      ),
    );
    await Future.delayed(Duration(milliseconds: 1000));
    try {
      await authRepository.signOut();
      add(
        HomeUpdateHomeLogOutStatusEvent(
          homeLogOutStatus: HomeLogOutStatus.success,
          messageError: null,
        ),
      );
      add(HomeChangeIndexBottomNavigationBarEvent(currentIndex: 0));
    } catch (e) {
      add(
        HomeUpdateHomeLogOutStatusEvent(
          homeLogOutStatus: HomeLogOutStatus.failure,
          messageError: e.toString(),
        ),
      );
    }
  }
}
