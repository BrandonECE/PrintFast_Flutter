import 'package:flutter/material.dart';
import 'package:printfast_rebuild/presentation/widgets/order_completed_dialog.dart';

void showHighlyCustomizableSuccessAlert(BuildContext context) {

if (!context.mounted) {
    print("❌ Contexto no disponible");
    return;
  }
  
  try {
    HighlyCustomizableSuccessAlert.show(
  context: context,
  title: "Éxito",
  message: "Compra completada",
  repeatAnimation: true,
  
  // ANIMACIÓN MÁS RÁPIDA/FRENÉTICA
  animationDuration: const Duration(milliseconds: 215), // Más rápido
  animationType: CustomQuickAlertAnimationType.slideInRight, // O slideInRight para más dinámico
  
  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
  borderRadius: 18,

  lottieHeight: 120,
  lottieWidth: 120,
  lottieMargin: const EdgeInsets.only(bottom: 16),

  // ESTILOS DE TEXTO MÁS MODERNOS
  titleMargin: const EdgeInsets.only(bottom: 8),
  messageMargin: const EdgeInsets.only(bottom: 20),

  customTitleStyle: TextStyle(
    fontSize: 22, // Un poco más grande
    fontWeight: FontWeight.w800, // Más negrita
    color: Colors.greenAccent.shade700,
    height: 1.1,
    letterSpacing: 0.5, // Más espaciado para elegancia
  ),
  customMessageStyle: TextStyle(
    fontSize: 16, // Un poco más grande
    color: Colors.grey[800], // Más oscuro para mejor contraste
    height: 1.3,
    fontWeight: FontWeight.w500, // Semi-negrita
    letterSpacing: 0.2,
  ),

  // BOTÓN
  showConfirm: true,
  confirmText: "Aceptar",
  buttonHeight: 52,
  buttonBorderRadius: 12,
  buttonMargin: const EdgeInsets.only(top: 16),
  confirmBtnColor: Colors.greenAccent.shade700,
  confirmTextColor: Colors.white,
  customButtonStyle: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700, // Más negrita
    color: Colors.white,
    letterSpacing: 0.8, // Más espaciado para elegancia
  ),
  
  backgroundColor: Colors.white,
  titleColor: Colors.greenAccent.shade700,
  messageColor: Colors.grey.shade800,
);
  } catch (e) {
    print("❌ Error mostrando alerta: $e");
  }


}
