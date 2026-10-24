import 'package:flutter/material.dart';
import 'floating.dart';

const _green = Color(0xFF58CC02);
const _bg = Color(0xFFF3F9FF);
const _ink = Color(0xFF2B3A4A);

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    boxShadow: const [
      BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
    ],
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  static const _titles = ['Ana Sayfa', 'Dersler', 'Tekrar', 'Profil'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: _index == 0
            ? const _HomeTab()
            : _Soon(title: _titles[_index]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFDDF0FF),
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
          color: _ink,
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
        _MascotCard(),
        SizedBox(height: 20),
        Text(
          'Günün dersi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
        SizedBox(height: 10),
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
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white,
          backgroundImage: AssetImage('assets/ready/girl_hi.png'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Yeni Başlangıç',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: const LinearProgressIndicator(
                  value: 45 / 200,
                  minHeight: 8,
                  color: _green,
                  backgroundColor: Color(0xFFDDE7EF),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Seviye 1  •  45 / 200 XP',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const _Stat(asset: 'assets/ready/icon_flame.png', value: '3'),
        const SizedBox(width: 10),
        const _Stat(asset: 'assets/ready/icon_gem.png', value: '120'),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String asset;
  final String value;
  const _Stat({required this.asset, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(asset, height: 26),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
      ],
    );
  }
}

class _MascotCard extends StatelessWidget {
  const _MascotCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFCDEBFF), Color(0xFFE6F5FF)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Floating(
            distance: 8,
            child: Image.asset('assets/ready/mascot_main.png', height: 110),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Harika gidiyorsun!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Bugün 5 dakikanı ayır ve İngilizcenin gücünü hisset!',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
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
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Image.asset('assets/ready/kids.png', fit: BoxFit.contain),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamlaşma ve Kendini Tanıtma',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '0/6',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ders ekranı yakında eklenecek')),
                );
              },
              child: const Text(
                'Derse Başla',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
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
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Image.asset('assets/ready/icon_target.png', height: 46),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Günlük hedef',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const Text(
                  '5 dakika öğren',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: const LinearProgressIndicator(
                          value: 0,
                          minHeight: 8,
                          color: _green,
                          backgroundColor: Color(0xFFDDE7EF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '0/5',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Image.asset('assets/ready/icon_gift.png', height: 38),
        ],
      ),
    );
  }
}
