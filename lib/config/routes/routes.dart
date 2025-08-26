import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/presentation/views/views.dart';

class Routes {
  static final Routes _instance = Routes._internal();
  factory Routes() => _instance;

  late final GoRouter routes;

  static final String login = "/login";
  static final String register = "/register";
  static final String home = "/home";
  static final String notifications = "/notifications";
  static final String shopping = "/shopping";
  static final String history = "/history";
  static final String activeOrder = "/activeOrder";
  static final String historyOrder = "/historyOrder";
  static final String pdfView = "/pdfView";
  static final String locationPicker = "/locationPicker";
  static final String liveTracking = "/liveTracking";

  Routes._internal() {
    routes = GoRouter(
      initialLocation: login, // Inicio en "/login"
      routes: <GoRoute>[
        _myLogin(),
        _myRegister(),
        _myHome(),
        _myNotifications(),
        _myShopping(),
        _myHistory(),
        _myActiveOrder(),
        _myHistoryOrder(),
        _mypdfView(),
        _myLocationPicker(),
        _myLiveTracking()
      ],
    );
  }

  GoRoute _myLogin() {
    return GoRoute(
      path: login,
      pageBuilder: (context, state) {
        final fromScreen = state.name;
        print(fromScreen);

        return CustomTransitionPage(
          key: state.pageKey,
          child: const MyLoginView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // CurvedAnimation para suavizar la transición
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.fastLinearToSlowEaseIn, // Aplica una curva suave
            );

            // SlideTransition: Deslizar la pantalla desde la derecha
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1.0, 0.0), // Desde la derecha
                end: Offset.zero, // Termina en su posición normal
              ).animate(curvedAnimation),
              child: child,
            );
          },
        );
      },
    );
  }

  GoRoute _myRegister() {
    return GoRoute(
      path: register,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const MyRegisterView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // CurvedAnimation para suavizar la transición
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastLinearToSlowEaseIn, // Aplica una curva suave
          );

          // Fade + SlideTransition: Deslizar desde la izquierda y desvanecer
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0), // Desde la izquierda
              end: Offset.zero, // A su posición normal
            ).animate(curvedAnimation),
            child: child,
          );
        },
      ),
    );
  }

  GoRoute _myHome() {
    return GoRoute(
      path: home,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const MyHomeView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastEaseInToSlowEaseOut,
          );

          // Deslizar hacia abajo + Fade
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0), // Desde arriba
              end: Offset.zero, // A su posición normal
            ).animate(curvedAnimation),
            child: child,
          );
        },
      ),
    );
  }

  GoRoute _myNotifications() {
    return GoRoute(
      path: notifications,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: MyNotificationsView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // CurvedAnimation para suavizar la transición
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastEaseInToSlowEaseOut, // Aplica una curva suave
          );

          // Fade + SlideTransition: Deslizar desde la izquierda y desvanecer
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0), // Desde la izquierda
              end: Offset.zero, // A su posición normal
            ).animate(curvedAnimation),
            child: child,
          );
        },
      ),
    );
  }

  GoRoute _myShopping() {
    return GoRoute(
      path: shopping,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const MyShoppingView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // CurvedAnimation para suavizar la transición
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastEaseInToSlowEaseOut, // Aplica una curva suave
          );

          // Fade + SlideTransition: Deslizar desde la izquierda y desvanecer
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1.0, 0.0), // Desde la izquierda
              end: Offset.zero, // A su posición normal
            ).animate(curvedAnimation),
            child: child,
          );
        },
      ),
    );
  }

  GoRoute _myHistory() {
    return GoRoute(
      path: history,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const MyHistoryView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // CurvedAnimation para suavizar la transición
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastEaseInToSlowEaseOut, // Aplica una curva suave
          );

          // Fade + SlideTransition: Deslizar desde la izquierda y desvanecer
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0), // Desde la izquierda
              end: Offset.zero, // A su posición normal
            ).animate(curvedAnimation),
            child: child,
          );
        },
      ),
    );
  }

  GoRoute _myActiveOrder() {
    return GoRoute(
      path: activeOrder,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const MyActiveOrderView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastEaseInToSlowEaseOut,
          );

          // Deslizar hacia abajo + Fade
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0), // Desde arriba
              end: Offset.zero, // A su posición normal
            ).animate(curvedAnimation),
            child: child,
          );
        },
      ),
    );
  }

  GoRoute _myHistoryOrder() {
    return GoRoute(
      path: historyOrder,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const MyOrderHistoryView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // CurvedAnimation para suavizar la transición
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastEaseInToSlowEaseOut, // Aplica una curva suave
          );

          // Fade + SlideTransition: Deslizar desde la izquierda y desvanecer
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0), // Desde la izquierda
              end: Offset.zero, // A su posición normal
            ).animate(curvedAnimation),
            child: child,
          );
        },
      ),
    );
  }

  GoRoute _mypdfView() {
    return GoRoute(
      path: pdfView,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const MyPdfView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastEaseInToSlowEaseOut,
          );

          // Deslizar hacia abajo + Fade
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0), // Desde arriba
              end: Offset.zero, // A su posición normal
            ).animate(curvedAnimation),
            child: child,
          );
        },
      ),
    );
  }

  GoRoute _myLocationPicker() {
    return GoRoute(
      path: locationPicker,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const MyLocationPickerView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastEaseInToSlowEaseOut,
          );

          // Deslizar hacia abajo + Fade
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0), // Desde arriba
              end: Offset.zero, // A su posición normal
            ).animate(curvedAnimation),
            child: child,
          );
        },
      ),
    );
  }

  GoRoute _myLiveTracking() {
    return GoRoute(
      path: liveTracking,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const MyLiveTrackingView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastEaseInToSlowEaseOut,
          );

          // Deslizar hacia abajo + Fade
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0), // Desde arriba
              end: Offset.zero, // A su posición normal
            ).animate(curvedAnimation),
            child: child,
          );
        },
      ),
    );
  }
}
