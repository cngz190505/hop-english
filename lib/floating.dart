import 'package:flutter/material.dart';

/// Çocuğunu yaylanır gibi hareket ettirir:
/// yumuşak yukarı aşağı süzülme + hafif esneme (yay etkisi).
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
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  late final Animation<double> _t = CurvedAnimation(
    parent: _c,
    curve: Curves.easeInOutSine,
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (context, child) {
        final v = _t.value;
        return Transform.translate(
          offset: Offset(0, -widget.distance * v),
          child: Transform(
            alignment: Alignment.bottomCenter,
            transform: Matrix4.diagonal3Values(
              1.0 - 0.025 * v,
              1.0 + 0.04 * v,
              1.0,
            ),
            child: child,
          ),
        );
      },
      child: RepaintBoundary(child: widget.child),
    );
  }
}
