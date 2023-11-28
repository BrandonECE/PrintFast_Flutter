import 'package:flutter/material.dart';
import 'package:jetpack/jetpack.dart';
import 'package:print_fast/dirScreens/convertTime.dart';
import 'package:print_fast/dirScreens/orderHistoryInfo.dart';
import 'package:print_fast/dirScreens/orderNotificationInfo.dart';
import 'dart:async';
import 'package:print_fast/firestore_service.dart';
import 'package:print_fast/notification_service.dart';

class SharedChangeNotifier extends ChangeNotifier {
  final MutableLiveData<String> _sharedMatricula = MutableLiveData("");
  MutableLiveData<String> get sharedMatricula => _sharedMatricula;

  final MutableLiveData<int> _sharedindexSectionOrderActive =
      MutableLiveData(0);
  MutableLiveData<int> get sharedindexSectionOrderActive =>
      _sharedindexSectionOrderActive;

  final MutableLiveData<int> _sharedindexScreen = MutableLiveData(0);
  MutableLiveData<int> get sharedindexScreen => _sharedindexScreen;

  void updateScreenIndex(int newIndex) {
    _sharedindexScreen.value = newIndex;
  }

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

  // final MutableLiveData<bool> _sharedindexSectionOrderActive0 =
  //     MutableLiveData(false);
  // MutableLiveData<bool> get sharedindexSectionOrderActive0 =>
  //     _sharedindexSectionOrderActive0;

  // final MutableLiveData<bool> _sharedindexSectionOrderActive1 =
  //     MutableLiveData(false);
  // MutableLiveData<bool> get sharedindexSectionOrderActive1 =>
  //     _sharedindexSectionOrderActive1;

  // final MutableLiveData<bool> _sharedindexSectionOrderActive2 =
  //     MutableLiveData(false);
  // MutableLiveData<bool> get sharedindexSectionOrderActive2 =>
  //     _sharedindexSectionOrderActive2;

  void updateindexSectionOrderActive(int newindexSectionOrderActive) {
    _sharedindexSectionOrderActive.value = newindexSectionOrderActive;
    notifyListeners();
  }

  void updateTime(int newTime) {
    _sharedTime.value = newTime;
    _sharedTimeSeconds.value = newTime * 60;
  }

  void updateTimeInit(bool changeTimeInit) {
    _sharedTimeInit.value = changeTimeInit;
  }

  final MutableLiveData<int> _sharedIDNotification = MutableLiveData(0);
  MutableLiveData<int> get sharedIDNotification => _sharedIDNotification;

  void initTimerPeriodic() {
    int timeMitad = (_sharedTime.value / 2).round();
    bool timeMitadOnce = false;
    _sharedTimePeriodic = MutableLiveData(
        Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (_sharedTimeSeconds.value == 0) {
        ++_sharedIDNotification.value;

        showNotification(_sharedIDNotification.value,
            "¡TU PEDIDO ESTA ESPERANDO A SER RECOGIDO!");
        updateDBTime(_sharedTime.value.toString(), _sharedMatricula.value);

        String date = ConvertTime().getFecha();
        String time = ConvertTime().getHora();

        Map notificacionAviso = {
          "asunto": "ORDEN ACTIVA",
          "date": date,
          "msj": "!Pedido Esperando!",
          "time": time,
          "vista": false
        };

        updateDBUserNotis(notificacionAviso, _sharedMatricula.value);

        print("TiempoAcabado");
        updateTime(0);
        notifyListeners();
        initTimerPeriodicCancel();
      }

      if (_sharedTime.value == timeMitad && timeMitadOnce == false) {
        ++_sharedIDNotification.value;
        showNotification(_sharedIDNotification.value,
            "¡Tu pedido esta a punto de estar listo! Llega a la sucursal en ${timeMitad} minutos.");

        String date = ConvertTime().getFecha();
        String time = ConvertTime().getHora();

        Map notificacionAviso = {
          "asunto": "ORDEN ACTIVA",
          "date": date,
          "msj": "Llega en ${timeMitad} minutos.",
          "time": time,
          "vista": false
        };

        updateDBUserNotis(notificacionAviso, _sharedMatricula.value);
        timeMitadOnce = true;
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

  final MutableLiveData<bool> _sharedAddOrderToHistory = MutableLiveData(true);
  MutableLiveData<bool> get shareAddOrderToHistory => _sharedAddOrderToHistory;

  void updateAddOrderToHistory(bool newAddOrderToHistory) {
    _sharedAddOrderToHistory.value = newAddOrderToHistory;
    // notifyListeners();
  }

  void OrderCancel() {
    print("Orden Cancelada (Desde ViewModel)");
    initTimerPeriodicCancel();
    updateTime(0);
    updateTimeInit(false);
    _sharedindexSectionOrderActive.value = 0;
    notifyListeners();
  }

  ///

  final MutableLiveData<List<myOrderHistoryInfo>> _sharedorderHistoryInfo =
      MutableLiveData([]);
  MutableLiveData<List<myOrderHistoryInfo>> get sharedorderHistoryInfo =>
      _sharedorderHistoryInfo;

  static final MutableLiveData<bool> _sharedIsThereOrderHistoryInfo =
      MutableLiveData(false);
  MutableLiveData<bool> get sharedIsThereOrderHistoryInfo =>
      _sharedIsThereOrderHistoryInfo;

  void updateorderHistoryInfo(List<myOrderHistoryInfo> neworderHistoryInfo) {
    _sharedIsThereOrderHistoryInfo.value = true;
    _sharedorderHistoryInfo.value = neworderHistoryInfo;
    notifyListeners();
  }

  void updateIsThereOrderHistoryInfo(bool newIsThereOrderHistoryInfo) {
    _sharedIsThereOrderHistoryInfo.value = newIsThereOrderHistoryInfo;
    notifyListeners();
  }

  ///

  final MutableLiveData<List<myOrderNotificationInfo>> _sharedNotificationInfo =
      MutableLiveData([]);
  MutableLiveData<List<myOrderNotificationInfo>> get sharedNotificationInfo =>
      _sharedNotificationInfo;

  final MutableLiveData<bool> _sharedIsThereNotificationInfo =
      MutableLiveData(false);
  MutableLiveData<bool> get sharedIsThereNotificationInfo =>
      _sharedIsThereNotificationInfo;

  void updateNotificationInfo(
      List<myOrderNotificationInfo> newNotificationInfo) {
    _sharedIsThereNotificationInfo.value = true;
    _sharedNotificationInfo.value = newNotificationInfo;
    notifyListeners();
  }

  void updateIsThereNotificationInfo(bool newIsThereNotificationInfo) {
    _sharedIsThereNotificationInfo.value = newIsThereNotificationInfo;
    notifyListeners();
  }
}

class SharedChangeNotifierAppBarMenuCountNotification extends ChangeNotifier {
  final MutableLiveData<int> _sharedCountNotification = MutableLiveData(0);
  MutableLiveData<int> get sharedCountNotification => _sharedCountNotification;

  void updateCountNotificatione(int newCountNotification) {
    _sharedCountNotification.value = newCountNotification;
    notifyListeners();
  }

  ///
}
