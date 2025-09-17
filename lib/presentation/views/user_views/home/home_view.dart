import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/home_bloc/home_bloc.dart';
import 'package:printfast_rebuild/presentation/views/views.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

/// MyMenu simplificado — solo diseño (sin lógica, sin constructores con params)
class MyHomeView extends StatelessWidget {
  const MyHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    // final onPrimary = Theme.of(context).colorScheme.onPrimary;
    // final width = MediaQuery.of(context).size.width;

    final List<Widget> pages = const [MyMenuView(), MySettingsView()];
    final PageController pageController = PageController(initialPage: 0);

    void onTapBottomNav(int index, HomeBloc homeBloc) {
      // Animación programática (funciona aún con swipe desactivado)
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 380),
        curve: Curves.fastLinearToSlowEaseIn,
      );
      homeBloc.add(
        HomeChangeIndexBottomNavigationBarEvent(currentIndex: index),
      );
    }

    return Scaffold(
      backgroundColor: primary,
      appBar: MyAppBarWidget(
        title: "PrintFast",
        imagePath: "assets/images/printfast_logo.png",
        imageSize: 18,
        actionIcon: Icons.notifications,
        actionIconSize: 25,
        onAction: () => context.push(Routes.notifications),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
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
    void Function(int index, HomeBloc homeBloc) onTapBottomNav,
  ) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return BottomNavigationBar(
          currentIndex: state.currentIndex,
          onTap: (value) => onTapBottomNav(value, context.read<HomeBloc>()),
          backgroundColor: Theme.of(context).colorScheme.primary,
          selectedItemColor: Colors.white,
          unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Menu"),
            BottomNavigationBarItem( icon: Icon(Icons.settings), label: "Opciones", ),
          ],
        );
      },
    );
  }
}
