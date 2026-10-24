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
- **Paket kuralı:** Şu an ek paketler: `flutter_tts` (seslendirme), `shared_preferences` (kayıt), `audioplayers` (ses efektleri, kullanıcı onayıyla eklendi), `vibration` (güçlü titreşim, kullanıcı "telefon sallansın" diye isteyince eklendi). Başka paket ekleme, gerekirse önce kullanıcıya sor.
- **Kaydırma akıcı olmalı ("yağ gibi") (KESİN KURAL)**: Kaydırılan sayfalarda her kart `ListView`'ın KENDİ elemanı
  olur (hepsini tek `Column`/tek `Padding` içine koyma), böylece her kart ayrı çizim katmanı olur.
  Her görsel `ResizeImage`/`cacheWidth`/`cacheHeight` ile küçültülür ve açılış ekranındaki önyükleme ile AYNI boyutta
  olur (örn. `bg_london` her yerde `width: 1080`). Gölge `blurRadius` en çok 10. Kaydırırken yeniden çizdiren şey yok.
- **Uzun listelerde `ListView.builder` kullan.** Çok elemanlı listeyi `Column` içine koyma.

## 2. Tasarım

- Tasarım modern, canlı ve çocuk dostu olacak: yuvarlak köşeler, yumuşak gölgeler,
  parlak renkler, 3D "basılabilir" butonlar (Duolingo tarzı).
- **Tüm renk, buton, kart ve ilerleme çubuğu `lib/theme.dart` içinden gelir**
  (`kGreen`, `kYellow`, `ChunkyButton`, `cardDecoration()`, `ProgressBar` vb.).
  Yeni ekranda aynı bileşenleri kullan, yeni renk/stil uydurma. Gerekirse `theme.dart`'a ekle.
- Maskot yeşil ejderhadır (`assets/ready/mascot_*.png`). Başka karakter ekleme. TEK İSTİSNA: kelime görselleri (`assets/words/`) çocuk karakteridir, bkz. Bölüm 8.
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
  quiz_screen.dart     -> quiz (5 soru tipi, Kontrol Et / Devam Et)
  quiz_extra.dart      -> yeni soru widget'ları: ListenBig (dinle ve seç), MatchQuestion (eşleştirme), ScrambleQuestion (harf dizme)
  result_screen.dart   -> Tebrikler ekranı (XP, seri, elmas)
  word_list_screen.dart -> Tekrar sekmesi: Kelime Listem (özet kartı, arama, Tümü/Yeni/Zor/Öğrenildi, derse göre gruplu)
  profile_screen.dart  -> Profil sekmesi (seviye, istatistik, rozetler)
  app_state.dart       -> TEK durum kaynağı: xp, elmas, seri, tamamlanan ders
  speech.dart          -> İngilizce seslendirme (Dinle butonları, flutter_tts)
  fx.dart              -> titreşim + ses efektleri (vibration, HapticFeedback yedek, audioplayers)
  lesson_map_screen.dart -> Dersler sekmesi: ders haritası (düğüm konumları fx/fy ile ayarlanır)
assets/images/         -> ham görseller (elleme)
assets/sounds/         -> ses efektleri: correct.wav, wrong.wav, gift.wav, celebrate.wav (küçük, elle üretildi)
assets/ready/          -> işlenmiş görseller (tools/prepare_images.py üretir)
                          (`bg_hero.png` = `bg_london`un ana sayfada görünen üst kısmı, 704x760 opak; script üretir)
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
1. ve 2. ders içeriği var, diğer dersler kilitli. Yeni ders içeriği `lesson_data.dart`'a eklenir.
Puan/elmas/seri/ilerleme/zor kelimeler `shared_preferences` ile telefona kaydedilir (`AppState.load/_save`).
Seri: dünden önce son ders yapıldıysa açılışta sıfırlanır.
Quizde yanlış yapılan kelimeler "Zor" listesine düşer, sonra doğru bilinirse çıkar.
Profilde Ayarlar / Yardım satırları henüz yok.
Günlük hedef (5 dk): ders ve quiz ekranlarında geçen süre `StudyTimer` ile ölçülür (iki dokunuş arası
en fazla 60 sn sayılır). 5 dk dolunca hediye kutusu +10 elmas verir, her gün sıfırlanır.
Yeni bir çalışma ekranı eklenirse içine `StudyTimer` konmalı: `tap()` dokunuşlarda, `finish()` dispose'da.

## 6.1 Yapılanlar (değişiklik günlüğü)

