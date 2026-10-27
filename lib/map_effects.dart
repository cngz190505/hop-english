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
  int sparks = 0, // başlangıç noktasından saçılan parıltı sayısı (0 = yok)
  int stagger = 130, // iki kristal arası (ms)
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
      sparks: sparks,
      stagger: stagger,
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
  final int sparks;
  final int stagger;
  final VoidCallback onDone;
  const _GemFlight({
    required this.from,
    required this.to,
    required this.count,
    required this.label,
    required this.onLand,
    required this.sparks,
    required this.stagger,
    required this.onDone,
  });

  @override
  State<_GemFlight> createState() => _GemFlightState();
}

class _GemFlightState extends State<_GemFlight> with SingleTickerProviderStateMixin {
  static const _fly = 750; // bir kristalin uçuş süresi (ms)
  static const _size = 30.0;

  late final AnimationController _c;
  late final List<bool> _landed;
  late final int _totalMs;

  @override
  void initState() {
    super.initState();
    _landed = List<bool>.filled(widget.count, false);
    _totalMs = (widget.count - 1) * widget.stagger + _fly;
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
      if (!_landed[k] && ms >= k * widget.stagger + _fly) {
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
                if (ms > k * widget.stagger && ms < k * widget.stagger + _fly)
                  _gem(k, ((ms - k * widget.stagger) / _fly).clamp(0.0, 1.0).toDouble()),
              // Parıltılar: ilk 700 ms'de dışa saçılır, küçülüp silinir.
              if (widget.sparks > 0 && ms < 700) ..._sparks(ms / 700),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _sparks(double t) {
    final e = Curves.easeOut.transform(t);
    return [
      for (var k = 0; k < widget.sparks; k++)
        Positioned(
          left: widget.from.dx + math.cos(k / widget.sparks * math.pi * 2) * (50 + (k * 37) % 60) * e - 4.5,
          top: widget.from.dy + math.sin(k / widget.sparks * math.pi * 2) * (50 + (k * 37) % 60) * e - 4.5,
          child: Opacity(
            opacity: 1 - t,
            child: Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Color(0xFFFFE27A), blurRadius: 6, spreadRadius: 2)],
              ),
            ),
          ),
        ),
    ];
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

/// Ekranın ortasında kısa süre beliren kutlama kartı (ör. "Ünite 1 tamamlandı!").
/// Yaklaşık 2,2 sn sürer: büyüyerek gelir, bekler, solar. Dokunmayı engellemez.
Future<void> showUnitToast(BuildContext context, {required String title, required String subtitle}) {
  final done = Completer<void>();
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) {
    done.complete();
    return done.future;
  }
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _UnitToast(
      title: title,
      subtitle: subtitle,
      onDone: () {
        entry.remove();
        if (!done.isCompleted) done.complete();
      },
    ),
  );
  overlay.insert(entry);
  return done.future;
}

class _UnitToast extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback onDone;
  const _UnitToast({required this.title, required this.subtitle, required this.onDone});

  @override
  State<_UnitToast> createState() => _UnitToastState();
}

class _UnitToastState extends State<_UnitToast> with SingleTickerProviderStateMixin {
  static const _totalMs = 2300;
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: _totalMs))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) widget.onDone();
      })
      ..forward();
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
        builder: (context, child) {
          final ms = _c.value * _totalMs;
          final inT = (ms / 400).clamp(0.0, 1.0).toDouble();
          final outT = ((ms - (_totalMs - 350)) / 350).clamp(0.0, 1.0).toDouble();
          return Align(
            alignment: const Alignment(0, -0.1),
            child: Opacity(
              opacity: 1 - outT,
              child: Transform.scale(scale: 0.5 + 0.5 * Curves.easeOutBack.transform(inT), child: child),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFD54A), Color(0xFFFFAB00)],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white, width: 5),
            boxShadow: const [
              BoxShadow(color: Color(0xFFB36B00), offset: Offset(0, 8)),
              BoxShadow(color: Color(0x66000000), blurRadius: 10, offset: Offset(0, 12)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF5A3500),
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF5A3500),
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
