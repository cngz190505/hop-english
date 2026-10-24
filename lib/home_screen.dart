import 'package:flutter/material.dart';
import 'theme.dart';

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
      body: SafeArea(
        // Sayfalar bellekte kalır: sekme değişince silinip yeniden kurulmaz.
        child: IndexedStack(
          index: _index,
          children: const [
            _HomeTab(),
            _Soon(title: 'Dersler'),
            _Soon(title: 'Tekrar'),
            _Soon(title: 'Profil'),
          ],
        ),
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

class _Soon extends StatelessWidget {
  final String title;
  const _Soon({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title\nYakında',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: kInk,
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
            const _StatPill(asset: 'assets/ready/icon_flame.png', value: '3'),
            const SizedBox(width: 8),
            const _StatPill(asset: 'assets/ready/icon_gem.png', value: '120'),
          ],
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(child: ProgressBar(value: 45 / 200, height: 8)),
            SizedBox(width: 10),
            Text(
              'Seviye 1  •  45 / 200 XP',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kMuted,
              ),
            ),
          ],
        ),
      ],
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
                Row(
                  children: [
                    Expanded(child: ProgressBar(value: 0, height: 10)),
                    SizedBox(width: 8),
                    Text(
                      '0/1',
                      style: TextStyle(
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
        ],
      ),
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
                    Row(
                      children: [
                        Icon(Icons.menu_book_rounded, size: 16, color: kMuted),
                        SizedBox(width: 6),
                        Text(
                          '0/6',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kMuted,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(child: ProgressBar(value: 0, height: 8)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ChunkyButton(
            text: 'Derse Başla',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ders ekranı yakında eklenecek')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Row(
        children: [
          Image.asset('assets/ready/icon_target.png', height: 48, cacheHeight: 150),
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
                  children: const [
                    Expanded(child: ProgressBar(value: 0, height: 8)),
                    SizedBox(width: 8),
                    Text(
                      '0/5',
                      style: TextStyle(
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
          Image.asset('assets/ready/icon_gift.png', height: 40, cacheHeight: 120),
        ],
      ),
    );
  }
}