- **Tebrikler ekranı yeniden tasarlandı** (`result_screen.dart`): Kullanıcının tasarımına göre. Canlı mavi-yeşil degrade zemin, üstte sabit konfeti parçaları (`_confetti`, animasyon yok, tek `RepaintBoundary`), büyük maskot, beyaz gölgeli "Tebrikler!" yazısı, tek beyaz ödül kartı (Puan / Günlük seri / Elmas, aralarında ince çizgi). Altta büyük yeşil "Sonraki Ders →" butonu (sıradaki ders varsa; `pushReplacement` ile `LessonScreen` açar), yoksa "Ana Sayfaya Dön". Altında beyaz yazı butonları: "Ana Sayfaya Dön" • "Dersi Tekrarla" (tekrar dersinde Dersi Tekrarla ve Sonraki Ders yok). Doğru sayısı satırı ve Özet (zor kelimeler) kartı korundu. Durum çubuğu simgeleri açık renk (`AnnotatedRegion`).

- **Ders haritası yeniden tasarlandı** (`lesson_map_screen.dart`): Kullanıcının tasarımına göre. Üstte "Ders Haritası" + "İngilizce yolculuğunda ilerle!" ve elmas sayısı. Dersler artık daire+yazı yerine geniş yuvarlak kartlar: solda ders renginde numara dairesi (her ders ayrı renk, `_LessonInfo.color`), ortada ders adı, sağda durum (bitti: yeşil tik, sıradaki: oynat simgesi + kendi renginde çerçeve, kilitli: gri + kilit). Kart konumu yine `fx/fy` ile ayarlanır, kart genişliği ekrana göre (en çok 236), ekran dışına taşmaz. Maskot sıradaki kartın boş yeri geniş tarafında durur. Alttaki "Toplam 5 ders" kartı aynı. Animasyon yok, blur yok (gölge blur ≤ 10).

- **Profil sekmesi yeniden tasarlandı** (`profile_screen.dart`, `home_screen.dart`): Kullanıcının verdiği tasarıma göre: lacivert degrade üst bölüm (alt köşeler yuvarlak; avatar, ad, "Seviye n" + XP çubuğu), altında 3 istatistik kartı (Günlük Seri, Elmas, Rozet sayısı), "Başarılarım n/4" başlığı ve 4 rozet (İlk Adım, 5 Gün, 10 Kelime, Hedefe Ulaş; kazanılmayan soluk). Üst bölüm durum çubuğunun altına uzandığı için `home_screen.dart`'ta Profil sekmesi artık `SafeArea` içinde DEĞİL, üst boşluk `MediaQuery.padding.top` ile profil içinde verilir; `AnnotatedRegion` ile saat/pil simgeleri açık renk. Animasyon/blur yok, her bölüm ListView'ın kendi elemanı. Tasarımdaki Ayarlar / Yardım / Çıkış satırları ve "Tümünü Gör" (Rozetlerim ekranı) henüz yapılmadı: o ekranlar projede yok.

- **Kaldığı yerden devam** (`app_state.dart`, `lesson_screen.dart`, `quiz_screen.dart`, `home_screen.dart`): Ders ya da quiz yarıda bırakılınca (X ya da uygulamayı kapatma) bir sonraki açışta kaldığı kelimeden/sorudan devam eder. `AppState.resume` (JSON, shared_preferences `resume` anahtarı): `lesson`, `stage` (`lesson`/`quiz`), `n`, `i`; quizde ayrıca `total`, `correct`, `streak`, `delta`, `missed`, `right`, `retries` ("kelime|tipIndex", tekrar sorularını geri kurar). Kayıt her Devam Et'te (`_next`) yapılır, yani cevaplanıp Devam'a basılmamış soru baştan sorulur. `openLesson` kaydı okur. Ders bitince (`completeLesson`) silinir. Sadece bitmemiş derslerde tutulur (`lessonIndex >= completedLessons`), tekrar dersi ve eski ders tekrarı tutulmaz. Ders içeriğindeki kelime sayısı değişmişse (`n` uyuşmaz) kayıt yok sayılır, baştan başlar. Ana sayfa kartında "Kaldığın yer: Soru 12/26" yazar. Not: `_baseTotal` (late) tekrar soruları eklenmeden önce okunmalı, `initState` bunu sağlar.

- **Ses netleştirildi** (`speech.dart`, `lesson_screen.dart`): Kelimeler yutuluyordu. Android'de Google ses motoru (`com.google.android.tts`) varsa seçilir, en-US internetsiz (local) ses tercih edilir, hız 0.38, `stop()` sonrası 90 ms bekleme (ilk ses kesilmesin), metnin sonuna nokta eklenir (son ünsüz tam okunsun). Ders kartına "🐢 Yavaş dinle" butonu (`Speech.speak(..., slow: true)`, hız 0.22). Hâlâ yutulan kelime olursa o kelimenin sesi için `assets/` altına kayıtlı ses dosyası eklenebilir.

