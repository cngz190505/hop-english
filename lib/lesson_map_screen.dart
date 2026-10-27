import 'dart:math' as math;
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
  _LessonInfo('Selamlaşma', 0.64, 0.50, Color(0xFF58CC02), Color(0xFF46A302)),
  _LessonInfo('Kendini Tanıtma', 0.36, 0.50, Color(0xFF8B5CF6), Color(0xFF6D3FD0)),
  _LessonInfo('Meyveler', 0.64, 0.50, Color(0xFF1CB0F6), Color(0xFF1288C9)),
  _LessonInfo('Hayvanlar', 0.36, 0.50, Color(0xFFFF9600), Color(0xFFE08400)),
  _LessonInfo('Renkler', 0.64, 0.50, Color(0xFFFF6FA8), Color(0xFFE04F89)),
  _LessonInfo('Sayılar', 0.36, 0.50, Color(0xFF14B8A6), Color(0xFF0F9488)),
  // ÜNİTE 2 (ders 7-12). fy artık kullanılmıyor (kartlar ekrana eşit yayılır), fx sağ/sol dönüşümlü.
  // İçerikleri henüz yok: kilitli görünür. İçerik gelince lessonsContent/lessonTitles'a eklenir.
  _LessonInfo('Aile', 0.64, 0.50, Color(0xFFFFC800), Color(0xFFE0A800)),
  _LessonInfo('Araçlar', 0.36, 0.50, Color(0xFFEF5350), Color(0xFFC62828)),
  _LessonInfo('Vücut', 0.64, 0.50, Color(0xFF8B5CF6), Color(0xFF6D3FD0)),
  _LessonInfo('Cümle Kurma', 0.36, 0.50, Color(0xFF58CC02), Color(0xFF46A302)),
  _LessonInfo('Günlük İfadeler', 0.64, 0.50, Color(0xFF1CB0F6), Color(0xFF1288C9)),
  _LessonInfo('Alışveriş', 0.36, 0.50, Color(0xFFFF6FA8), Color(0xFFE04F89)),
];

/// Ünite: adı ve _lessons içindeki ders aralığı (arka plan kodla çizilir, resim yok).
class _Unit {
  final String name;
  final int start; // _lessons içinde ilk dersin sırası
  final int count;
  const _Unit(this.name, this.start, this.count);
}

const _units = [
  _Unit('Ünite 1', 0, 6),
  _Unit('Ünite 2', 6, 6),
];

