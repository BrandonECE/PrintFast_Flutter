import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/di/service_locator.dart';
import 'package:printfast_rebuild/domain/repositories/admin_repository.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_change_report_date_range_bloc/admin_change_report_date_range_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_home_bloc/admin_home_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_reports_bloc/admin_reports_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/cloud_storage_pdf_bloc.dart/cloud_storage_pdf_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/message_error_warning_bloc/message_error_warning_bloc.dart';
import 'package:printfast_rebuild/presentation/views/admin_views/admin_home/admin_orders_history/admin_orders_history_view.dart';
import 'package:printfast_rebuild/presentation/views/admin_views/admin_home/admin_reports/widgets/date_range_bottom_sheet.dart';
import 'package:printfast_rebuild/presentation/views/views.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

import '../../../../utils/utils.dart';

class MyAdminHomeView extends StatelessWidget {
  const MyAdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final messageErrorWarningBloc = context.read<MessageErrorWarningBloc>();
    final copyShopEmail = context
        .read<AdminHomeBloc>()
        .state
        .userEntity
        .adminLocationByEmail;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AdminChangeReportDateRangeBloc()),
        BlocProvider(
          create: (context) =>
              AdminReportsBloc(
                emailCopyShop: copyShopEmail,
                adminRepository: getIt<AdminRepository>(),
              )..add(
                LoadAdminReports(
                  startDate: DateTime.now().subtract(const Duration(days: 7)),
                  endDate: DateTime.now(),
                ),
              ),
        ),
      ],
      child: _MyAdminHomeScreen(
        primary: primary,
        messageErrorWarningBloc: messageErrorWarningBloc,
      ),
    );
  }
}

