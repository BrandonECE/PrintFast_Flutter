import 'package:flutter/material.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

class MyAnimatedContentSwitcherButton extends StatelessWidget {
  const MyAnimatedContentSwitcherButton({
    super.key,
    required this.showLoad,
    required this.text,
    this.durationTimeInMilliseconds = 180,
    this.loadingIndicatorSize = 28,
    this.textSize = 15,
    this.icon,
    this.iconSize = 20
  });
  final bool showLoad;
  final int durationTimeInMilliseconds;
  final double loadingIndicatorSize;
  final String text;
  final double textSize;
  final IconData? icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: durationTimeInMilliseconds),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        final fade = FadeTransition(opacity: animation, child: child);
        final scale = ScaleTransition(
          scale: Tween<double>(
            begin: 0.97,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: fade,
        );
        return scale;
      },
      child: showLoad
          ? MyLoadingIndicator(
              key: const ValueKey('loader'),
              size: loadingIndicatorSize,
              color: Colors.white,
            )
          : Row(
              key: const ValueKey('text'),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if(icon != null)
                Row(
                  children: [
                    Icon(icon, size: iconSize),
                    SizedBox(width: 8),
                  ],
                ),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}
