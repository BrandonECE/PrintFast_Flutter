import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/presentation/blocs/home_bloc/home_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/login_bloc/login_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/message_error_warning_bloc/message_error_warning_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';
import 'package:printfast_rebuild/utils/utils.dart';

import '../../domain/entities/entities.dart';

class MyMenuView extends StatelessWidget {
  const MyMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final messageErrorWarningBloc = context.read<MessageErrorWarningBloc>();
    final homeBloc = context.read<HomeBloc>();


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
          return  Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: _myMenuScreen(width, context, state),
              ),
              MyErrorWarning(),
            ],
          );
        },
      ),
    );
  }

  SafeArea _myMenuScreen(double width, BuildContext context, HomeState state) {
    return SafeArea(
      child: Center(
        child: Container(
          width: width * 0.95,
          alignment: Alignment.center,
          child: Column(
            children: [
              // --- Card superior: saludo + opciones ---
              Container(
                padding: const EdgeInsets.only(bottom: 20),
                width: width * 0.95,
                decoration: const BoxDecoration(
                  color: Colors.white, // como el original: superficies blancas
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    _briefGreetingOriginal(context, state),
                    SizedBox(height: 8),
                    _containerMenuOptionsOriginal(context),
                  ],
                ),
              ),

              SizedBox(height: width * 0.03),

              // --- Contenido principal ---
              Expanded(
                child: Container(
                  width: width * 0.95,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      _titlesOriginal('Novedades', Icons.star_rounded, context),
                      SizedBox(height: 8),
                      _myNewsOriginal(context),
                      SizedBox(height: 12),
                      _titlesOriginal(
                        'Orden activa',
                        Icons.arrow_drop_down,
                        context,
                      ),
                      SizedBox(height: 8),
                      // Aquí están las 3 variantes (sin lógica) en la forma del original
                      Expanded(child: OrderActiveVariantsOriginal()),
                      SizedBox(height: 13),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _briefGreetingOriginal(BuildContext context, HomeState homeState) {
    final inverse = Theme.of(context).colorScheme.inverseSurface;
    return Container(
      width: MediaQuery.of(context).size.width * 0.83,
      margin: const EdgeInsets.only(top: 15),
      child: Row(
        children: [
          const Icon(Icons.waving_hand_rounded, color: Colors.amber),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "¡Hola, ",
                    style: TextStyle(
                      fontSize: 20,
                      color: inverse,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    firstName(homeState.userEntity.name),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text("!", style: TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Es un gusto poderte atender",
                style: TextStyle(fontSize: 14, color: inverse),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _containerMenuOptionsOriginal(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // final primary = Theme.of(context).colorScheme.primary;

    // Comprar activo (primario), Historial activo con primary también (como en original)
    return SizedBox(
      width: width * 0.83,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _menuOptionOriginal(
            Icons.shopping_cart_rounded,
            'Comprar',
            true,
            context,
            () => context.push(Routes.shopping),
          ),
          _menuOptionOriginal(
            Icons.history,
            'Historial',
            true,
            context,
            () => context.push(Routes.history),
          ),
        ],
      ),
    );
  }

  Widget _menuOptionOriginal(
    IconData icon,
    String label,
    bool active,
    BuildContext context,
    void Function() callback,
  ) {
    final width = MediaQuery.of(context).size.width;
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Colors.white;

    return Container(
      margin: const EdgeInsets.only(top: 15),
      width: width * 0.4,
      height: 100,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: active ? primary : primary.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: callback,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: onPrimary, size: 35),
                const SizedBox(height: 6),
                Text(label, style: TextStyle(color: onPrimary, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _titlesOriginal(String title, IconData icon, BuildContext context) {
    final inverse = Theme.of(context).colorScheme.inverseSurface;
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 8),
      width: MediaQuery.of(context).size.width * 0.83,
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: inverse,
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, color: inverse),
        ],
      ),
    );
  }

  Widget _myNewsOriginal(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Container(
      width: width * 0.83,
      height: height * 0.17,
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.fill,
                child: Image.asset("assets/images/printfast_news.png"),
              ),
            ),
          ),
          Container(
            color: Colors.black12,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            top: 10,
            left: 20,
            child: Row(
              children: [
                const Text(
                  "PrintFast",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 18,
                  height: 18,
                  child: Image.asset(
                    'assets/images/printfast_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 60,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: Text(
                "¡NUEVO PRODUCTO!",
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: Text(
                "COMPRALO YA!",
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(
                Icons.star_border_outlined,
                color: Colors.white,
                size: 70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderActiveVariantsOriginal extends StatelessWidget {
  const OrderActiveVariantsOriginal({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Mostrar las 3 variantes (apiladas) para referencia visual (igual que en tu original)
    return Container(
      width: width * 0.83,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.grey.shade400, width: 1.5),
      ),
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 12),
      child: _activeOrder(context),
    );
  }

  Widget _noOrder(BuildContext context) {
    return Center(
      child: Icon(Icons.hide_source, color: Colors.grey.shade300, size: 70),
    );
  }

  Widget _activeOrder(BuildContext context) {
    final inverse = Theme.of(context).colorScheme.inverseSurface;
    final grey600 = Colors.grey.shade600;
    final width = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1),
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // izquierda: lugar, tiempo, precio
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, color: inverse, size: 18),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          "FIME",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: inverse,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        ' 12 min',
                        style: TextStyle(
                          color: grey600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.access_time_rounded, color: grey600, size: 16),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        ' 75.00 Mxn',
                        style: TextStyle(
                          color: grey600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.attach_money_rounded,
                        color: grey600,
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // derecha: botones (estilo original)
            _activeOrderOptions(context),
          ],
        ),
      ),
    );
  }

  Column _activeOrderOptions(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => context.push(Routes.activeOrder),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Ver detalles',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 33),
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Cancelar',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Row _activeOrderCompletedMessage(BuildContext context) {
    return Row(
      children: const [
        Text(
          ' ¡Entregado!',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(width: 10),
        Icon(Icons.check_circle, color: Colors.greenAccent, size: 35),
      ],
    );
  }
}
