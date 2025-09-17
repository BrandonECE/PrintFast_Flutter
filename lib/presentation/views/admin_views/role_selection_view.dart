import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_role_selection_bloc/admin_role_selection_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/home_bloc/home_bloc.dart';
import '../../widgets/widgets.dart';

class MyRoleSelectionView extends StatelessWidget {
  const MyRoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final homeBloc = context.read<HomeBloc>();
    final adminRoleSelectionBloc = context.read<AdminRoleSelectionBloc>();

    void navigateAsAdmin() => adminRoleSelectionBloc.selectRole(AdminRoleDestination.admin);
    void navigateAsUser() => adminRoleSelectionBloc.selectRole(AdminRoleDestination.user);
    void retryLoading() => adminRoleSelectionBloc.getAdminData();
    void goToSelectedRoute(String route) {
      context.go(route);
      adminRoleSelectionBloc.add( ChangeAdminRoleDestinationEvent(AdminRoleDestination.unknown), );
    }

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child:
                  BlocConsumer<AdminRoleSelectionBloc, AdminRoleSelectionState>(
                    listener: (context, state) {
                      if (state.adminRoleDestination ==
                          AdminRoleDestination.admin) {
                        goToSelectedRoute(Routes.adminHome);
                      } else if (state.adminRoleDestination ==
                          AdminRoleDestination.user) {
                        goToSelectedRoute(Routes.home);
                      }
                    },
                    builder: (context, state) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLogo(colorScheme),
                          const SizedBox(height: 22),
                          // Contenedor con sombra y borde redondeado
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.10),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 290),
                                  switchInCurve: Curves.easeInOut,
                                  switchOutCurve: Curves.easeInOut,
                                  transitionBuilder:
                                      (
                                        Widget child,
                                        Animation<double> animation,
                                      ) {
                                        final curved = CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeInOut,
                                        );
                                        return SizeTransition(
                                          sizeFactor: curved,
                                          axisAlignment: -1,
                                          child: ClipRect(child: child),
                                        );
                                      },
                                  layoutBuilder:
                                      (
                                        Widget? currentChild,
                                        List<Widget> previousChildren,
                                      ) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ...previousChildren,
                                            if (currentChild != null)
                                              currentChild,
                                          ],
                                        );
                                      },
                                  child: _innerSwitcherContent(
                                    context: context,
                                    state: state,
                                    userLocation: state.copyShopEntity == null
                                        ? 'CopyShopName'
                                        : state.copyShopEntity!.copyShopName,
                                    navigateAsAdmin: navigateAsAdmin,
                                    navigateAsUser: navigateAsUser,
                                    retryLoading: retryLoading,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _innerSwitcherContent({
    required BuildContext context,
    required AdminRoleSelectionState state,
    required String userLocation,
    required VoidCallback navigateAsAdmin,
    required VoidCallback navigateAsUser,
    required VoidCallback retryLoading,
  }) {
    switch (state.adminRoleSelectionStatus) {
      case AdminRoleSelectionStatus.loading:
        return KeyedSubtree(
          key: const ValueKey('loading'),
          child: Container(
            constraints: const BoxConstraints(minHeight: 200),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyLoadingIndicator(
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Cargando información...',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inverseSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      case AdminRoleSelectionStatus.success:
        return KeyedSubtree(
          key: const ValueKey('success'),
          child: _buildSuccessContent(
            context,
            userLocation,
            navigateAsAdmin,
            navigateAsUser,
          ),
        );
      case AdminRoleSelectionStatus.failure:
        return KeyedSubtree(
          key: const ValueKey('failure'),
          child: _buildFailureContent(
            context,
            userLocation,
            navigateAsUser,
            retryLoading,
          ),
        );
    }
  }

  Widget _buildSuccessContent(
    BuildContext context,
    String userLocation,
    VoidCallback navigateAsAdmin,
    VoidCallback navigateAsUser,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header compacto
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecciona el modo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tienes permisos de administrador en:',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: Theme.of(
                        context,
                      ).colorScheme.inverseSurface.withOpacity(0.66),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Tooltip(
              message: 'Rol de administrador es específico para esta ubicación',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.transparent,
                        duration: const Duration(seconds: 2),
                        elevation: 0,
                        content: MySnackBarContentWidget(
                          message:
                              'Rol de administrador es específico para $userLocation',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Badge con la ubicación
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Text(
            userLocation,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blue[700],
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Opciones de rol
        Column(
          children: [
            _buildRoleOption(
              context,
              icon: Icons.print,
              title: 'Modo Administrador',
              subtitle: 'Panel de control de $userLocation',
              color: Colors.blue,
              onTap: navigateAsAdmin,
            ),
            const SizedBox(height: 12),
            _buildRoleOption(
              context,
              icon: Icons.person_2,
              title: 'Modo Usuario',
              subtitle: 'Experiencia normal de impresión',
              color: Colors.green,
              onTap: navigateAsUser,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Divider(color: Colors.grey.shade200, height: 1),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Tu acceso como administrador es específico para esta ubicación',
            style: TextStyle(
              fontSize: 10,
              color: Colors.black.withOpacity(0.55),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildFailureContent(
    BuildContext context,
    String userLocation,
    VoidCallback navigateAsUser,
    VoidCallback retryLoading,
  ) {
    return Column(
      children: [
        const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
        const SizedBox(height: 16),
        Text(
          'Error al cargar información',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.inverseSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'No se pudo cargar la información de administrador para su uso.',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(
              context,
            ).colorScheme.inverseSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _buildRoleOption(
          context,
          icon: Icons.person_2,
          title: 'Continuar como Usuario',
          subtitle: 'Experiencia normal de impresión',
          color: Colors.green,
          onTap: navigateAsUser,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: retryLoading,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.blue),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Reintentar carga',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo(ColorScheme colorScheme) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.supervised_user_circle_rounded,
                  size: 36,
                  color: colorScheme.primary,
                ),
              ),
            ),
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'PrintFast',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Selección de modo',
          style: TextStyle(
            color: Colors.blue[100],
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
