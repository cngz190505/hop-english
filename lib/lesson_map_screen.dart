import 'package:flutter/material.dart';
import 'app_state.dart';
import 'lesson_data.dart';
import 'lesson_screen.dart';
import 'theme.dart';

enum _Status { done, current, locked }

class _LessonInfo {
  final String title;
  // Konum: haritanın genişliğine (fx) ve yüksekliğine (fy) oranla 0..1.
  // Düğümler yolun üstünde durur; kaydırmak istersen sadece bu sayıları değiştir.
  final double fx;
  final double fy;
  const _LessonInfo(this.title, this.fx, this.fy);
}

const _lessons = [
  _LessonInfo('Selamlaşma', 0.63, 0.91),
  _LessonInfo('Kendini Tanıtma', 0.45, 0.77),
  _LessonInfo('Günlük İfadeler', 0.42, 0.63),
  _LessonInfo('Sosyal Hayat', 0.64, 0.50),
  _LessonInfo('Alışveriş', 0.40, 0.37),
];

/// Toplam ders sayısı (_lessons listesiyle aynı olmalı).
const _lessonsCount = 5;

/// İçeriği hazır ders sayısı (lessonsContent ile aynı).
final _playableLessons = lessonsContent.length;

// bg_map.png oranı (704 x 1504)
const _mapAspect = 1504 / 704;

_Status _statusOf(int i, int completed) {
  if (i < completed) return _Status.done;
  if (i == completed && i < _playableLessons) return _Status.current;
  return _Status.locked;
}

class LessonMapTab extends StatelessWidget {
  const LessonMapTab({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) => _content(context, top),
    );
  }

  Widget _content(BuildContext context, double top) {
    return Stack(
      children: [
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final h = w * _mapAspect;
              return SingleChildScrollView(
                // Harita en alttan (1. dersten) başlar, yukarı doğru ilerler.
                reverse: true,
                padding: const EdgeInsets.only(bottom: 96),
                child: SizedBox(
                  width: w,
                  height: h,
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: RepaintBoundary(
                          child: Image(
                            image: AssetImage('assets/ready/bg_map.png'),
                            fit: BoxFit.fill,
                            gaplessPlayback: true,
                          ),
                        ),
                      ),
                      for (var i = 0; i < _lessons.length; i++)
                        ..._buildLesson(context, i, w, h),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          top: top + 10,
          left: 0,
          right: 0,
          child: const Center(child: _TitlePill()),
        ),
        const Positioned(left: 16, right: 16, bottom: 12, child: _TotalCard()),
      ],
    );
  }

  List<Widget> _buildLesson(BuildContext context, int i, double w, double h) {
    final l = _lessons[i];
    final status = _statusOf(i, AppState.instance.completedLessons);
    final x = l.fx * w;
    final y = l.fy * h;
    return [
      if (status == _Status.current)
        Positioned(
          left: x - 80 - 70,
          top: y - 40,
          child: Image.asset(
            'assets/ready/mascot_wave.png',
            height: 84,
            cacheHeight: 252,
            gaplessPlayback: true,
          ),
        ),
      Positioned(
        left: x - 80,
        top: y - 32,
        width: 160,
        child: _LessonNode(
          number: i + 1,
          title: l.title,
          status: status,
          // İçeriği hazır olan her ders (bitmiş de olsa) istenen yerden açılır.
          onTap: i < _playableLessons ? () => openLesson(context, i) : null,
        ),
      ),
    ];
  }
}

class _LessonNode extends StatelessWidget {
  final int number;
  final String title;
  final _Status status;
  final VoidCallback? onTap;
  const _LessonNode({
    required this.number,
    required this.title,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color;
    final Color shadow;
    switch (status) {
      case _Status.done:
        color = kGreen;
        shadow = kGreenDark;
      case _Status.current:
        color = kBlue;
        shadow = kBlueDark;
      case _Status.locked:
        color = kLocked;
        shadow = kLockedDark;
    }
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [BoxShadow(color: shadow, offset: const Offset(0, 5))],
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xEBFFFFFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: status == _Status.locked ? kMuted : kInk,
                    ),
                  ),
                ),
                if (status == _Status.done) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.check_circle_rounded, size: 16, color: kGreen),
                ],
                if (status == _Status.locked) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.lock_rounded, size: 14, color: kMuted),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TitlePill extends StatelessWidget {
  const _TitlePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xEBFFFFFF),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0x261C6BA8), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: const Text(
        'Ders Haritası',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kInk),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final done = AppState.instance.completedLessons.clamp(0, _lessonsCount);
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          decoration: cardDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Toplam $_lessonsCount ders  •  $done/$_lessonsCount tamamlandı',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: kInk,
                ),
              ),
              const SizedBox(height: 8),
              ProgressBar(value: done / _lessonsCount, height: 10),
            ],
          ),
        );
      },
    );
  }
}
