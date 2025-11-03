import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/di/service_locator.dart';
import 'package:printfast_rebuild/domain/repositories/location_repository.dart';
import 'package:printfast_rebuild/domain/repositories/user_repository.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/message_error_warning_bloc/message_error_warning_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/home_bloc/home_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/live_tracking_bloc/live_tracking_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';
import 'package:printfast_rebuild/utils/utils.dart';

class MyLiveTrackingView extends StatelessWidget {
  const MyLiveTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final messageErrorWarningBloc = context.read<MessageErrorWarningBloc>();
    final homeBloc = context.read<HomeBloc>();

    return BlocProvider(
      create: (context) => LiveTrackingBloc(
        polylineColor: colorScheme.primary,
        locationRepository: getIt<LocationRepository>(),
        userRepository: getIt<UserRepository>(),
        activeOrder: context.read<HomeBloc>().state.activeOrder!,
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: _MyLiveTrackingViewContent(),
          ),

          BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (prev, curr) => prev.homeActions != curr.homeActions,
            builder: (context, state) {
              return MyMessageErrorWarning(
                voidCallback: () {
                  if (state.homeActions == HomeActions.cancelOrder) {
                    homeBloc.add(HomeCancelOrderEvent());
                    homeBloc.add(
                      HomeUpdateHomeActionsEvent(homeActions: HomeActions.none),
                    );
                    context.go(Routes.home);
                  }

                  messageErrorWarningBloc.add(
                    ShowMessageErrorWarningEvent(
                      showMessageErrorWarning: false,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MyLiveTrackingViewContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: _myAppBar(context),
      body: _myBody(width, height, context),
    );
  }

  MyAppBarWidget _myAppBar(BuildContext context) {
    return MyAppBarWidget(
      title: "Seguimiento",
      leadingIcon: Icons.directions_rounded,
      leadingIconSize: 25,
      actionIcon: Icons.close_rounded,
      actionIconSize: 25,
      onAction: () => context.canPop() ? context.pop() : null,
    );
  }

  Widget _myBody(double width, double height, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final panelHeight = height * 0.28;
    final panelPadding = 12.0;

    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: width * 0.025),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: width * 0.95,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Mapa
                _buildMapContainer(colorScheme, context),

                // Overlay degradado
                _gradientOverlay(panelHeight, panelPadding),

                // Botón de centrar en usuario (MEJORADO)
                _buildLocationIconContainer(colorScheme),

                // Panel inferior con animación
                _buildBottomContentContainer(
                  panelHeight,
                  panelPadding,
                  colorScheme,
                  context,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapContainer(ColorScheme colorScheme, BuildContext context) {
    final activeOrder = context.read<LiveTrackingBloc>().activeOrder;
    final copyShopLocation = LatLng(
      double.parse(activeOrder.placeLat),
      double.parse(activeOrder.placeLong),
    );

    return BlocBuilder<LiveTrackingBloc, LiveTrackingState>(
      builder: (context, state) {
        return FutureBuilder<BitmapDescriptor>(
          future: _createShopMarker(Colors.white, colorScheme.primary),
          builder: (context, snapshot) {
            final shopMarkerIcon =
                snapshot.data ?? BitmapDescriptor.defaultMarker;

            final markers = <Marker>{};

            // Marcador de la copyshop
            markers.add(
              Marker(
                markerId: const MarkerId('copy_shop'),
                position: copyShopLocation,
                icon: shopMarkerIcon,
                infoWindow: InfoWindow(title: activeOrder.copyShopName),
                zIndex: 2,
              ),
            );

            return _MyMapPulseWrapperWidget(
              isLoading: state.status == LiveTrackingStatus.loading,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: copyShopLocation,
                  zoom: LiveTrackingBloc.initZoom,
                ),
                markers: markers,
                polylines: state.polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                onMapCreated: (controller) {
                  context.read<LiveTrackingBloc>().add(
                    LiveTrackingMapCreated(controller),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // BOTÓN DE UBICACIÓN MEJORADO (igual que en ShoppingLocationPicker)
  Widget _buildLocationIconContainer(ColorScheme colorScheme) {
    return Positioned(
      top: 16,
      right: 16,
      child: BlocBuilder<LiveTrackingBloc, LiveTrackingState>(
        builder: (context, state) {
          // Solo mostrar el botón si no estamos en estado de permisos denegados
          return AnimatedSwitcher(
            duration: Duration(
              milliseconds:
                  (LiveTrackingBloc.translationAnimationDurationInMilliseconds /
                          1.8)
                      .round(),
            ),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: state.status == LiveTrackingStatus.permissionDenied
                ? const SizedBox.shrink()
                : _buildLocationIcon(state, context, colorScheme),
          );
        },
      ),
    );
  }

  Widget _buildLocationIcon(
    LiveTrackingState state,
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return FloatingActionButton(
      onPressed: state.isGettingLocation || state.userLocation == null
          ? null
          : () => context.read<LiveTrackingBloc>().add(
              LiveTrackingCenterOnUser(),
            ),
      backgroundColor: colorScheme.primary,
      mini: true,
      child: AnimatedSwitcher(
        duration: Duration(
          milliseconds:
              LiveTrackingBloc.translationAnimationDurationInMilliseconds,
        ),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: state.isGettingLocation
            ? SizedBox(
                width: 20,
                height: 20,
                child: MyLoadingIndicator(size: 20, color: Colors.white),
              )
            : Icon(
                Icons.my_location,
                color: state.userLocation == null
                    ? Colors.white.withOpacity(0.5)
                    : Colors.white,
                size: 20,
              ),
      ),
    );
  }

  Widget _buildBottomContentContainer(
    double panelHeight,
    double panelPadding,
    ColorScheme colorScheme,
    BuildContext context,
  ) {
    return BlocBuilder<LiveTrackingBloc, LiveTrackingState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (Widget child, Animation<double> animation) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
              reverseCurve: Curves.easeIn,
            );

            return FadeTransition(
              opacity: curvedAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1.0),
                  end: Offset.zero,
                ).animate(curvedAnimation),
                child: child,
              ),
            );
          },
          child: _contentForState(
            state,
            context,
            panelHeight,
            panelPadding,
            colorScheme,
          ),
        );
      },
    );
  }

  Widget _contentForState(
    LiveTrackingState state,
    BuildContext context,
    double panelHeight,
    double panelPadding,
    ColorScheme colorScheme,
  ) {
    switch (state.status) {
      case LiveTrackingStatus.loading:
        return KeyedSubtree(
          key: const ValueKey('loading'),
          child: _buildLoadingBottom(
            panelHeight: panelHeight,
            panelPadding: panelPadding,
            colorScheme: colorScheme,
          ),
        );

      case LiveTrackingStatus.failure:
        return KeyedSubtree(
          key: const ValueKey('failure'),
          child: _buildFailureBottom(
            context: context,
            panelHeight: panelHeight,
            panelPadding: panelPadding,
            colorScheme: colorScheme,
            errorMessage: state.error ?? 'Error desconocido',
            onRetry: () =>
                context.read<LiveTrackingBloc>().add(LiveTrackingRetry()),
          ),
        );

      case LiveTrackingStatus.permissionDenied:
        return KeyedSubtree(
          key: const ValueKey('permission_denied'),
          child: _buildPermissionDeniedBottom(
            context: context,
            panelHeight: panelHeight,
            panelPadding: panelPadding,
            colorScheme: colorScheme,
            onRetry: () => context.read<LiveTrackingBloc>().add(
              LiveTrackingRequestPermission(),
            ),
          ),
        );

      case LiveTrackingStatus.success:
        return KeyedSubtree(
          key: const ValueKey('success'),
          child: _buildSuccessBottom(
            state: state,
            panelHeight: panelHeight,
            panelPadding: panelPadding,
            colorScheme: colorScheme,
            context: context,
          ),
        );
    }
  }

  Widget _buildLoadingBottom({
    required double panelHeight,
    required double panelPadding,
    required ColorScheme colorScheme,
  }) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.all(panelPadding),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            height: panelHeight * 0.74,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: MyLoadingIndicator(
                      size: 28,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Iniciando seguimiento',
                  style: TextStyle(
                    color: colorScheme.inverseSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cargando tu ubicación y ruta...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.inverseSurface.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFailureBottom({
    required double panelHeight,
    required double panelPadding,
    required ColorScheme colorScheme,
    required String errorMessage,
    required VoidCallback onRetry,
    required BuildContext context,
  }) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.all(panelPadding),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: panelHeight * 0.86,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    size: 24,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Error de seguimiento',
                  style: TextStyle(
                    color: colorScheme.inverseSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.inverseSurface.withOpacity(0.7),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: onRetry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh_rounded, size: 14),
                              SizedBox(width: 4),
                              Text(
                                "Reintentar",
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: OutlinedButton(
                          onPressed: () =>
                              context.canPop() ? context.pop() : null,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colorScheme.primary),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Volver",
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionDeniedBottom({
    required double panelHeight,
    required double panelPadding,
    required ColorScheme colorScheme,
    required VoidCallback onRetry,
    required BuildContext context,
  }) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.all(panelPadding),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: panelHeight * 0.95,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_disabled_rounded,
                    size: 24,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ubicación requerida',
                  style: TextStyle(
                    color: colorScheme.inverseSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Necesitamos tu ubicación para el seguimiento en vivo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.inverseSurface.withOpacity(0.7),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: onRetry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on_rounded, size: 14),
                              SizedBox(width: 4),
                              Text("Permitir", style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: OutlinedButton(
                          onPressed: () =>
                              context.canPop() ? context.pop() : null,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colorScheme.primary),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Volver",
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessBottom({
    required LiveTrackingState state,
    required double panelHeight,
    required double panelPadding,
    required ColorScheme colorScheme,
    required BuildContext context,
  }) {
    final activeOrder = context.read<LiveTrackingBloc>().activeOrder;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.all(panelPadding),
        child: Container(
          height: panelHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _panelTopRow(
                placeName: activeOrder.copyShopName,
                colorScheme: colorScheme,
                state: state, // Pasamos el estado completo
              ),
              const SizedBox(height: 12),
              _panelInfoAndAction(
                colorScheme: colorScheme,
                state: state, // Pasamos el estado completo
                context: context,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MODIFICADO: Ahora recibe el estado completo
  Widget _panelTopRow({
    required String placeName,
    required ColorScheme colorScheme,
    required LiveTrackingState state,
  }) {

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, homeState) {

      Color statusColor;
      String statusMessage;
      IconData statusIcon;
      bool showLoading = state.isFetchingRoute;
      
      if (showLoading) {
        statusColor = colorScheme.primary;
        statusMessage = "Calculando tiempo...";
        statusIcon = Icons.timer_rounded;
      } else if (homeState.remainingMinutes <= 0) {
        statusColor = Colors.green;
        statusMessage = "¡Pedido listo para recoger!";
        statusIcon = Icons.check_circle_rounded;
      } else if (homeState.remainingMinutes <= 4) {
        statusColor = Colors.orange;
        statusMessage = "Listo en ~${homeState.remainingMinutes.ceil()} min";
        statusIcon = Icons.timer_rounded;
      } else {
        statusColor = colorScheme.primary;
        statusMessage = "En preparación • ${homeState.remainingMinutes.ceil()} min restantes";
        statusIcon = Icons.local_printshop_rounded;
      }

        return Column(
          children: [
            Text(
              placeName,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: colorScheme.inverseSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 14, color: statusColor),
                  const SizedBox(width: 6),
                  AnimatedSwitcher(
                    duration: Duration(
                      milliseconds: LiveTrackingBloc
                          .translationAnimationDurationInMilliseconds,
                    ),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                    child: showLoading
                        ? SizedBox(
                            key: const ValueKey('loading_indicator'),
                            width: 20,
                            height: 20,
                            child: MyLoadingIndicator(
                              size: 20,
                              color: statusColor,
                            ),
                          )
                        : Text(
                            key: ValueKey(statusMessage),
                            statusMessage,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // MODIFICADO: Ahora recibe el estado completo
  Widget _panelInfoAndAction({
    required ColorScheme colorScheme,
    required LiveTrackingState state,
    required BuildContext context,
  }) {
    final activeOrder = context.read<LiveTrackingBloc>().activeOrder;
    final showLoading = state.isFetchingRoute;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Información
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.userLocation != null) ...[
                _infoItem(
                  icon: Icons.navigation_rounded,
                  text: "Desde tu ubicación",
                  color: Colors.blue,
                  isBold: true,
                ),
                const SizedBox(height: 4),
              ],
              _buildInfoItemWithLoading(
                icon: Icons.location_on_rounded,
                text: showLoading
                    ? "Calculando distancia..."
                    : "${_formatDistance(state.remainingDistance)} de distancia",
                color: colorScheme.inverseSurface,
                isLoading: showLoading,
              ),
              const SizedBox(height: 6),
              _buildInfoItemWithLoading(
                icon: Icons.access_time_rounded,
                text: showLoading
                    ? "Calculando tiempo..."
                    : "${_formatDuration(state.remainingTime)} estimado",
                color: colorScheme.inverseSurface.withOpacity(0.7),
                isLoading: showLoading,
              ),
              const SizedBox(height: 10),
              _infoItem(
                icon: Icons.attach_money_rounded,
                text: "Total: \$${activeOrder.price.toStringAsFixed(2)}",
                color: colorScheme.primary,
                isBold: true,
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Botón de cancelar
        _cancelButton(state, context),
      ],
    );
  }

  // NUEVO: Widget para items con loading (similar al LocationPicker)
  Widget _buildInfoItemWithLoading({
    required IconData icon,
    required String text,
    required Color color,
    required bool isLoading,
  }) {
    return AnimatedSwitcher(
      duration: Duration(
        milliseconds:
            LiveTrackingBloc.translationAnimationDurationInMilliseconds,
      ),
      child: isLoading
          ? SizedBox(
              key: const ValueKey('loading'),
              height: 20,
              child: Row(
                children: [
                  Icon(icon, size: 16, color: color.withOpacity(0.5)),
                  const SizedBox(width: 8),
                  MyLoadingIndicator(size: 34, color: color.withOpacity(0.5)),
                ],
              ),
            )
          : SizedBox(
              key: const ValueKey('loaded'),
              height: 20,
              child: _infoItem(icon: icon, text: text, color: color),
            ),
    );
  }

  // _infoItem permanece igual
  Widget _infoItem({
    required IconData icon,
    required String text,
    required Color color,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _cancelButton(LiveTrackingState state, BuildContext context) {
    final homeBloc = context.read<HomeBloc>();

    return SizedBox(
      width: 125,
      child: ElevatedButton(
        onPressed: state.isCanceling
            ? null
            : () {
                // context.go(Routes.home);
                homeBloc.add(
                  HomeUpdateHomeActionsEvent(
                    homeActions: HomeActions.cancelOrder,
                  ),
                );
                showSnackBar(
                  context: context,
                  title: "¿Cancelar orden?",
                  text: "Esta acción no se puede deshacer",
                  showCancelButton: true,
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: state.isCanceling
            ? SizedBox(
                width: 20,
                height: 20,
                child: MyLoadingIndicator(size: 20, color: Colors.white),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.close_rounded, size: 18),
                  SizedBox(width: 6),
                  Text(
                    "Cancelar",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }

  String _formatDistance(int meters) {
    if (meters == 0) return '--';
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  String _formatDuration(int minutes) {
    if (minutes == 0) return '--';
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}min';
      }
    }
  }

  Widget _gradientOverlay(double panelHeight, double panelPadding) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: panelHeight + panelPadding,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(0, 255, 255, 255),
              Color.fromARGB(180, 255, 255, 255),
              Colors.white,
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
      ),
    );
  }

  Future<BitmapDescriptor> _createShopMarker(
    Color iconColor,
    Color backGroundColor,
  ) async {
    try {
      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      const sizeExtra = 0.0;
      const size = 67.0 + sizeExtra;

      // Dibujar círculo de fondo
      final backgroundPaint = Paint()..color = backGroundColor;
      final borderPaint = Paint()
        ..color = iconColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      // Dibujar el círculo principal
      canvas.drawCircle(
        Offset(size / 2, size / 2),
        size / 2 - 2,
        backgroundPaint,
      );

      // Dibujar borde
      canvas.drawCircle(Offset(size / 2, size / 2), size / 2 - 2, borderPaint);

      // Dibujar el icono en el centro
      final textPainter = TextPainter(textDirection: TextDirection.ltr);

      const iconSize = 39.0 + sizeExtra;

      textPainter.text = TextSpan(
        text: String.fromCharCode(Icons.print.codePoint),
        style: TextStyle(
          fontSize: iconSize,
          fontFamily: Icons.print.fontFamily,
          color: iconColor,
        ),
      );

      textPainter.layout();

      final offsetIcon = Offset((size - iconSize) / 2, (size - iconSize) / 2);
      textPainter.paint(canvas, offsetIcon);

      final picture = pictureRecorder.endRecording();
      final image = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('No se pudo crear el marcador');
      }

      return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
    } catch (e) {
      print('Error creando marcador de copyshop: $e');
      return BitmapDescriptor.defaultMarker;
    }
  }
}

class _MyMapPulseWrapperWidget extends StatefulWidget {
  final bool isLoading;
  final Widget child;
  final Duration pulseDuration;

  const _MyMapPulseWrapperWidget({
    required this.isLoading,
    required this.child,
    // ignore: unused_element_parameter
    this.pulseDuration = const Duration(milliseconds: 800),
  });

  @override
  State<_MyMapPulseWrapperWidget> createState() =>
      _MyMapPulseWrapperWidgetState();
}

class _MyMapPulseWrapperWidgetState extends State<_MyMapPulseWrapperWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.pulseDuration,
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    if (widget.isLoading) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant _MyMapPulseWrapperWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isLoading && !oldWidget.isLoading) {
      _controller.repeat(reverse: true);
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _controller.stop();
      _controller.animateTo(
        1.0,
        duration: const Duration(milliseconds: 775),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double opacity = 0.45 + 0.55 * _controller.value;
        return Opacity(opacity: opacity, child: child);
      },
      child: widget.child,
    );
  }
}
