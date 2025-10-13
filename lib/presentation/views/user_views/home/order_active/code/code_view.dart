import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/home_bloc/home_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

class MyCodeView extends StatelessWidget {
  const MyCodeView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: _myAppBar(context),
      body: _myBody(width, context),
    );
  }

  MyAppBarWidget _myAppBar(BuildContext context) {
    return MyAppBarWidget(
      title: "Código de entrega",
      leadingIcon: Icons.qr_code_rounded,
      leadingIconSize: 24,
      actionIcon: Icons.close_rounded,
      actionIconSize: 22,
      onAction: () => context.canPop() ? context.pop() : null,
    );
  }

  Widget _myBody(double width, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final code = context.read<HomeBloc>().state.activeOrder!.verificationCode; // Código de ejemplo

    return Center(
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _headerSection(colorScheme),
                const SizedBox(height: 28),
                _codeDisplay(context, code),
                const SizedBox(height: 28),
                _instructionsSection(colorScheme),
                const SizedBox(height: 28),
                _actionButtons(context, colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerSection(ColorScheme colorScheme) {
    return Column(
      children: [
        Icon(Icons.verified_user_rounded, 
             size: 44, 
             color: colorScheme.primary),
        const SizedBox(height: 14),
        Text(
          "Código de verificación",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colorScheme.inverseSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Muestra este código al personal",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.inverseSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _codeDisplay(BuildContext context, String code) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          "Tu código de 5 dígitos",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.inverseSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < code.length; i++)
              _digitBox(context, code[i], isLast: i == code.length - 1),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          "5 minutos de tolerancia para llegar",
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.inverseSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _digitBox(BuildContext context, String digit, {bool isLast = false}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 54, // Reducido de 60 a 54
      height: 64, // Reducido de 70 a 64
      margin: EdgeInsets.only(right: isLast ? 0 : 10), // Reducido de 12 a 10
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          digit,
          style: TextStyle(
            fontSize: 28, // Reducido de 32 a 28
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Widget _instructionsSection(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, 
                   size: 16, 
                   color: colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                "Instrucciones",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.inverseSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _instructionItem(
            icon: Icons.person_rounded,
            text: "Solo el titular puede recoger",
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 6),
          _instructionItem(
            icon: Icons.timer_rounded,
            text: "5 minutos de tolerancia",
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 6),
          _instructionItem(
            icon: Icons.location_on_rounded,
            text: "Acude al mostrador de recolección",
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _instructionItem({
    required IconData icon,
    required String text,
    required ColorScheme colorScheme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: colorScheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.inverseSurface.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButtons(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Acción para compartir código
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.share_rounded, size: 16),
            label: const Text(
              "Compartir código",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            "Cerrar",
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}