import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  _LessonInfo('Günlük İfadeler', 0.36, 0.50, Color(0xFFFF6FA8), Color(0xFFE04F89)),
  _LessonInfo('Ev', 0.64, 0.50, Color(0xFFFF9600), Color(0xFFE08400)),
  _LessonInfo('Yiyecekler', 0.36, 0.50, Color(0xFF58CC02), Color(0xFF46A302)),
  // ÜNİTE 3 (ders 13-)
  _LessonInfo('Giysiler', 0.64, 0.50, Color(0xFF8B5CF6), Color(0xFF6D3FD0)),
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
  _Unit('Ünite 2', 6, 6), // 6 ders: cümle dersleri ve Küçük Kelimeler kaldırıldı (kullanıcı istedi), Ev ve Yiyecekler eklendi
  _Unit('Ünite 3', 12, 1), // Giysiler ile başladı, yeni ders gelince count artar (en çok 6)
];

/// Hazine sandığı: yatay yeri (genişliğe oran), görsel boyu ve yarım genişliği (ejderha yeri için).
const double _chestFx = 0.5;
/// Haritadaki düğüm, ejderha ve hazine boyutu çarpanı (1 = eski büyük hal). Başlık değişmez.
const double _mapK = 0.78;
const double _chestImg = 78;
const double _chestHalfW = 44;

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

