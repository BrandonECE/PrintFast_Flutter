import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_home_bloc/admin_home_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/message_error_warning_bloc/message_error_warning_bloc.dart';
import 'package:printfast_rebuild/presentation/views/admin_views/admin_home/admin_orders_history/admin_orders_history_view.dart';
import 'package:printfast_rebuild/presentation/views/admin_views/admin_home/widgets/date_range_bottom_sheet.dart';
import 'package:printfast_rebuild/presentation/views/views.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

/// MyMenu simplificado — solo diseño (sin lógica, sin constructores con params)
class MyAdminHomeView extends StatelessWidget {
  const MyAdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final messageErrorWarningBloc = context.read<MessageErrorWarningBloc>();

    // final onPrimary = Theme.of(context).colorScheme.onPrimary;
    // final width = MediaQuery.of(context).size.width;

    final PageController pageController = PageController(initialPage: 0);
    final adminHomeBloc = context.read<AdminHomeBloc>();

    void onTapBottomNav(int index) {
      // Animación programática (funciona aún con swipe desactivado)
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 380),
        curve: Curves.fastLinearToSlowEaseIn,
      );
      adminHomeBloc.add(
        AdminHomeChangeIndexBottomNavigationBarEvent(currentIndex: index),
      );
    }

    final List<Widget> pages =  [
      MyAdminOrdersView(callBack: onTapBottomNav,),
      MyAdminOrdersHistoryView(),
      MyAdminReportsView(),
      MyAdminSettingsView(),
    ];

    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: _myBody(
            primary,
            context,
            pageController,
            pages,
            onTapBottomNav,
          ),
        ),
        MyDateRangeBottomSheet(),
        MyMessageErrorWarning(
          voidCallback: () => messageErrorWarningBloc.add(
            ShowMessageErrorWarningEvent(showMessageErrorWarning: false),
          ),
        ),
      ],
    );
  }

  Scaffold _myBody(
    Color primary,
    BuildContext context,
    PageController pageController,
    List<Widget> pages,
    void Function(int index) onTapBottomNav,
  ) {
    return Scaffold(
      backgroundColor: primary,
      appBar: MyAppBarWidget(
        title: "PrintFast",
        imagePath: "assets/images/printfast_logo.png",
        imageSize: 18,
        actionIcon: Icons.notifications,
        actionIconSize: 25,
        onAction: () => context.push(Routes.adminNotifications),
      ),
      body: BlocBuilder<AdminHomeBloc, AdminHomeState>(
        builder: (context, state) {
          return PageView(
            controller: pageController,
            physics: NeverScrollableScrollPhysics(),
            children: pages,
          );
        },
      ), //MySettingsaView
      bottomNavigationBar: _myBottomNavigationBar(context, onTapBottomNav),
    );
  }

  BlocBuilder _myBottomNavigationBar(
    BuildContext context,
    void Function(int index) onTapBottomNav,
  ) {
    return BlocBuilder<AdminHomeBloc, AdminHomeState>(
      builder: (context, state) {
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: state.currentIndex,
          onTap: (value) =>
              onTapBottomNav(value),
          backgroundColor: Theme.of(context).colorScheme.primary,
          selectedItemColor: Colors.white,
          unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: "Órdenes",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: "Historial",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: "Reportes",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Ajustes",
            ),
          ],
        );
      },
    );
  }
}
