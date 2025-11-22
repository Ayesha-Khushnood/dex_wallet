import 'package:flutter/material.dart';

/// ✅ Helper SizedBox shortcut
class SB extends StatelessWidget {
  final double height, width;

  const SB.h(this.height, {super.key}) : width = 0;
  const SB.w(this.width, {super.key}) : height = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, width: width);
  }
}
