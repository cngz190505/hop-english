import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Titreşim + kısa ses efektleri (doğru, yanlış, hediye).
/// Hata olursa uygulama çökmez, sadece ses/titreşim olmaz.
class Fx {
  Fx._();

  // Her ses için ayrı oynatıcı, ilk kullanımda kurulur (açılışı yavaşlatmaz).
  static final Map<String, AudioPlayer> _players = {};

  static Future<void> _play(String file) async {
    try {
      final p = _players.putIfAbsent(file, () {
        final a = AudioPlayer();
        a.setPlayerMode(PlayerMode.lowLatency);
        return a;
      });
      await p.stop();
      await p.play(AssetSource('sounds/$file'), volume: 0.8);
    } catch (_) {}
  }

  /// Doğru cevap: ding sesi + orta titreşim.
  static void right() {
    HapticFeedback.mediumImpact();
    _play('correct.wav');
  }

  /// Yanlış cevap: kısık "bzzt" sesi + güçlü titreşim.
  static void wrong() {
    HapticFeedback.heavyImpact();
    _play('wrong.wav');
  }

  /// Hediye alma: yükselen ses + güçlü titreşim.
  static void reward() {
    HapticFeedback.heavyImpact();
    _play('gift.wav');
  }
}
