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
import 'package:printfast_rebuild/presentation/blocs/user_blocs/shopping_blocs/shopping_bloc/shopping_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/shopping_blocs/shopping_location_picker_bloc/shopping_location_picker_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

class MyShoppingLocationPickerView extends StatelessWidget {
  const MyShoppingLocationPickerView({super.key});

  @override
  Widget build(BuildContext context) {
    final messageErrorWarningBloc = context.read<MessageErrorWarningBloc>();

    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: _myShoppingLocationPickerScreen(context),
        ),
        MyMessageErrorWarning(
          voidCallback: () => messageErrorWarningBloc.add(
            ShowMessageErrorWarningEvent(showMessageErrorWarning: false),
          ),
        ),
      ],
    );
  }

  Widget _myShoppingLocationPickerScreen(BuildContext context) {
    try {
      final colorScheme = Theme.of(context).colorScheme;
      final width = MediaQuery.of(context).size.width;
      final height = MediaQuery.of(context).size.height;

      return BlocProvider(
        create: (context) => ShoppingLocationPickerBloc(
          totalPrice: context.read<ShoppingBloc>().state.totalPrice,
          polylineColor: colorScheme.primary,
          locationRepository: getIt<LocationRepository>(),
          userRepository: getIt<UserRepository>(),
        ),
        child: BlocListener<ShoppingBloc, ShoppingState>(
          listener: (context, state) {
            if (state.shoppingStatus == ShoppingStatus.failureByNoReception) {
              context.read<ShoppingLocationPickerBloc>().add(ResetAll());
            }
          },
          child: Scaffold(
            backgroundColor: colorScheme.primary,
            appBar: _myAppBar(context),
            body: _myBody(width, height, context),
          ),
        ),
      );
    } catch (e, stackTrace) {
      print('Error crítico en build: $e');
      print('Stack trace: $stackTrace');

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Ubicación'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text('Error al cargar la vista de ubicación'),
        ),
      );
    }
  }

  MyAppBarWidget _myAppBar(BuildContext context) {
    return MyAppBarWidget(
      title: "Ubicación",
      leadingIcon: Icons.location_on_rounded,
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

    return Stack(
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: width * 0.025),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                alignment: Alignment.center,
                width: width * 0.95,
                color: Colors.white,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.hardEdge,
                  children: [
                    // MAP + MARKERS
                    _buildGoogleMapsContainer(colorScheme),

                    // CONTENIDO INFERIOR
                    _buildBottomContentByStatusContainer(
                      panelHeight,
                      panelPadding,
                      colorScheme,
                    ),
                    // BOTÓN PARA CENTRAR EN USUARIO
                    _buildLocationIconContainer(colorScheme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  BlocBuilder<ShoppingBloc, ShoppingState> _buildBottomContentByStatusContainer(
    double panelHeight,
    double panelPadding,
    ColorScheme colorScheme,
  ) {
    return BlocBuilder<ShoppingBloc, ShoppingState>(
      buildWhen: (prev, curr) => prev.shoppingStatus != curr.shoppingStatus,
      builder: (context, shoppingState) {
        return BlocBuilder<
          ShoppingLocationPickerBloc,
          ShoppingLocationPickerState
        >(
          buildWhen: (prev, curr) =>
              prev.status != curr.status ||
              prev.error != curr.error ||
              prev.index != curr.index ||
              prev.shops != curr.shops ||
              prev.isFetchingRoute != curr.isFetchingRoute ||
              prev.isGettingLocation != curr.isGettingLocation,
          builder: (context, state) {
            final status = state.status;

            // VERIFICAR SI DEBEMOS MOSTRAR OVERLAY DE SHOPPING
            if (shoppingState.shoppingStatus == ShoppingStatus.loading ||
                shoppingState.shoppingStatus == ShoppingStatus.inProgress) {
              return AnimatedSwitcher(
                duration: Duration(
                  milliseconds:
                      (ShoppingLocationPickerBloc
                                  .translationAnimationDurationInMilliseconds *
                              1.25)
                          .round(),
                ),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final curvedAnimation = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                    reverseCurve: Curves.easeIn,
                  );

                  return FadeTransition(opacity: curvedAnimation, child: child);
                },
                child: _buildShoppingOverlayByStatus(
                  shoppingState: shoppingState,
                  context: context,
                  panelHeight: panelHeight,
                  panelPadding: panelPadding,
                  colorScheme: colorScheme,
                ),
              );
            }

            // CONTENIDO NORMAL CON ANIMATED SWITCHER
            return AnimatedSwitcher(
              duration: Duration(
                milliseconds:
                    (ShoppingLocationPickerBloc
                                .translationAnimationDurationInMilliseconds *
                            1.8)
                        .round(),
              ),
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
              child: _buildBottomContentByStatus(
                context: context,
                state: state,
                status: status,
                panelHeight: panelHeight,
                panelPadding: panelPadding,
                colorScheme: colorScheme,
              ),
            );
          },
        );
      },
    );
  }

  Positioned _buildGoogleMapsContainer(ColorScheme colorScheme) {
    return Positioned.fill(
      child: BlocBuilder<ShoppingBloc, ShoppingState>(
        buildWhen: (prev, curr) => prev.shoppingStatus != curr.shoppingStatus,
        builder: (context, stateSB) {
          return BlocBuilder<
            ShoppingLocationPickerBloc,
            ShoppingLocationPickerState
          >(
            builder: (context, stateSLPB) {
              final shopMarkerFuture = _createCustomMarker(
                Colors.white,
                colorScheme.primary,
                Colors.white,
                Icons.print,
              );
              final userMarkerFuture = _createCustomMarker(
                colorScheme.primary,
                Colors.white,
                colorScheme.primary,
                Icons.person_2_rounded,
              );

              return FutureBuilder<List<BitmapDescriptor>>(
                future: Future.wait([shopMarkerFuture, userMarkerFuture]),
                builder: (context, snapshot) {
                  final shopMarkerIcon =
                      snapshot.data?[0] ?? BitmapDescriptor.defaultMarker;
                  final userMarkerIcon =
                      snapshot.data?[1] ??
                      BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueBlue,
                      );

                  final markers = <Marker>{};

                  if (stateSLPB.currentLocation != null) {
                    markers.add(
                      Marker(
                        markerId: const MarkerId('current_location'),
                        position: stateSLPB.currentLocation!,
                        icon: userMarkerIcon,
                        infoWindow: const InfoWindow(title: 'Mi ubicación'),
                        zIndexInt: 2,
                      ),
                    );
                  }

                  for (var i = 0; i < stateSLPB.shops.length; i++) {
                    final shop = stateSLPB.shops[i];
                    markers.add(
                      Marker(
                        markerId: MarkerId('${shop.copyShopName}-$i'),
                        position: LatLng(shop.latDouble, shop.longDouble),
                        infoWindow: InfoWindow(title: shop.copyShopName),
                        icon: shopMarkerIcon,
                        onTap: () => context
                            .read<ShoppingLocationPickerBloc>()
                            .add(SelectLocationIndex(i)),
                        zIndexInt: 1,
                      ),
                    );
                  }

                  final initialCameraPosition = stateSLPB.shops.isNotEmpty
                      ? CameraPosition(
                          target: LatLng(
                            stateSLPB.shops[0].latDouble,
                            stateSLPB.shops[0].longDouble,
                          ),
                          zoom: ShoppingLocationPickerBloc.initZoom,
                        )
                      : const CameraPosition(
                          target: ShoppingLocationPickerBloc.initCoordinates,
                          zoom: ShoppingLocationPickerBloc.initZoom,
                        );

                  return _MyMapPulseWrapperWidget(
                    isLoading:
                        stateSLPB.status ==
                            ShoppingLocationPickerStatus.loading ||
                        stateSLPB.status ==
                            ShoppingLocationPickerStatus.failure ||
                        stateSLPB.status ==
                            ShoppingLocationPickerStatus.permissionDenied ||
                        stateSB.shoppingStatus == ShoppingStatus.loading ||
                        stateSB.shoppingStatus == ShoppingStatus.inProgress,
                    child: GoogleMap(
                      initialCameraPosition: initialCameraPosition,
                      markers: markers,
                      polylines:
                          (stateSLPB.isFetchingRoute ||
                              stateSLPB.currentLocation == null)
                          ? {}
                          : stateSLPB.polylines,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      onCameraMove: (position) {},
                      onMapCreated: (controller) {
                        context.read<ShoppingLocationPickerBloc>().add(
                          MapCreated(controller),
                        );
                      },
                      zoomControlsEnabled: false,
                      minMaxZoomPreference: const MinMaxZoomPreference(3, 20),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Positioned _buildLocationIconContainer(ColorScheme colorScheme) {
    return Positioned(
      top: 16,
      right: 16,
      child: BlocBuilder<ShoppingLocationPickerBloc, ShoppingLocationPickerState>(
        builder: (context, state) {
          // Solo mostrar el botón si no estamos en estado de permisos denegados
          return AnimatedSwitcher(
            duration: Duration(
              milliseconds:
                  (ShoppingLocationPickerBloc
                              .translationAnimationDurationInMilliseconds /
                          1.8)
                      .round(),
            ),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: state.status == ShoppingLocationPickerStatus.permissionDenied
                ? SizedBox.shrink()
                : _buildLocationIcon(state, context, colorScheme),
          );
        },
      ),
    );
  }

  FloatingActionButton _buildLocationIcon(
    ShoppingLocationPickerState state,
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return FloatingActionButton(
      onPressed: state.isGettingLocation || state.currentLocation == null
          ? null
          : () => context.read<ShoppingLocationPickerBloc>().add(
              CenterMapOnUser(),
            ),
      backgroundColor: colorScheme.primary,
      mini: true,
      child: AnimatedSwitcher(
        duration: Duration(
          milliseconds: ShoppingLocationPickerBloc
              .translationAnimationDurationInMilliseconds,
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
                color: state.currentLocation == null
                    ? Colors.white.withOpacity(0.5)
                    : Colors.white,
                size: 20,
              ),
      ),
    );
  }

  // MÉTODO PARA OVERLAYS DE SHOPPING (SIN ANIMATED SWITCHER)
  // MÉTODO PARA OVERLAYS DE SHOPPING (CON KEYEDSUBTREE)
  Widget _buildShoppingOverlayByStatus({
    required ShoppingState shoppingState,
    required BuildContext context,
    required double panelHeight,
    required double panelPadding,
    required ColorScheme colorScheme,
  }) {
    switch (shoppingState.shoppingStatus) {
      case ShoppingStatus.loading:
        return KeyedSubtree(
          key: const ValueKey('shopping_loading_overlay'),
          child: _buildShoppingLoadingOverlay(
            context: context,
            panelHeight: panelHeight,
            panelPadding: panelPadding,
            colorScheme: colorScheme,
          ),
        );

      case ShoppingStatus.inProgress:
        return KeyedSubtree(
          key: const ValueKey('shopping_in_progress_overlay'),
          child: _buildShoppingInProgressOverlay(
            context: context,
            panelHeight: panelHeight,
            panelPadding: panelPadding,
            colorScheme: colorScheme,
          ),
        );

      default:
        return KeyedSubtree(
          key: const ValueKey('shopping_default'),
          child: const SizedBox.shrink(),
        );
    }
  }

  // CORRECCIÓN PRINCIPAL: Estructura correcta de los estados
  Widget _buildBottomContentByStatus({
    required BuildContext context,
    required ShoppingLocationPickerState state,
    required ShoppingLocationPickerStatus status,
    required double panelHeight,
    required double panelPadding,
    required ColorScheme colorScheme,
  }) {
    // CONTENIDO NORMAL SEGÚN SHOPPING LOCATION PICKER STATUS
    switch (status) {
      case ShoppingLocationPickerStatus.loading:
        return KeyedSubtree(
          key: const ValueKey('loading_bottom'),
          child: _buildLoadingBottom(
            context: context,
            panelHeight: panelHeight,
            panelPadding: panelPadding,
            colorScheme: colorScheme,
          ),
        );

      case ShoppingLocationPickerStatus.failure:
        return KeyedSubtree(
          key: const ValueKey('failure_bottom'),
          child: _buildFailureBottom(
            context: context,
            panelHeight: panelHeight,
            panelPadding: panelPadding,
            colorScheme: colorScheme,
            errorMessage: state.error,
            onRetry: () =>
                context.read<ShoppingLocationPickerBloc>().add(RetryLoading()),
          ),
        );

      case ShoppingLocationPickerStatus.permissionDenied:
        return KeyedSubtree(
          key: const ValueKey('permission_denied_bottom'),
          child: _buildPermissionDeniedBottom(
            context: context,
            panelHeight: panelHeight,
            panelPadding: panelPadding,
            colorScheme: colorScheme,
            onRetry: () =>
                context.read<ShoppingLocationPickerBloc>().add(RetryLoading()),
          ),
        );

      case ShoppingLocationPickerStatus.empty:
        return KeyedSubtree(
          key: const ValueKey('empty_bottom'),
          child: _buildEmptyBottom(
            context: context,
            panelHeight: panelHeight,
            panelPadding: panelPadding,
            colorScheme: colorScheme,
          ),
        );

      case ShoppingLocationPickerStatus.success:
        return KeyedSubtree(
          key: const ValueKey('success_bottom'),
          child: Stack(
            children: [
              _gradientOverlay(panelHeight, panelPadding),
              _recommendedBadge(colorScheme, panelHeight, panelPadding),
              _bottomPanel(
                context: context,
                panelHeight: panelHeight,
                panelPadding: panelPadding,
                colorScheme: colorScheme,
              ),
            ],
          ),
        );
    }
  }

  // OVERLAY PARA SHOPPING LOADING
  Widget _buildShoppingLoadingOverlay({
    required BuildContext context,
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
                  'Pedido en progreso',
                  style: TextStyle(
                    color: colorScheme.inverseSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tu pedido está siendo procesado por la papelería...',
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

  // OVERLAY PARA SHOPPING IN PROGRESS
  Widget _buildShoppingInProgressOverlay({
    required BuildContext context,
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
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.schedule_rounded,
                    size: 24,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Pedido en progreso',
                  style: TextStyle(
                    color: colorScheme.inverseSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ya tienes un pedido en proceso en este momento...',
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

  // // OVERLAY PARA SHOPPING SUCCESS
  // Widget _buildShoppingSuccessOverlay({
  //   required BuildContext context,
  //   required double panelHeight,
  //   required double panelPadding,
  //   required ColorScheme colorScheme,
  // }) {
  //   return Align(
  //     alignment: Alignment.bottomCenter,
  //     child: Container(
  //       padding: EdgeInsets.all(panelPadding),
  //       child: ClipRRect(
  //         borderRadius: BorderRadius.circular(18),
  //         child: Container(
  //           width: double.infinity,
  //           height: panelHeight * 0.86,
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(18),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.black.withOpacity(0.08),
  //                 blurRadius: 12,
  //                 offset: const Offset(0, 4),
  //               ),
  //             ],
  //           ),
  //           padding: const EdgeInsets.all(16),
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Container(
  //                 width: 56,
  //                 height: 56,
  //                 decoration: BoxDecoration(
  //                   color: Colors.green.withOpacity(0.1),
  //                   shape: BoxShape.circle,
  //                 ),
  //                 child: const Icon(
  //                   Icons.check_circle_rounded,
  //                   size: 24,
  //                   color: Colors.green,
  //                 ),
  //               ),
  //               const SizedBox(height: 12),
  //               Text(
  //                 '¡Pedido exitoso!',
  //                 style: TextStyle(
  //                   color: colorScheme.inverseSurface,
  //                   fontWeight: FontWeight.w600,
  //                   fontSize: 14,
  //                 ),
  //               ),
  //               const SizedBox(height: 4),
  //               Text(
  //                 'Tu pedido ha sido realizado con éxito',
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(
  //                   color: colorScheme.inverseSurface.withOpacity(0.7),
  //                   fontSize: 12,
  //                 ),
  //               ),
  //               const SizedBox(height: 16),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Expanded(
  //                     child: SizedBox(
  //                       height: 40,
  //                       child: ElevatedButton(
  //                         onPressed: () {

  //                         },
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: colorScheme.primary,
  //                           foregroundColor: Colors.white,
  //                           padding: const EdgeInsets.symmetric(horizontal: 12),
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                           ),
  //                         ),
  //                         child: const Row(
  //                           mainAxisAlignment: MainAxisAlignment.center,
  //                           children: [
  //                             Icon(Icons.list_alt_rounded, size: 14),
  //                             SizedBox(width: 4),
  //                             Text(
  //                               "Ver pedidos",
  //                               style: TextStyle(fontSize: 12),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                   const SizedBox(width: 8),
  //                   Expanded(
  //                     child: SizedBox(
  //                       height: 40,
  //                       child: OutlinedButton(
  //                         onPressed: () {
  //                           // Volver al inicio
  //                           context.pop();
  //                         },
  //                         style: OutlinedButton.styleFrom(
  //                           side: BorderSide(color: colorScheme.primary),
  //                           padding: const EdgeInsets.symmetric(horizontal: 12),
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                           ),
  //                         ),
  //                         child: Text(
  //                           "Volver",
  //                           style: TextStyle(
  //                             color: colorScheme.primary,
  //                             fontSize: 12,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // WIDGET DE CARGA
  Widget _buildLoadingBottom({
    required BuildContext context,
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
                  'Buscando papelerías',
                  style: TextStyle(
                    color: colorScheme.inverseSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cargando información de ubicación...',
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

  // WIDGET DE ERROR
  Widget _buildFailureBottom({
    required BuildContext context,
    required double panelHeight,
    required double panelPadding,
    required ColorScheme colorScheme,
    required VoidCallback onRetry,
    String? errorMessage,
  }) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.all(panelPadding),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: panelHeight * 0.96,
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
                  'Error de carga',
                  style: TextStyle(
                    color: colorScheme.inverseSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  textAlign: TextAlign.center,
                  errorMessage ?? 'No se pudo cargar la información',
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

  // WIDGET PARA PERMISOS DENEGADOS
  Widget _buildPermissionDeniedBottom({
    required BuildContext context,
    required double panelHeight,
    required double panelPadding,
    required ColorScheme colorScheme,
    required VoidCallback onRetry,
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
                  'El permiso de ubicación está bloqueado. Actívalo en ajustes de la app.',
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

  // WIDGET PARA LISTA VACÍA
  Widget _buildEmptyBottom({
    required BuildContext context,
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
                    color: colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_off_rounded,
                    size: 24,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'No hay papelerías cerca',
                  style: TextStyle(
                    color: colorScheme.inverseSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'No encontramos papelerías disponibles en tu zona actual',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.inverseSurface.withOpacity(0.7),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => context.canPop() ? context.pop() : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back_rounded, size: 14),
                        SizedBox(width: 6),
                        Text("Volver atrás", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Método para crear marcador personalizado CON PARÁMETRO DE ICONO
  Future<BitmapDescriptor> _createCustomMarker(
    Color iconColor,
    Color backGroundColor,
    Color borderColor,
    IconData icon,
  ) async {
    try {
      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      const sizeExtra = 0.0;
      const size = 67.0 + sizeExtra;

      // Dibujar círculo de fondo
      final backgroundPaint = Paint()..color = backGroundColor;
      final borderPaint = Paint()
        ..color = borderColor
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
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: iconSize,
          fontFamily: icon.fontFamily,
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
      print('Error creando marcador personalizado: $e');
      return BitmapDescriptor.defaultMarker;
    }
  }

  // ------------------
  // Wrapper que hace pulso de opacidad mientras isLoading == true
  // ------------------
  // Añadido: _MapPulseWrapper
  // Ajusta pulseDuration o rango de opacidad si quieres personalizar
  // colocarlo aquí para que tenga acceso a imports y sea privado
  // ------------------------------------------------------------------
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

  Widget _recommendedBadge(
    ColorScheme colorScheme,
    double panelHeight,
    double panelPadding,
  ) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: panelHeight + panelPadding + 16),
        child:
            BlocBuilder<
              ShoppingLocationPickerBloc,
              ShoppingLocationPickerState
            >(
              buildWhen: (prev, curr) =>
                  prev.index != curr.index || prev.shops != curr.shops,
              builder: (context, state) {
                final isRecommended =
                    state.shops.isNotEmpty &&
                    state.shops[state.index].isRecommended;
                return AnimatedSwitcher(
                  duration: Duration(
                    milliseconds: ShoppingLocationPickerBloc
                        .translationAnimationDurationInMilliseconds,
                  ),
                  transitionBuilder: (child, anim) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(anim),
                      child: FadeTransition(opacity: anim, child: child),
                    );
                  },
                  child: isRecommended
                      ? Container(
                          key: const ValueKey('recommended_on'),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Recomendada",
                                style: TextStyle(
                                  color: colorScheme.inverseSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(
                          key: ValueKey('recommended_off'),
                          width: 0,
                          height: 0,
                        ),
                );
              },
            ),
      ),
    );
  }

  String _formatDistance(double meters) {
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

  Widget _bottomPanel({
    required BuildContext context,
    required double panelHeight,
    required double panelPadding,
    required ColorScheme colorScheme,
  }) {
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
          child: BlocBuilder<ShoppingLocationPickerBloc, ShoppingLocationPickerState>(
            builder: (context, state) {
              final hasShops = state.shops.isNotEmpty;
              final selected = hasShops ? state.shops[state.index] : null;
              final isFirst = state.index == 0;
              final isLast = state.index == state.shops.length - 1;
              final isFetchingRoute = state.isFetchingRoute;
              final hasCurrentLocation = state.currentLocation != null;
              final isGettingLocation = state.isGettingLocation;

              // Mostrar loading en la información si no hay ubicación o está cargando
              final shouldShowInfoLoading =
                  isFetchingRoute || !hasCurrentLocation || isGettingLocation;

              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _circleArrowButton(
                        icon: Icons.arrow_back_ios_rounded,
                        color: isFirst || isFetchingRoute
                            ? colorScheme.primary.withOpacity(0.3)
                            : colorScheme.primary,
                        onPressed: (isFirst || isFetchingRoute)
                            ? null
                            : () => context
                                  .read<ShoppingLocationPickerBloc>()
                                  .add(PreviousLocation()),
                      ),
                      Expanded(
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: Duration(
                              milliseconds: ShoppingLocationPickerBloc
                                  .translationAnimationDurationInMilliseconds,
                            ),
                            child: Text(
                              selected?.copyShopName ?? 'Sin papelerías',
                              key: ValueKey(selected?.copyShopName ?? 'empty'),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.inverseSurface,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                      _circleArrowButton(
                        icon: Icons.arrow_forward_ios_rounded,
                        color: isLast || isFetchingRoute
                            ? colorScheme.primary.withOpacity(0.3)
                            : colorScheme.primary,
                        onPressed: (isLast || isFetchingRoute)
                            ? null
                            : () => context
                                  .read<ShoppingLocationPickerBloc>()
                                  .add(NextLocation()),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasCurrentLocation) ...[
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
                              text: hasCurrentLocation
                                  ? "${_formatDistance(selected?.distance ?? 0)} de distancia"
                                  : "Calculando distancia...",
                              color: colorScheme.inverseSurface,
                              isLoading: shouldShowInfoLoading,
                            ),
                            const SizedBox(height: 6),
                            _buildInfoItemWithLoading(
                              icon: Icons.access_time_rounded,
                              text: hasCurrentLocation
                                  ? "${_formatDuration(selected?.duration ?? 0)} estimado"
                                  : "Calculando tiempo...",
                              color: colorScheme.inverseSurface.withOpacity(
                                0.7,
                              ),
                              isLoading: shouldShowInfoLoading,
                            ),
                            const SizedBox(height: 6),
                            _infoItem(
                              icon: Icons.people_rounded,
                              text: "${selected?.queue ?? '-'} en fila",
                              color: colorScheme.inverseSurface.withOpacity(
                                0.7,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _infoItem(
                              icon: Icons.attach_money_rounded,
                              text:
                                  "Precio: \$${selected?.price != null ? (selected!.price.toStringAsFixed(2)) : '-'}",
                              color: colorScheme.primary,
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 140,
                        child: ElevatedButton(
                          onPressed: () => context.push(
                            Routes.payMethodView,
                            extra: context.read<ShoppingLocationPickerBloc>(),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 13,
                              horizontal: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_forward_rounded, size: 17),
                              SizedBox(width: 5),
                              Text(
                                "Continuar",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItemWithLoading({
    required IconData icon,
    required String text,
    required Color color,
    required bool isLoading,
  }) {
    return AnimatedSwitcher(
      duration: Duration(
        milliseconds: ShoppingLocationPickerBloc
            .translationAnimationDurationInMilliseconds,
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

  Widget _circleArrowButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 22),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.2), width: 1),
        ),
      ),
    );
  }

  Widget _infoItem({
    Key? key,
    required IconData icon,
    required String text,
    required Color color,
    bool isBold = false,
  }) {
    return Row(
      key: key,
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
}

// ------------------
// _MapPulseWrapper (fuera de la clase para mantener organizado)
// ------------------
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

    if (oldWidget.pulseDuration != widget.pulseDuration) {
      _controller.duration = widget.pulseDuration;
    }

    if (widget.isLoading && !oldWidget.isLoading) {
      _controller.repeat(reverse: true);
    } else if (!widget.isLoading && oldWidget.isLoading) {
      // detener el repeat y animar a opacidad completa
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
        // rango de opacidad: 0.4 .. 1.0
        final double opacity = 0.45 + 0.55 * _controller.value;
        return Opacity(opacity: opacity, child: child);
      },
      child: widget.child,
    );
  }
}