class _MyAdminHomeScreen extends StatelessWidget {
  const _MyAdminHomeScreen({
    required this.primary,
    required this.messageErrorWarningBloc,
  });
  final Color primary;
  final MessageErrorWarningBloc messageErrorWarningBloc;

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController(initialPage: 0);
    final adminHomeBloc = context.read<AdminHomeBloc>();
    final adminReportsBloc = context.read<AdminReportsBloc>();
    final cloudStoragePdfViewBloc = context.read<CloudStoragePdfBloc>();
    final messageErrorWarningBloc = context.read<MessageErrorWarningBloc>();
    void onTapBottomNav(int index) {
      if (adminHomeBloc.state.currentIndex == index) {
        return;
      }

      if (index == 2) {
        //is MyAdminReportsView
        adminReportsBloc.add(
          LoadAdminReports(
            startDate: adminReportsBloc.state.report.startDate,
            endDate: adminReportsBloc.state.report.endDate,
          ),
        );
      }
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 380),
        curve: Curves.fastLinearToSlowEaseIn,
      );
      adminHomeBloc.add(
        AdminHomeChangeIndexBottomNavigationBarEvent(currentIndex: index),
      );
    }

    final List<Widget> pages = [
      MyAdminOrdersView(callBack: onTapBottomNav),
      MyAdminOrdersHistoryView(),
      MyAdminReportsView(),
      MyAdminSettingsView(),
    ];

    void handleErrorToPrint() {
      adminHomeBloc.add( AdminHomeUpdateAdminHomeActionsEvent( adminHomeActions: AdminHomeActions.none, ), );
      showSnackBar( context: context, title: "¡Error de impresión!", text: "No se pudo cargar el documento", );
      messageErrorWarningBloc.add( ShowMessageErrorWarningEvent(showMessageErrorWarning: true), );
      cloudStoragePdfViewBloc.add( ChangeStatusPdfFileFromCloudStorageToPrintEvent( cloudStoragePrintPdfStatus: CloudStoragePrintPdfStatus.initial, ), );
    }


    return BlocListener<CloudStoragePdfBloc, CloudStoragePdfState>(
      listenWhen: (prev, curr) =>
          prev.cloudStoragePrintPdfStatus != curr.cloudStoragePrintPdfStatus,
      listener: (context, state) {
       if (state.cloudStoragePrintPdfStatus ==
            CloudStoragePrintPdfStatus.failure) {

          handleErrorToPrint();
        }
      },
      child: BlocListener<AdminHomeBloc, AdminHomeState>(
        listenWhen: (prev, curr) =>
            prev.pendingOrderStatus != curr.pendingOrderStatus ||
            prev.receptionStatus != curr.receptionStatus,
        listener: (context, state) {
          final adminReceptionStatus = state.receptionStatus;
          if (adminReceptionStatus == AdminReceptionStatus.requestFailure) {
            _thereWasAnError(
              context,
              "¡Error inesperado!",
              state.receptionErrorMessage ?? "",
            );
          }

          final adminPendingOrderStatus = state.pendingOrderStatus;
          if (adminPendingOrderStatus != PendingOrderStatus.loading) {
            if (adminPendingOrderStatus == PendingOrderStatus.failure) {
              _thereWasAnError(
                context,
                "¡Error inesperado!",
                state.pendingOrderErrorMessage ?? "",
              );
              adminHomeBloc.add(
                AdminHomeUpdatePendingOrderStatusEvent(
                  pendingOrderStatus: PendingOrderStatus.idle,
                ),
              );
            } else if (adminPendingOrderStatus == PendingOrderStatus.success) {
              adminHomeBloc.add(
                AdminHomeUpdatePendingOrderStatusEvent(
                  pendingOrderStatus: PendingOrderStatus.idle,
                ),
              );
            }
          }
        },
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: _myAdminHomeScreen(
                primary,
                context,
                pageController,
                pages,
                onTapBottomNav,
              ),
            ),
            const MyDateRangeBottomSheet(),
            MyMessageErrorWarning(
              voidCallback: () async {
                if (adminHomeBloc.state.adminHomeActions ==
                    AdminHomeActions.togglePauseReception) {
                  _togglePauseReceptionFailureHandle(
                    adminHomeBloc,
                    onTapBottomNav,
                  );
                } else if (adminHomeBloc.state.adminHomeActions ==
                        AdminHomeActions.makePendingOrderDecision &&
                    adminHomeBloc.state.pendingOrderDecision !=
                        PendingOrderDecision.none &&
                    adminHomeBloc.state.pendingOrderStatus !=
                        PendingOrderStatus.idle) {
                  _makePendingOrderDecisionFailureHandle(adminHomeBloc);
                }

                messageErrorWarningBloc.add(
                  ShowMessageErrorWarningEvent(showMessageErrorWarning: false),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _makePendingOrderDecisionFailureHandle(AdminHomeBloc adminHomeBloc) {
    adminHomeBloc.add(
      AdminHomeUpdatePendingOrderStatusEvent(
        pendingOrderStatus: PendingOrderStatus.idle,
      ),
    );
    adminHomeBloc.add(
      AdminHomeUpdateAdminHomeActionsEvent(
        adminHomeActions: AdminHomeActions.none,
      ),
    ); //
    adminHomeBloc.add(
      AdminHomeUpdatePendingOrderDecisionEvent(
        pendingOrderDecision: PendingOrderDecision.none,
      ),
    );
  }

  void _togglePauseReceptionFailureHandle(
    AdminHomeBloc adminHomeBloc,
    void Function(int index) onTapBottomNav,
  ) {
    final adminReceptionStatus = adminHomeBloc.state.receptionStatus;
    if (adminReceptionStatus == AdminReceptionStatus.success) {
      adminHomeBloc.add(
        AdminHomeUpdateDataBaseReceptionValueEvent(
          copyShopReceptionAvailabilityValue:
              !adminHomeBloc.state.copyShopEntity.pauseReception,
        ),
      );
      onTapBottomNav(0);
    }
    adminHomeBloc.add(
      AdminHomeUpdateAdminHomeActionsEvent(
        adminHomeActions: AdminHomeActions.none,
      ),
    );
  }

  void _thereWasAnError(
    BuildContext context,
    String title,
    String errorMessage,
  ) {
    showSnackBar(context: context, title: title, text: errorMessage);
  }

  Scaffold _myAdminHomeScreen(
    Color primary,
    BuildContext context,
    PageController pageController,
    List<Widget> pages,
    void Function(int index) onTapBottomNav,
  ) {
    return Scaffold(
      backgroundColor: primary,
      appBar: _myAppBar(context),
      body: _myBody(pageController, pages),
      bottomNavigationBar: _myBottomNavigationBar(context, onTapBottomNav),
    );
  }

  BlocBuilder<AdminHomeBloc, AdminHomeState> _myBody(
    PageController pageController,
    List<Widget> pages,
  ) {
    return BlocBuilder<AdminHomeBloc, AdminHomeState>(
      builder: (context, state) {
        return PageView(
          controller: pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: pages,
        );
      },
    );
  }

  MyAppBarWidget _myAppBar(BuildContext context) {
    return MyAppBarWidget(
      title: "PrintFast",
      leadingIcon: Icons.print,
      leadingIconSize: 25,
      trailingAction: Padding(
        padding: const EdgeInsets.only(right: 0),
        child: BlocBuilder<AdminHomeBloc, AdminHomeState>(
          builder: (context, state) {
            final unseenNotificationsCount = state.unseenNotificationsCount;

            return AnimatedContainer(
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
            );
          },
        ),
      ),
      trailingOnTap: () => context.push(Routes.adminNotifications),
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
          onTap: onTapBottomNav,
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