- **Okunuş sadeleştirildi** (`lesson_screen.dart`, `home_screen.dart`): Ders kartında IPA (`/θæŋk/`) artık gösterilmiyor, sadece Türkçe okunuş (`say`) büyük ve mavi, altında "Dinlemek için dokun". Ana sayfada Günün kelimesi sadece Türkçesini gösterir. `Word.phonetic` verisi duruyor (gerekirse tekrar gösterilebilir).

- **Harf dizme düzeni düzeltildi** (`quiz_extra.dart`): Kutularda `Container(alignment: ...)` Wrap içinde tam genişliğe uzuyor, harfler alt alta diziliyordu. Artık `Center(widthFactor: 1, heightFactor: 1)` ile içerik kadar geniş, yan yana dizilir. (Kural: Wrap içindeki kutuda `alignment` kullanma.)
- **İpucu eklendi** (`quiz_screen.dart`, `quiz_extra.dart`): Eşleştirme hariç her soruda alt panelde "İpucu (n)" butonu. Seçmeli sorularda her ipucu 1 yanlış şıkkı soluklaştırıp kapatır (en az 2 şık kalır). Harf dizmede sıradaki doğru parçayı yerleştirir, yanlış yerleşenleri geri alır (`hintTick`, `target`). Yazmada ilk harfleri açar ("h _ _ _ _"). İpucuyla doğru bilinen soru puana, hakimiyete ve üst üste doğru serisine sayılmaz ("İpucuyla doğru!"), ders yine ilerler. Amaç: zorlanan çocuk dersten çıkmak yerine ipucu alsın.

- **Yazma sorusu eklendi** (`QType.typing`; `lesson_data.dart`, `quiz_extra.dart` → `TypeQuestion`, `quiz_screen.dart`): Türkçesi + görsel gösterilir, kullanıcı İngilizcesini klavyeyle yazar. `buildQuiz` her 2 kelimeden birinde (tek sıralı kelimeler) Harf dizme'den sonra ekler (6 kelime = +3 soru). Karşılaştırma `normalizeTyped` ile: büyük/küçük harf, baştaki/sondaki/fazla boşluk, kıvrık tırnak yok sayılır. Otomatik düzeltme ve öneri kapalı. Klavyedeki "bitti" tuşu da Kontrol Et'i çalıştırır. Yanlışsa tekrar sorusu olarak seçmeli `text` sorusu eklenir (`retryQuestion`). Animasyon yok, ek paket yok.

- **Ders haritasında serbest çalışma** (`lesson_map_screen.dart`): İçeriği hazır olan (`lessonsContent`) her ders, tamamlanmış olsa bile haritadan dokunarak açılır. İçeriği olmayan dersler kilitli kalır. İlerleme geriye gitmez (`completeLesson` sadece ileri taşır).

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
- **Ana sayfa görselleri önceden yüklenir** (`welcome_screen.dart`): Videoda "Başlayalım"dan sonra avatar,
  alev/elmas, ders kartı, hedef ve hediye simgeleri yarım saniye boş gelip sonra beliriyordu.
  Artık açılış ekranı `precacheImage` ile bunları yükler. Boyutlar `home_screen.dart`'taki `cacheHeight` /
  `ResizeImage` değerleriyle AYNI kalmalı (alev/elmas 114, hafta kartı alevi 54, maskot 600, kids 200, hedef 150, hediye 120, `bg_hero` width 1080, avatar width 144). Home'da bir
  görselin boyutu değişirse welcome_screen.dart'taki listeyi de güncelle.
- Açılışta ~2 sn siyah ekran var: Android'in kendi başlatma ekranı, Flutter kodundan değil. Düzeltmek için
  `.github/workflows/build.yml`'e launch arka plan rengi yaması gerekir (henüz yapılmadı).
- Bu değişiklikler Flutter ile derlenip denenmedi, APK ile test edilmeli.

- **Ders kartında kelimeye özel görsel**: `lesson_screen.dart` içindeki `MascotBubble` artık `image` alır; ders ekranı `word.imagePath` (`assets/words/<kelime>.png`) gösterir. Quizdeki Türkçe soru kartı ejderha maskotu kullanmaya devam eder. `assets/words/` görselleri çocuk karakteridir (kullanıcı onayıyla, ejderha kuralının istisnası), yeni kelime için aynı stilde saydam PNG eklenir.

