import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_home_bloc/admin_home_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/message_error_warning_bloc/message_error_warning_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';
import 'package:printfast_rebuild/utils/utils.dart';

class MyAdminSettingsView extends StatelessWidget {
  const MyAdminSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final messageErrorWarningBloc = context.read<MessageErrorWarningBloc>();
    final adminHomeBloc = context.read<AdminHomeBloc>();

    // función para disparar signOut en el bloc (evita múltiples llamadas)
    void signOut() async {
      if (adminHomeBloc.state.adminHomeLogOutStatus != AdminHomeLogOutStatus.loading &&
          adminHomeBloc.state.adminHomeLogOutStatus != AdminHomeLogOutStatus.success) {
        await adminHomeBloc.signOut();
      }
    }

    void thereWasAnError(
      MessageErrorWarningBloc messageErrorWarningBloc,
      AdminHomeState state,
      AdminHomeBloc adminHomeBloc,
    ) {
       showSnackBar(context: context, title: "¡Error inesperado!", text: state.messageError ?? "",);
      adminHomeBloc.add(
        AdminHomeUpdateHomeLogOutStatusEvent(
          adminHomeLogOutStatus: AdminHomeLogOutStatus.initial,
          messageError: null,
        ),
      );
    }

    void comeBackToLoginScreen(AdminHomeBloc adminHomeBloc, BuildContext context) {
      // navegamos a login y reseteamos el estado de logout
      context.go(Routes.login);
      adminHomeBloc.add(
        AdminHomeUpdateHomeLogOutStatusEvent(
          adminHomeLogOutStatus: AdminHomeLogOutStatus.initial,
          messageError: null,
        ),
      );
    }

    return BlocListener<AdminHomeBloc, AdminHomeState>(
      listener: (context, state) {
        if (state.adminHomeLogOutStatus == AdminHomeLogOutStatus.success) {
          comeBackToLoginScreen(adminHomeBloc, context);
        }
        if (state.adminHomeLogOutStatus == AdminHomeLogOutStatus.failure) {
          thereWasAnError(messageErrorWarningBloc, state, adminHomeBloc);
        }
      },
      child: BlocBuilder<AdminHomeBloc, AdminHomeState>(
        builder: (context, state) {
          return _mySettingsScreen(width, context, state, signOut);
        },
      ),
    );
  }

  SafeArea _mySettingsScreen(
    double width,
    BuildContext context,
    AdminHomeState state,
    VoidCallback callBack,
  ) {
    // ignore: unused_local_variable
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
                Expanded(
                  child: Column(
                    children: [
                      _profileBox(context, state),
                      const SizedBox(height: 20),
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

  Widget _profileBox(BuildContext context, AdminHomeState adminHomeState) {
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
            child: Icon(Icons.local_print_shop, color: colorScheme.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      adminHomeState.copyShopEntity.copyShopName,
                      style: TextStyle(
                        color: colorScheme.inverseSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  adminHomeState.userEntity.registration,
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
    // ignore: unused_local_variable
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
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
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
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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

  Widget _detailsCard(BuildContext context, AdminHomeState adminHomeState) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final adminHomeBloc = context.read<AdminHomeBloc>();


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
              Icon(Icons.info_outline_rounded, color: colorScheme.primary, size: 20),
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
          _detailRow(context, "Email", adminHomeState.copyShopEntity.copyShopEmail),
          _detailRow(context, "Teléfono", "+52 ${adminHomeState.copyShopEntity.copyShopPhone}"),
          const SizedBox(height: 20),
          _pauseReception(
            context: context,
            isChecked: adminHomeState.copyShopEntity.pauseReception,
            onChanged: (value) {
              if(adminHomeState.receptionStatus == AdminReceptionStatus.success){
                adminHomeBloc.add(AdminHomeUpdateAdminHomeActionsEvent(adminHomeActions: AdminHomeActions.togglePauseReception));
                final String title = value! ? "Pausar Recepción" : "Reanudar Recepción";
                final String message = value ? "¿Seguro quieres pausar?" : "¿Seguro quieres reanudar?";
                showSnackBar(context: context, title: title, text: message,);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _logoutArea(
    BuildContext context,
    AdminHomeState adminHomeState,
    VoidCallback callBack,
  ) {
    final width = MediaQuery.of(context).size.width;
    // ignore: unused_local_variable
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
                side: BorderSide(color: Colors.red.withOpacity(0.2), width: 1.5),
              ),
            ),
            onPressed: callBack,
            child: _animatedSwitcherButton(adminHomeState),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Universidad Autónoma de Nuevo León",
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  AnimatedSwitcher _animatedSwitcherButton(AdminHomeState adminHomeState) {
    final isLoading = adminHomeState.adminHomeLogOutStatus == AdminHomeLogOutStatus.loading;

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
          scale: Tween<double>(begin: 0.97, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: fade,
        );
        return scale;
      },
      child: !isLoading
          ? Row(
              key: const ValueKey('admin_sign_out_text'),
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

  Widget _pauseReception({
    required bool isChecked,
    required BuildContext context,
    required ValueChanged<bool?> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pausar recepción',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.inverseSurface,
                ),
              ),
              Switch(
                value: isChecked,
                onChanged: onChanged,
                activeColor: colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Los pedidos en curso continuarán, pero no se aceptarán nuevos hasta reactivar la opción. ✅',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
