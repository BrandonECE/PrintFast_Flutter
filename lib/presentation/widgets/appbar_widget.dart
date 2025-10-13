import 'package:flutter/material.dart';

/// AppBar parametrizable: título, imagen (asset) o icono al costado, spacing y acción.
/// Si se pasa **imagePath** se prioriza frente a **leadingIcon**.
/// Nuevo: parámetro `trailingAction` (Widget?) con prioridad sobre `actionIcon`.
class MyAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBarWidget({
    super.key,
    required this.title,
    this.titleFontSize = 20.0,
    this.imagePath,
    this.imageSize = 18.0,
    this.leadingIcon,
    this.leadingIconSize = 18.0,
    this.spacing = 8.0,
    this.actionIcon,
    this.actionIconSize = 22.0,
    this.onAction,
    this.backgroundColor,
    this.elevation = 0.0,

    // NUEVOS parámetros:
    this.trailingAction,
    this.trailingOnTap,
  });

  /// Texto que aparecerá en el AppBar
  final String title;

  /// Tamaño de la letra del título
  final double titleFontSize;

  /// Ruta del asset de la imagen (asset path). Si está presente se mostrará la imagen.
  final String? imagePath;

  /// Tamaño (width & height) de la imagen
  final double imageSize;

  /// Icono alternativo si no se pasa imagePath
  final IconData? leadingIcon;

  /// Tamaño del icono alternativo
  final double leadingIconSize;

  /// Espaciado entre título y (imagen|icono)
  final double spacing;

  /// Icono de acción de la derecha (opcional)
  final IconData? actionIcon;

  /// Tamaño del icono de acción
  final double actionIconSize;

  /// Callback para la acción del icono derecho (opcional)
  final VoidCallback? onAction;

  /// Color de fondo opcional (si es null usa colorScheme.primary)
  final Color? backgroundColor;

  /// Elevación del AppBar
  final double elevation;

  /// Nuevo: widget que sustituye al actionIcon (tiene prioridad si no es null)
  final Widget? trailingAction;

  /// Nuevo: callback específico para el trailingAction (si se desea hacerlo interactivo)
  final VoidCallback? trailingOnTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Widget? _buildTrailingMedia(BuildContext context) {
    // Prioriza imagePath (asset) si está presente y no vacío
    if (imagePath != null && imagePath!.trim().isNotEmpty) {
      return SizedBox(
        width: imageSize,
        height: imageSize,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.asset(
            imagePath!,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      );
    }

    if (leadingIcon != null) {
      return Icon(leadingIcon, size: leadingIconSize, color: Colors.white);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final trailingMedia = _buildTrailingMedia(context);
    final bg = backgroundColor ?? Theme.of(context).colorScheme.primary;

    const animDur = Duration(milliseconds: 225);

    // Construcción del trailing: prioridad a `trailingAction`, si no existe usamos `actionIcon`
    Widget? buildTrailingButton() {
      if (trailingAction != null) {
        final widget = trailingOnTap != null
            ? Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: trailingOnTap,
                    borderRadius: BorderRadius.circular(8),
                    child: trailingAction,
                  ),
                ),
            )
            : trailingAction!;
        return widget;
      }

      if (actionIcon != null) {
        return IconButton(
          onPressed: onAction,
          icon: Icon(actionIcon, size: actionIconSize, color: Colors.white),
          tooltip: 'Acción',
        );
      }

      return null;
    }

    final trailingButton = buildTrailingButton();

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: bg,
      elevation: elevation,
      titleSpacing: 16,
      title: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: titleFontSize,
            ),
          ),
          if (trailingMedia != null) SizedBox(width: spacing),
          if (trailingMedia != null) trailingMedia,
        ],
      ),
      actions: [
        // AnimatedSwitcher para animar cambios de trailing (fade 225ms)
        AnimatedSwitcher(
          duration: animDur,
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: trailingButton != null
              ? Padding(
                  key: ValueKey(trailingButton.hashCode),
                  padding: const EdgeInsets.only(right: 2),
                  child: trailingButton,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
