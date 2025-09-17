import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/home_bloc/home_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/message_error_warning_bloc/message_error_warning_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

class MySettingsView extends StatelessWidget {
  const MySettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final messageErrorWarningBloc = context.read<MessageErrorWarningBloc>();
    final homeBloc = context.read<HomeBloc>();

    void signOut() async {
      if (homeBloc.state.homeLogOutStatus != HomeLogOutStatus.loading &&
          homeBloc.state.homeLogOutStatus != HomeLogOutStatus.success) {
        await homeBloc.signOut();
      }
    }

    void thereWasAnError(
      MessageErrorWarningBloc messageErrorWarningBloc,
      HomeState state,
      HomeBloc homeBloc,
    ) {
      messageErrorWarningBloc.updateMessageErrorWarning(
        "¡Error inesperado!",
        state.messageError ?? "",
      );
      messageErrorWarningBloc.add(
        ShowMessageErrorWarningEvent(showMessageErrorWarning: true),
      );
      homeBloc.add(
        HomeUpdateHomeLogOutStatusEvent(
          homeLogOutStatus: HomeLogOutStatus.initial,
          messageError: null,
        ),
      );
    }

    void comeBackToLoginScreen(HomeBloc homeBloc, BuildContext context) {
      homeBloc.add(
        HomeUpdateUserEntityEvent(userEntity: UserEntity.defaultValues),
      );
      context.go(Routes.login);
      homeBloc.add(
        HomeUpdateHomeLogOutStatusEvent(
          homeLogOutStatus: HomeLogOutStatus.initial,
          messageError: null,
        ),
      );
    }

    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state.homeLogOutStatus == HomeLogOutStatus.success) {
          comeBackToLoginScreen(homeBloc, context);
        }
        if (state.homeLogOutStatus == HomeLogOutStatus.failure) {
          thereWasAnError(messageErrorWarningBloc, state, homeBloc);
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return _mySettingsScreen(width, context, state, signOut);
        },
      ),
    );
  }

  SafeArea _mySettingsScreen(
    double width,
    BuildContext context,
    HomeState state,
    VoidCallback callBack,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Center(
        child: Container(
          width: width * 0.95,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top: profile header + details
                Column(
                  children: [
                    _profileBox(context, state),
                    const SizedBox(height: 20),
                    _detailsCard(context, state),
                  ],
                ),

                // Bottom: logout + footer
                _logoutArea(context, state, callBack),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileBox(BuildContext context, HomeState homeState) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width * 0.83,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.primary, width: 2),
            ),
            child: Icon(
              Icons.person_2_rounded,
              color: colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  homeState.userEntity.name,
                  style: TextStyle(
                    color: colorScheme.inverseSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  homeState.userEntity.registration,
                  style: TextStyle(
                    color: colorScheme.inverseSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String title, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colorScheme.inverseSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Editar"),
          ),
        ],
      ),
    );
  }

  Widget _detailsCard(BuildContext context, HomeState homeState) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width * 0.83,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Detalles",
                style: TextStyle(
                  color: colorScheme.inverseSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _detailRow(context, "Nombre", homeState.userEntity.name),
          _detailRow(context, "Matrícula", homeState.userEntity.registration),
          _detailRow(context, "E-mail", homeState.userEntity.email),
          _detailRow(context, "Teléfono", homeState.userEntity.phone),
        ],
      ),
    );
  }

  Widget _logoutArea(
    BuildContext context,
    HomeState homeState,
    VoidCallback callBack,
  ) {
    final width = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              elevation: 0,
              fixedSize: Size(width * 0.8, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Colors.red.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
            ),
            onPressed: callBack,
            child: _animatedSwitcherButton(homeState),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Universidad Autónoma de Nuevo León",
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ],
    );
  }

  AnimatedSwitcher _animatedSwitcherButton(HomeState state) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        final fade = FadeTransition(opacity: animation, child: child);
        final scale = ScaleTransition(
          scale: Tween<double>(
            begin: 0.97,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: fade,
        );
        return scale;
      },
      child: state.homeLogOutStatus != HomeLogOutStatus.loading
          ? Row(
              key: const ValueKey('sign_out_text'),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Cerrar sesión",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.logout, color: Colors.red, size: 20),
              ],
            )
          : MyLoadingIndicator(
              size: 27,
              color: Colors.red,
              key: const ValueKey('register_loader'),
            ),
    );
  }
}
