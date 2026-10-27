import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'fx.dart';
import 'app_state.dart';
import 'debug_tools.dart';
import 'lesson_data.dart';
import 'lesson_screen.dart';
import 'map_effects.dart';
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

/// Hazine sandığı: yatay yeri (genişliğe oran), görsel boyu ve yarım genişliği (ejderha yeri için).
const double _chestFx = 0.64;
const double _chestImg = 60;
const double _chestHalfW = 40;

/// Ders bitince kartın yıldızları sırayla yanar: hangi ders ve kaç yıldız yanık (lesson -1 = yok).
class _StarFx {
  final int lesson;
  final int lit;
  const _StarFx(this.lesson, this.lit);
}

/// İçeriği hazır ders sayısı (lessonsContent ile aynı).
final _playableLessons = lessonsContent.length;

_Status _statusOf(int i, int completed) {
  if (i < completed) return _Status.done;
  if (i == completed && i < _playableLessons) return _Status.current;
  if (kUnlockAll) return _Status.current; // TEST: içeriği olmayanlar dahil hepsi açık görünür
  return _Status.locked;
}

class LessonMapTab extends StatefulWidget {
  /// [active]: Dersler sekmesi şu an açık mı (sekmeye geçince animasyon başlasın diye).
  const LessonMapTab({super.key, this.active = true});
  final bool active;

  @override
  State<LessonMapTab> createState() => _LessonMapTabState();
}

class _LessonMapTabState extends State<LessonMapTab> with SingleTickerProviderStateMixin, RouteAware {
  // Açılışta sıradaki dersin (ya da açılmayı bekleyen hazinenin) bulunduğu ünite görünür.
  late int _unit = _initialUnit();

  static int _initialUnit() {
    final c = AppState.instance.completedLessons;
    for (var u = 0; u < _units.length; u++) {
      final end = _units[u].start + _units[u].count;
      if (c < end) return u;
      if (c == end && !AppState.instance.chestOpened(u)) return u;
    }
    return _units.length - 1;
  }

