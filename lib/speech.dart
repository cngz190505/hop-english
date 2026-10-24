import 'package:flutter_tts/flutter_tts.dart';

/// "Dinle" butonları için İngilizce seslendirme.
/// Hata olursa uygulama çökmez, sadece ses çıkmaz.
class Speech {
  static final FlutterTts _tts = FlutterTts();
  static bool _ready = false;

  static Future<void> speak(String text, {bool slow = false}) async {
    try {
      if (!_ready) {
        await _tts.setLanguage('en-US');
        _ready = true;
      }
      await _tts.setSpeechRate(slow ? 0.25 : 0.4);
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  static Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
