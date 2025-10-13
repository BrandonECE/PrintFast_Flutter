// lib/presentation/views/add_card_view.dart
// UI completo de AddCardView — versión optimizada para evitar parpadeo al cargar CardFormField

// ignore_for_file: unused_element_parameter

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:printfast_rebuild/di/service_locator.dart';
import 'package:printfast_rebuild/domain/repositories/user_repository.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/message_error_warning_bloc/message_error_warning_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/home_bloc/home_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/payment_blocs/add_card_bloc/add_card_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

import '../../../../../utils/utils.dart';

class MyAddCardView extends StatefulWidget {
  const MyAddCardView({super.key, required this.extra});
  final Object? extra;

  @override
  State<MyAddCardView> createState() => _MyAddCardViewState();
}

class _MyAddCardViewState extends State<MyAddCardView> {
  final _cardHolderFocus = FocusNode();
  late final TextEditingController _cardHolderController;

  // Indicador para controlar la visibilidad/interacción del CardFormField nativo
  bool _cardFieldInitialized = false;

  @override
  void initState() {
    super.initState();
    _cardHolderController = TextEditingController();

    // Fallback: si por alguna razón el CardFormField no llama a onCardChanged
    // (algunas veces ocurre en views nativas/platform views), forzamos mostrarlo
    // después de un corto timeout para evitar que nunca aparezca.
    // También mantenemos el onCardChanged como la señal preferida para mostrarlo.
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted && !_cardFieldInitialized) {
        //print('CardFormField: no llamado onCardChanged en 600ms — mostrando por fallback');
        setState(() {
          _cardFieldInitialized = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _cardHolderFocus.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final homeBlocState = context.read<HomeBloc>().state;
    final registration = homeBlocState.userEntity.registration;
    final messageErrorWarningBloc = context.read<MessageErrorWarningBloc>();

    return Stack(
      children: [
        _addCardScreen(registration, colorScheme, context, width),
        MyMessageErrorWarning(
          voidCallback: () => messageErrorWarningBloc.add(
            ShowMessageErrorWarningEvent(showMessageErrorWarning: false),
          ),
        ),
      ],
    );
  }

  BlocProvider<AddCardBloc> _addCardScreen(
    String registration,
    ColorScheme colorScheme,
    BuildContext context,
    double width,
  ) {
    return BlocProvider(
      create: (context) => AddCardBloc(
        userRepository: getIt<UserRepository>(),
        registration: registration,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.primary,
        appBar: _myAppBar(context),
        body: Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: width * 0.025),
            child: Container(
              width: width * 0.95,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mantener header siempre visible (titulo + subtitulo)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _headerSection(colorScheme),
                  ),

                  const SizedBox(height: 20),

                  // Contenido principal que cargará: mientras el CardFormField no esté listo
                  // mostramos un loader; cuando esté listo hacemos un fade a la UI completa.
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 225),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: _cardFieldInitialized
                          ? SingleChildScrollView(
                              key: const ValueKey('content_ready'),
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _cardPreview(context),
                                  const SizedBox(height: 20),
                                  _cardForm(context),
                                ],
                              ),
                            )
                          : Center(
                              key: const ValueKey('content_loading'),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [MyLoadingIndicator()],
                              ),
                            ),
                    ),
                  ),

                  // Botón guardar (mantener siempre visible en el pie)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: _saveButton(context, colorScheme, widget.extra),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  MyAppBarWidget _myAppBar(BuildContext context) {
    return MyAppBarWidget(
      title: "Agregar tarjeta",
      leadingIcon: Icons.add_card_rounded,
      leadingIconSize: 22,
      actionIcon: Icons.close_rounded,
      actionIconSize: 25,
      onAction: () => context.canPop() ? context.pop() : null,
    );
  }

  Widget _headerSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Agregar tarjeta",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.inverseSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Ingresa los datos de tu tarjeta",
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.inverseSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ------------------------------
  // REEMPLAZADO: Card preview con estilo "card" que coincide con los items
  // ------------------------------
  // Reemplaza tu _cardPreview por esta versión corregida (colores en hex válidos)
  // Reemplaza tu _cardPreview por esta versión
  Widget _cardPreview(BuildContext context) {
    return BlocBuilder<AddCardBloc, AddCardState>(
      builder: (context, state) {
        final holder = state.cardHolder.isEmpty
            ? 'TITULAR'
            : state.cardHolder.toUpperCase();
        final month = state.expiryMonth == 0
            ? 'MM'
            : state.expiryMonth.toString().padLeft(2, '0');
        final year = state.expiryYear == 0 ? 'AA' : state.expiryYear.toString();
        final displayLast = state.displayLastFour.isEmpty
            ? '0000'
            : state.displayLastFour;

        // Paleta: naranja (opaco), gris neutro para acento, blanco/gris, texto negro
        final bg = Colors.grey.shade50; // gris muy claro
        final border = Colors.grey.shade300; // gris borde
        final accentLeftStart = const Color(
          0xFFF4F5F7,
        ); // gris muy muy claro (#F4F5F7)
        final accentLeftEnd = const Color.fromARGB(
          202,
          227,
          229,
          232,
        ); // gris claro suave (#E0E4EA)
        final chipColor = Colors.orange.withOpacity(0.10); // naranja sutil
        final chipBorder = Colors.orange.withOpacity(0.22);
        final chipIconColor = Colors.orange; // icono naranja
        final textPrimary = const Color(0xFF111111); // negro intenso
        final textSecondary = const Color.fromARGB(
          190,
          0,
          0,
          0,
        ); // negro con opacidad

        return Material(
          color: Colors.transparent,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border, width: 0.1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Fondo suave (ligero degradado)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [bg.withOpacity(0.995), bg.withOpacity(0.96)],
                      ),
                    ),
                  ),

                  // // ACENTO VERTICAL GRIS A LA IZQUIERDA
                  // Positioned(
                  //   left: 0,
                  //   top: 0,
                  //   bottom: 0,
                  //   width: 10,
                  //   child: Opacity(
                  //     opacity: 1,
                  //     child: Container(
                  //       decoration: BoxDecoration(
                  //         gradient: LinearGradient(
                  //           begin: Alignment.topCenter,
                  //           end: Alignment.bottomCenter,
                  //           colors: [accentLeftStart, accentLeftEnd],
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  // CONTENIDO
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TOP ROW: chip simple + (badge predet. + brand badge)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Chip simple (naranja opaco) con icono rotado
                            Container(
                              width: 50,
                              height: 34,
                              decoration: BoxDecoration(
                                color: chipColor,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: chipBorder),
                              ),
                              child: Center(
                                child: Transform.rotate(
                                  angle:
                                      -pi /
                                      2, // ligera rotación para "giro" realista
                                  child: Icon(
                                    Icons.sim_card, // icono de sim
                                    size: 20,
                                    color: chipIconColor,
                                  ),
                                ),
                              ),
                            ),

                            // Agrupamos badge + brand en una fila para que el badge quede a la izquierda del brand
                            Row(
                              children: [
                                // AnimatedSwitcher para badge "Predet."
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 260),
                                  switchInCurve: Curves.easeOutBack,
                                  switchOutCurve: Curves.easeInBack,
                                  transitionBuilder: (child, animation) {
                                    return ScaleTransition(
                                      scale: animation,
                                      child: FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: state.isDefault
                                      ? Container(
                                          key: const ValueKey(
                                            'preview_default_indicator',
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          margin: const EdgeInsets.only(
                                            right: 13,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(
                                              0.10,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: Border.all(
                                              color: Colors.green.withOpacity(
                                                0.25,
                                              ),
                                            ),
                                          ),
                                          child: const Text(
                                            "Predet.",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.green,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(
                                          key: ValueKey('no_preview_default'),
                                          width: 0,
                                          height: 0,
                                        ),
                                ),

                                // Brand badge limpio (negro sobre blanco)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.blue.withOpacity(0.13),
                                    ),
                                    // boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 2, offset: const Offset(0, 1))],
                                  ),
                                  child: Text(
                                    state.brand.isEmpty
                                        ? "VISA"
                                        : state.brand.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const Spacer(),

                        // NÚMERO (segmentado)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _cardNumberSegment(
                              "****",
                              isLast: false,
                              color: textPrimary,
                            ),
                            _cardNumberSegment(
                              "****",
                              isLast: false,
                              color: textPrimary,
                            ),
                            _cardNumberSegment(
                              "****",
                              isLast: false,
                              color: textPrimary,
                            ),
                            Flexible(
                              flex: 2,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: _cardNumberSegment(
                                  displayLast,
                                  isLast: true,
                                  color: textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // TITULAR / VENCE
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "TITULAR",
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    holder,
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "VENCE",
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    (state.expiryMonth == 0 ||
                                            state.expiryYear == 0)
                                        ? "MM/AA"
                                        : "$month/$year",
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Borde interior sutil
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: border.withOpacity(1.0),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Auxiliar (asegúrate de tener esta función en el mismo archivo)
  Widget _cardNumberSegment(String text, {bool isLast = false, Color? color}) {
    return Text(
      text,
      style: TextStyle(
        color: color ?? Colors.black,
        fontSize: isLast ? 18 : 14,
        fontWeight: isLast ? FontWeight.w700 : FontWeight.w600,
        letterSpacing: 1.6,
      ),
    );
  }

  Widget _cardForm(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<AddCardBloc, AddCardState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Información",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.inverseSurface.withOpacity(0.8),
              ),
            ),

            const SizedBox(height: 10),

            // Campo Titular: usamos controller persistente para evitar recrearlo en cada build
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(14),
                child: Column(
                  children: [
                    _formField(
                      context: context,
                      label: "Titular",
                      keyboardType: TextInputType.text,
                      controller: _cardHolderController,
                      focusNode: _cardHolderFocus,
                      onChanged: (value) {
                        context.read<AddCardBloc>().add(
                          CardHolderChanged(cardHolder: value),
                        );
                      },
                      sufixIcon: Icons.person_3,
                    ),

                    // Stack: CardFormField real (invisible al inicio) + placeholder encima.
                    SizedBox(
                      height: 206,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // 1) CardFormField real - inicialmente invisible
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 220),
                            opacity: _cardFieldInitialized ? 1.0 : 0.0,
                            curve: Curves.easeOut,
                            child: IgnorePointer(
                              ignoring: !_cardFieldInitialized,
                              child: CardFormField(
                                countryCode: 'MX',
                                enablePostalCode: false,
                                style: CardFormStyle(
                                  backgroundColor: Colors.grey[50],
                                  borderColor: Colors.transparent,
                                  borderWidth: 0,
                                  textColor: Theme.of(
                                    context,
                                  ).colorScheme.inverseSurface,
                                  cursorColor: Colors.blue,
                                  placeholderColor: Theme.of(
                                    context,
                                  ).colorScheme.inverseSurface.withOpacity(0.5),
                                ),
                                onCardChanged: (details) {
                                  // si recibimos detalles (incluso incomplete) consideramos que la vista nativa está lista
                                  if (!_cardFieldInitialized &&
                                      details != null) {
                                    //print('CardFormField: onCardChanged recibido - mostrando campo real');
                                    setState(() {
                                      _cardFieldInitialized = true;
                                    });
                                  }

                                  // propagar al bloc
                                  context.read<AddCardBloc>().add(
                                    CardFormChanged(details: details),
                                  );
                                },
                              ),
                            ),
                          ),

                          // 2) Placeholder que imita la apariencia del CardFormField
                          Visibility(
                            visible: !_cardFieldInitialized,
                            maintainState: true,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFE6E6E6),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // fila superior simulada
                                  Row(
                                    children: [
                                      Expanded(child: Container()),
                                      Icon(
                                        Icons.credit_card,
                                        size: 18,
                                        color: Colors.grey.shade500,
                                      ),
                                    ],
                                  ),

                                  const Spacer(),

                                  // número de tarjeta simulado
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      '**** **** **** 0000',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .inverseSurface
                                            .withOpacity(0.6),
                                        fontSize: 16,
                                        letterSpacing: 1.6,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Checkbox para predeterminar
            BlocBuilder<AddCardBloc, AddCardState>(
              builder: (context, state) {
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      context.read<AddCardBloc>().add(
                        const ToggleDefaultCard(),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 8,
                        top: 8,
                        bottom: 4,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: state.isDefault,
                              onChanged: (value) {
                                context.read<AddCardBloc>().add(
                                  const ToggleDefaultCard(),
                                );
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              overlayColor: WidgetStateProperty.resolveWith(
                                (states) => Colors.transparent,
                              ),
                              side: WidgetStateBorderSide.resolveWith(
                                (states) => state.isDefault == false
                                    ? BorderSide(
                                        color: Colors.grey.shade400,
                                        width: 1.2,
                                      )
                                    : null,
                              ),
                              activeColor: Colors.blue,
                              checkColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Establecer como predeterminada",
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(
                                context,
                              ).colorScheme.inverseSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _formField({
    required BuildContext context,
    required String label,
    required TextInputType keyboardType,
    required TextEditingController controller,
    required FocusNode focusNode,
    required Function(String) onChanged,
    required IconData sufixIcon,
    bool obscureText = false,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      cursorColor: Colors.blue,
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      inputFormatters: inputFormatters,

      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelStyle: const TextStyle(color: Color(0xFF8E8F8F), fontSize: 14),
        labelText: label,
        suffixIcon: Icon(sufixIcon, color: const Color(0xFF959595), size: 25),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 1),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 1),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 1),
        ),
        counterText: '',
      ),
    );
  }

  Widget _saveButton(
    BuildContext context,
    ColorScheme colorScheme,
    Object? extra,
  ) {
    return BlocConsumer<AddCardBloc, AddCardState>(
      listener: (context, state) {
        if (state.submitStatus == ActionAddCardStatus.success) {
          final onCardSaved = extra as VoidCallback?;
          onCardSaved?.call();
          context.pop();
        } else if (state.submitStatus == ActionAddCardStatus.failure) {
          _thereWasAnError(context, state);
        }
      },
      builder: (context, state) {
        final isLoading =
            state.submitStatus == ActionAddCardStatus.loading ||
            state.submitStatus == ActionAddCardStatus.success;
        final isEnabled = state.isValid && !isLoading;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isEnabled
                ? () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    context.read<AddCardBloc>().add(const SubmitCard());
                  }
                : isLoading
                ? () {}
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: MyAnimatedContentSwitcherButton(
              showLoad: isLoading,
              text: "Guardar tarjeta",
              icon: Icons.add_card_rounded,
            ),
          ),
        );
      },
    );
  }

  void _thereWasAnError(
    BuildContext context,
    AddCardState state,
  ) {
    showSnackBar(context: context, title: "¡Error inesperado!", text: state.submitError  ?? "",);
  }
}

