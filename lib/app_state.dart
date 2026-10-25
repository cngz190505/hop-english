import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'fx.dart';
import 'lesson_data.dart';

/// Ders bitince kazanılanlar.
class Reward {
  final int xp;
  final int gems;
  final bool streakGained; // bugünün ilk dersi mi (seri +1)
  final int streak;
  const Reward({
    required this.xp,
    required this.gems,
    required this.streakGained,
    required this.streak,
  });
}

/// Uygulamanın tek durum kaynağı (puan, elmas, seri, tamamlanan ders).
/// Ekranlar bunu ListenableBuilder ile dinler, sadece değişen kısım yenilenir.
/// Veriler telefona kaydedilir (shared_preferences), uygulama kapanınca kaybolmaz.
class AppState extends ChangeNotifier {
  static final AppState instance = AppState._();
  AppState._();

  static const xpPerLevel = 200;
  static const xpReward = 20;
  static const gemReward = 5;
  static const reviewXp = 10; // tekrar dersi ödülü
  static const reviewGems = 2;
  static const goalSeconds = 300; // günlük hedef: 5 dakika
  static const giftGems = 10; // hedef tamamlanınca hediye

  int xp = 45;
  int gems = 120;
  int streak = 3;
  int completedLessons = 0;
  int lessonsToday = 0;
  /// Quizde yanlış yapılan kelimeler (İngilizce yazılışı). "Zor" listesi.
  final Set<String> hardWords = {};
  /// Kelime hakimiyeti: İngilizce kelime -> 0..3 yıldız. 3 yıldız = "Öğrenildi".
  final Map<String, int> mastery = {};
  static const maxMastery = 3;
  String? _day;

  /// Kaldığı yer: ders/quiz yarıda bırakılınca burada tutulur, telefona kaydedilir.
  /// Alanlar: lesson, stage ('lesson' | 'quiz'), n (kelime sayısı), i (kelime/soru sırası),
  /// quizde ayrıca total, correct, streak, delta, missed, right, retries.
  Map<String, dynamic>? resume;

  /// [lesson] dersi için kaydedilmiş geçerli bir kaldığı yer varsa döner.
  Map<String, dynamic>? resumeFor(int lesson) {
    final r = resume;
    if (r == null || r['lesson'] != lesson) return null;
    if (lesson < 0 || lesson >= lessonsContent.length) return null;
    if (r['n'] != lessonsContent[lesson].length) return null; // ders içeriği değişmiş
    return r;
  }

  /// Her adımda çağrılır (bildirim yok, sadece kaydeder).
  void saveResume(Map<String, dynamic> r) {
    resume = r;
    _persistResume();
  }

  void clearResume() {
    if (resume == null) return;
    resume = null;
    _persistResume();
  }

