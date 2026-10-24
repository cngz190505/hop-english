import 'package:flutter/material.dart';
import 'app_state.dart';
import 'lesson_map_screen.dart';
import 'lesson_screen.dart';
import 'profile_screen.dart';
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
        children: const [
          SafeArea(child: _HomeTab()),
          LessonMapTab(), // kendi güvenli alanını yönetir (tam ekran harita)
          SafeArea(child: WordListTab()),
          SafeArea(child: ProfileTab()),
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
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: const [
        _Header(),
        SizedBox(height: 16),
        _HeroCard(),
        SizedBox(height: 22),
        Text(
          'Senin Derslerin',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: kInk,
          ),
        ),
        SizedBox(height: 12),
        _LessonCard(),
        SizedBox(height: 16),
        _GoalCard(),
      ],
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
        return Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: kBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    backgroundImage: ResizeImage(
                      AssetImage('assets/ready/girl_hi.png'),
                      width: 144,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Merhaba,',
                        style: TextStyle(fontSize: 13, color: kMuted),
                      ),
                      Text(
                        'Yeni Başlangıç',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: kInk,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatPill(
                  asset: 'assets/ready/icon_flame.png',
                  value: '${s.streak}',
                ),
                const SizedBox(width: 8),
                _StatPill(
                  asset: 'assets/ready/icon_gem.png',
                  value: '${s.gems}',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ProgressBar(
                    value: s.xpInLevel / AppState.xpPerLevel,
                    height: 8,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Seviye ${s.level}  •  ${s.xpInLevel} / ${AppState.xpPerLevel} XP',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kMuted,
                  ),
                ),
              ],
            ),
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
      padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3EEF8), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(asset, height: 22, cacheHeight: 66),
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

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFCFEBFF), Color(0xFFEAF6FF)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A1C6BA8),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/ready/mascot_main.png',
            height: 120,
            cacheHeight: 360,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bugünün Hedefi',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: kInk,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Bugün 5 dakikanı ayır ve İngilizcenin gücünü hisset!',
                  style: TextStyle(fontSize: 13, color: kMuted, height: 1.3),
                ),
                SizedBox(height: 10),
                _HeroProgress(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroProgress extends StatelessWidget {
  const _HeroProgress();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final sec = AppState.instance.studySeconds;
        final min = (sec ~/ 60).clamp(0, 5);
        return Row(
          children: [
            Expanded(
              child: ProgressBar(
                value: (sec / AppState.goalSeconds).clamp(0.0, 1.0),
                height: 10,
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
        );
      },
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Image.asset(
                  'assets/ready/kids.png',
                  fit: BoxFit.contain,
                  cacheHeight: 200,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamlaşma ve Kendini Tanıtma',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: kInk,
                      ),
                    ),
                    SizedBox(height: 8),
                    _LessonProgress(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ChunkyButton(
            text: 'Derse Başla',
            onPressed: () => openLesson1(context),
          ),
        ],
      ),
    );
  }
}

class _LessonProgress extends StatelessWidget {
  const _LessonProgress();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final done = AppState.instance.completedLessons >= 1 ? 6 : 0;
        return Row(
          children: [
            const Icon(Icons.menu_book_rounded, size: 16, color: kMuted),
            const SizedBox(width: 6),
            Text(
              '$done/6',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: kMuted,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: ProgressBar(value: done / 6, height: 8)),
          ],
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
