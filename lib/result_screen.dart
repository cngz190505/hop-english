import 'package:flutter/material.dart';
import 'app_state.dart';
import 'lesson_data.dart';
import 'lesson_screen.dart';
import 'theme.dart';

class ResultScreen extends StatelessWidget {
  final Reward reward;
  final int correct;
  final int total;
  final List<Word> words;
  const ResultScreen({
    super.key,
    required this.reward,
    required this.correct,
    required this.total,
    required this.words,
  });

  void _home(BuildContext context) =>
      Navigator.of(context).popUntil((r) => r.isFirst);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8ED4FF), Color(0xFFDDF1FF), Colors.white],
            stops: [0, 0.45, 1],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, size: 28),
                  color: Colors.white,
                  onPressed: () => _home(context),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      RepaintBoundary(
                        child: Image.asset(
                          'assets/ready/mascot_star.png',
                          height: 230,
                          cacheHeight: 690,
                          gaplessPlayback: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tebrikler!',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: kInk,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Dersi tamamladın!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: kBlueDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$total sorudan $correct tanesini doğru yaptın',
                        style: const TextStyle(fontSize: 14, color: kMuted),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          _RewardCard(
                            asset: 'assets/ready/icon_star.png',
                            value: '+${reward.xp} XP',
                            label: 'Puan',
                          ),
                          const SizedBox(width: 10),
                          _RewardCard(
                            asset: 'assets/ready/icon_flame.png',
                            value: reward.streakGained
                                ? '+1'
                                : '${reward.streak}',
                            label: 'Günlük seri',
                          ),
                          const SizedBox(width: 10),
                          _RewardCard(
                            asset: 'assets/ready/icon_gem.png',
                            value: '+${reward.gems}',
                            label: 'Elmas',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Column(
                  children: [
                    ChunkyButton(
                      text: 'Ana Sayfaya Dön',
                      onPressed: () => _home(context),
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => LessonScreen(words: words),
                          ),
                        );
                      },
                      child: const Text(
                        'Dersi Tekrarla',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: kBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final String asset;
  final String value;
  final String label;
  const _RewardCard({
    required this.asset,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: cardDecoration(),
        child: Column(
          children: [
            Image.asset(asset, height: 36, cacheHeight: 108),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: kInk,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: kMuted),
            ),
          ],
        ),
      ),
    );
  }
}