/// Harita kartının yüksekliği (yerleşim bu sayıyla hesaplanır).
const double _cardH = 58;

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
        final yTop = top + 10 + 48 + 14 + _cardH / 2;
        final yBottom = h - 12 - 66 - 14 - _cardH / 2;
        final usable = yBottom - yTop;
        final n = unit.count;
        // Kartlar aralarında eşit boşlukla dizilir, çok seyrek olmasın diye üst sınır var.
        final step = n > 1 ? (usable / (n - 1)).clamp(0.0, 104.0) : 0.0;
        final y0 = yBottom - (usable - step * (n - 1)) / 2; // ilk dersin (en alttaki) ortası
        return Stack(
          children: [
            // Tam ekran arka plan: resim yok, kodla çizilir (gökyüzü, bulut, tepe/dalga). Ünite başına renk teması.
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(painter: _MapBgPainter(_unit)),
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
    final pillW = (w - 24).clamp(0.0, 232.0);
    final left = (_lessons[i].fx * w - pillW / 2).clamp(12.0, w - pillW - 12).toDouble();
    return left + pillW / 2;
  }

  List<Widget> _buildLesson(BuildContext context, int i, double y, double w) {
    final l = _lessons[i];
    final status = _statusOf(i, AppState.instance.completedLessons);
    final x = l.fx * w;
    final pillW = (w - 24).clamp(0.0, 232.0);
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
        top: y - _cardH / 2,
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

/// Arka plan: resim yerine kodla çizilen sahne. Ünite 0 = çayır (gökyüzü, tepeler, ağaçlar),
/// ünite 1 = kıyı (gökyüzü, dalgalar, yelkenli). Hepsi düz renk ve yol, blur yok, ucuz; sadece ünite değişince yeniden çizilir.
class _MapBgPainter extends CustomPainter {
  final int unit;
  const _MapBgPainter(this.unit);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;
    final meadow = unit == 0;

    // Gökyüzü degradesi
    final sky = meadow
        ? const [Color(0xFF4FB6F5), Color(0xFFBFEAFF), Color(0xFFDDF6C4)]
        : const [Color(0xFF3CC4D8), Color(0xFFCFF3F7), Color(0xFFFFEFC2)];
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: sky,
          stops: const [0.0, 0.55, 1.0],
        ).createShader(rect),
    );

    // Büyük yumuşak daireler (derinlik hissi)
    final blob = Paint()..color = const Color(0x2EFFFFFF);
    canvas.drawCircle(Offset(w * 0.95, h * 0.16), w * 0.40, blob);
    canvas.drawCircle(Offset(w * 0.02, h * 0.46), w * 0.30, blob);
    canvas.drawCircle(Offset(w * 0.92, h * 0.70), w * 0.34, blob);

    // Bulutlar
    _cloud(canvas, Offset(w * 0.20, h * 0.15), w * 0.075);
    _cloud(canvas, Offset(w * 0.78, h * 0.33), w * 0.06);
    _cloud(canvas, Offset(w * 0.30, h * 0.52), w * 0.05);

    // Küçük parıltılar
    final spark = Paint()..color = const Color(0x99FFFFFF);
    for (final f in const [
      Offset(0.08, 0.26),
      Offset(0.55, 0.20),
      Offset(0.90, 0.48),
      Offset(0.12, 0.64),
      Offset(0.70, 0.60),
      Offset(0.46, 0.40),
    ]) {
      canvas.drawCircle(Offset(w * f.dx, h * f.dy), 3, spark);
    }

    if (meadow) {
      _hill(canvas, size, h * 0.72, h * 0.05, 1, const Color(0xFFC6EDA3)); // uzak tepe
      _hill(canvas, size, h * 0.80, h * 0.05, -1, const Color(0xFF9EDD6C));
      for (final t in const [Offset(0.10, 0.80), Offset(0.88, 0.77), Offset(0.50, 0.83), Offset(0.28, 0.84)]) {
        _tree(canvas, Offset(w * t.dx, h * t.dy), w * 0.05);
      }
      _hill(canvas, size, h * 0.87, h * 0.04, 1, const Color(0xFF7BCB48));
      _hill(canvas, size, h * 0.93, h * 0.03, -1, const Color(0xFF5DB835));
    } else {
      _hill(canvas, size, h * 0.74, h * 0.03, 1, const Color(0xFF9BE3F0)); // uzak deniz
      _boat(canvas, Offset(w * 0.80, h * 0.745), w * 0.06);
      _boat(canvas, Offset(w * 0.18, h * 0.80), w * 0.045);
      _hill(canvas, size, h * 0.82, h * 0.03, -1, const Color(0xFF63CFE6));
      _hill(canvas, size, h * 0.88, h * 0.03, 1, const Color(0xFF3DB9DA));
      _hill(canvas, size, h * 0.94, h * 0.025, -1, const Color(0xFFFFE3A3)); // kum
    }
  }

  /// Yumuşak dalgalı bir şerit: y çizgisinden aşağısı dolu. phase 1 / -1 dalganın yönünü çevirir.
  void _hill(Canvas canvas, Size s, double y, double amp, int phase, Color color) {
    final w = s.width;
    final path = Path()
      ..moveTo(0, s.height)
      ..lineTo(0, y + amp * phase)
      ..cubicTo(w * 0.30, y - amp * phase, w * 0.60, y + amp * 1.2 * phase, w, y - amp * phase)
      ..lineTo(w, s.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _cloud(Canvas canvas, Offset c, double r) {
    final p = Paint()..color = const Color(0xD9FFFFFF);
    canvas.drawCircle(c, r, p);
    canvas.drawCircle(c.translate(r * 1.0, r * 0.25), r * 0.8, p);
    canvas.drawCircle(c.translate(-r * 1.0, r * 0.3), r * 0.7, p);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c.translate(0, r * 0.5), width: r * 3.2, height: r * 0.9),
        Radius.circular(r * 0.45),
      ),
      p,
    );
  }

  void _tree(Canvas canvas, Offset base, double r) {
    canvas.drawRect(
      Rect.fromCenter(center: base.translate(0, -r * 0.4), width: r * 0.35, height: r * 0.9),
      Paint()..color = const Color(0xFF8D6E4A),
    );
    canvas.drawCircle(base.translate(0, -r * 1.3), r, Paint()..color = const Color(0xFF4DAA2E));
    canvas.drawCircle(base.translate(-r * 0.35, -r * 1.5), r * 0.45, Paint()..color = const Color(0xFF6CC84A));
  }

  void _boat(Canvas canvas, Offset base, double r) {
    canvas.drawPath(
      Path()
        ..moveTo(base.dx - r, base.dy)
        ..lineTo(base.dx + r, base.dy)
        ..lineTo(base.dx + r * 0.6, base.dy + r * 0.45)
        ..lineTo(base.dx - r * 0.6, base.dy + r * 0.45)
        ..close(),
      Paint()..color = const Color(0xFFE5574B),
    );
    canvas.drawPath(
      Path()
        ..moveTo(base.dx, base.dy - r * 1.6)
        ..lineTo(base.dx + r * 0.8, base.dy - r * 0.1)
        ..lineTo(base.dx, base.dy - r * 0.1)
        ..close(),
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_MapBgPainter old) => old.unit != unit;
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
    final band = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x40FFFFFF);
    canvas.drawPath(path, band);
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

