import 'package:flutter/material.dart';
import 'package:jetpack/jetpack.dart';
import 'dart:async';
import 'package:print_fast/firestore_service.dart';



class SharedChangeNotifier extends ChangeNotifier {
  final MutableLiveData<String> _sharedMatricula = MutableLiveData("");
  MutableLiveData<String> get sharedMatricula => _sharedMatricula;

  final MutableLiveData<int> _sharedTime = MutableLiveData(0);
  MutableLiveData<int> get sharedTime => _sharedTime;

  final MutableLiveData<int> _sharedTimeSeconds = MutableLiveData(0);
  MutableLiveData<int> get sharedTimeSeconds => _sharedTimeSeconds;

  final MutableLiveData<bool> _sharedTimeInit = MutableLiveData(false);
  MutableLiveData<bool> get sharedTimeInit => _sharedTimeInit;

  late MutableLiveData<Timer> _sharedTimePeriodic;
  MutableLiveData<Timer> get sharedPeriodic => _sharedTimePeriodic;

  void updateMatricula(String newMatricula) {
    _sharedMatricula.value = newMatricula;
  }

  void updateTime(int newTime) {
    _sharedTime.value = newTime;
    _sharedTimeSeconds.value = newTime * 60;
  }

  void updateTimeInit(bool changeTimeInit) {
    _sharedTimeInit.value = changeTimeInit;
  }

  void initTimerPeriodic() {
    _sharedTimePeriodic =
        MutableLiveData(Timer.periodic(const Duration(seconds: 1), (timer) {

      if (_sharedTimeSeconds.value == 0) {
        updateDBTime(_sharedTime.value.toString(), _sharedMatricula.value);
        print("TiempoAcabado");
        updateTime(0);
        notifyListeners();
        initTimerPeriodicCancel();
      }

      if (_sharedTimeSeconds.value % 60 == 0) {
        _sharedTime.value = _sharedTimeSeconds.value ~/ 60;
        notifyListeners();
        updateDBTime(_sharedTime.value.toString(), _sharedMatricula.value);
        print("Minutos: ${_sharedTime.value}");
      }
      --_sharedTimeSeconds.value;
      print("Segundos: ${_sharedTimeSeconds.value}");
    }));
  }

  void initTimerPeriodicCancel() {
    _sharedTimePeriodic.value.cancel();
  }

  void OrderCancel() {
    print("Orden Cancelada (Desde ViewModel)");
    initTimerPeriodicCancel();
    updateTime(0);
    updateTimeInit(false);
  }
}
