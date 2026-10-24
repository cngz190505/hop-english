import 'package:flutter/foundation.dart';
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
/// NOT: Şimdilik sadece bellekte tutulur, uygulama kapanınca sıfırlanır.
class AppState extends ChangeNotifier {
  static final AppState instance = AppState._();
  AppState._();

  static const xpPerLevel = 200;
  static const xpReward = 20;
  static const gemReward = 5;

  int xp = 45;
  int gems = 120;
  int streak = 3;
  int completedLessons = 0;
  int lessonsToday = 0;
  /// Quizde yanlış yapılan kelimeler (İngilizce yazılışı). "Zor" listesi.
  final Set<String> hardWords = {};
  String? _day;

  /// Tamamlanan derslerdeki kelimeler.
  List<Word> get learnedWords => [
        for (var i = 0; i < completedLessons && i < lessonsContent.length; i++)
          ...lessonsContent[i],
      ];

  int get level => xp ~/ xpPerLevel + 1;
  int get xpInLevel => xp % xpPerLevel;

  String _today() => DateTime.now().toIso8601String().substring(0, 10);

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
    hardWords.addAll(missed);
    hardWords.removeAll(correct);
    xp += xpReward;
    gems += gemReward;
    if (gained) streak++;
    notifyListeners();
    return Reward(
      xp: xpReward,
      gems: gemReward,
      streakGained: gained,
      streak: streak,
    );
  }
}
