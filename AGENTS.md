# Hop English – Proje Kuralları (YAPAY ZEKA VE GELİŞTİRİCİLER İÇİN ZORUNLU)

Bu dosyayı kodda herhangi bir değişiklik yapmadan ÖNCE oku.
Buradaki kurallar proje sahibinin kesin isteğidir. İzin almadan çiftleme, esnetme veya kaldırma.

## 1. Performans (en önemli kural)

Uygulama donmamalı, kasmamalı. Hiçbir şey gereksiz yere tekrar çizilmemeli.

- **ANİMASYON YOK.** Hiçbir yerde animasyon kullanma:
  - `AnimationController`, `AnimatedContainer`, `AnimatedOpacity`, `AnimatedBuilder`, `Hero`, `TweenAnimationBuilder`, `Lottie`, `Rive`, `.repeat()` vb. yasak.
  - Sayfa geçişleri anında olur (`NoTransitionsBuilder`, `theme.dart` içinde).
  - Dokunma dalgası (ripple/splash) kapalıdır (`NoSplash`).
  - Alt menüde `animationDuration: Duration.zero` kalmalı.
  - Kendi kendine hareket eden, titreyen, süzülen, dönen hiçbir öğe olmasın (maskot dahil).
- **İSTİSNA – Yaylanarak kaydırma AÇIK kalmalı.** Listeler başa/sona gelince iOS gibi
  yaylanıp geri gelir (`BouncyScrollBehavior`, `theme.dart` içinde, `main.dart`'ta bağlı).
  Proje sahibi bunu özellikle istedi: `ClampingScrollPhysics` ile değiştirme, kapatma.
- **Sekmeler silinip yeniden kurulmaz.** Alt menü sekmeleri `IndexedStack` ile tutulur
  (`home_screen.dart`). `_index == 0 ? A : B` gibi yapı KULLANMA. Sekme değişince
  sayfa baştan oluşmamalı, görseller yeniden yüklenmemeli.
- **`const` kullan.** Değişmeyen her widget `const` olsun.
- **`setState` küçük kalsın.** Tüm ekranı değil, sadece değişen küçük parçayı yeniden
  oluşturacak şekilde yaz. Gerekirse parçayı ayrı bir widget'a böl.
- **Görseller küçültülerek yüklenir.** Her `Image.asset` için ekranda görüneceği boyutun
  yaklaşık 3 katı `cacheWidth` veya `cacheHeight` ver. Tam boyutlu büyük resmi
  doğrudan yükleme. Avatar gibi `ImageProvider` gereken yerlerde `ResizeImage` kullan.
- **Büyük ve sabit görseller `RepaintBoundary` içinde olsun** (arka plan, ana maskot).
- **Sürekli yeniden çizdiren şeyler yasak:** `Timer.periodic` ile sürekli `setState`,
  `StreamBuilder`/`FutureBuilder` ile gereksiz yenileme, `Opacity` ile sürekli
  değişen katmanlar, ağır `BackdropFilter`/blur, çok büyük `blurRadius` gölgeler.
- **Paket kuralı:** Şu an ek paketler: `flutter_tts` (seslendirme), `shared_preferences` (kayıt), `audioplayers` (ses efektleri, kullanıcı onayıyla eklendi). Başka paket ekleme, gerekirse önce kullanıcıya sor.
- **Uzun listelerde `ListView.builder` kullan.** Çok elemanlı listeyi `Column` içine koyma.

## 2. Tasarım

- Tasarım modern, canlı ve çocuk dostu olacak: yuvarlak köşeler, yumuşak gölgeler,
  parlak renkler, 3D "basılabilir" butonlar (Duolingo tarzı).
- **Tüm renk, buton, kart ve ilerleme çubuğu `lib/theme.dart` içinden gelir**
  (`kGreen`, `kYellow`, `ChunkyButton`, `cardDecoration()`, `ProgressBar` vb.).
  Yeni ekranda aynı bileşenleri kullan, yeni renk/stil uydurma. Gerekirse `theme.dart`'a ekle.
- Maskot yeşil ejderhadır (`assets/ready/mascot_*.png`). Başka karakter ekleme.
- Uygulama dili Türkçedir. Tüm yazılar Türkçe, İngilizce kelime/örnekler dersin içeriğidir.
- Tema: Material 3, açık tema, arka plan `kBg`.

## 3. Dosya düzeni

```
lib/
  main.dart            -> uygulama girişi, tema ve yaylanmalı kaydırma ayarı
  theme.dart           -> renkler, tema, ortak widget'lar (tek stil kaynağı)
  welcome_screen.dart  -> açılış ekranı
  home_screen.dart     -> ana sayfa + alt menü (IndexedStack)
  lesson_data.dart     -> ders içerikleri (kelimeler, örnek cümleler); içerik buradan eklenir
  lesson_screen.dart   -> ders ekranı (yeni kelime kartları)
  quiz_screen.dart     -> quiz (Doğru cevabı seç, Kontrol Et / Devam Et)
  result_screen.dart   -> Tebrikler ekranı (XP, seri, elmas)
  word_list_screen.dart -> Tekrar sekmesi: Kelime Listem (Tümü/Zor/Öğrenildi)
  profile_screen.dart  -> Profil sekmesi (seviye, istatistik, rozetler)
  app_state.dart       -> TEK durum kaynağı: xp, elmas, seri, tamamlanan ders
  speech.dart          -> İngilizce seslendirme (Dinle butonları, flutter_tts)
  fx.dart              -> titreşim + ses efektleri (HapticFeedback, audioplayers)
  lesson_map_screen.dart -> Dersler sekmesi: ders haritası (düğüm konumları fx/fy ile ayarlanır)
assets/images/         -> ham görseller (elleme)
assets/sounds/         -> ses efektleri: correct.wav, wrong.wav, gift.wav, celebrate.wav (küçük, elle üretildi)
assets/ready/          -> işlenmiş görseller (tools/prepare_images.py üretir)
```

- Silinen ve geri EKLENMEYECEK dosya: `floating.dart` (maskotu sürekli hareket ettiriyordu).
  (`bouncy_scroll.dart` da silindi, yaylanma artık `theme.dart` içindeki `BouncyScrollBehavior`.)
- Yeni ekran eklerken ayrı dosya aç, `theme.dart`'taki bileşenleri kullan.

## 4. Değişiklik yaparken

1. Önce bu kuralları oku.
2. Sadece istenen şeyi değiştir, çalışan yerlere dokunma.
3. Kural ihlali gerektiren bir istek gelirse (örn. "animasyon ekle") yapma, kullanıcıya
   bu dosyadaki kuralı hatırlat ve onay iste.
4. Kodun sonunda, yukarıdaki performans listesini kontrol et.

## 5. Derleme

- APK, GitHub Actions ile alınır (`.github/workflows/build.yml`, elle çalıştırılır).
- Görseller `tools/prepare_images.py` ile `assets/ready/` klasörüne hazırlanır.

## 6. Ekran sırası ve durum

Referans tasarıma göre sırayla yapılır. Sırayı bozma, bir önceki bitmeden diğerine geçme.

1. [x] Açılış ekranı
2. [x] Ana sayfa
3. [x] Ders haritası (Dersler sekmesi)
4. [x] Ders ekranı (yeni kelime: kelime, okunuş, Türkçesi, "Dinle", "Devam Et")
5. [x] Quiz ekranı ("Doğru cevabı seç", 3 şık)
6. [x] Tebrikler ekranı (XP, seri, elmas)
7. [x] Kelime Listem (Tekrar sekmesinde)
8. [x] Profil
9. [x] Tekrar sekmesi (= Kelime Listem)

Akış: Ders (6 kelime) -> Quiz (6 soru) -> Tebrikler -> Ana sayfa.
Sadece 1. ders içeriği var, diğer dersler kilitli. Yeni ders içeriği `lesson_data.dart`'a eklenir.
Puan/elmas/seri/ilerleme/zor kelimeler `shared_preferences` ile telefona kaydedilir (`AppState.load/_save`).
Seri: dünden önce son ders yapıldıysa açılışta sıfırlanır.
Quizde yanlış yapılan kelimeler "Zor" listesine düşer, sonra doğru bilinirse çıkar.
Profilde Ayarlar / Yardım satırları henüz yok.
Günlük hedef (5 dk): ders ve quiz ekranlarında geçen süre `StudyTimer` ile ölçülür (iki dokunuş arası
en fazla 60 sn sayılır). 5 dk dolunca hediye kutusu +10 elmas verir, her gün sıfırlanır.
Yeni bir çalışma ekranı eklenirse içine `StudyTimer` konmalı: `tap()` dokunuşlarda, `finish()` dispose'da.

## 6.1 Yapılanlar (değişiklik günlüğü)

Her değişiklikten sonra buraya yazılır ve güncel AGENTS.md kullanıcıya dosya olarak verilir.

- **Günlük hedef sayacı bağlandı** (`lesson_screen.dart`, `quiz_screen.dart`, `home_screen.dart`):
  - Ders ve quiz ekranlarında `StudyTimer` var: `tap()` Devam Et / Kontrol Et dokunuşlarında,
    `finish()` `dispose` içinde çağrılır.
  - Ana sayfada "Bugünün Hedefi" ve "Günlük Hedef" kartları gerçek süreyi gösterir (x/5 dk, çubuk).
    Eskiden "Bugünün Hedefi" ders sayısını gösteriyordu, artık süreyi gösterir.
  - 5 dk dolunca hediye kutusunun altında "Hediyeni aç!" yazar, basınca +10 elmas verir
    (`AppState.claimGift`), sonra "Hediye alındı ✓" görünür. Süre ekran kapanınca ana sayfaya yansır
    (canlı yenileme yok, performans kuralı).
- **Görselli quiz sorusu eklendi** (`lesson_data.dart`, `quiz_screen.dart`):
  - `QuizQuestion.pictures` doluysa "Doğru görseli seç" sorusudur: üstte İngilizce kelime + dinle
    butonu (`_ListenWord`), altta 2x2 kart (`_PicOption`: büyük emoji + Türkçesi).
  - `buildQuiz`: tek numaralı sorular (2., 4., 6.) görselli, diğerleri yazılı. Görselli soru için
    en az 4 kelime gerekir. Görseller `Word.emoji` alanından gelir, yeni görsel dosyası/paket yok.
  - Soyut kelimelerde (hello, yes, no) emoji yaklaşık anlatır. Somut kelimeli derslerde daha iyi olur.
  - Kullanıcının onayı olmadan yeni çizim görseli eklenmedi.
- **Titreşim eklendi** (`fx.dart`, `quiz_screen.dart`, `app_state.dart`): Kontrol Et'te doğruysa orta,
  yanlışsa güçlü titreşim; hediye alınca güçlü titreşim. `HapticFeedback` kullanır, ek paket/izin yok.
- **Ses efektleri eklendi** (kullanıcı onayladı): `audioplayers` paketi (`pubspec.yaml`) ve `assets/sounds/`
  içinde kısa wav dosyaları. Oynatıcılar ilk kullanımda kurulur, hata olursa sessizce geçer.
  Ses değiştirmek için aynı isimli wav dosyasını değiştir.
- **Quiz titreşimi güçlendirildi**: doğruda 2, yanlışta 3 darbe (`Fx._buzz`: `vibrate` + `heavyImpact`).
- **Quizde doğru/yanlış efekt sesi KALDIRILDI** (kullanıcı istedi): Kontrol Et'te efekt sesi, kelimenin
  okunuşuyla (`Speech`) karışıyordu. Şimdi sadece titreşim + okunuş var. `correct.wav` ve `wrong.wav`
  dosyaları duruyor ama kullanılmıyor. Quiz Kontrol Et'e geri ses EKLEME.
  Efekt sesi sadece hediye (`gift.wav`) ve tebrikler (`celebrate.wav`) ekranında çalar.
- **Tebrikler ekranında kutlama**: `Fx.celebrate()` quiz bitince (`quiz_screen.dart`, sonuç ekranına geçmeden
  hemen önce, olay içinden) çağrılır. `assets/sounds/celebrate.wav` (güçlü fanfar, ~2 sn) çalar, ayrıca
  arka arkaya 6 güçlü titreşim + sonda uzun `vibrate` verir. Animasyon yok, sadece ses ve titreşim.
- Bu değişiklikler Flutter ile derlenip denenmedi, APK ile test edilmeli.

## 7. Durum yönetimi kuralı

- Puan, elmas, seri, ilerleme gibi paylaşılan veri SADECE `AppState` içinde tutulur.
- Ekranlar bunu `ListenableBuilder` ile dinler ve sadece değişen küçük parçayı yeniler.
- Yeni bir kalıcı veri eklenirse `AppState` içinde hem `load()` hem `_save()` güncellenmeli.
- `AppState.completeLesson()` sadece tıklama/olay içinden çağrılır, `build` veya `initState` içinden asla
  (yoksa "setState called during build" hatası verir).
