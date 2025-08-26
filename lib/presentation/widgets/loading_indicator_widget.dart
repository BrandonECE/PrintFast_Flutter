import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class MyLoadingIndicator extends StatelessWidget {
  const MyLoadingIndicator({super.key, this.size = 100, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      child: LoadingIndicator(
        indicatorType: Indicator.ballPulse,
        colors: [color ?? Theme.of(context).colorScheme.primary],
        strokeWidth: 1,
      ),
    );
  }
}
