import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

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

  /// Doğru cevap: tek uzun, kesintisiz güçlü titreşim (efekt sesi YOK, çünkü kelimenin
  /// okunuşuyla (Speech) karışıyordu).
  static Future<void> right() => _pattern(const [220]);

  /// Yanlış cevap: 3 uzun güçlü titreşim (arada kısa duraklama), sonuncusu en uzun.
  static Future<void> wrong() => _pattern(const [260, 90, 260, 90, 380]);

  /// Kesintisiz güçlü titreşim: [ms] süre boyunca her 25 ms'de bir `vibrate` + `heavyImpact`
  /// gönderir. Tek bir `HapticFeedback` çağrısı kısa bir "tık"tır; peş peşe gönderince
  /// titreşim kesilmeden, çok daha güçlü ve uzun hissedilir. Paket/izin gerekmez.
  static Future<void> _burst(int ms) async {
    final sw = Stopwatch()..start();
    while (sw.elapsedMilliseconds < ms) {
      HapticFeedback.vibrate();
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 25));
    }
  }

  /// Desen: tek sayılar (0., 2., ...) titreşim süresi, çift sayılar (1., 3., ...) sessiz
  /// bekleme süresi, hepsi ms. Örn. [260, 90, 260] = titre, dur, titre.
  static Future<void> _pattern(List<int> parts) async {
    try {
      for (var i = 0; i < parts.length; i++) {
        if (i.isEven) {
          await _burst(parts[i]);
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
    await _pattern(const [220, 80, 220, 80, 220, 80, 220, 120, 700]);
  }

  /// Hediye alma: yükselen ses + uzun güçlü titreşim.
  static void reward() {
    _play('gift.wav');
    _pattern(const [320, 90, 420]);
  }
}
