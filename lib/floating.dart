import 'package:flutter/material.dart';

/// Çocuğunu yukarı aşağı süzülür gibi hareket ettirir.
class Floating extends StatefulWidget {
  final Widget child;
  final double distance;

  const Floating({super.key, required this.child, this.distance = 10});

  @override
  State<Floating> createState() => _FloatingState();
}

class _FloatingState extends State<Floating>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -widget.distance * _c.value),
        child: child,
      ),
      child: widget.child,
    );
  }
}