  // Ekranda gösterilen tamamlanan ders sayısı. Ders bitince AppState hemen artar; harita önce
  // kristalleri toplatır, sonra ejderhayı yürütür, bu sayı en son güncellenir.
  late int _shown = AppState.instance.completedLessons;
  bool _playing = false;
  bool _walking = false;
  int _walkFrom = 0;
  int _walkSteps = 1;
  late final AnimationController _walk =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  final ValueNotifier<bool> _pulse = ValueNotifier<bool>(false);
  final ValueNotifier<_StarFx> _starFx = ValueNotifier<_StarFx>(const _StarFx(-1, 0));
  final GlobalKey _gemKey = GlobalKey();
  final GlobalKey _chestKey = GlobalKey();
  // Ekranda açık gösterilen hazineler (AppState'ten kopya: patlama bitene kadar sandık kapalı görünür).
  late final Set<int> _chestDone = {...AppState.instance.chestsOpened};
  bool _chestBusy = false;
  ModalRoute<void>? _route;
  // Son çizimdeki yerleşim (kristal ve ejderha nereden nereye gidecek bilmek için).
  double _w = 0;
  double _y0 = 0;
  double _step = 0;

  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_maybePlay);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute<void>? r = ModalRoute.of<void>(context);
    if (r != null && r != _route) {
      mapRouteObserver.unsubscribe(this);
      _route = r;
      mapRouteObserver.subscribe(this, r);
    }
  }

  @override
  void didUpdateWidget(LessonMapTab old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) _maybePlay();
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_maybePlay);
    mapRouteObserver.unsubscribe(this);
    _walk.dispose();
    _pulse.dispose();
    _starFx.dispose();
    super.dispose();
  }

  /// Ders/quiz/sonuç ekranı kapanıp harita yeniden görününce çağrılır.
  @override
  void didPopNext() => _maybePlay();

  /// Yeni bitmiş bir ders varsa ve harita ekranda görünüyorsa animasyonu başlatır.
  void _maybePlay() {
    if (!mounted || _playing || !widget.active) return;
    final route = _route;
    if (route != null && !route.isCurrent) return; // üstte ders/quiz/sonuç ekranı var
    final c = AppState.instance.completedLessons;
    if (c == _shown) return;
    if (c < _shown) {
      setState(() => _shown = c);
      return;
    }
    _playing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _play());
  }

  /// Bir kristal elmasa varınca: ding sesi, elmas kısa büyür.
  void _onGemLand(int k) {
    Fx.gem(k);
    _pulse.value = true;
    Future.delayed(const Duration(milliseconds: 140), () {
      if (mounted) _pulse.value = false;
    });
  }

  /// Ünite sonundaki hazineye dokununca: elmaslar saçılıp uçar, kutlama kartı çıkar.
  /// Hazine ancak ünitedeki tüm dersler bitince açılır, bir kez alınır (AppState.openChest).
  Future<void> _openChest(int u) async {
    if (_chestBusy || _playing || _walking || _chestDone.contains(u)) return;
    final unit = _units[u];
    if (_shown < unit.start + unit.count) {
      Fx.tap();
      ScaffoldMessenger.maybeOf(context)
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Hazineyi açmak için ${unit.name} içindeki tüm dersleri bitir.')),
        );
      return;
    }
    final chestBox = _chestKey.currentContext?.findRenderObject() as RenderBox?;
    final gemBox = _gemKey.currentContext?.findRenderObject() as RenderBox?;
    _chestBusy = true;
    try {
      if (!AppState.instance.openChest(u)) return;
      Fx.reward();
      if (chestBox != null && gemBox != null && chestBox.hasSize && gemBox.hasSize) {
        await flyGems(
          context: context,
          from: chestBox.localToGlobal(chestBox.size.center(Offset.zero)),
          to: gemBox.localToGlobal(gemBox.size.center(Offset.zero)),
          count: AppState.chestGems.clamp(1, 8).toInt(),
          label: AppState.chestGems,
          sparks: 20,
          stagger: 90,
          onLand: _onGemLand,
        );
      }
      if (!mounted) return;
      setState(() => _chestDone.add(u));
      Fx.unitDone();
      await showUnitToast(context, title: '🎉 ${unit.name} tamamlandı!', subtitle: 'Hazine açıldı');
    } finally {
      _chestBusy = false;
    }
  }

  /// 1) Yıldızlar yanar, 2) kristaller biten dersten üst çubuktaki elmasa uçar, 3) ders "tamam" olur,
  /// 4) ejderha sıradaki derse (ünite bittiyse hazineye) yürür.
  Future<void> _play() async {
    try {
      if (!mounted) return;
      final c = AppState.instance.completedLessons;
      final unit = _units[_unit];
      final from = _shown;
      final unitEnd = unit.start + unit.count;
      final inUnit = from >= unit.start && from < unitEnd;
      final box = context.findRenderObject() as RenderBox?;
      final gemBox = _gemKey.currentContext?.findRenderObject() as RenderBox?;
      final route = _route;
      if (!inUnit ||
          box == null ||
          gemBox == null ||
          !box.hasSize ||
          !gemBox.hasSize ||
          (route != null && !route.isCurrent)) {
        setState(() => _shown = c); // animasyonsuz güncelle
        return;
      }
      // 1) Biten dersin 3 yıldızı sırayla yanar (her yıldızda yükselen nota).
      for (var k = 0; k < 3; k++) {
        await Future.delayed(const Duration(milliseconds: 260));
        if (!mounted) return;
        _starFx.value = _StarFx(from, k + 1);
        Fx.star(k);
      }
      await Future.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      // 2) Kristaller elmasa uçar.
      final start = box.localToGlobal(Offset(_centerX(from, _w), _y0 - (from - unit.start) * _step));
      final end = gemBox.localToGlobal(gemBox.size.center(Offset.zero));
      final earned = (c - from) * AppState.gemReward;
      await flyGems(
        context: context,
        from: start,
        to: end,
        count: earned.clamp(1, 8).toInt(),
        label: earned,
        onLand: _onGemLand,
      );
      if (!mounted) return;
      // 3) Ders "tamam" olur, ejderha sıradaki derse (ünite bittiyse hazineye) yürür.
      final canWalk = c <= unitEnd;
      setState(() {
        _shown = c;
        _walkFrom = from;
        _walkSteps = (c - from).clamp(1, unit.count).toInt();
        _walking = canWalk;
      });
      _starFx.value = const _StarFx(-1, 0);
      if (canWalk) {
        _walk.duration = Duration(milliseconds: (_walkSteps * 700).clamp(700, 1600).toInt());
        await _walk.forward(from: 0);
        if (mounted) setState(() => _walking = false);
      }
    } finally {
      _playing = false;
      if (mounted) _maybePlay(); // animasyon sürerken başka ders bittiyse devam et
    }
  }

  /// Ünite içindeki k. sıranın yatay ortası (k == unit.count: hazine sandığı).
  double _slotCx(_Unit u, int k, double w) => k >= u.count ? _chestFx * w : _centerX(u.start + k, w);

  double _slotHalfW(_Unit u, int k, double w) =>
      k >= u.count ? _chestHalfW : (w - 24).clamp(0.0, 232.0).toDouble() / 2;

  /// Maskotun kartın (ya da sandığın) yanındaki durağan yeri (sol-üst köşe). Boş yeri geniş olan tarafta durur.
  Offset _mascotSpot(_Unit u, int k, double w, double y) {
    final cx = _slotCx(u, k, w);
    final hw = _slotHalfW(u, k, w);
    final left = cx - hw;
    final right = cx + hw;
    final mx = left >= w - right ? left - 74.0 : right + 4;
    return Offset(mx, y - 44);
  }

  Widget _dragonImage() => Image.asset(
        'assets/ready/mascot_wave.png',
        height: 88,
        cacheHeight: 264,
        gaplessPlayback: true,
      );

  Widget _staticDragon(_Unit u, int k, double y, double w) {
    final s = _mascotSpot(u, k, w, y);
    return Positioned(left: s.dx, top: s.dy, child: _dragonImage());
  }

  /// Ejderha yol çizgisini izleyerek zıplaya zıplaya sıradaki derse (ya da hazineye) gider.
  Widget _walkingDragon(_Unit unit, double w) {
    return AnimatedBuilder(
      animation: _walk,
      builder: (context, _) {
        final t = _walk.value * _walkSteps;
        final seg = t.floor().clamp(0, _walkSteps - 1).toInt();
        final lt = (t - seg).clamp(0.0, 1.0).toDouble();
        final ka = _walkFrom - unit.start + seg;
        final kb = ka + 1;
        final ya = _y0 - ka * _step;
        final yb = _y0 - kb * _step;
        final a = Offset(_slotCx(unit, ka, w), ya);
        final b = Offset(_slotCx(unit, kb, w), yb);
        final m = (ya + yb) / 2;
        final p1 = Offset(a.dx, m);
        final p2 = Offset(b.dx, m);
        final u = 1 - lt;
        // Yolun eğrisi (_PathPainter ile aynı): a -> b
        final road = a * (u * u * u) + p1 * (3 * u * u * lt) + p2 * (3 * u * lt * lt) + b * (lt * lt * lt);
        final oa = _mascotSpot(unit, ka, w, ya) - a;
        final ob = _mascotSpot(unit, kb, w, yb) - b;
        final hop = -(math.sin(lt * math.pi * 4)).abs() * 12;
        final pos = road + Offset.lerp(oa, ob, lt)! + Offset(0, hop);
        return Positioned(left: pos.dx, top: pos.dy, child: _dragonImage());
      },
    );
  }

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
        final slots = n + 1; // dersler + en üstte ünite hazinesi
        final unitEnd = unit.start + n;
        // Kartlar aralarında eşit boşlukla dizilir, çok seyrek olmasın diye üst sınır var.
        final step = slots > 1 ? (usable / (slots - 1)).clamp(0.0, 104.0) : 0.0;
        final y0 = yBottom - (usable - step * (slots - 1)) / 2; // ilk dersin (en alttaki) ortası
        _w = w;
        _y0 = y0;
        _step = step;
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
                    for (var k = 0; k < slots; k++) Offset(_slotCx(unit, k, w), y0 - k * step),
                  ]),
                ),
              ),
            ),
            for (var k = 0; k < n; k++) ..._buildLesson(context, unit.start + k, y0 - k * step, w),
            _buildChest(unit, y0 - n * step, w),
            // Ejderha: yürürken animasyonlu, değilken sıradaki kartın (ünite bittiyse hazinenin) yanında durur.
            if (_walking)
              _walkingDragon(unit, w)
            else if (_chestPending(_unit))
              _staticDragon(unit, n, y0 - n * step, w)
            else if (_shown >= unit.start &&
                _shown < unitEnd &&
                _statusOf(_shown, _shown) == _Status.current &&
                !(_unit > 0 && _chestPending(_unit - 1)))
              _staticDragon(unit, _shown - unit.start, y0 - (_shown - unit.start) * step, w),
            Positioned(
              top: top + 10,
              left: 16,
              right: 16,
              child: _UnitBar(
                selected: _unit,
                completed: _shown,
                gemKey: _gemKey,
                pulse: _pulse,
                onSelect: (u) {
                  if (u == _unit) return;
                  Fx.tap();
                  setState(() => _unit = u);
                },
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: _TotalCard(unit: unit, completed: _shown, chestOpened: _chestDone.contains(_unit)),
            ),
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

  /// Ünitenin tüm dersleri bitti ama hazine henüz açılmadı mı? (ejderha sandığın yanında bekler)
  bool _chestPending(int u) => _shown == _units[u].start + _units[u].count && !_chestDone.contains(u);

  /// Ünite sonundaki hazine sandığı (haritanın en üstü). Tüm dersler bitince açılabilir.
  Widget _buildChest(_Unit unit, double y, double w) {
    final done = _chestDone.contains(_unit);
    final ready = _shown >= unit.start + unit.count;
    final status = done ? _Status.done : (ready ? _Status.current : _Status.locked);
    const boxW = _chestHalfW * 2 + 30;
    return Positioned(
      left: _chestFx * w - boxW / 2,
      top: y - _chestImg / 2,
      width: boxW,
      child: _ChestNode(
        status: status,
        imageKey: _chestKey,
        onTap: () => _openChest(_unit),
      ),
    );
  }

  List<Widget> _buildLesson(BuildContext context, int i, double y, double w) {
    final l = _lessons[i];
    final status = _statusOf(i, _shown);
    final x = l.fx * w;
    final pillW = (w - 24).clamp(0.0, 232.0);
    final left = (x - pillW / 2).clamp(12.0, w - pillW - 12);
    return [
      Positioned(
        left: left,
        top: y - _cardH / 2,
        width: pillW,
        child: _LessonCard(
          number: i + 1,
          info: l,
          status: status,
          starFx: _starFx,
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
  final ValueNotifier<_StarFx> starFx; // ders bitince yıldızların sırayla yanması
  final VoidCallback? onTap;
  const _LessonCard({
    required this.number,
    required this.info,
    required this.status,
    required this.starFx,
    this.onTap,
  });

  /// Ders adının altı: yanan yıldızlar (bitti / yıldızlar yanarken) ya da kazanılacak kristal.
  Widget _sub(bool locked) {
    final index = number - 1;
    return ValueListenableBuilder<_StarFx>(
      valueListenable: starFx,
      builder: (context, v, _) {
        if (v.lesson == index) return _StarsRow(lit: v.lit, animate: true);
        if (status == _Status.done) return const _StarsRow(lit: 3, animate: false);
        return _RewardTag(muted: locked);
      },
    );
  }

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
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
                  const SizedBox(height: 2),
                  _sub(locked),
                ],
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
  final int completed; // ekranda gösterilen tamamlanan ders sayısı
  final GlobalKey gemKey; // kristallerin uçacağı elmasın konumu
  final ValueNotifier<bool> pulse; // kristal varınca elmas büyüyüp küçülür
  const _UnitBar({
    required this.selected,
    required this.onSelect,
    required this.completed,
    required this.gemKey,
    required this.pulse,
  });

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
          Expanded(child: _UnitTrack(completed: completed, gemKey: gemKey, pulse: pulse)),
          _UnitChip(label: _units[1].name, selected: selected == 1, onTap: () => onSelect(1)),
        ],
      ),
    );
  }
}

