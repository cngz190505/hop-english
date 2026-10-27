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
  _LessonInfo('Sayılar', 0.64, 0.24, Color(0xFF14B8A6), Color(0xFF0F9488)),
  _LessonInfo('Aile', 0.40, 0.12, Color(0xFFFFC800), Color(0xFFE0A800)),
  // ÜNİTE 2 (bg_map2.png, yol altta sol başlar, köprüden geçip limana çıkar).
  // İçerikleri henüz yok: kilitli görünür. İçerik gelince lessonsContent/lessonTitles'a eklenir.
  _LessonInfo('Araçlar', 0.32, 0.86, Color(0xFFEF5350), Color(0xFFC62828)),
  _LessonInfo('Vücut', 0.64, 0.70, Color(0xFF8B5CF6), Color(0xFF6D3FD0)),
  _LessonInfo('Cümle Kurma', 0.36, 0.54, Color(0xFF58CC02), Color(0xFF46A302)),
  _LessonInfo('Günlük İfadeler', 0.62, 0.38, Color(0xFF1CB0F6), Color(0xFF1288C9)),
  _LessonInfo('Alışveriş', 0.38, 0.22, Color(0xFFFF6FA8), Color(0xFFE04F89)),
];

/// Ünite: kendi arka plan resmi ve _lessons içindeki ders aralığı (hepsi aynı 704x1504 oranında).
class _Unit {
  final String name;
  final String bg;
  final int start; // _lessons içinde ilk dersin sırası
  final int count;
  const _Unit(this.name, this.bg, this.start, this.count);
}

const _units = [
  _Unit('Ünite 1', 'assets/ready/bg_map.png', 0, 7),
  _Unit('Ünite 2', 'assets/ready/bg_map2.png', 7, 5),
];

/// İçeriği hazır ders sayısı (lessonsContent ile aynı).
final _playableLessons = lessonsContent.length;

_Status _statusOf(int i, int completed) {
  if (i < completed) return _Status.done;
  if (i == completed && i < _playableLessons) return _Status.current;
  if (kUnlockAll) return _Status.current; // TEST: içeriği olmayanlar dahil hepsi açık görünür
  return _Status.locked;
}

class LessonMapTab extends StatefulWidget {
  const LessonMapTab({super.key});

  @override
  State<LessonMapTab> createState() => _LessonMapTabState();
}

class _LessonMapTabState extends State<LessonMapTab> {
  int _unit = 0;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) => _content(context, top),
    );
  }

  Widget _content(BuildContext context, double top) {
    final unit = _units[_unit];
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;
        // Kartların ortası bu iki çizgi arasına sığar: üstte ünite çubuğu, altta ilerleme kartı.
        final yTop = top + 10 + 52 + 14 + 32;
        final yBottom = h - 12 - 66 - 14 - 32;
        final usable = yBottom - yTop;
        final n = unit.count;
        // Kartlar aralarında eşit boşlukla dizilir, çok seyrek olmasın diye üst sınır var.
        final step = n > 1 ? (usable / (n - 1)).clamp(0.0, 112.0) : 0.0;
        final y0 = yBottom - (usable - step * (n - 1)) / 2; // ilk dersin (en alttaki) ortası
        return Stack(
          children: [
            // Tam ekran harita: resim ekranı kaplar (oran bozulmaz, fazlalık kırpılır).
            Positioned.fill(
              child: RepaintBoundary(
                child: Image(
                  image: AssetImage(unit.bg),
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
              ),
            ),
            // Kartları birbirine bağlayan beyaz yol çizgisi (kartların altında kalır).
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _PathPainter([
                    for (var k = 0; k < n; k++) Offset(_centerX(unit.start + k, w), y0 - k * step),
                  ]),
                ),
              ),
            ),
            for (var k = 0; k < n; k++) ..._buildLesson(context, unit.start + k, y0 - k * step, w),
            Positioned(
              top: top + 10,
              left: 16,
              right: 16,
              child: _UnitBar(
                selected: _unit,
                onSelect: (u) {
                  if (u == _unit) return;
                  Fx.tap();
                  setState(() => _unit = u);
                },
              ),
            ),
            Positioned(left: 16, right: 16, bottom: 12, child: _TotalCard(unit: unit)),
          ],
        );
      },
    );
  }

  /// Kartın yatay ortası (_buildLesson ile aynı hesap: ekrandan taşmaz).
  double _centerX(int i, double w) {
    final pillW = (w - 24).clamp(0.0, 236.0);
    final left = (_lessons[i].fx * w - pillW / 2).clamp(12.0, w - pillW - 12).toDouble();
    return left + pillW / 2;
  }

  List<Widget> _buildLesson(BuildContext context, int i, double y, double w) {
    final l = _lessons[i];
    final status = _statusOf(i, AppState.instance.completedLessons);
    final x = l.fx * w;
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
              : kUnlockAll
                  // TEST: içeriği olmayan ders açık görünür ama dokununca uyarır.
                  ? () {
                      ScaffoldMessenger.maybeOf(context)
                        ?..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(content: Text('Bu dersin içeriği henüz hazır değil.')),
                        );
                    }
                  : null,
        ),
      ),
    ];
  }
}