  /// Ders/quiz ekranı kapanınca ana sayfa "kaldığın yer" yazısı yenilensin.
  void refreshLater() {
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  Future<void> _persistResume() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (resume == null) {
        await p.remove('resume');
      } else {
        await p.setString('resume', jsonEncode(resume));
      }
    } catch (_) {}
  }

  // Günlük hedef (süre) ve hediye. Ders günü (_day) ile ayrı tutulur.
  String? _studyDay;
  int _studySeconds = 0;
  bool _giftClaimed = false;

  int get studySeconds => _studyDay == _today() ? _studySeconds : 0;
  bool get goalReached => studySeconds >= goalSeconds;
  bool get giftClaimed => _studyDay == _today() && _giftClaimed;
  bool get giftReady => goalReached && !giftClaimed;

  int masteryOf(String en) => mastery[en] ?? 0;
  bool isMastered(String en) => masteryOf(en) >= maxMastery;

  /// Quiz bitince, complete* çağrılmadan ÖNCE çağrılır. Kelime başına net sonuç
  /// (doğru - yanlış) -1..+2 ile sınırlanır: bir ders tek başına kelimeyi öğrendirmez.
  void applyMastery(Map<String, int> delta) {
    delta.forEach((en, d) {
      if (sentenceKeys.contains(en)) return; // cümleler hakimiyete girmez
      mastery[en] = (masteryOf(en) + d.clamp(-1, 2)).clamp(0, maxMastery);
    });
  }

  /// Tamamlanan derslerdeki kelimeler.
  List<Word> get learnedWords => [
        for (var i = 0; i < completedLessons && i < lessonsContent.length; i++)
          ...lessonsContent[i].where((w) => !w.isSentence),
      ];

  int get level => xp ~/ xpPerLevel + 1;
  int get xpInLevel => xp % xpPerLevel;

  /// Uygulama açılırken bir kez çağrılır (main.dart). Hata olursa varsayılanlarla devam eder.
  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      xp = p.getInt('xp') ?? xp;
      gems = p.getInt('gems') ?? gems;
      streak = p.getInt('streak') ?? streak;
      completedLessons = p.getInt('completedLessons') ?? completedLessons;
      _day = p.getString('day');
      // Bugün ders yapılmadıysa "bugünkü ders" sayacı sıfır.
      lessonsToday = _day == _today() ? (p.getInt('lessonsToday') ?? 0) : 0;
      hardWords.addAll(p.getStringList('hardWords') ?? const []);
      for (final e in p.getStringList('mastery') ?? const <String>[]) {
        final k = e.lastIndexOf('|');
        if (k > 0) mastery[e.substring(0, k)] = int.tryParse(e.substring(k + 1)) ?? 0;
      }
      final rs = p.getString('resume');
      if (rs != null) {
        final d = jsonDecode(rs);
        if (d is Map) resume = Map<String, dynamic>.from(d);
      }
      _studyDay = p.getString('studyDay');
      _studySeconds = p.getInt('studySeconds') ?? 0;
      _giftClaimed = p.getBool('giftClaimed') ?? false;
      // Dünden önce son ders yapıldıysa seri bozulmuştur.
      final yesterday = DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String()
          .substring(0, 10);
      if (_day != null && _day!.compareTo(yesterday) < 0) streak = 0;
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setInt('xp', xp);
      await p.setInt('gems', gems);
      await p.setInt('streak', streak);
      await p.setInt('completedLessons', completedLessons);
      await p.setInt('lessonsToday', lessonsToday);
      if (_day != null) await p.setString('day', _day!);
      await p.setStringList('hardWords', hardWords.toList());
      await p.setStringList(
        'mastery',
        [for (final e in mastery.entries) '${e.key}|${e.value}'],
      );
      if (_studyDay != null) await p.setString('studyDay', _studyDay!);
      await p.setInt('studySeconds', _studySeconds);
      await p.setBool('giftClaimed', _giftClaimed);
    } catch (_) {}
  }

  String _today() => DateTime.now().toIso8601String().substring(0, 10);

  /// Çalışma süresi ekler (ders/quiz ekranı kapanırken). Güvenli: ekranlar
  /// kapanırken çağrılabilir, bildirim bir sonraki kareye ertelenir.
  void addStudySeconds(int seconds) {
    if (seconds <= 0) return;
    final t = _today();
    if (_studyDay != t) {
      _studyDay = t;
      _studySeconds = 0;
      _giftClaimed = false;
    }
    _studySeconds += seconds;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
      _save();
    });
  }

  /// Hedef tamamlanınca hediye kutusuna basınca elmas verir (sadece tıklamadan çağır).
  void claimGift() {
    if (!giftReady) return;
    _giftClaimed = true;
    Fx.reward();
    gems += giftGems;
    notifyListeners();
    _save();
  }

  /// Tekrar dersi bittiğinde çağrılır (sadece olay/tıklama içinden). Ders sayısını ve seriyi
  /// değiştirmez, sadece küçük XP/elmas verir ve "zor" listesini günceller.
  Reward completeReview({
    List<String> missed = const [],
    List<String> correct = const [],
  }) {
    hardWords.addAll(missed.where((e) => !sentenceKeys.contains(e)));
    hardWords.removeAll(correct);
    xp += reviewXp;
    gems += reviewGems;
    notifyListeners();
    _save();
    return Reward(
      xp: reviewXp,
      gems: reviewGems,
      streakGained: false,
      streak: streak,
    );
  }

  /// Ders bittiğinde çağrılır (sadece olay/tıklama içinden, build içinden değil).
  Reward completeLesson(
    int index, {
    List<String> missed = const [],
    List<String> correct = const [],
  }) {
    final today = _today();
    if (_day != today) {
      _day = today;
      lessonsToday = 0;
    }
    final gained = lessonsToday == 0;
    lessonsToday++;
    if (completedLessons <= index) completedLessons = index + 1;
    resume = null; // ders bitti, kaldığı yer silinir
    _persistResume();
    hardWords.addAll(missed.where((e) => !sentenceKeys.contains(e)));
    hardWords.removeAll(correct);
    xp += xpReward;
    gems += gemReward;
    if (gained) streak++;
    notifyListeners();
    _save();
    return Reward(
      xp: xpReward,
      gems: gemReward,
      streakGained: gained,
      streak: streak,
    );
  }
}

/// Bir ekranda geçirilen süreyi ölçer. Her dokunuşta [tap], ekran kapanırken
/// [finish] çağrılır. İki dokunuş arası en fazla 60 sn sayılır (boşta bekleme sayılmaz).
class StudyTimer {
  final Stopwatch _sw = Stopwatch()..start();
  int _last = 0;
  int _acc = 0;

  void tap() {
    final now = _sw.elapsed.inSeconds;
    _acc += min(now - _last, 60);
    _last = now;
  }

  void finish() {
    tap();
    AppState.instance.addStudySeconds(_acc);
    _acc = 0;
  }
}
