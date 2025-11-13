import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HighlyCustomizableSuccessAlert {
  static Future<void> show({
    required BuildContext context,
    
    // Contenido
    String title = "Éxito",
    String message = "Operación completada con éxito",
    
    // Animación Lottie
    String lottieAsset = 'packages/custom_quick_alert/assets/animations/success.json',
    double lottieWidth = 80,  // Reducido de 120
    double lottieHeight = 80, // Reducido de 120
    bool repeatAnimation = false,
    
    // Animación del diálogo
    CustomQuickAlertAnimationType animationType = CustomQuickAlertAnimationType.slideInRight,
    Duration animationDuration = const Duration(milliseconds: 400),
    
    // Tamaño y diseño
    double? width,        // Más compacto
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Más compacto
    double borderRadius = 10.0, // Más compacto
    
    // Colores
    Color backgroundColor = Colors.white,
    Color titleColor = Colors.green,
    Color messageColor = Colors.grey,
    Color barrierColor = Colors.black54,
    
    // Botón
    String confirmText = "OK",
    bool showConfirm = false,  // Por defecto sin botón para más compacto
    Color confirmBtnColor = Colors.green,
    Color confirmTextColor = Colors.white,
    VoidCallback? onConfirm,
    
    // Comportamiento
    Duration autoCloseDuration = const Duration(seconds: 2),
    bool barrierDismissible = true,
    
    // Personalización EXTREMA
    Widget? customIcon, // Reemplaza completamente el Lottie
    TextStyle? customTitleStyle,
    TextStyle? customMessageStyle,
    TextStyle? customButtonStyle,
    List<BoxShadow>? customShadows,
    Widget? customContent, // Contenido adicional
    EdgeInsets? lottieMargin,
    EdgeInsets? titleMargin,
    EdgeInsets? messageMargin,
    EdgeInsets? buttonMargin,
    double? buttonHeight,
    double? buttonBorderRadius,
    bool useGradientButton = false,
    Gradient? buttonGradient,
    
  }) async {
    
    // Timer para auto-cierre
    Timer? autoCloseTimer;
    
    await showGeneralDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: 'Alert',
      transitionDuration: animationDuration,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return _buildAnimation(
          child: child,
          animation: animation,
          animationType: animationType,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        // Iniciar timer de auto-cierre si está configurado
        if (autoCloseDuration.inSeconds > 0 && !showConfirm) {
          autoCloseTimer = Timer(autoCloseDuration, () {
            Navigator.of(context).pop();
          });
        }
        
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: WillPopScope(
            onWillPop: () async => barrierDismissible,
            child: Container(
              width: width ?? (MediaQuery.of(context).size.width * 0.85).clamp(280.0, MediaQuery.of(context).size.width - 40),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: customShadows ?? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: Padding(
                  padding: padding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ICONO/ANIMACIÓN
                      if (customIcon != null)
                        Container(
                          margin: lottieMargin ?? const EdgeInsets.only(bottom: 12),
                          child: customIcon,
                        )
                      else
                        Container(
                          margin: lottieMargin ?? const EdgeInsets.only(bottom: 12),
                          child: Lottie.asset(
                            lottieAsset,
                            width: lottieWidth,
                            height: lottieHeight,
                            repeat: repeatAnimation,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: lottieWidth,
                                height: lottieHeight,
                                decoration: BoxDecoration(
                                  color: titleColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check_circle,
                                  color: titleColor,
                                  size: lottieHeight * 0.6,
                                ),
                              );
                            },
                          ),
                        ),

                      // TÍTULO
                      if (title.isNotEmpty)
                        Container(
                          margin: titleMargin ?? const EdgeInsets.only(bottom: 8),
                          child: Text(
                            title,
                            style: customTitleStyle ?? TextStyle(
                              fontSize: 18, // Reducido de 22
                              fontWeight: FontWeight.w600,
                              color: titleColor,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // MENSAJE
                      if (message.isNotEmpty)
                        Container(
                          margin: messageMargin ?? const EdgeInsets.only(bottom: 20),
                          child: Text(
                            message,
                            style: customMessageStyle ?? TextStyle(
                              fontSize: 14, // Reducido de 16
                              color: messageColor,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // CONTENIDO PERSONALIZADO ADICIONAL
                      if (customContent != null) customContent,

                      // BOTÓN
                      if (showConfirm)
                        Container(
                          margin: buttonMargin ?? const EdgeInsets.only(top: 8),
                          child: Container(
                            height: buttonHeight ?? 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(buttonBorderRadius ?? 10),
                              gradient: useGradientButton 
                                  ? (buttonGradient ?? LinearGradient(
                                      colors: [confirmBtnColor, confirmBtnColor.withOpacity(0.8)],
                                    ))
                                  : null,
                              color: useGradientButton ? null : confirmBtnColor,
                              boxShadow: [
                                BoxShadow(
                                  color: confirmBtnColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(buttonBorderRadius ?? 10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(buttonBorderRadius ?? 10),
                                onTap: () {
                                  autoCloseTimer?.cancel();
                                  Navigator.of(context).pop();
                                  onConfirm?.call();
                                },
                                child: Center(
                                  child: Text(
                                    confirmText,
                                    style: customButtonStyle ?? TextStyle(
                                      color: confirmTextColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    
    // Cancelar timer si aún está activo
    autoCloseTimer?.cancel();
  }

  static Widget _buildAnimation({
    required Widget child,
    required Animation<double> animation,
    required CustomQuickAlertAnimationType animationType,
  }) {
    switch (animationType) {
      case CustomQuickAlertAnimationType.slideInRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      
      case CustomQuickAlertAnimationType.slideInLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      
      case CustomQuickAlertAnimationType.slideInDown:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      
      case CustomQuickAlertAnimationType.slideInUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      
      case CustomQuickAlertAnimationType.scale:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0,
            end: 1,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          )),
          child: child,
        );
      
      case CustomQuickAlertAnimationType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      
      default:
        return child;
    }
  }
}

enum CustomQuickAlertAnimationType {
  scale,
  fade,
  slideInDown,
  slideInUp,
  slideInLeft,
  slideInRight,
  rotate,
  slide,
  none,
  custom
}