- **Titreşim Duolingo gibi güçlendirildi** (`fx.dart`): doğru 3 darbe, yanlış 5 darbe, kutlama 10 darbe; her darbede `vibrate` + `heavyImpact`. Ek paket yok.
- **Ders 2 (Kendini Tanıtma) eklendi**: `lesson_data.dart` içinde `lesson2Words` (10 kelime), `lessonsContent` listesinde. `openLesson1` yerine `openLesson(context, index)` var; `LessonScreen`, `QuizScreen`, `ResultScreen` `lessonIndex` taşır ve `completeLesson(index)` doğru dersi işaretler. Ders haritasında içerik hazır ders sayısı `lessonsContent.length`'ten gelir. Ana sayfa butonu sıradaki dersi açar, ilerleme çubuğu öğrenilen kelime/toplam kelime gösterir. Derlenip denenmedi.
- **Türkçe okunuş eklendi**: `Word.say` (örn. `yuu`) her kelimede zorunlu; ders kartında IPA yanında `/juː/ · yuu` gösterilir. Yeni kelimede `say` da yazılır.
- **Yeni ana sayfa**: `home_screen.dart` baştan yazıldı: gökyüzü bölümü (`bg_london` + ejderha + balon), büyük yeşil "Devam Et" kartı, haftalık seri satırı, günlük hedef, zor kelimeler kartı. Cam/blur yok, sadece degrade. Yeni ders eklenince `lessonTitles` listesine ders adı da eklenir (`lessonsContent` ile aynı sıra).

