import 'package:flutter/foundation.dart';

/// Performans ölçeri (Flutter'ın kendi Raster/UI grafiği).
/// Profil sekmesinde "Yeni Başlangıç" ismine UZUN BASINCA açılır/kapanır.
/// Her açılışta kapalı başlar, kaydedilmez. Kapalıyken performansa etkisi yoktur.
final ValueNotifier<bool> showPerfOverlay = ValueNotifier<bool>(false);