/// Dersin ilerlemesi 0..1: bitti = 1, yarıda kaldıysa kelime/soru sırasına göre (ilk yarı ders, ikinci yarı quiz).
double _progressOf(int index, bool done) {
  if (done) return 1;
  final r = AppState.instance.resumeFor(index);
  if (r == null) return 0;
  final i = (r['i'] as num?) ?? 0;
  if (r['stage'] == 'quiz') {
    final t = (r['total'] as num?) ?? 0;
    return t > 0 ? 0.5 + 0.5 * (i / t).clamp(0.0, 1.0).toDouble() : 0.5;
  }
  final n = (r['n'] as num?) ?? 1;
  return 0.5 * (i / n).clamp(0.0, 1.0).toDouble();
}

/// Numara dairesinin çevresindeki halka: soluk iz + ilerleme yayı (üstten saat yönünde).
class _RingPainter extends CustomPainter {
  final Color color;
  final double progress;
  const _RingPainter(this.color, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(2.5);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = color.withAlpha(60);
    canvas.drawArc(rect, 0, math.pi * 2, false, track);
    if (progress > 0) {
      final arc = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = color;
      canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, arc);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.color != color || old.progress != progress;
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
        height: _cardH,
        padding: const EdgeInsets.fromLTRB(5, 0, 14, 0),
        // Uçları köşeli (altıgen) kart: ince renkli çerçeve, sıradaki derste kalın.
        decoration: ShapeDecoration(
          color: const Color(0xF2FFFFFF),
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(
              color: locked ? kLocked : info.color,
              width: current ? 2.5 : 1.5,
            ),
          ),
          shadows: const [
            BoxShadow(color: Color(0x261C6BA8), blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            // Numara dairesi ve çevresinde ders ilerleme halkası (bitti: tam, yarıda: kısmen).
            SizedBox(
              width: 48,
              height: 48,
              child: CustomPaint(
                painter: _RingPainter(
                  locked ? kLocked : info.color,
                  locked ? 0 : _progressOf(number - 1, status == _Status.done),
                ),
                child: Center(
                  child: Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: circle,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: circleShadow, offset: const Offset(0, 3))],
                    ),
                    child: Text(
                      '$number',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
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
      height: 48,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xE6FFFFFF),
        borderRadius: BorderRadius.circular(24),
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
        height: 38,
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