/// İki ünite arasındaki çizgi: tamamlanan ders oranı kadar mavi, elmas ilerlemeyi gösterir.
class _UnitTrack extends StatelessWidget {
  final int completed;
  final GlobalKey gemKey;
  final ValueNotifier<bool> pulse;
  const _UnitTrack({required this.completed, required this.gemKey, required this.pulse});

  @override
  Widget build(BuildContext context) {
    final total = _units.fold<int>(0, (a, u) => a + u.count);
    final done = completed.clamp(0, total);
    final a = (done * 100 / total).round();
    final b = 100 - a;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          if (a > 0) Expanded(flex: a, child: const _TrackBar(color: kBlue)),
          ValueListenableBuilder<bool>(
            valueListenable: pulse,
            builder: (context, on, child) => AnimatedScale(
              scale: on ? 1.5 : 1.0,
              duration: const Duration(milliseconds: 120),
              child: child,
            ),
            child: Image.asset('assets/ready/icon_gem.png', key: gemKey, height: 22, cacheHeight: 66),
          ),
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
  final int completed;
  final bool chestOpened; // ünite hazinesi açıldı mı (son, altın renkli parça)
  const _TotalCard({required this.unit, required this.completed, required this.chestOpened});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final n = unit.count;
        final done = (completed - unit.start).clamp(0, n);
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
                  const SizedBox(width: 4),
                  Container(
                    width: 26,
                    height: 10,
                    decoration: BoxDecoration(
                      color: chestOpened ? kYellow : const Color(0xFFDDE5EE),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Kartın altındaki yıldız sırası. [animate] true iken yanan yıldızlar "pop" ile belirir
/// (ders yeni bitti), false iken sabit çizilir (önceden bitmiş dersler).
class _StarsRow extends StatelessWidget {
  final int lit;
  final bool animate;
  const _StarsRow({required this.lit, required this.animate});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var k = 0; k < 3; k++)
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: _StarIcon(on: k < lit, animate: animate),
          ),
      ],
    );
  }
}

