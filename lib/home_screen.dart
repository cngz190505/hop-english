import 'package:flutter/material.dart';
import 'fx.dart';
import 'app_state.dart';
import 'lesson_data.dart';
import 'lesson_map_screen.dart';
import 'lesson_screen.dart';
import 'profile_screen.dart';
import 'speech.dart';
import 'theme.dart';
import 'word_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: IndexedStack(
        // Sayfalar bellekte kalır: sekme değişince silinip yeniden kurulmaz.
        index: _index,
        children: [
          _HomeTab(
            onReview: () => setState(() => _index = 2),
            onLessons: () => setState(() => _index = 1),
          ),
          const LessonMapTab(), // kendi güvenli alanını yönetir (tam ekran harita)
          const SafeArea(child: WordListTab()),
          const ProfileTab(), // lacivert üst bölüm durum çubuğunun altına uzanır, SafeArea yok
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x141C6BA8),
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          animationDuration: Duration.zero,
          selectedIndex: _index,
          onDestinationSelected: (i) {
            Fx.tap();
            setState(() => _index = i);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_rounded),
              label: 'Ana Sayfa',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_rounded),
              label: 'Dersler',
            ),
            NavigationDestination(
              icon: Icon(Icons.refresh_rounded),
              label: 'Tekrar',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final VoidCallback onReview;
  final VoidCallback onLessons;
  const _HomeTab({required this.onReview, required this.onLessons});

  @override
  Widget build(BuildContext context) {
    // Her kart ListView'ın kendi elemanı: kaydırırken kartlar önceden çizilmiş katman olarak kayar.
    const side = EdgeInsets.fromLTRB(14, 0, 14, 12);
    return ListView(
      padding: EdgeInsets.zero,
      cacheExtent: 2000,
      children: [
        const _HeroWithCard(),
        _TodayLessons(onAll: onLessons),
        const Padding(padding: side, child: _WeekCard()),
        const Padding(padding: side, child: _GoalCard()),
        const Padding(padding: side, child: _WordOfDayCard()),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
          child: _HardWordsCard(onReview: onReview),
        ),
      ],
    );
  }
}

// Bulanık (blur) metin gölgesi kaydırırken pahalı: sert, ucuz gölge kullanılır.
const _lightText = [Shadow(color: Color(0x990A3C78), offset: Offset(0, 2))];

/// Üstte gökyüzü + başlık + maskot; altına taşan Seri/Puan kartı ve "Dersine Başla" butonu.
class _HeroWithCard extends StatelessWidget {
  const _HeroWithCard();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final heroH = 290 + top;
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: heroH,
          child: RepaintBoundary(
            child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              const Positioned.fill(
                child: RepaintBoundary(
                  child: Image(
                    image: ResizeImage(AssetImage('assets/ready/bg_london.png'), width: 1080),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    gaplessPlayback: true,
                  ),
                ),
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x401E8CE6), Color(0x00EEF7FF), kBg],
                      stops: [0, 0.55, 1],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: top + 24,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hop',
                      style: TextStyle(
                        fontSize: 44,
                        height: 1.0,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: _lightText,
                      ),
                    ),
                    Text(
                      'English',
                      style: TextStyle(
                        fontSize: 44,
                        height: 1.0,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFB6F04A),
                        shadows: _lightText,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Daha iyi bir sen için\nİngilizce öğren!',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        shadows: _lightText,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 6,
                bottom: 40,
                child: Image.asset(
                  'assets/ready/mascot_main.png',
                  height: 190,
                  cacheHeight: 600,
                  gaplessPlayback: true,
                ),
              ),
            ],
          ),
          ),
        ),
        // Kart hero'nun altına taşar; Stack'in yüksekliğini bu çocuk belirler.
        Padding(
          padding: EdgeInsets.fromLTRB(14, heroH - 44, 14, 16),
          child: const RepaintBoundary(child: _StartCard()),
        ),
      ],
    );
  }
}

