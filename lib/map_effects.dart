import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Sayfa geçişlerini izler. Ders bitip haritaya dönünce kristal/ejderha animasyonu başlasın diye
/// main.dart'ta MaterialApp'e navigatorObservers olarak eklenir.
final RouteObserver<ModalRoute<void>> mapRouteObserver = RouteObserver<ModalRoute<void>>();

/// Kristalleri [from] noktasından [to] noktasına uçurur (ikisi de ekran koordinatı).
/// Her kristal varınca [onLand] çağrılır (kaçıncı kristal olduğuyla). Hepsi bitince Future tamamlanır.
/// [label]: uçuşun başında yukarı süzülen "+5" yazısındaki sayı.
Future<void> flyGems({
  required BuildContext context,
  required Offset from,
  required Offset to,
  required int count,
  required int label,
  required void Function(int index) onLand,
}) {
  final done = Completer<void>();
  final overlay = Overlay.maybeOf(context);
  if (overlay == null || count <= 0) {
    for (var k = 0; k < count; k++) {
      onLand(k);
    }
    done.complete();
    return done.future;
  }
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _GemFlight(
      from: from,
      to: to,
      count: count,
      label: label,
      onLand: onLand,
      onDone: () {
        entry.remove();
        if (!done.isCompleted) done.complete();
      },
    ),
  );
  overlay.insert(entry);
  return done.future;
}

/// Tek bir animasyon kontrolcüsüyle tüm kristalleri uçurur (hafif: birkaç küçük resim).
class _GemFlight extends StatefulWidget {
  final Offset from;
  final Offset to;
  final int count;
  final int label;
  final void Function(int index) onLand;
  final VoidCallback onDone;
  const _GemFlight({
    required this.from,
    required this.to,
    required this.count,
    required this.label,
    required this.onLand,
    required this.onDone,
  });

  @override
  State<_GemFlight> createState() => _GemFlightState();
}

class _GemFlightState extends State<_GemFlight> with SingleTickerProviderStateMixin {
  static const _stagger = 130; // iki kristal arası (ms)
  static const _fly = 750; // bir kristalin uçuş süresi (ms)
  static const _size = 30.0;

  late final AnimationController _c;
  late final List<bool> _landed;
  late final int _totalMs;

  @override
  void initState() {
    super.initState();
    _landed = List<bool>.filled(widget.count, false);
    _totalMs = (widget.count - 1) * _stagger + _fly;
    _c = AnimationController(vsync: this, duration: Duration(milliseconds: _totalMs))
      ..addListener(_tick)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) widget.onDone();
      })
      ..forward();
  }

  void _tick() {
    final ms = _c.value * _totalMs;
    for (var k = 0; k < widget.count; k++) {
      if (!_landed[k] && ms >= k * _stagger + _fly) {
        _landed[k] = true;
        widget.onLand(k);
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final ms = _c.value * _totalMs;
          final p = (ms / 900).clamp(0.0, 1.0).toDouble();
          return Stack(
            children: [
              // "+5" yazısı: yukarı süzülür ve silinir
              Positioned(
                left: widget.from.dx - 24,
                top: widget.from.dy - 46 - 40 * p,
                child: Opacity(
                  opacity: 1 - p,
                  child: Text(
                    '+${widget.label}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      shadows: [
                        Shadow(color: Color(0xFF2F3A9A), offset: Offset(0, 2)),
                        Shadow(color: Color(0xFF2F3A9A), blurRadius: 8),
                      ],
                    ),
                  ),
                ),
              ),
              for (var k = 0; k < widget.count; k++)
                if (ms > k * _stagger && ms < k * _stagger + _fly)
                  _gem(k, ((ms - k * _stagger) / _fly).clamp(0.0, 1.0).toDouble()),
            ],
          );
        },
      ),
    );
  }

  Widget _gem(int k, double t) {
    final start = widget.from + Offset((k - (widget.count - 1) / 2) * 14.0, 0);
    final e = Curves.easeInOut.transform(t);
    final pos = Offset.lerp(start, widget.to, e)! + Offset(0, -math.sin(math.pi * t) * 70);
    final scale = math.min(1.0, t * 6) * (1 - 0.3 * t);
    return Positioned(
      left: pos.dx - _size / 2,
      top: pos.dy - _size / 2,
      child: Transform.scale(
        scale: scale,
        child: Transform.rotate(
          angle: t * math.pi * 2,
          child: Image.asset(
            'assets/ready/icon_gem.png',
            width: _size,
            height: _size,
            cacheWidth: 90,
          ),
        ),
      ),
    );
  }
}
