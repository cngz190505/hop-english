import 'package:flutter/services.dart';

/// Titreşim geri bildirimi (ek paket gerekmez, izin istemez).
/// Ses efektleri için ayrı paket gerekir, bkz. AGENTS.md 6.1.
class Fx {
  Fx._();

  /// Doğru cevap: kısa, hafif titreşim.
  static void right() => HapticFeedback.mediumImpact();

  /// Yanlış cevap: daha güçlü titreşim.
  static void wrong() => HapticFeedback.heavyImpact();

  /// Hediye alma gibi ödüllerde.
  static void reward() => HapticFeedback.heavyImpact();
}
