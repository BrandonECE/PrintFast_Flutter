import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/presentation/views/views.dart';

class Routes {
  static final Routes _instance = Routes._internal();
  factory Routes() => _instance;

  late final GoRouter routes;

  static final String login = "/login";
  static final String register = "/register";

  //User
  static final String home = "/home";
  static final String notifications = "/notifications";
  static final String shopping = "/shopping";
  static final String history = "/history";
  static final String activeOrder = "/activeOrder";
  static final String codeView = "/codeView";
  static final String historyOrder = "/historyOrder";
  static final String shoppingPdfView = "/shoppingPdfView";
  static final String locationPicker = "/locationPicker";
  static final String payMethodView = "/payMethodView";
  static final String addCard = "/addCard";
  static final String liveTracking = "/liveTracking";

  //Admin

  static final String adminHome = "/adminHome";
  static final String adminNotifications = "/adminNotifications";
  static final String adminOrderView = "/adminOrderView";
  static final String adminOrderHistoryView = "/adminOrderHistoryView";
  static final String adminMonthOrdersHistorySelectedView = "/adminMonthOrdersHistorySelectedView";
  static final String adminCodeValidationView = "/adminCodeValidationView";

  //Shared
  static final String cloudStoragePdfView = "/cloudStoragePdfView";
  static final String roleSelectionView = "/roleSelectionView";

  Routes._internal() {
    routes = GoRouter(
      initialLocation: login, // Inicio en "/login"
      routes: <GoRoute>[
        //User
        _myLogin(),
        _myRegister(),
        _myHome(),
        _myNotifications(),
        _myShopping(),
        _myHistory(),
        _myActiveOrder(),
        _myCodeView(),
        _myHistoryOrder(),
        _myShoppingPdfView(),
        _myLocationPicker(),
        _myPayMethodView(),
        _myAddCard(),
        _myLiveTracking(),
        //Admin
        _myAdminHome(),
        _myAdminNotifications(),
        _myAdminOrderView(),
        _myAdminCodeValidationView(),
        _myAdminOrderHistoryView(),
        _myAdminMonthOrdersHistorySelectedView(),
        //Shared
        _myCloudStoragePdfView(),
        _myRoleSelectionView()
      ],
    );
  }

  //User

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

    GoRoute _myCodeView() {
    return GoRoute(
      path: codeView,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const MyCodeView(),
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

  GoRoute _myShoppingPdfView() {
    return GoRoute(
      path: shoppingPdfView,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const MyShoppingPdfView(),
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

  GoRoute _myPayMethodView() {
    return GoRoute(
      path: payMethodView,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const MyPayMethodView(),
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

  GoRoute _myAddCard() {
    return GoRoute(
      path: addCard,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const AddCardView(),
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

  //Admin

  GoRoute _myAdminHome() {
    return GoRoute(
      path: adminHome,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const MyAdminHomeView(),
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

  GoRoute _myAdminNotifications() {
    return GoRoute(
      path: adminNotifications,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: MyAdminNotificationsView(),
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

  GoRoute _myAdminOrderView() {
    return GoRoute(
      path: adminOrderView,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const MyAdminOrderView(),
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

  GoRoute _myAdminCodeValidationView() {
    return GoRoute(
      path: adminCodeValidationView,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const MyAdminCodeValidationView(),
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

  GoRoute _myAdminOrderHistoryView() {
    return GoRoute(
      path: adminOrderHistoryView,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const MyAdminOrderHistoryView(),
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

  GoRoute _myAdminMonthOrdersHistorySelectedView() {
    return GoRoute(
      path: adminMonthOrdersHistorySelectedView,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: MyAdminMonthOrdersHistorySelectedView(),
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


  //Shared

  GoRoute _myCloudStoragePdfView() {
    return GoRoute(
      path: cloudStoragePdfView,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const MyCloudStoragePdfView(),
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

  GoRoute _myRoleSelectionView() {
    return GoRoute(
      path: roleSelectionView,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const MyRoleSelectionView(),
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