- **Yeni soru tipleri eklendi (KURAL, kullanıcı istedi)** (`lesson_data.dart`, `quiz_screen.dart`, `quiz_extra.dart`):
  Quiz artık 5 soru tipi içerir (`QType`): `text` (Doğru cevabı seç), `picture` (Doğru görseli seç),
  `listen` (Dinle ve seç), `match` (Eşleştirme), `scramble` (Harf dizme).
  - **Dinle ve seç**: büyük hoparlör butonu, soru açılınca kelime otomatik okunur, 3 Türkçe şık.
  - **Eşleştirme**: 5 İngilizce kelime ile 5 Türkçe karşılık; biri, sonra diğeri seçilir (sıra fark etmez).
    Doğru çift yeşil olup kilitlenir, yanlış çift kırmızı olur ve sonraki dokunuşta temizlenir.
    Hepsi bitince soru kendiliğinden kontrol edilir (Kontrol Et butonu yok), hata yapılan kelimeler "Zor" listesine düşer.
  - **Harf dizme**: üstte kelimenin görseli + Türkçesi, altta karışık harfler. Harfe dokun, kutuya girer; kutudaki
    harfe dokununca geri alınır. Sadece tek kelime, sadece harf, 3-9 harflik kelimelerde kullanılır (`canScramble`),
    uymayan kelimede yerine "Doğru cevabı seç" sorulur.
  - `buildQuiz`: her kelime için 1 soru, sırayla Dinle ve seç, Görseli seç, Doğru cevabı seç, Harf dizme (4'lü döngü).
    Sonra her 5 kelime için 1 Eşleştirme eklenir (10 kelimede 2 tane: biri ortada, biri sonda). Karıştırma sabit
    tohumlu, her seferinde aynı sonuç. 10 kelimelik ders = 12 soru.
  - Bir kelime bir soruda yanlış, başka soruda doğruysa "Zor" listesinde kalır.
  - Animasyon yok, `setState` sadece küçük widget'ta. Ek paket yok. Derlenip denenmedi, APK ile test edilmeli.
- **Yanlışları tekrar sorma, Tekrar dersi, üst üste doğru (KURAL, kullanıcı istedi)**
  (`quiz_screen.dart`, `lesson_data.dart`, `app_state.dart`, `result_screen.dart`, `word_list_screen.dart`):
  - Yanlış yapılan kelime sorunun sonuna BİR KEZ tekrar eklenir (`QuizQuestion.retry`, `retryQuestion`).
    Farklı tipte sorulur (yazılı yanlışsa Dinle ve seç, diğerlerinde yazılı). Başlık "Tekrar: ..." olur.
    Tekrar soruları puana ve toplam soru sayısına sayılmaz (`_baseTotal`). Tekrarda doğru yapılsa da kelime "Zor"da kalır.
    Eşleştirmede hata yapılan kelimelerin her biri için tekrar sorusu eklenir.
  - Üst üste 3+ doğruda alt panelde "N üst üste doğru!" yazar (sadece yazı, animasyon yok).
  - **Tekrar dersi**: Tekrar sekmesinde (Kelime Listem üstü) mavi "Tekrar Dersi" butonu. En az 5 öğrenilmiş kelime
    olunca görünür. `pickReviewWords`: önce Zor kelimeler, sonra diğerleri (günün tarihine göre kaydırılır), en çok 10.
    `QuizScreen(review: true)`: aynı soru tipleri. Bitince `AppState.completeReview` (+10 XP, +2 elmas, ders sayısı
    ve seri DEĞİŞMEZ). Tebrikler ekranında "Tekrar dersini tamamladın!", "Dersi Tekrarla" butonu gizli.
  - Derlenip denenmedi, APK ile test edilmeli.
- **Cümle tamamlama, kelime hakimiyeti yıldızları, ders sonu özeti, günün kelimesi (KURAL, kullanıcı istedi)**
  (`lesson_data.dart`, `quiz_screen.dart`, `app_state.dart`, `result_screen.dart`, `word_list_screen.dart`, `home_screen.dart`):
  - **Cümle tamamlama** (`QType.sentence`, "Boşluğu doldur"): kelimenin örnek cümlesinde kelime yerine `_____` yazılır,
    altında Türkçesi görünür, 3 İngilizce şık. `blankSentence(word)` cümleyi üretir; kelime örnek cümlede TAM BİR kez
    geçmiyorsa soru "Doğru cevabı seç"e döner. Kontrol sonrası tam cümle sesli okunur.
    Tanıma sorusu döngüsü 4'lü: Dinle ve seç, Görseli seç, Cümle tamamlama, Doğru cevabı seç. Harf dizme ayrı, her kelimede (Bölüm 10).
  - **Kelime hakimiyeti** (`AppState.mastery`, 0-3 yıldız, kalıcı): quizde doğru +1, yanlış -1 (tekrar sorusunda yanlış
    sayılmaz). Bir quizde kelime başına net değişim -1..+2 ile sınırlı (tek ders kelimeyi öğrendirmez).
    `applyMastery` quiz sonunda, `complete*` çağrılmadan ÖNCE çağrılır. Kelime listesinde her kelimenin yanında 3 yıldız;
    "Öğrenildi" sekmesi ve yeşil tik = 3 yıldız. (Ana sayfa ilerleme çubuğu eskisi gibi görülen kelimeleri sayar.)
  - **Ders sonu özeti** (`result_screen.dart` `_SummaryCard`): kaç kelime çalışıldı, hangileri zor geldi (İngilizce = Türkçe).
  - **Günün kelimesi** (`home_screen.dart` `_WordOfDayCard`): `wordOfDay` tarihe göre öğrenilen kelimelerden birini seçer
    (hiç ders yoksa 1. dersten). Karta dokununca okunur. Görseli ilk açılışta yüklenir (welcome precache listesinde yok).
  - Derlenip denenmedi, APK ile test edilmeli.

- **Ana sayfa kaydırma akıcılığı düzeltildi** (`home_screen.dart`, `theme.dart`): hero arka planı (`bg_london`) tam boyutta
  çözülüyordu, artık `ResizeImage(width: 1080)` (açılış önyüklemesiyle aynı önbellek). Kartlar tek `Column` yerine
  `ListView`'ın ayrı elemanları (her biri ayrı katman), `cacheExtent: 800`. `cardDecoration` gölgesi blur 16 -> 10.
  Kaydırma fiziği (`BouncingScrollPhysics`, yaylanma) aynen kaldı. Derlenip denenmedi, APK ile test edilmeli.

- **Kelime Listem yeniden tasarlandı** (`word_list_screen.dart`): Kullanıcının tasarımına göre. Üstte renkli özet kartı
  (x/N öğrenildi, çubuk, yıldız ve zor sayısı, "Tekrar Dersi" butonu içinde), arama (büyüteç), sayılı sekmeler
  (Tümü / Yeni / Zor / Öğrenildi), derse göre başlıklı liste, kart başına durum rozeti (Yeni / Öğreniyor / Zor / Öğrenildi).
  Animasyon YOK (ilk sürümde yanlışlıkla `Animated*` ve `TweenAnimationBuilder` kullanılmıştı, kaldırıldı).
- **Ana sayfa yeniden tasarlandı** (`home_screen.dart`): Kullanıcının tasarımına göre. Gökyüzü + "Hop English" başlığı + maskot,
  hero'nun altına taşan kart (Günlük Seri | Puan, seviye çubuğu, "Dersine Başla / Devam Et" butonu, kaldığın yer yazısı),
  "Bugünün Dersleri" (ders başına ilerleme kartı, kilitliler soluk, "Tümünü Gör" Dersler sekmesine gider), sonra Bu hafta,
  Günlük Hedef, Günün kelimesi, Zor kelimeler kartları. Eski "Devam Et" kartı, avatar ve konuşma balonu kaldırıldı.
- **Titreşim güçlendirildi** (`fx.dart`, `theme.dart`, tüm ekranlar): `vibration` paketi ile gerçek titreşim.
  Doğru: 2 sert vuruş, yanlış: 3 uzun vuruş, kutlama/hediye: uzun. `Fx.tap()` (kısa tık: sekme, kart, seçenek) ve
  `Fx.press()` (sert darbe: `ChunkyButton` her basışta). Cihaz desteklemezse eski `HapticFeedback` yöntemi yedek.
- `Speech.speak(text, {slow})`: `slow: true` yavaş okur (ders ekranındaki "Yavaş dinle" butonu bunu çağırıyordu, parametre eksikti, derleme hatası veriyordu).
- Bu değişiklikler Flutter ile derlenip denenmedi, APK ile test edilmeli.
- **Kelime Listem dersleri kapanır-açılır yapıldı** (`word_list_screen.dart`): Dersler kapalı gelir, kullanıcı başlığa dokunup açar (Bölüm 12). Animasyon yok.

- **Ana sayfa kaydırma ağırlığı azaltıldı** (`home_screen.dart`, `welcome_screen.dart`, `tools/prepare_images.py`):
  Diğer sekmeler akıcıydı, sadece ana sayfa kasıyordu; şüphe üstteki gökyüzü (hero) bölümüydü.
  - Hero artık tam boy `bg_london` (704x1504, saydam kanallı) yerine sadece görünen üst kısmı olan `bg_hero.png` (704x760, opak, ~4 kat küçük) kullanır. `prepare_images.py` bunu `bg_london`dan keser. Açılış ekranı `bg_london`u kullanmaya devam eder.
  - Hero'daki iç içe `RepaintBoundary` ve `Clip.hardEdge` kaldırıldı: tek katman. `MediaQuery.of` yerine `MediaQuery.paddingOf` (gereksiz yeniden kurmayı önler).
  - Açılış önyüklemesindeki boyutlar ana sayfayla eşitlendi (alev/elmas 66 -> 114, maskot 360 -> 600; hafta alevi 54 ve `bg_hero` eklendi). Eskiden anahtarlar tutmadığı için önbellek işe yaramıyordu.
  - Görünüm aynı. Derlenip denenmedi, APK ile test edilmeli. Hâlâ kasarsa sıradaki şüpheliler: `ProgressBar` içindeki `ClipRRect`, `cacheExtent: 2000`.

## 7. Durum yönetimi kuralı

- Puan, elmas, seri, ilerleme gibi paylaşılan veri SADECE `AppState` içinde tutulur.
- Ekranlar bunu `ListenableBuilder` ile dinler ve sadece değişen küçük parçayı yeniler.
- Yeni bir kalıcı veri eklenirse `AppState` içinde hem `load()` hem `_save()` güncellenmeli.
- `AppState.completeLesson()` sadece tıklama/olay içinden çağrılır, `build` veya `initState` içinden asla
  (yoksa "setState called during build" hatası verir).

## 8. İçerik kuralı: HER KELİMENİN KENDİ GÖRSELİ VAR (KESİN KURAL)

Proje sahibinin kesin isteği. İzin almadan esnetme, atlama, değiştirme.

- Her ders kelimesinin (`lesson_data.dart`) kendine ait görseli olur: `assets/words/<kelime>.png`
  (küçük harf, boşluksuz: `thank you` -> `thankyou.png`). Kod yolu `Word.imagePath` ile otomatik gelir.
- Ders ekranında kelime kartındaki maskot alanında **o kelimenin görseli** gösterilir
  (`MascotBubble(image: word.imagePath)`). Her kelimede aynı görsel/ejderha TEKRARLANMAZ.
- Aynı görsel iki farklı kelimede kullanılmaz. Karışıklık yok: 1 kelime = 1 görsel = 1 dosya.
- Yeni kelime/ders eklerken ÖNCE görseli hazırla (aynı çocuk karakteri, aynı çizim stili, saydam PNG,
  yaklaşık 420 px yükseklik), SONRA kelimeyi `lesson_data.dart`'a ekle. Görseli olmayan kelime eklenmez.
- Karakter: kahverengi saçlı çocuk, yeşil tişört, mavi şort, kırmızı ayakkabı. Başka karakter/stil karıştırma.
- Görselin pozu kelimenin anlamını anlatmalı (örn. hello = el sallıyor, yes = başparmak yukarı, please = eller birleşik).
- Quizdeki görselli sorular da aynı dosyaları kullanır, ayrı görsel üretme.
- Bu kural ders ekranı ve quiz için geçerlidir; yeni bir ekran kelime gösteriyorsa aynı görseli kullanır.

## 9. Müfredat ve çalışma sırası (SIRAYLA GİDİLİR, atlama)

Kurallar:
- 1 ders = 10 kelime. Her kelimenin görseli Bölüm 8'e göre hazır olmadan ders koda eklenmez.
- Dersler aşağıdaki sırayla yapılır. Bir ders bitmeden (kullanıcı test edip onaylamadan) sıradakine geçilmez.
- Kategori dersleri (somut kelimeler) önce, soyut konuşma dersleri sona. Soyut kelimelerin görseli zordur. (İstisna: Ders 2 Kendini Tanıtma kullanıcı isteğiyle öne alındı.)
- Ders haritası şu an 5 ders gösteriyor (Selamlaşma, Kendini Tanıtma, Günlük İfadeler, Sosyal Hayat, Alışveriş).
  Ders sayısı/isimleri bu listeye göre `lesson_map_screen.dart` içinde güncellenecek (ilgili ders eklenirken).

Her ders için 4 adım:
1. Claude 10 kelimeyi (İngilizce, okunuş, Türkçe, örnek cümle) ve Gemini görsel prompt'larını verir.
2. Kullanıcı görselleri üretip gönderir.
3. Claude arka planı siler, `assets/words/<kelime>.png` adlandırır, `lesson_data.dart`'a dersi ekler, kilidi açar.
4. Kullanıcı test eder, onaylar. Sonra sıradaki ders.

Durum (tamamlanınca [x] yap):

1. [x] Selamlaşma (6 kelime: hello, goodbye, thank you, please, yes, no; görseller hazır). 10'a tamamlamak isteğe bağlı.
2. [~] Kendini Tanıtma (10 kelime: name, I, you, my, age, from, nice to meet you, friend, student, fine). Görseller ve kod eklendi, kullanıcı testi bekleniyor.
3. [ ] Meyveler
4. [ ] Hayvanlar
5. [ ] Renkler
6. [ ] Araçlar
7. [ ] Aile
8. [ ] Vücut
9. [ ] Günlük İfadeler
10. [ ] Alışveriş

Ders 2: kelimeler [x] görseller [x] kod [x] test [ ]


## 10. Soru tipleri ve ders akışı (KESİN KURAL)

Proje sahibinin kesin isteği. İzin almadan çıkarma, esnetme, değiştirme. Ayrıntılar Bölüm 6.1'de.

- Quiz bu 6 soru tipini içerir ve hepsi kalır: Doğru cevabı seç (`text`), Doğru görseli seç (`picture`),
  Dinle ve seç (`listen`), Eşleştirme (`match`), Harf dizme (`scramble`), Cümle tamamlama (`sentence`). Kodları `lesson_data.dart` (`buildQuiz`),
  `quiz_screen.dart` ve `quiz_extra.dart` içindedir.
- Quiz sırası (`buildQuiz`): 1) her kelime için 1 tanıma sorusu (Dinle ve seç, Görseli seç, Cümle tamamlama, Doğru cevabı seç
  döngüsü), 2) 1. Eşleştirme, 3) HER kelime için Harf dizme (üretme), 4) 2. Eşleştirme. 10 kelime = 10+1+10+1 = 22 soru.
  Eşleştirme: 5 kelimede 1, 6+ kelimede 2 tane (ilk 5 ve son 5 kelime).