/// Günlük Seri | Puan kutuları, seviye çubuğu ve büyük yeşil başlat butonu.
class _StartCard extends StatelessWidget {
  const _StartCard();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final s = AppState.instance;
        final total = lessonsContent.length;
        final allDone = s.completedLessons >= total;
        final idx = allDone ? total - 1 : s.completedLessons;
        final resume = _resumeText(idx);
        final label = allDone
            ? 'Tekrar Et'
            : (resume != null ? 'Devam Et' : 'Dersine Başla');
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE3EEF8), width: 1.5),
            boxShadow: const [
              BoxShadow(color: Color(0x261C6BA8), blurRadius: 10, offset: Offset(0, 6)),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      asset: 'assets/ready/icon_flame.png',
                      title: 'Günlük Seri',
                      value: '${s.streak} gün',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatTile(
                      asset: 'assets/ready/icon_gem.png',
                      title: 'Puan',
                      value: '${s.gems}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Seviye ${s.level}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: kInk,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ProgressBar(value: s.xpInLevel / AppState.xpPerLevel, height: 10),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${s.xpInLevel} / ${AppState.xpPerLevel} XP',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: kMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ChunkyButton(
                text: '$label  →',
                height: 52,
                fontSize: 18,
                onPressed: () => openLesson(context, idx),
              ),
              if (resume != null && !allDone) ...[
                const SizedBox(height: 8),
                Text(
                  '${lessonTitles[idx]} • $resume',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: kMuted,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final String asset;
  final String title;
  final String value;
  const _StatTile({required this.asset, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3EEF8), width: 1.5),
      ),
      child: Row(
        children: [
          Image.asset(asset, height: 38, cacheHeight: 114),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kMuted),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: kInk),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Bugünün Dersleri": her ders için ilerleme kartı. Kilitli dersler soluk.
class _TodayLessons extends StatelessWidget {
  final VoidCallback onAll;
  const _TodayLessons({required this.onAll});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final s = AppState.instance;
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Bugünün Dersleri',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kInk),
                      ),
                    ),
                    GestureDetector(
                      onTap: onAll,
                      behavior: HitTestBehavior.opaque,
                      child: const Text(
                        'Tümünü Gör  ›',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kBlueDark),
                      ),
                    ),
                  ],
                ),
              ),
              for (var i = 0; i < lessonsContent.length; i++)
                RepaintBoundary(
                  child: _LessonTile(
                    index: i,
                    done: i < s.completedLessons,
                    locked: i > s.completedLessons,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LessonTile extends StatelessWidget {
  final int index;
  final bool done;
  final bool locked;
  const _LessonTile({required this.index, required this.done, required this.locked});

  @override
  Widget build(BuildContext context) {
    final n = lessonsContent[index].length;
    final r = AppState.instance.resumeFor(index);
    var step = 0;
    if (done) {
      step = n;
    } else if (!locked && r != null && r['stage'] != 'quiz') {
      step = (r['i'] is int) ? (r['i'] as int).clamp(0, n) : 0;
    } else if (!locked && r != null) {
      step = n;
    }
    final Color c = done ? kGreen : (locked ? kLocked : kBlue);
    return GestureDetector(
      onTap: locked
          ? null
          : () {
              Fx.tap();
              openLesson(context, index);
            },
      behavior: HitTestBehavior.opaque,
      child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: cardDecoration(),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                child: done
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 28)
                    : Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lessonTitles[index],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: locked ? kMuted : kInk,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      locked ? 'Kilitli' : '$step / $n tamamlandı',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kMuted),
                    ),
                    const SizedBox(height: 7),
                    ProgressBar(value: n == 0 ? 0 : step / n, height: 7, color: c),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                locked ? Icons.lock_rounded : Icons.chevron_right_rounded,
                color: kLocked,
                size: 26,
              ),
            ],
          ),
        ),
    );
  }
}

String? _resumeText(int idx) {
  final r = AppState.instance.resumeFor(idx);
  if (r == null) return null;
  final i = (r['i'] is int) ? (r['i'] as int) : 0;
  if (r['stage'] == 'quiz') {
    final total = (r['total'] is int) ? (r['total'] as int) : 0;
    return total > 0 ? 'Kaldığın yer: Soru ${i + 1}/$total' : 'Kaldığın yerden devam';
  }
  return 'Kaldığın yer: Kelime ${i + 1}/${lessonsContent[idx].length}';
}

/// Haftalık seri satırı (Pzt-Paz). Seri sayısından hesaplanır.
class _WeekCard extends StatelessWidget {
  const _WeekCard();

