import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/message_error_warning_bloc/message_error_warning_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/home_bloc/home_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/shopping_blocs/shopping_bloc/shopping_bloc.dart';
import 'package:printfast_rebuild/presentation/views/views.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

import '../../../../utils/utils.dart';

/// MyMenu simplificado — solo diseño (sin lógica, sin constructores con params)
class MyHomeView extends StatelessWidget {
  const MyHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final shoppingBloc = context.read<ShoppingBloc>();
    final messageErrorWarningBloc = context.read<MessageErrorWarningBloc>();

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

    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: _myHomeScreen(primary, context, shoppingBloc, messageErrorWarningBloc, pageController, pages, onTapBottomNav)),
           MyMessageErrorWarning(
                voidCallback: () => messageErrorWarningBloc.add(
                  ShowMessageErrorWarningEvent(showMessageErrorWarning: false),
                ),
              ),
      ],
    );
  }

  Scaffold _myHomeScreen(Color primary, BuildContext context, ShoppingBloc shoppingBloc, MessageErrorWarningBloc messageErrorWarningBloc, PageController pageController, List<Widget> pages, void Function(int index, HomeBloc homeBloc) onTapBottomNav) {
    return Scaffold(
    backgroundColor: primary,
    appBar: _myAppBar(context),
    body: _myHomeBody(
      shoppingBloc,
      messageErrorWarningBloc,
      pageController,
      pages,
    ), //MySettingsaView
    bottomNavigationBar: _myBottomNavigationBar(context, onTapBottomNav),
  );
  }

  BlocListener<ShoppingBloc, ShoppingState> _myHomeBody(
    ShoppingBloc shoppingBloc,
    MessageErrorWarningBloc messageErrorWarningBloc,
    PageController pageController,
    List<Widget> pages,
  ) {
    return BlocListener<ShoppingBloc, ShoppingState>(
      listener: (context, state) async {
        if (state.shoppingStatus == ShoppingStatus.inProgress) {
          context.go(Routes.home);
          await Future.delayed(Duration(seconds: 1), () {
            shoppingBloc.add(
              ShoppingChangeStatusEvent(shoppingStatus: ShoppingStatus.idle),
            );
          });
        } else if (state.shoppingStatus == ShoppingStatus.failure) {
          _thereWasAnError(state, shoppingBloc, context);
        } else if (state.shoppingStatus ==
            ShoppingStatus.failureByNoReception) {
          _thereWasAnError(state, shoppingBloc, context);
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return PageView(
            controller: pageController,
            physics: NeverScrollableScrollPhysics(),
            children: pages,
          );
        },
      ),
    );
  }

  MyAppBarWidget _myAppBar(BuildContext context) {
    return MyAppBarWidget(
      title: "PrintFast",
      leadingIcon: Icons.print,
      leadingIconSize: 25,
      trailingAction: Padding(
        padding: const EdgeInsets.only(right: 0),
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            final unseenNotificationsCount = state.unseenNotificationsCount;

            return GestureDetector(
              onTap: () {
                context.read<HomeBloc>().add( const HomeMarkAllNotificationsAsSeenEvent(), );
                context.push(Routes.notifications);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 210),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(
                  right: unseenNotificationsCount > 9 ? 7.0 : 0.0,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.notifications,
                      size: 26,
                      color: Colors.white,
                    ),

                    Positioned(
                      top: -4,
                      right: unseenNotificationsCount > 9 ? -9.0 : -2.0,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 210),
                        child: unseenNotificationsCount > 0
                            ? Container(
                                key: ValueKey(unseenNotificationsCount),
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 19,
                                  minHeight: 19,
                                ),
                                child: Center(
                                  child: Text(
                                    unseenNotificationsCount > 9
                                        ? "+9"
                                        : unseenNotificationsCount.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: unseenNotificationsCount > 9
                                          ? 10.5
                                          : 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      trailingOnTap: () => context.push(Routes.notifications),
    );
  }

  void _thereWasAnError(
    ShoppingState state,
    ShoppingBloc shoppingBloc,
    BuildContext context
  ) {
   showSnackBar(context: context, title: "¡Error inesperado!", text: state.messageError ?? "",);
    shoppingBloc.add(
      ShoppingChangeStatusEvent(shoppingStatus: ShoppingStatus.idle),
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
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Opciones",
            ),
          ],
        );
      },
    );
  }
}
