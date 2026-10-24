import 'package:flutter/material.dart';
import 'fx.dart';
import 'app_state.dart';
import 'debug_tools.dart';
import 'lesson_data.dart';
import 'lesson_screen.dart';
import 'theme.dart';

enum _Status { done, current, locked }

class _LessonInfo {
  final String title;
  // Konum: haritanın genişliğine (fx) ve yüksekliğine (fy) oranla 0..1.
  // Kartlar yolun üstünde durur; kaydırmak istersen sadece bu sayıları değiştir.
  final double fx;
  final double fy;
  final Color color; // ders numarası dairesinin rengi
  final Color shadow; // dairenin alt gölgesi (koyu ton)
  const _LessonInfo(this.title, this.fx, this.fy, this.color, this.shadow);
}

const _lessons = [
  _LessonInfo('Selamlaşma', 0.63, 0.91, Color(0xFF58CC02), Color(0xFF46A302)),
  _LessonInfo('Kendini Tanıtma', 0.45, 0.77, Color(0xFF8B5CF6), Color(0xFF6D3FD0)),
  _LessonInfo('Meyveler', 0.42, 0.63, Color(0xFF1CB0F6), Color(0xFF1288C9)),
  _LessonInfo('Hayvanlar', 0.64, 0.50, Color(0xFFFF9600), Color(0xFFE08400)),
  _LessonInfo('Renkler', 0.40, 0.37, Color(0xFFFF6FA8), Color(0xFFE04F89)),
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
  if (kUnlockAll && i < _playableLessons) return _Status.current; // TEST: hepsi açık
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
          left: 16,
          right: 16,
          child: const _Header(),
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
    final pillW = (w - 24).clamp(0.0, 236.0);
    final left = (x - pillW / 2).clamp(12.0, w - pillW - 12);
    // Maskot, kartın yanında boş yeri daha geniş olan tarafta durur.
    final roomLeft = left;
    final roomRight = w - (left + pillW);
    final mascotLeft = roomLeft >= roomRight ? left - 74.0 : left + pillW + 4;
    return [
      if (status == _Status.current && i == AppState.instance.completedLessons)
        Positioned(
          left: mascotLeft,
          top: y - 44,
          child: Image.asset(
            'assets/ready/mascot_wave.png',
            height: 88,
            cacheHeight: 264,
            gaplessPlayback: true,
          ),
        ),
      Positioned(
        left: left,
        top: y - 32,
        width: pillW,
        child: _LessonCard(
          number: i + 1,
          info: l,
          status: status,
          // İçeriği hazır olan her ders (bitmiş de olsa) istenen yerden açılır.
          onTap: i < _playableLessons
              ? () {
                  Fx.tap();
                  openLesson(context, i);
                }
              : null,
        ),
      ),
    ];
  }
}

/// Haritadaki ders kartı: solda renkli numara dairesi, ortada ders adı, sağda durum simgesi
/// (tamam: yeşil tik, sıradaki: oynat, kilitli: kilit).
class _LessonCard extends StatelessWidget {
  final int number;
  final _LessonInfo info;
  final _Status status;
  final VoidCallback? onTap;
  const _LessonCard({
    required this.number,
    required this.info,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locked = status == _Status.locked;
    final current = status == _Status.current;
    final circle = locked ? kLocked : info.color;
    final circleShadow = locked ? kLockedDark : info.shadow;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 64,
        padding: const EdgeInsets.fromLTRB(8, 0, 12, 0),
        decoration: BoxDecoration(
          color: const Color(0xF2FFFFFF),
          borderRadius: BorderRadius.circular(32),
          // Sıradaki ders: kendi renginde kalın çerçeve.
          border: current ? Border.all(color: info.color, width: 3) : null,
          boxShadow: const [
            BoxShadow(color: Color(0x261C6BA8), blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: circle,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [BoxShadow(color: circleShadow, offset: const Offset(0, 3))],
              ),
              child: Text(
                '$number',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                info.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                  color: locked ? kMuted : kInk,
                ),
              ),
            ),
            const SizedBox(width: 6),
            if (status == _Status.done)
              const Icon(Icons.check_circle_rounded, size: 26, color: kGreen)
            else if (current)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: info.color, shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow_rounded, size: 20, color: Colors.white),
              )
            else
              const Icon(Icons.lock_rounded, size: 22, color: kLockedDark),
          ],
        ),
      ),
    );
  }
}

/// Üst başlık: "Ders Haritası", alt yazı ve elmas sayısı.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xF2FFFFFF),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0x261C6BA8), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ders Haritası',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: kInk,
                  ),
                ),
                Text(
                  'İngilizce yolculuğunda ilerle!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kMuted,
                  ),
                ),
              ],
            ),
          ),
          ListenableBuilder(
            listenable: AppState.instance,
            builder: (context, _) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F5FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/ready/icon_gem.png', height: 22, cacheHeight: 66),
                  const SizedBox(width: 6),
                  Text(
                    '${AppState.instance.gems}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: kBlueDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
