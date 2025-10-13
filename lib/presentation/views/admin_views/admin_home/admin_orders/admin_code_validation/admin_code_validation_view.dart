import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_pin_code_fields/flutter_pin_code_fields.dart';
import 'package:flutter/services.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

class MyAdminCodeValidationView extends StatefulWidget {
  const MyAdminCodeValidationView({super.key});

  @override
  State<MyAdminCodeValidationView> createState() =>
      _MyAdminCodeValidationViewState();
}

class _MyAdminCodeValidationViewState extends State<MyAdminCodeValidationView> {

  String _enteredPin = '';



  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: _myAppBar(context),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          // Forzamos una altura mínima igual al viewport disponible
          constraints: BoxConstraints(
            minHeight:
                height - MediaQuery.of(context).padding.top - kToolbarHeight,
          ),
          child: IntrinsicHeight(
            child: Center( // <-- asegura centrado horizontal
              child: Padding(
                padding: EdgeInsets.only(bottom: width * 0.025),
                child: Container(
                  width: width * 0.95,
                  // Importante: height infinity para que rellene el espacio mínimo
                  height: double.infinity,
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
                      // Distribuye espacio entre la sección superior y el botón inferior
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center, // centra horizontalmente
                          children: [
                            _headerSection(colorScheme),
                            const SizedBox(height: 28),
                            _codeInputSection(context),
                            const SizedBox(height: 28),
                            _instructionsSection(colorScheme),
                          ],
                        ),
                        Column(
                          children: [
                            const SizedBox(height: 28),
                            _actionButton(context),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  MyAppBarWidget _myAppBar(BuildContext context) {
    return MyAppBarWidget(
      title: "Validar código",
      leadingIcon: Icons.verified_user_rounded,
      leadingIconSize: 24,
      actionIcon: Icons.close_rounded,
      actionIconSize: 22,
      onAction: () => context.canPop() ? context.pop() : null,
    );
  }

  Widget _headerSection(ColorScheme colorScheme) {
    return Column(
      children: [
        Icon(
          Icons.qr_code_scanner_rounded,
          size: 44,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 14),
        Text(
          "Validación de código",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colorScheme.inverseSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Ingresa el código de 5 dígitos del usuario",
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

  Widget _codeInputSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          "Ingresa el código de verificación",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.inverseSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 16),

        // PinCodeFields con controller y focusNode (centrado)
        Center(
          child: PinCodeFields(
            length: 5,
            fieldBorderStyle: FieldBorderStyle.square,
            responsive: false,
            fieldHeight: 60.0,
            fieldWidth: 50.0,
            borderWidth: 1.5,
            activeBorderColor: colorScheme.primary,
            activeBackgroundColor: Colors.grey[50]!,
            borderRadius: BorderRadius.circular(10.0),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            autoHideKeyboard: false,
            fieldBackgroundColor: Colors.grey[50]!,
            borderColor: colorScheme.primary.withOpacity(0.3),
            textStyle: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),

            autofocus: false, // ya manejamos el requestFocus manualmente
            onComplete: (pin) {
              // if (!mounted) return;
              // setState(() {
                _enteredPin = pin;
              // });
              FocusScope.of(context).unfocus();
            },
            onChange: (pin) {
              // if (!mounted) return;
              // setState(() {
                _enteredPin = pin;
              // });
                          },
            margin: const EdgeInsets.only(right: 6),
          ),
        ),

        const SizedBox(height: 14),
        Text(
          "El código se completará automáticamente",
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.inverseSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                "Instrucciones para validación",
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
            icon: Icons.numbers_rounded,
            text:
                "Ingresa los 5 dígitos del código proporcionado por el usuario",
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 6),
          _instructionItem(
            icon: Icons.verified_user_rounded,
            text: "Verifica la identidad del usuario antes de validar",
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 6),
          _instructionItem(
            icon: Icons.timer_rounded,
            text: "El código expira después de 5 minutos de ser generado",
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

  Widget _actionButton(BuildContext context) {
    // ignore: unused_local_variable
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = _enteredPin.length == 5;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isEnabled
            ? () {
                // Lógica para validar el código
                _showValidationResult(context, true);
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? Colors.green : Colors.grey.shade300,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 3,
        ),
        icon: Icon(
          Icons.verified_rounded,
          size: 18,
          color: isEnabled ? Colors.white : Colors.grey.shade500,
        ),
        label: Text(
          "Validar y entregar",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isEnabled ? Colors.white : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  void _showValidationResult(BuildContext context, bool isSuccess) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
              color: isSuccess ? Colors.green : Colors.red,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              isSuccess ? "¡Entrega exitosa!" : "Error de validación",
              style: TextStyle(
                color: colorScheme.inverseSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          isSuccess
              ? "El código ha sido validado correctamente y la orden ha sido entregada."
              : "El código es inválido o ha expirado. Por favor verifica.",
          style: TextStyle(
            color: colorScheme.inverseSurface.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // cerrar diálogo
              if (isSuccess && context.canPop()) {
                context.pop(); // cerrar la pantalla de validación si fue exitosa
              }
            },
            child: Text(
              "Aceptar",
              style: TextStyle(
                color: isSuccess ? Colors.green : colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