- **Harf dizme HER kelimede çıkar** (kullanıcı istedi): tek kelimede harfler, çok kelimeli ifadede ("nice to meet you")
  kelime parçaları dizilir (`scrambleTiles`). Tek istisna: tek parçalı kelime (örn. "I"). Sıra sabit, rastgelelik yok (sabit tohum).
- Yanlış yapılan kelime quiz sonunda BİR KEZ tekrar sorulur (farklı tipte). Tekrar soruları puana sayılmaz.
- Üst üste 3+ doğruda "N üst üste doğru!" yazısı çıkar (sadece yazı, animasyon yok).
- Tekrar sekmesinde "Tekrar Dersi" butonu olur (en az 5 öğrenilmiş kelime): önce Zor kelimeler, en çok 10 kelime.
  Ders sayısını ve seriyi değiştirmez.
- Yeni soru tipi veya ders akışı eklerken: animasyon yok, ek paket yok (gerekirse önce sor), `setState` küçük kalır,
  tüm renk/buton `theme.dart`'tan gelir.
- Kelime hakimiyeti: her kelimenin 3 yıldızı var, 3 yıldız = "Öğrenildi". Ders sonunda özet kartı çıkar.
  Ana sayfada "Günün kelimesi" kartı durur. Bunlar kalkmaz.