  static const _names = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final s = AppState.instance;
        final today = DateTime.now().weekday - 1;
        final doneToday = s.lessonsToday > 0;
        final back = doneToday ? s.streak - 1 : s.streak;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: cardDecoration(),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Bu hafta',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: kInk,
                      ),
                    ),
                  ),
                  Image.asset('assets/ready/icon_flame.png', height: 18, cacheHeight: 54),
                  const SizedBox(width: 4),
                  Text(
                    '${s.streak} günlük seri',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: kMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < 7; i++)
                    _DayDot(
                      label: _names[i],
                      done: i == today ? doneToday : (i < today && today - i <= back),
                      isToday: i == today,
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DayDot extends StatelessWidget {
  final String label;
  final bool done;
  final bool isToday;
  const _DayDot({required this.label, required this.done, required this.isToday});

  @override
  Widget build(BuildContext context) {
    final Widget dot;
    if (done) {
      dot = Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7BE02A), Color(0xFF4CB800)],
          ),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Color(0xFF3A9300), offset: Offset(0, 3))],
        ),
        child: const Icon(Icons.check_rounded, size: 20, color: Colors.white),
      );
    } else if (isToday) {
      dot = Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: kBlue, width: 3),
        ),
      );
    } else {
      dot = Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          color: Color(0xFFE1E9F1),
          shape: BoxShape.circle,
        ),
      );
    }
    return Column(
      children: [
        dot,
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isToday ? FontWeight.w900 : FontWeight.w800,
            color: isToday ? kInk : kMuted,
          ),
        ),
      ],
    );
  }
}

/// Günün kelimesi: tarihe göre öğrenilen kelimelerden biri (ders yoksa 1. dersten). Dokununca okunur.
class _WordOfDayCard extends StatelessWidget {
  const _WordOfDayCard();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final learned = AppState.instance.learnedWords;
        final w = wordOfDay(learned.isEmpty ? lessonsContent.first : learned);
        return GestureDetector(
          onTap: () {
            Fx.tap();
            Speech.speak(w.en);
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: cardDecoration(),
            child: Row(
              children: [
                SizedBox(
                  width: 84,
                  height: 84,
                  child: Image.asset(
                    w.imagePath,
                    height: 84,
                    cacheHeight: 252,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) =>
                        Center(child: Text(w.emoji, style: const TextStyle(fontSize: 44))),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Günün kelimesi',
                        style: TextStyle(fontSize: 12, color: kMuted),
                      ),
                      Text(
                        w.en,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: kInk,
                        ),
                      ),
                      Text(
                        w.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kBlueDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.volume_up_rounded, color: kBlue, size: 30),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HardWordsCard extends StatelessWidget {
  final VoidCallback onReview;
  const _HardWordsCard({required this.onReview});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final n = AppState.instance.hardWords.length;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: cardDecoration(),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Zor kelimeler',
                      style: TextStyle(fontSize: 12, color: kMuted),
                    ),
                    Text(
                      n == 0 ? 'Hepsini biliyorsun!' : '$n kelime',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: kInk,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Fx.press();
                  onReview();
                },
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFF1ECFF), Color(0xFFE3DAFF)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(color: Color(0xFFCFC3F5), offset: Offset(0, 3)),
                    ],
                  ),
                  child: const Text(
                    'Tekrar Et',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF5B3FC4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final s = AppState.instance;
        final min = (s.studySeconds ~/ 60).clamp(0, 5);
        final String hint;
        if (s.giftReady) {
          hint = 'Hediyeni aç!';
        } else if (s.giftClaimed) {
          hint = 'Hediye alındı ✓';
        } else {
          hint = '';
        }
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: cardDecoration(),
          child: Row(
            children: [
              Image.asset(
                'assets/ready/icon_target.png',
                height: 48,
                cacheHeight: 150,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Günlük Hedef',
                      style: TextStyle(fontSize: 12, color: kMuted),
                    ),
                    const Text(
                      '5 dakika öğren',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: kInk,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ProgressBar(
                            value:
                                (s.studySeconds / AppState.goalSeconds).clamp(0.0, 1.0),
                            height: 8,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$min/5',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: kMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: s.giftReady ? AppState.instance.claimGift : null,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/ready/icon_gift.png',
                      height: 40,
                      cacheHeight: 120,
                    ),
                    if (hint.isNotEmpty)
                      Text(
                        hint,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: s.giftReady ? kBlue : kMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
