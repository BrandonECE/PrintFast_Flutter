// MySnackBarContent.dart
import 'package:flutter/material.dart';

class MySnackBarContentWidget extends StatelessWidget {
  const MySnackBarContentWidget({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          // sombra principal más oscura y difusa (profundidad)
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            spreadRadius: 1.2,
            offset: const Offset(0, 8),
          ),
          // segunda sombra más pequeña para dar definición cerca del contenedor
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 0.4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 20, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