class _LessonMapTabState extends State<LessonMapTab> with TickerProviderStateMixin, RouteAware {
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
  // Ejderhanın bekleme animasyonu: 1 sn'de hafif yukarı çıkıp iner (demodaki "idle"). Sekme/ekran görünmüyorken durur.
  late final AnimationController _idle =
      AnimationController(vsync: this, duration: const Duration(seconds: 1));
  final ValueNotifier<bool> _pulse = ValueNotifier<bool>(false);
  // Animasyon bitene kadar sayaçta henüz gösterilmeyen kristal sayısı (kristaller varınca azalır).
  final ValueNotifier<int> _held = ValueNotifier<int>(0);
  final ValueNotifier<_StarFx> _starFx = ValueNotifier<_StarFx>(const _StarFx(-1, 0));
  final GlobalKey _gemKey = GlobalKey();
  final GlobalKey _chestKey = GlobalKey();
  // Ekranda açık gösterilen hazineler (AppState'ten kopya: patlama bitene kadar sandık kapalı görünür).
  late final Set<int> _chestDone = {...AppState.instance.chestsOpened};
  bool _chestBusy = false;
  final ScrollController _scroll = ScrollController();
  bool _needFocus = true; // ilk çizimde ve ünite değişince sıradaki derse kaydır
  double _viewH = 0;
  double _fullH = 0;
  ModalRoute<void>? _route;
  // Son çizimdeki yerleşim (kristal ve ejderha nereden nereye gidecek bilmek için).
  double _w = 0;
  double _y0 = 0;
  double _step = 0;

  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_maybePlay);
    if (widget.active) _idle.repeat();
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
    if (widget.active != old.active) {
      if (widget.active) {
        _idle.repeat();
      } else {
        _idle.stop();
      }
    }
    if (widget.active && !old.active) _maybePlay();
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_maybePlay);
    mapRouteObserver.unsubscribe(this);
    _walk.dispose();
    _idle.dispose();
    _pulse.dispose();
    _held.dispose();
    _starFx.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Ders/quiz/sonuç ekranı kapanıp harita yeniden görününce çağrılır.
  @override
  void didPopNext() {
    if (widget.active && !_idle.isAnimating) _idle.repeat();
    _maybePlay();
  }

  /// Üstte ders/quiz/sonuç ekranı açılınca ejderha animasyonu durur.
  @override
  void didPushNext() => _idle.stop();

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
    _held.value = (c - _shown) * AppState.gemReward; // sayaç kristaller varınca artar
    WidgetsBinding.instance.addPostFrameCallback((_) => _play());
  }

  /// k. kristal varınca sayaç artar: toplam [total], [count] kristale bölünür (son kristal kalanı alır).
  void _release(int k, int count, int total) {
    final share = total ~/ count;
    final add = k == count - 1 ? total - share * (count - 1) : share;
    _held.value = math.max(0, _held.value - add);
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
      _held.value = AppState.chestGems; // sayaç kristaller varınca artar
      if (!AppState.instance.openChest(u)) {
        _held.value = 0;
        return;
      }
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
          onLand: (k) {
            _release(k, AppState.chestGems.clamp(1, 8).toInt(), AppState.chestGems);
            _onGemLand(k);
          },
        );
      }
      if (!mounted) return;
      setState(() => _chestDone.add(u));
      Fx.unitDone();
      await showUnitToast(context, title: '🎉 ${unit.name} tamamlandı!', subtitle: 'Hazine açıldı');
    } finally {
      _chestBusy = false;
      _held.value = 0;
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
      // 0) Biten dersin düğümü görünür olsun.
      final target = _offsetFor(from - unit.start);
      if (_scroll.hasClients && (target - _scroll.offset).abs() > 4) {
        await _scroll.animateTo(target, duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
        if (!mounted) return;
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
      final start = box.localToGlobal(
        Offset(_slotCx(unit, from - unit.start, _w), _y0 - (from - unit.start) * _step - _scroll.offset),
      );
      final end = gemBox.localToGlobal(gemBox.size.center(Offset.zero));
      final earned = (c - from) * AppState.gemReward;
      await flyGems(
        context: context,
        from: start,
        to: end,
        count: earned.clamp(1, 8).toInt(),
        label: earned,
        onLand: (k) {
          _release(k, earned.clamp(1, 8).toInt(), earned);
          _onGemLand(k);
        },
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
        _walk.duration = Duration(milliseconds: (_walkSteps * 1300).clamp(1300, 3200).toInt());
        await _walk.forward(from: 0);
        if (mounted) setState(() => _walking = false);
        if (mounted) _focusCurrent();
      }
    } finally {
      _playing = false;
      _held.value = 0;
      if (mounted) _maybePlay(); // animasyon sürerken başka ders bittiyse devam et
    }
  }

  /// Ünite içindeki k. sıranın yatay ortası (k == unit.count: hazine sandığı).
  double _slotCx(_Unit u, int k, double w) => k >= u.count ? _chestFx * w : (k.isEven ? 0.28 : 0.72) * w;

  /// Ejderha demodaki gibi düğümün üstünde durur: ayakları düğümün üst kenarına biner (merkezden 30 yukarı).
  static const double _dragonW = 74;
  static const double _dragonH = 79;

  Offset _dragonPos(_Unit u, int k, double w, double y) => Offset(_slotCx(u, k, w) - _dragonW / 2, y - 30 * _mapK - _dragonH);

  /// Maskot görseli (mascot_main, bayraklı): kenarlardaki boş şeffaflık kırpılır, genişlik 74 olur; ayağın altında gölge.
  Widget _dragonSprite() => Transform.scale(
      scale: _mapK,
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: _dragonW,
        height: _dragonH,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 10,
              right: 10,
              bottom: -3,
              height: 9,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0x38000000),
                  borderRadius: BorderRadius.all(Radius.elliptical(27, 4.5)),
                ),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: const Alignment(0.026, 0.005),
                widthFactor: 0.753,
                heightFactor: 0.804,
                child: Image.asset(
                  'assets/ready/mascot_main.png',
                  width: 98.3,
                  height: 98.3,
                  cacheWidth: 300,
                  gaplessPlayback: true,
                ),
              ),
            ),
          ],
        ),
      ),
      );

  /// Duran ejderha: yukarı-aşağı hafif nefes alır (demodaki idle: 5 px yukarı, boy %4 uzar).
  Widget _staticDragon(_Unit u, int k, double y, double w) {
    final s = _dragonPos(u, k, w, y);
    return Positioned(
      left: s.dx,
      top: s.dy,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _idle,
          child: _dragonSprite(),
          builder: (context, child) {
            final t = math.sin(_idle.value * math.pi);
            return Transform.translate(
              offset: Offset(0, -5 * t),
              child: Transform.scale(scaleY: 1 + 0.04 * t, alignment: Alignment.bottomCenter, child: child),
            );
          },
        ),
      ),
    );
  }

  /// Ejderha yol çizgisini izleyerek zıplaya zıplaya sıradaki derse (ya da hazineye) gider
  /// (demodaki hop: 0,3 sn'de bir zıplar, 14 px yükselir, 8 derece yatar).
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
        final ms = _walk.value * (_walk.duration?.inMilliseconds ?? 1300);
        final hopT = math.sin(math.pi * ((ms / 300) % 1.0));
        return Positioned(
          left: road.dx - _dragonW / 2,
          top: road.dy - 30 * _mapK - _dragonH,
          child: IgnorePointer(
            child: Transform.translate(
              offset: Offset(0, -14 * hopT),
              child: Transform.rotate(angle: 0.14 * hopT, child: _dragonSprite()),
            ),
          ),
        );
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
        final n = unit.count;
        final slots = n + 1; // dersler + en üstte ünite hazinesi
        final unitEnd = unit.start + n;
        // Harita ekrana SIĞAR: ders aralığı boş yüksekliğe göre hesaplanır (kaydırma yok).
        // Ekran çok kısaysa aralık en az 96 olur ve harita kaydırılabilir kalır.
        final headerH = top + _MapHeader.h;
        final topPad = headerH + 14 + _chestImg * _mapK / 2; // başlığın altında hazine
        const bottomPad = 74.0; // dersin yarı boyu + ad etiketi + boşluk (küçültülmüş boyutla)
        final step = ((h - topPad - bottomPad) / n).clamp(68.0, 120.0).toDouble();
        final fullH = math.max(h, topPad + n * step + bottomPad);
        final fits = fullH <= h + 0.5;
        final y0 = fullH - bottomPad; // ilk dersin (en alttaki) ortası
        _w = w;
        _y0 = y0;
        _step = step;
        _viewH = h;
        _fullH = fullH;
        if (_needFocus) {
          _needFocus = false;
          WidgetsBinding.instance.addPostFrameCallback((_) => _focusCurrent(jump: true));
        }
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
          child: Stack(
          children: [
            // Kaydırılan harita: arka plan, süsler, yol, düğümler, hazine, ejderha.
            Positioned.fill(
              child: SingleChildScrollView(
                controller: _scroll,
                physics: fits ? const NeverScrollableScrollPhysics() : null,
                child: SizedBox(
                  width: w,
                  height: fullH,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: RepaintBoundary(
                          child: Stack(
                            children: [
                              Positioned.fill(child: CustomPaint(painter: _MapBgPainter(_unit))),
                              for (final d in _decor[_unit])
                                Positioned(
                                  left: d.fx * w,
                                  top: d.fy * fullH,
                                  child: FractionalTranslation(
                                    translation: const Offset(-0.5, -1),
                                    child: Text(d.emoji, style: TextStyle(fontSize: d.size, height: 1)),
                                  ),
                                ),
                              CustomPaint(
                                size: Size(w, fullH),
                                painter: _PathPainter([
                                  for (var k = 0; k < slots; k++) Offset(_slotCx(unit, k, w), y0 - k * step),
                                ], (_shown - unit.start).clamp(0, n).toInt()),
                              ),
                            ],
                          ),
                        ),
                      ),
                      for (var k = 0; k < n; k++) ..._buildLesson(context, unit.start + k, y0 - k * step, w),
                      _buildChest(unit, y0 - n * step, w),
                      // Ejderha: yürürken animasyonlu, değilken sıradaki düğümün (ünite bittiyse hazinenin) yanında durur.
                      if (_walking)
                        _walkingDragon(unit, w)
                      else if (_chestPending(_unit))
                        _staticDragon(unit, n, y0 - n * step, w)
                      else if (_shown >= unit.start &&
                          _shown < unitEnd &&
                          _statusOf(_shown, _shown) == _Status.current &&
                          !(_unit > 0 && _chestPending(_unit - 1)))
                        _staticDragon(unit, _shown - unit.start, y0 - (_shown - unit.start) * step, w),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _MapHeader(
                top: top,
                title: unit.name,
                done: (_shown - unit.start).clamp(0, n).toInt(),
                total: n,
                hasPrev: _unit > 0,
                hasNext: _unit < _units.length - 1,
                gemKey: _gemKey,
                pulse: _pulse,
                held: _held,
                onPrev: () => _selectUnit(_unit - 1),
                onNext: () => _selectUnit(_unit + 1),
              ),
            ),
          ],
          ),
        );
      },
    );
  }

  void _selectUnit(int u) {
    if (u < 0 || u >= _units.length || u == _unit) return;
    Fx.tap();
    _needFocus = true;
    setState(() => _unit = u);
  }

  /// Haritayı sıradaki dersin (ünite bittiyse hazinenin) görüneceği yere kaydırır.
  void _focusCurrent({bool jump = false}) {
    if (!_scroll.hasClients) return;
    final unit = _units[_unit];
    final k = (_shown - unit.start).clamp(0, unit.count).toInt();
    final o = _offsetFor(k);
    if (jump) {
      _scroll.jumpTo(o);
    } else {
      _scroll.animateTo(o, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  /// k. sıra ekranın ortasının biraz altında görünsün diye gereken kaydırma miktarı.
  double _offsetFor(int k) {
    final y = _y0 - k * _step;
    final maxO = math.max(0.0, _fullH - _viewH);
    return (y - _viewH * 0.55).clamp(0.0, maxO).toDouble();
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
      top: y - _chestImg * _mapK / 2,
      width: boxW,
      child: Transform.scale(
        scale: _mapK,
        alignment: Alignment.topCenter,
        child: _ChestNode(
          status: status,
          imageKey: _chestKey,
          onTap: () => _openChest(_unit),
        ),
      ),
    );
  }

  List<Widget> _buildLesson(BuildContext context, int i, double y, double w) {
    final l = _lessons[i];
    final status = _statusOf(i, _shown);
    final cx = _slotCx(_units[_unit], i - _units[_unit].start, w);
    return [
      Positioned(
        left: cx - _LessonNode.d / 2,
        top: y - _LessonNode.d / 2,
        width: _LessonNode.d,
        height: _LessonNode.d,
        child: Transform.scale(
          scale: _mapK,
          child: _LessonNode(
          number: i + 1,
          info: l,
          status: status,
          starFx: _starFx,
          // İçeriği hazır olan her ders (bitmiş de olsa) istenen yerden açılır.
          onTap: status == _Status.locked
              ? null // kilitli ders geçilene kadar açılmaz
              : i < _playableLessons
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
      ),
    ];
  }
}

/// Haritadaki süs (emoji): yatay/dikey yeri harita boyuna oran, boyutu punto.
class _Deco {
  final double fx;
  final double fy;
  final String emoji;
  final double size;
  const _Deco(this.fx, this.fy, this.emoji, this.size);
}

const _decor = [
  [
    _Deco(0.10, 0.93, '🌳', 54), _Deco(0.90, 0.96, '🌲', 60), _Deco(0.525, 0.985, '🌿', 30),
    _Deco(0.15, 0.82, '🌲', 56), _Deco(0.90, 0.70, '🌳', 52), _Deco(0.10, 0.56, '🌳', 60),
    _Deco(0.875, 0.61, '🌸', 30), _Deco(0.15, 0.33, '🌲', 56), _Deco(0.875, 0.40, '🌳', 54),
    _Deco(0.11, 0.21, '🌲', 62), _Deco(0.89, 0.17, '🌳', 50), _Deco(0.50, 0.945, '🍄', 30),
    _Deco(0.20, 0.085, '🏔️', 90), _Deco(0.80, 0.095, '🏔️', 110), _Deco(0.825, 0.86, '🌸', 28),
    _Deco(0.475, 0.44, '🍄', 28), _Deco(0.075, 0.74, '🌼', 26), _Deco(0.94, 0.33, '🌼', 26),
  ],
  [
    _Deco(0.12, 0.92, '🌴', 60), _Deco(0.88, 0.94, '🌴', 56), _Deco(0.50, 0.975, '🐚', 28),
    _Deco(0.10, 0.72, '🌴', 54), _Deco(0.90, 0.62, '⛵', 40), _Deco(0.10, 0.46, '🐚', 26),
    _Deco(0.90, 0.36, '🌊', 34), _Deco(0.12, 0.24, '⛵', 38), _Deco(0.88, 0.17, '🌴', 50),
    _Deco(0.50, 0.46, '🦀', 28), _Deco(0.85, 0.83, '🐚', 26),
  ],
  [
    _Deco(0.10, 0.93, '🌷', 44), _Deco(0.90, 0.95, '🌷', 40), _Deco(0.50, 0.975, '🌸', 28),
    _Deco(0.12, 0.70, '🎈', 40), _Deco(0.88, 0.58, '🎈', 36), _Deco(0.10, 0.40, '🌷', 34),
    _Deco(0.90, 0.30, '🌸', 30), _Deco(0.12, 0.20, '🎈', 38), _Deco(0.88, 0.14, '🌷', 40),
  ],
];

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
    final lilac = unit >= 2;

    // Gökyüzü degradesi
    final sky = meadow
        ? const [
            Color(0xFF52B4F5),
            Color(0xFF9FDCFB),
            Color(0xFFD6F2E6),
            Color(0xFFC1EA9A),
            Color(0xFF93D768),
            Color(0xFF6CBB48),
          ]
        : lilac
            ? const [Color(0xFFB794F6), Color(0xFFE9D8FD), Color(0xFFFFE8F1)]
            : const [Color(0xFF3CC4D8), Color(0xFFCFF3F7), Color(0xFFFFEFC2)];
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: sky,
          stops: meadow ? const [0.0, 0.22, 0.45, 0.62, 0.85, 1.0] : const [0.0, 0.55, 1.0],
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
      _hill(canvas, size, h * 0.87, h * 0.04, 1, const Color(0xFF7BCB48));
      _hill(canvas, size, h * 0.93, h * 0.03, -1, const Color(0xFF5DB835));
    } else if (lilac) {
      _hill(canvas, size, h * 0.74, h * 0.04, 1, const Color(0xFFEBDDFB)); // uzak tepe
      _hill(canvas, size, h * 0.82, h * 0.04, -1, const Color(0xFFD6BEF5));
      _hill(canvas, size, h * 0.89, h * 0.03, 1, const Color(0xFFC3A3EF));
      _hill(canvas, size, h * 0.95, h * 0.025, -1, const Color(0xFFB28BE8));
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

/// Düğümlerin ortalarından geçen yol (demodaki gibi): gölge, dış şerit, iç şerit, kesik çizgi.
/// Kum rengi yol, biten derslere kadar YEŞİL olur (`reached` = biten ders sayısı: 0. noktadan
/// reached. noktaya kadar olan parça yeşil). Blur yok, ucuz; sadece nokta ya da `reached` değişince yeniden çizilir.
class _PathPainter extends CustomPainter {
  final List<Offset> pts; // en alttaki (1.) dersten yukarı doğru
  final int reached; // yeşil olan parça sayısı (biten ders sayısı, hazineye kadar en çok pts.length - 1)
  const _PathPainter(this.pts, this.reached);

  static Path _build(List<Offset> pts, int count) {
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (var k = 1; k <= count; k++) {
      final a = pts[k - 1];
      final b = pts[k];
      final midY = (a.dy + b.dy) / 2;
      path.cubicTo(a.dx, midY, b.dx, midY, b.dx, b.dy);
    }
    return path;
  }

  static Paint _stroke(double wd, Color c) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = wd
    ..strokeCap = StrokeCap.round
    ..color = c;

  static void _draw(Canvas canvas, Path path, Color outer, Color inner, Color dashColor) {
    canvas.drawPath(path, _stroke(26, outer));
    canvas.drawPath(path, _stroke(18, inner));
    final dash = _stroke(3, dashColor);
    for (final m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, math.min(d + 3, m.length)), dash);
        d += 17;
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (pts.length < 2) return;
    final full = _build(pts, pts.length - 1);
    canvas.drawPath(full.shift(const Offset(0, 7)), _stroke(30, const Color(0x2E0B3A2A)));
    _draw(canvas, full, const Color(0xFFF3D89A), const Color(0xFFFFEEC2), const Color(0xFFE0B868));
    final g = reached.clamp(0, pts.length - 1).toInt();
    if (g > 0) {
      // Biten derslere kadar yeşil yol (kum yolun üstüne).
      _draw(canvas, _build(pts, g), const Color(0xFF58CC02), const Color(0xFF9BE35F), const Color(0xFFD9F7B8));
    }
  }

  @override
  bool shouldRepaint(_PathPainter old) {
    if (old.reached != reached || old.pts.length != pts.length) return true;
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

/// Haritadaki ders düğümü (demodaki gibi): yuvarlak numara düğmesi, üstünde 3 yıldız, köşede kazanılacak
/// kristal, altında ders adı. Bitti: tik, sıradaki: numara + hale, kilitli: gri + kilit.
class _LessonNode extends StatelessWidget {
  static const double d = 78;
  final int number;
  final _LessonInfo info;
  final _Status status;
  final ValueNotifier<_StarFx> starFx; // ders bitince yıldızların sırayla yanması
  final VoidCallback? onTap;
  const _LessonNode({
    required this.number,
    required this.info,
    required this.status,
    required this.starFx,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locked = status == _Status.locked;
    final done = status == _Status.done;
    final current = status == _Status.current;
    final base = locked ? const Color(0xFF8E98A8) : info.color;
    final light = locked ? const Color(0xFFC9D0DB) : Color.lerp(info.color, Colors.white, 0.4)!;
    final dark = locked ? const Color(0xFF6B7586) : info.shadow;
    final progress = (locked || done) ? 0.0 : _progressOf(number - 1, false);
    final Widget face;
    if (locked) {
      face = const Icon(Icons.lock_rounded, size: 32, color: Color(0xFFFFC107));
    } else if (done) {
      face = const Icon(Icons.check_rounded, size: 46, color: Colors.white);
    } else {
      face = Text(
        '$number',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          shadows: [Shadow(color: dark, offset: const Offset(0, 3))],
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Sıradaki derste arkasında beyaz hale (sabit).
          if (current)
            const Positioned(
              left: -14,
              top: -14,
              right: -14,
              bottom: -14,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0xE6FFFFFF), Color(0x00FFFFFF)],
                    stops: [0.2, 0.7],
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 5),
                gradient: RadialGradient(center: const Alignment(-0.3, -0.5), radius: 1, colors: [light, base]),
                boxShadow: [
                  BoxShadow(color: dark, offset: const Offset(0, 8)),
                  const BoxShadow(color: Color(0x44000000), blurRadius: 10, offset: Offset(0, 12)),
                ],
              ),
              child: face,
            ),
          ),
          // Parlama (düğmenin üstündeki beyaz leke).
          Positioned(
            left: 16,
            top: 10,
            width: 26,
            height: 12,
            child: Transform.rotate(
              angle: -0.44,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0x66FFFFFF),
                  borderRadius: BorderRadius.all(Radius.elliptical(13, 6)),
                ),
              ),
            ),
          ),
          // Yarıda kalan dersin ilerleme halkası.
          if (progress > 0)
            Positioned(
              left: -7,
              top: -7,
              right: -7,
              bottom: -7,
              child: CustomPaint(painter: _RingPainter(info.color, progress)),
            ),
          // Üstteki 3 yıldız: bitmiş derste yanık, yeni biterken sırayla yanar, diğerlerinde gri.
          Positioned(
            left: -30,
            right: -30,
            top: -34,
            child: Center(
              child: ValueListenableBuilder<_StarFx>(
                valueListenable: starFx,
                builder: (context, v, _) {
                  if (v.lesson == number - 1) return _StarsRow(lit: v.lit, animate: true);
                  return _StarsRow(lit: done ? 3 : 0, animate: false);
                },
              ),
            ),
          ),
          // Ders adı
          Positioned(
            left: -70,
            right: -70,
            top: d + 10,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [BoxShadow(color: Color(0x33000000), offset: Offset(0, 4))],
                ),
                child: Text(
                  info.title,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: locked ? const Color(0xB32A2F4A) : const Color(0xFF2A2F4A),
                  ),
                ),
              ),
            ),
          ),
          // Kazanılacak kristal
          if (!done) const Positioned(right: -26, top: -8, child: _RewardTag()),
        ],
      ),
    );
  }
}