class _StarIcon extends StatelessWidget {
  final bool on;
  final bool animate;
  const _StarIcon({required this.on, required this.animate});

  static const double _size = 15;

  @override
  Widget build(BuildContext context) {
    final img = Image.asset(
      'assets/ready/icon_star.png',
      width: _size,
      height: _size,
      cacheWidth: 48,
      // Yanmayan yıldız: düz gri silüet.
      color: on ? null : const Color(0xFFC3CCD6),
      colorBlendMode: on ? null : BlendMode.srcIn,
    );
    if (!(on && animate)) return img;
    // Yanış: önce 1.7 kata büyür ve hafif döner, sonra yerine oturur (kısa, tek seferlik).
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      child: img,
      builder: (context, t, child) {
        final k = t < 0.4 ? 1 + 0.7 * (t / 0.4) : 1.7 - 0.7 * ((t - 0.4) / 0.6);
        return Transform.scale(
          scale: k,
          child: Transform.rotate(angle: (k - 1) * 0.5, child: child),
        );
      },
    );
  }
}

/// Tamamlanmamış kartın altında: dersi bitirince kazanılacak kristal ("+5").
class _RewardTag extends StatelessWidget {
  final bool muted;
  const _RewardTag({required this.muted});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: muted ? 0.55 : 1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/ready/icon_gem.png', height: 15, cacheHeight: 45),
          const SizedBox(width: 3),
          Text(
            '+${AppState.gemReward}',
            style: TextStyle(
              fontSize: 12,
              height: 1.1,
              fontWeight: FontWeight.w900,
              color: muted ? kLockedDark : kBlue,
            ),
          ),
        ],
      ),
    );
  }
}

