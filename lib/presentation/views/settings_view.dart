import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/presentation/blocs/home_bloc/home_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/message_error_warning_bloc/message_error_warning_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

/// MySettingsView
/// Solo DISEÑO: StatelessWidget con parámetros para que los métodos internos funcionen.
/// Mantiene el orden que pediste: profileBox, detailsCard, logoutArea.
class MySettingsView extends StatelessWidget {
  const MySettingsView({super.key});

  // Parámetros que usarán los métodos internos

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final messageErrorWarningBloc = context.read<MessageErrorWarningBloc>();
    final homeBloc = context.read<HomeBloc>();

    void signOut() async {
    if(homeBloc.state.homeStatus != HomeStatus.loading && homeBloc.state.homeStatus != HomeStatus.success){
        await homeBloc.signOut();
      }
    }

    void thereWasAnError(MessageErrorWarningBloc messageErrorWarningBloc, HomeState state, HomeBloc homeBloc) {
       messageErrorWarningBloc.updateMessageErrorWarning(
                "¡Error inesperado!",
                state.messageError ?? "",
              );
              messageErrorWarningBloc.add(
                ShowMessageErrorWarningEvent(showMessageErrorWarning: true),
              );
              homeBloc.add(HomeUpdateHomeStatusEvent(homeStatus: HomeStatus.initial, messageError: null));
    }

    void comeBackToLoginScreen(HomeBloc homeBloc, BuildContext context) {
      homeBloc.add(HomeUpdateUserEntityEvent(userEntity: UserEntity.defaultValues()));
      context.go(Routes.login);
      homeBloc.add(HomeUpdateHomeStatusEvent(homeStatus: HomeStatus.initial, messageError: null));
    }


    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if(state.homeStatus == HomeStatus.success){
          comeBackToLoginScreen(homeBloc, context);
        }
        if(state.homeStatus == HomeStatus.failure){
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
    VoidCallback callBack
  ) {
    return SafeArea(
      child: Center(
        child: Container(
          height: double.infinity,
          alignment: Alignment.center,
          width: width * 0.95,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Container(
            margin: const EdgeInsets.only(top: 20, bottom: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top: profile header + details
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      _profileBox(context, state),
                      _detailsCard(context, state),
                    ],
                  ),
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

  // ---------- Métodos internos (reciben BuildContext) ----------

  Widget _profileBox(BuildContext context, HomeState homeState) {
    final width = MediaQuery.of(context).size.width;
    final primary = Theme.of(context).colorScheme.primary;
    final inverse = Theme.of(context).colorScheme.inverseSurface;

    return Container(
      padding: const EdgeInsets.all(20),
      width: width * 0.83,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              border: Border.all(color: primary, width: 4),
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(100)),
            ),
            child: Icon(Icons.person, color: primary, size: 25),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  homeState.userEntity.name,
                  style: TextStyle(
                    color: inverse,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  homeState.userEntity.registration,
                  style: TextStyle(
                    color: inverse,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
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
    final width = MediaQuery.of(context).size.width;
    final primary = Theme.of(context).colorScheme.primary;
    final inverse = Theme.of(context).colorScheme.inverseSurface;

    return Container(
      margin: const EdgeInsets.only(top: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // left: title + value
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: inverse,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(
                width: width * 0.45,
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          // right: edit button (visual)
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
              ),
              child: const Text(
                "Editar",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsCard(BuildContext context, HomeState homeState) {
    final width = MediaQuery.of(context).size.width;
    final inverse = Theme.of(context).colorScheme.inverseSurface;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 20),
      width: width * 0.83,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Container(
            margin: const EdgeInsets.only(bottom: 10, top: 5),
            child: Row(
              children: [
                Text(
                  "Detalles",
                  style: TextStyle(
                    color: inverse,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 2),
                  child: Icon(Icons.arrow_drop_down),
                ),
              ],
            ),
          ),

          // Detail rows
          _detailRow(context, "Nombre", homeState.userEntity.name),
          _detailRow(context, "Matricula", homeState.userEntity.registration),
          _detailRow(context, "E-mail", homeState.userEntity.email),
          _detailRow(context, "Telefono", homeState.userEntity.phone),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _logoutArea(BuildContext context, HomeState homeState, VoidCallback callBack) {
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  fixedSize: Size(width * 0.8, 60),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                onPressed: callBack,
                child: _animatedSwitcherButton(homeState)
              ),
            ),
          ),
          Text(
            "Universidad Autónoma de Nuevo León",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }

AnimatedSwitcher _animatedSwitcherButton(
  HomeState state,
) {
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
      // Fade + tiny scale for a snappy feeling
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
    child: state.homeStatus != HomeStatus.loading
        ? Row(
          key: const ValueKey('sign_out_text'),
          mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Cerrar sesión",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.logout,
                        color: Colors.redAccent,
                        size: 22,
                      ),
                    ),
                  ],
                )
    
        : MyLoadingIndicator(size: 65, color: Colors.redAccent, key: ValueKey('register_loader')),
  );
}

}
