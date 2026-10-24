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

  /// Doğru cevap: sadece orta titreşim. Efekt sesi YOK, çünkü kelimenin okunuşuyla
  /// (Speech) karışıyordu. Okunuş zaten çalıyor.
  static Future<void> right() => _buzz(const [0, 90]);

  /// Yanlış cevap: sadece güçlü titreşim (efekt sesi yok, sebep yukarıda).
  /// Doğrudan daha uzun: 3 darbe.
  static Future<void> wrong() => _buzz(const [0, 110, 110]);

  /// Güçlü titreşim: her darbe için bekleme (ms) listesi. Paket/izin gerekmez,
  /// HapticFeedback.vibrate + heavyImpact arka arkaya verilir.
  static Future<void> _buzz(List<int> gaps) async {
    try {
      for (final ms in gaps) {
        if (ms > 0) await Future.delayed(Duration(milliseconds: ms));
        HapticFeedback.vibrate();
        HapticFeedback.heavyImpact();
      }
    } catch (_) {}
  }

  /// Ders bitti (Tebrikler ekranı): güçlü fanfar sesi + arka arkaya güçlü titreşim.
  static Future<void> celebrate() async {
    _play('celebrate.wav', volume: 1.0);
    try {
      HapticFeedback.heavyImpact();
      for (final ms in const [120, 120, 150, 200, 250]) {
        await Future.delayed(Duration(milliseconds: ms));
        HapticFeedback.heavyImpact();
      }
      await Future.delayed(const Duration(milliseconds: 250));
      HapticFeedback.vibrate();
    } catch (_) {}
  }

  /// Hediye alma: yükselen ses + güçlü titreşim.
  static void reward() {
    HapticFeedback.heavyImpact();
    _play('gift.wav');
  }
}
