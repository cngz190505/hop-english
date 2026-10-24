import 'package:flutter/material.dart';
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
          _HomeTab(onReview: () => setState(() => _index = 2)),
          const LessonMapTab(), // kendi güvenli alanını yönetir (tam ekran harita)
          const SafeArea(child: WordListTab()),
          const SafeArea(child: ProfileTab()),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x141C6BA8),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          animationDuration: Duration.zero,
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
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
  const _HomeTab({required this.onReview});

  @override
  Widget build(BuildContext context) {
    // Her kart ListView'ın kendi elemanı: ListView her elemanı ayrı RepaintBoundary içine alır,
    // kaydırırken kartlar önceden çizilmiş katman olarak kayar (tek büyük parça olmaz).
    const side = EdgeInsets.fromLTRB(14, 0, 14, 12);
    return ListView(
      padding: EdgeInsets.zero,
      cacheExtent: 800,
      children: [
        const _Hero(),
        const Padding(padding: side, child: _ContinueCard()),
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

const _softShadow = [
  BoxShadow(color: Color(0x1F1C6BA8), blurRadius: 10, offset: Offset(0, 3)),
];

const _lightText = [Shadow(color: Color(0x8C0A3C78), blurRadius: 4)];

/// Üstteki gökyüzü bölümü: arka plan resmi, profil, seri/elmas, ejderha ve konuşma balonu.
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: 300 + top,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          const Positioned.fill(
            child: RepaintBoundary(
              child: Image(
                // Açılış ekranındaki önyükleme ile AYNI boyut (width: 1080), tam boyut çözülmez.
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
                  stops: [0, 0.45, 1],
                ),
              ),
            ),
          ),
          Positioned(
            top: top + 12,
            left: 16,
            right: 16,
            child: const _Header(),
          ),
          Positioned(
            left: 16,
            top: top + 92,
            width: 178,
            child: const _Bubble(),
          ),
          Positioned(
            right: 6,
            bottom: -6,
            child: Image.asset(
              'assets/ready/mascot_main.png',
              height: 200,
              cacheHeight: 600,
              gaplessPlayback: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final s = AppState.instance;
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                backgroundImage: ResizeImage(
                  AssetImage('assets/ready/girl_hi.png'),
                  width: 144,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Merhaba,',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      shadows: _lightText,
                    ),
                  ),
                  Text(
                    'Yeni Başlangıç',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: _lightText,
                    ),
                  ),
                ],
              ),
            ),
            _StatPill(asset: 'assets/ready/icon_flame.png', value: '${s.streak}'),
            const SizedBox(width: 8),
            _StatPill(asset: 'assets/ready/icon_gem.png', value: '${s.gems}'),
          ],
        );
      },
    );
  }
}

class _StatPill extends StatelessWidget {
  final String asset;
  final String value;
  const _StatPill({required this.asset, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 4, 12, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: _softShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(asset, height: 24, cacheHeight: 72),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: kInk,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final s = AppState.instance;
        final title = s.giftReady
            ? 'Hediyeni aç!'
            : (s.goalReached ? 'Bugünkü hedefin tamam!' : 'Hadi devam edelim!');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: const BoxDecoration(
                color: Color(0xF0FFFFFF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(6),
                ),
                boxShadow: _softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: kInk,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Bugün 5 dakika yeter.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Seviye ${s.level}  •  ${s.xpInLevel} / ${AppState.xpPerLevel} XP',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: _lightText,
              ),
            ),
            const SizedBox(height: 4),
            ProgressBar(value: s.xpInLevel / AppState.xpPerLevel, height: 12),
          ],
        );
      },
    );
  }
}

/// Büyük yeşil "Devam Et" kartı: sıradaki dersi açar.
class _ContinueCard extends StatelessWidget {
  const _ContinueCard();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final total = lessonsContent.length;
        final allDone = AppState.instance.completedLessons >= total;
        final idx = allDone ? total - 1 : AppState.instance.completedLessons;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF6BDC1E), Color(0xFF4CB800)],
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(color: Color(0xFF348A00), offset: Offset(0, 5)),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, Color(0xFFE4F5D3)],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFB8EE8A), width: 4),
                    ),
                    child: Text(
                      '${idx + 1}',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF3E9A00),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          allDone ? 'DERSİ TEKRARLA' : 'SIRADAKİ DERS',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          lessonTitles[idx],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.15,
                          ),
                        ),
                        Text(
                          '${lessonsContent[idx].length} kelime',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ChunkyButton(
                text: allDone ? 'Tekrar Et' : 'Devam Et',
                color: Colors.white,
                shadowColor: const Color(0xFFBFE5A3),
                textColor: const Color(0xFF3E9A00),
                height: 48,
                fontSize: 17,
                onPressed: () => openLesson(context, idx),
              ),
            ],
          ),
        );
      },
    );
  }
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
          onTap: () => Speech.speak(w.en),
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
                onTap: onReview,
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
