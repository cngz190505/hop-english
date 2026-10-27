import 'package:flutter/foundation.dart';

/// Performans ölçeri (Flutter'ın kendi Raster/UI grafiği).
/// Profil sekmesinde "Yeni Başlangıç" ismine UZUN BASINCA açılır/kapanır.
/// Her açılışta kapalı başlar, kaydedilmez. Kapalıyken performansa etkisi yoktur.
final ValueNotifier<bool> showPerfOverlay = ValueNotifier<bool>(false);

/// Ana sayfa gökyüzü deneyi: hangi parça GPU'yu yoruyor? (ölçerle birlikte kullanılır)
/// Ana sayfada "Hop" yazısına UZUN BASINCA mod değişir: 0 normal, 1 gökyüzü resmi yok,
/// 2 degrade yok, 3 maskot yok, 4 hepsi yok (sadece yazılar). Her açılışta 0'dan başlar.
final ValueNotifier<int> heroTest = ValueNotifier<int>(0);

/// TEST: true ise içeriği hazır TÜM dersler kilitsiz açılır (harita ve ana sayfa).
/// Test bitince false yap, kilitler normale döner.
const bool kUnlockAll = false;