/// Ünite sonu hazine sandığı. Kilitli: gri ve kilitli, hazır: parlayan daire içinde (dokununca açılır),
/// açılmış: altın kupa. Altında "Hazine +10" etiketi.
class _ChestNode extends StatelessWidget {
  final _Status status;
  final GlobalKey imageKey; // kristaller/parıltılar sandığın ortasından çıkar
  final VoidCallback onTap;
  const _ChestNode({required this.status, required this.imageKey, required this.onTap});

  static const _gray = ColorFilter.matrix(<double>[
    0.33, 0.33, 0.33, 0, 0, //
    0.33, 0.33, 0.33, 0, 0,
    0.33, 0.33, 0.33, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    final locked = status == _Status.locked;
    final done = status == _Status.done;
    final Widget icon;
    if (done) {
      icon = const Icon(
        Icons.emoji_events_rounded,
        size: _chestImg - 4,
        color: kYellow,
        shadows: [Shadow(color: kYellowDark, offset: Offset(0, 3))],
      );
    } else {
      final gift = Image.asset('assets/ready/icon_gift.png', height: _chestImg - 6, cacheHeight: 180);
      icon = Stack(
        alignment: Alignment.center,
        children: [
          // Sıra gelince arkasında beyaz hale (sabit, animasyon yok).
          if (!locked)
            Container(
              width: _chestImg + 18,
              height: _chestImg + 18,
              decoration: const BoxDecoration(color: Color(0xB3FFFFFF), shape: BoxShape.circle),
            ),
          locked ? Opacity(opacity: 0.7, child: ColorFiltered(colorFilter: _gray, child: gift)) : gift,
          if (locked) const Icon(Icons.lock_rounded, size: 22, color: kLockedDark),
        ],
      );
    }
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(key: imageKey, width: _chestImg, height: _chestImg, child: Center(child: icon)),
          Transform.translate(
            offset: const Offset(0, -10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [BoxShadow(color: Color(0x33000000), offset: Offset(0, 3))],
              ),
              child: done
                  ? const Text(
                      'Hazine açıldı',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: kGreen),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Hazine',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: locked ? kMuted : kInk,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Opacity(
                          opacity: locked ? 0.55 : 1,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset('assets/ready/icon_gem.png', height: 14, cacheHeight: 42),
                              const SizedBox(width: 2),
                              Text(
                                '+${AppState.chestGems}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: kBlue,
                                ),
                              ),
                            ],
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
