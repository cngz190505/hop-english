import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Titreşim + kısa ses efektleri (doğru, yanlış, hediye).
/// Hata olursa uygulama çökmez, sadece ses/titreşim olmaz.
class Fx {
  Fx._();

  // Her ses için ayrı oynatıcı, ilk kullanımda kurulur (açılışı yavaşlatmaz).
  static final Map<String, AudioPlayer> _players = {};

  static Future<void> _play(String file, {double volume = 0.8}) async {
    try {
      final p = _players.putIfAbsent(file, () {
        final a = AudioPlayer();
        a.setPlayerMode(PlayerMode.lowLatency);
        return a;
      });
      await p.stop();
      await p.play(AssetSource('sounds/$file'), volume: volume);
    } catch (_) {}
  }

  // Gerçek titreşim motoru (vibration paketi): telefon gerçekten sallanır.
  // Paket/cihaz desteklemezse eski HapticFeedback yöntemine döner.
  static bool? _has;
  static bool _amp = false;

  static Future<bool> _init() async {
    if (_has != null) return _has!;
    try {
      _has = await Vibration.hasVibrator() ?? false;
      _amp = await Vibration.hasAmplitudeControl() ?? false;
    } catch (_) {
      _has = false;
    }
    return _has!;
  }

  /// Doğru cevap: güçlü "ta-dam" (iki sert vuruş).
  static Future<void> right() => _pattern(const [160, 70, 320]);

  /// Yanlış cevap: 3 uzun sert titreşim, sonuncusu en uzun (telefon sallanır).
  static Future<void> wrong() => _pattern(const [320, 100, 320, 100, 520]);

  /// Her dokunuşta kısa ama hissedilir "tık" (seçim, sekme, kart).
  static void tap() => _short(28, 180);

  /// Butona basma: daha sert tek darbe.
  static void press() => _short(55, 255);

  static Future<void> _short(int ms, int amp) async {
    try {
      if (await _init()) {
        Vibration.vibrate(duration: ms, amplitude: _amp ? amp : -1);
      } else {
        HapticFeedback.mediumImpact();
      }
    } catch (_) {}
  }

  /// Desen: tek sayılar (0., 2., ...) titreşim süresi, çift sayılar (1., 3., ...) sessiz
  /// bekleme süresi, hepsi ms. Örn. [260, 90, 260] = titre, dur, titre. Hep tam güç.
  static Future<void> _pattern(List<int> parts) async {
    try {
      if (await _init()) {
        final pattern = [0, ...parts];
        final intensities = [
          0,
          for (var i = 0; i < parts.length; i++) i.isEven ? 255 : 0,
        ];
        Vibration.vibrate(
          pattern: pattern,
          intensities: _amp ? intensities : const [],
        );
        return;
      }
      // Yedek: eski yöntem
      for (var i = 0; i < parts.length; i++) {
        if (i.isEven) {
          final sw = Stopwatch()..start();
          while (sw.elapsedMilliseconds < parts[i]) {
            HapticFeedback.vibrate();
            HapticFeedback.heavyImpact();
            await Future.delayed(const Duration(milliseconds: 25));
          }
        } else {
          await Future.delayed(Duration(milliseconds: parts[i]));
        }
      }
    } catch (_) {}
  }

  /// Ders bitti (Tebrikler ekranı): güçlü fanfar sesi + uzun, kesintisiz kutlama titreşimi
  /// (4 kısa darbe, sonda çok uzun bir titreşim). Toplam yaklaşık 2 saniye.
  static Future<void> celebrate() async {
    _play('celebrate.wav', volume: 1.0);
    await _pattern(const [240, 90, 240, 90, 240, 90, 240, 140, 800]);
  }

  /// Kristal elmasa varınca: kısa "ding". Her kristalde nota bir basamak yükselir (5 notada döner).
  static void gem(int k) {
    _play('gem${k % 5}.wav', volume: 0.7);
    _short(15, 120);
  }

  /// Ders bitince haritada yıldız yanarken: her yıldızda nota bir basamak yükselir (s = 0, 1, 2).
  static void star(int s) {
    _play('star${s.clamp(0, 2)}.wav', volume: 0.7);
    _short(20, 150);
  }

  /// Ünite bitip hazine açılınca: fanfar sesi + kısa titreşim deseni.
  static Future<void> unitDone() {
    _play('celebrate.wav', volume: 1.0);
    return _pattern(const [200, 90, 200, 90, 500]);
  }

  /// Hediye alma: yükselen ses + uzun güçlü titreşim.
  static void reward() {
    _play('gift.wav');
    _pattern(const [360, 100, 480]);
  }
}
