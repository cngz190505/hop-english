import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';

/// "Dinle" butonları için İngilizce seslendirme.
///
/// Sıra:
/// 1) assets/voices/<kelime>.mp3 varsa kayıtlı ses çalınır (en net olan budur).
/// 2) Yoksa telefonun TTS motoru okur (Google motoru + yerel en-US ses tercih edilir).
/// Hata olursa uygulama çökmez, sadece ses çıkmaz.
class Speech {
  static final FlutterTts _tts = FlutterTts();
  static final AudioPlayer _player = AudioPlayer();
  static bool _ready = false;
  static final Map<String, bool> _hasFile = {};

  static Future<void> _setup() async {
    if (_ready) return;
    _ready = true;
    try {
      // Google ses motoru varsa onu seç (genelde en anlaşılır olan).
      final engines = await _tts.getEngines;
      if (engines is List && engines.contains('com.google.android.tts')) {
        await _tts.setEngine('com.google.android.tts');
      }
    } catch (_) {}
    try {
      await _tts.setLanguage('en-US');
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (_) {}
    try {
      // İnternet gerektirmeyen en-US sesi tercih et.
      final voices = await _tts.getVoices;
      if (voices is List) {
        for (final v in voices) {
          if (v is Map) {
            final locale = (v['locale'] ?? '').toString().replaceAll('_', '-');
            final network = (v['network_required'] ?? '').toString();
            if (locale == 'en-US' && network != '1') {
              await _tts.setVoice({
                'name': v['name'].toString(),
                'locale': v['locale'].toString(),
              });
              break;
            }
          }
        }
      }
    } catch (_) {}
  }

  /// "thank you" -> "thankyou" (assets/voices/thankyou.mp3)
  static String _key(String text) =>
      text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  static Future<bool> _playFile(String text, bool slow) async {
    final key = _key(text);
    if (key.isEmpty) return false;
    try {
      var ok = _hasFile[key];
      if (ok == null) {
        try {
          await rootBundle.load('assets/voices/$key.mp3');
          ok = true;
        } catch (_) {
          ok = false;
        }
        _hasFile[key] = ok;
      }
      if (!ok) return false;
      await _player.stop();
      await _player.setPlaybackRate(slow ? 0.7 : 1.0);
      await _player.play(AssetSource('voices/$key.mp3'));
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> speak(String text, {bool slow = false}) async {
    try {
      await _tts.stop();
      if (await _playFile(text, slow)) return;

      await _setup();
      await _tts.setSpeechRate(slow ? 0.22 : 0.38);
      // stop() hemen ardından speak() ilk sesi yutabiliyor.
      await Future.delayed(const Duration(milliseconds: 90));
      // Sona noktalama koymak son ünsüzün net okunmasına yardım eder.
      final t = text.trim();
      final spoken = RegExp(r'[.!?]$').hasMatch(t) ? t : '$t.';
      await _tts.speak(spoken);
    } catch (_) {}
  }

  static Future<void> stop() async {
    try {
      await _tts.stop();
      await _player.stop();
    } catch (_) {}
  }
}