- Sıradaki işler (sırayla): cümle kurma, rozetler, yavaş okuma butonu. Bildirim hatırlatması ve konuşma (mikrofon)
  paket gerektirir, önce kullanıcıya sor.

- **Ders uzunluğu kararı**: Kullanıcı 22 soruluk dersi olduğu gibi bıraktı. Telefonda test edilip çocuk için çok uzun
  bulunursa sırayla: önce "akıllı kısaltma" (tanıma sorusunu doğru bilen kelimede harf dizme atlanır), hâlâ uzunsa
  dersi 2 kısma bölme (5+5 kelime). Kullanıcı istemeden yapma.

## 11. YENİ KATEGORİYE (DERSE) GEÇİŞ KONTROL LİSTESİ (KESİN KURAL, her seferinde uygulanır)

Amaç: her yeni kategori aynı düzenle gelsin, hiçbir özellik atlanmasın, devamlılık bozulmasın.
Yeni kategori = yeni ders (Bölüm 9 sırasıyla). Bir önceki ders kullanıcı onayı almadan yenisine geçilmez.

**A. Başlamadan önce**
1. Bölüm 9'daki sıradaki kategoriyi ve durumunu kontrol et. Önceki ders `test [x]` değilse dur, kullanıcıya sor.
2. Kullanıcıya 10 kelimeyi ver: İngilizce, okunuş (`say`), Türkçe, örnek cümle + cümlenin Türkçesi, Gemini görsel prompt'ları.
3. Örnek cümleler şu kuralları sağlamalı (Harf dizme artık her kelimede çıkar, uzunluk sınırı yok):
   - Kelime örnek cümlede TAM BİR kez geçer (Cümle tamamlama bunu ister, `blankSentence` null dönmemeli).
   - Çok kelimeli ifadeler çok uzun olmasın (Harf dizmede kelime parçaları dizilir, en çok 4-5 parça).