/// Kartların ortalarından geçen yumuşak "S" şeklinde beyaz yol çizgisi.
/// Altında hafif bir gölge çizgisi vardır (blur yok, ucuz). Sadece nokta değişince yeniden çizilir.
class _PathPainter extends CustomPainter {
  final List<Offset> pts; // en alttaki (1.) dersten yukarı doğru
  const _PathPainter(this.pts);

  @override
  void paint(Canvas canvas, Size size) {
    if (pts.length < 2) return;
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (var k = 1; k < pts.length; k++) {
      final a = pts[k - 1];
      final b = pts[k];
      final midY = (a.dy + b.dy) / 2;
      path.cubicTo(a.dx, midY, b.dx, midY, b.dx, b.dy);
    }
    final shadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x26000000);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xE6FFFFFF);
    canvas.drawPath(path.shift(const Offset(0, 2)), shadow);
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(_PathPainter old) {
    if (old.pts.length != pts.length) return true;
    for (var k = 0; k < pts.length; k++) {
      if (old.pts[k] != pts[k]) return true;
    }
    return false;
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

/// Üst çubuk: [Ünite 1] ---(toplam ilerleme, elmas işaretli)--- [Ünite 2].
/// Ünite adına dokununca o ünitenin haritası açılır.
class _UnitBar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  const _UnitBar({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xE6FFFFFF),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(color: Color(0x261C6BA8), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          _UnitChip(label: _units[0].name, selected: selected == 0, onTap: () => onSelect(0)),
          const Expanded(child: _UnitTrack()),
          _UnitChip(label: _units[1].name, selected: selected == 1, onTap: () => onSelect(1)),
        ],
      ),
    );
  }
}

/// İki ünite arasındaki çizgi: tamamlanan ders oranı kadar mavi, elmas ilerlemeyi gösterir.
class _UnitTrack extends StatelessWidget {
  const _UnitTrack();

  @override
  Widget build(BuildContext context) {
    final total = _units.fold<int>(0, (a, u) => a + u.count);
    final done = AppState.instance.completedLessons.clamp(0, total);
    final a = (done * 100 / total).round();
    final b = 100 - a;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          if (a > 0) Expanded(flex: a, child: const _TrackBar(color: kBlue)),
          Image.asset('assets/ready/icon_gem.png', height: 22, cacheHeight: 66),
          if (b > 0) Expanded(flex: b, child: const _TrackBar(color: Color(0xFFDDE5EE))),
        ],
      ),
    );
  }
}

class _TrackBar extends StatelessWidget {
  final Color color;
  const _TrackBar({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
    );
  }
}

class _UnitChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _UnitChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? kBlue : const Color(0x00FFFFFF),
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? const [BoxShadow(color: kBlueDark, offset: Offset(0, 3))]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: selected ? Colors.white : kMuted,
          ),
        ),
      ),
    );
  }
}

/// Alt kart: ünite adı, tamamlanan/toplam ders ve ders başına bir parça olan ilerleme çubuğu.
class _TotalCard extends StatelessWidget {
  final _Unit unit;
  const _TotalCard({required this.unit});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final n = unit.count;
        final done = (AppState.instance.completedLessons - unit.start).clamp(0, n);
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          decoration: cardDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${unit.name}: $n ders  •  $done/$n tamamlandı',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: kInk,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (var k = 0; k < n; k++) ...[
                    if (k > 0) const SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: k < done ? kGreen : const Color(0xFFDDE5EE),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