/// Üst başlık (yüzen beyaz haplar, bar yok): solda oklu ünite seçici "Ünite 1 · 0/6", sağda kristal sayacı.
/// Harita ekranın en üstüne kadar uzanır, haplar üstünde durur. Kristaller buradaki sayaca uçar
/// (`gemKey` = kristal simgesi); varınca sayaç büyür ve sayı artar. Ünite okları ile ünite değişir.
class _MapHeader extends StatelessWidget {
  static const double h = 52; // pil yüksekliği (40) + üst/alt boşluk
  static const double _pillH = 40;
  final double top;
  final String title;
  final int done;
  final int total;
  final bool hasPrev;
  final bool hasNext;
  final GlobalKey gemKey;
  final ValueNotifier<bool> pulse;
  final ValueNotifier<int> held;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const _MapHeader({
    required this.top,
    required this.title,
    required this.done,
    required this.total,
    required this.hasPrev,
    required this.hasNext,
    required this.gemKey,
    required this.pulse,
    required this.held,
    required this.onPrev,
    required this.onNext,
  });

  static const _pillDeco = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(_pillH / 2)),
    boxShadow: [BoxShadow(color: Color(0xFFC9D6E3), offset: Offset(0, 3))], // sert gölge, blur yok
  );

  Widget _arrow(IconData icon, bool on, VoidCallback onTap) => GestureDetector(
        onTap: on ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 32,
          height: _pillH,
          child: Icon(icon, size: 26, color: on ? kInk : kLocked),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: top + h,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, top + 6, 12, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: _pillH,
              decoration: _pillDeco,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _arrow(Icons.chevron_left_rounded, hasPrev, onPrev),
                  Text(
                    title,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: kInk),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      '$done/$total',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kMuted),
                    ),
                  ),
                  _arrow(Icons.chevron_right_rounded, hasNext, onNext),
                ],
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: pulse,
              builder: (context, on, child) => AnimatedScale(
                scale: on ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 120),
                child: child,
              ),
              child: Container(
                height: _pillH,
                padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
                decoration: _pillDeco,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/ready/icon_gem.png', key: gemKey, height: 28, cacheHeight: 84),
                    const SizedBox(width: 6),
                    ListenableBuilder(
                      listenable: Listenable.merge([AppState.instance, held]),
                      builder: (context, _) => Text(
                        '${math.max(0, AppState.instance.gems - held.value)}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kInk),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Düğmenin üstündeki yıldız sırası (ortadaki biraz yukarıda). [animate] true iken yanan yıldızlar
/// "pop" ile belirir (ders yeni bitti), false iken sabit çizilir.
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
          Transform.translate(
            offset: Offset(0, k == 1 ? -8 : 0),
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

  static const double _size = 30;

  @override
  Widget build(BuildContext context) {
    final img = Image.asset(
      'assets/ready/icon_star.png',
      width: _size,
      height: _size,
      cacheWidth: 90,
    );
    // Yanmayan yıldız: gri ve soluk.
    if (!on) return Opacity(opacity: 0.7, child: ColorFiltered(colorFilter: _grayFilter, child: img));
    if (!animate) return img;
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

const _grayFilter = ColorFilter.matrix(<double>[
  0.33, 0.33, 0.33, 0, 0, //
  0.33, 0.33, 0.33, 0, 0,
  0.33, 0.33, 0.33, 0, 0,
  0, 0, 0, 1, 0,
]);

/// Düğmenin köşesinde: dersi bitirince kazanılacak kristal ("+5").
class _RewardTag extends StatelessWidget {
  const _RewardTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(3, 1, 8, 1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x4D000000), offset: Offset(0, 3))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/ready/icon_gem.png', height: 20, cacheHeight: 60),
          const SizedBox(width: 2),
          Text(
            '+${AppState.gemReward}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF2F3A9A)),
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