4. Görseller Bölüm 8'e göre hazır olmadan ders koda eklenmez.

**B. Koda eklerken (sadece bunlar değişir, başka dosyaya dokunma)**
5. `lesson_data.dart`: `lessonNWords` listesi (10 kelime, `Word` alanlarının hepsi dolu), `lessonsContent` ve
   `lessonTitles` listelerine EKLE (aynı sıra).
6. `assets/words/<kelime>.png` dosyaları (küçük harf, boşluksuz, saydam PNG).
7. Ders haritası (`lesson_map_screen.dart`) ve ana sayfa içerik hazır ders sayısını `lessonsContent.length`'ten alır;
   kilit ve ders adı doğru görünüyor mu kontrol et.

**C. Otomatik gelenler (ek iş yok, ama çalıştığını kontrol et)**
8. Quiz (`buildQuiz`): 10 kelimede 22 soru çıkmalı (10 tanıma + 1 eşleştirme + 10 harf dizme + 1 eşleştirme); 6 soru tipinin hepsi görünmeli; yanlışlar sonda tekrar sorulmalı.
9. Tekrar dersi: yeni dersin kelimeleri otomatik katılır. Her 2-3 dersten sonra kullanıcıya "Tekrar dersi yapalım mı?" diye hatırlat.
10. Kelime hakimiyeti yıldızları, Zor listesi, günün kelimesi, ders sonu özeti yeni kelimelerle kendiliğinden çalışır.
11. Yeni kalıcı veri gerekirse `AppState` içinde `load()` ve `_save()` ikisi de güncellenir (Bölüm 7).

**D. Bitirirken**
12. Performans kurallarını kontrol et (Bölüm 1): animasyon yok, yeni paket yok, `const`, küçük `setState`.
13. Bölüm 9'daki durum satırını güncelle (kelimeler [x] görseller [x] kod [x] test [ ]) ve Bölüm 6.1'e günlük yaz.
14. Değişen dosyalar ve güncel `AGENTS.md` kullanıcıya ZIP olarak DEĞİL, tek tek dosya olarak verilir.
15. Kullanıcı test edip onaylayınca `test [x]` yapılır, sonra sıradaki kategoriye geçilir.

## 12. Kelime Listem: dersler kapanır-açılır (KESİN KURAL)

Proje sahibinin kesin isteği. İzin almadan değiştirme.

- Kelime Listem'de (`word_list_screen.dart`) her dersin kelimeleri **KAPALI** gelir. Sadece ders başlığı görünür
  (numara, ders adı, kelime sayısı, ok simgesi).
- Kullanıcı başlığa dokunarak dersi **kendisi açar**, tekrar dokununca kapatır. Açık dersler `_open` kümesinde tutulur.
- Arama yazılırken bulunan kelimelerin görünmesi için dersler açık gösterilir (arama kutusu kapanınca eski hali).
- Açma/kapama anında olur, ANİMASYON YOK (Bölüm 1). Ok simgesi iki ayrı ikondur (`keyboard_arrow_down/up`), döndürme yok.
- Yeni ders eklenince de aynı kural geçerli: kelimeler kapalı gelir. Başlık `lessonTitles`'tan okunur.
