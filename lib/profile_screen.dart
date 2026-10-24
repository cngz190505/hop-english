import 'package:flutter/material.dart';
import 'app_state.dart';
import 'theme.dart';

/// Profil sekmesi.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final s = AppState.instance;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            const Center(
              child: Text(
                'Profil',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: kInk,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: kBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    backgroundImage: ResizeImage(
                      AssetImage('assets/ready/girl_hi.png'),
                      width: 240,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yeni Başlangıç',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: kInk,
                        ),
                      ),
                      Text(
                        'English Learner',
                        style: TextStyle(fontSize: 14, color: kMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Seviye ${s.level}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: kInk,
                  ),
                ),
                Text(
                  '${s.xpInLevel} / ${AppState.xpPerLevel} XP',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: kMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ProgressBar(value: s.xpInLevel / AppState.xpPerLevel, height: 12),
            const SizedBox(height: 18),
            Row(
              children: [
                _StatCard(
                  asset: 'assets/ready/icon_flame.png',
                  value: '${s.streak}',
                  label: 'Günlük Seri',
                ),
                const SizedBox(width: 10),
                _StatCard(
                  asset: 'assets/ready/icon_star.png',
                  value: '${s.xp}',
                  label: 'Toplam Puan',
                ),
                const SizedBox(width: 10),
                _StatCard(
                  asset: 'assets/ready/icon_gem.png',
                  value: '${s.gems}',
                  label: 'Elmas',
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Başarı Rozetleri',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: kInk,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Badge(
                  asset: 'assets/ready/badge_star.png',
                  label: 'İlk Adım',
                  earned: s.completedLessons >= 1,
                ),
                _Badge(
                  asset: 'assets/ready/icon_flame.png',
                  label: '5 Gün',
                  earned: s.streak >= 5,
                ),
                _Badge(
                  asset: 'assets/ready/badge_book.png',
                  label: '10 Kelime',
                  earned: s.learnedWords.length >= 10,
                ),
                const _Badge(asset: null, label: 'Sürpriz', earned: false),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String asset;
  final String value;
  final String label;
  const _StatCard({
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
            Image.asset(asset, height: 34, cacheHeight: 102),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: kInk,
              ),
            ),
            Text(label, style: const TextStyle(fontSize: 12, color: kMuted)),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String? asset;
  final String label;
  final bool earned;
  const _Badge({required this.asset, required this.label, required this.earned});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 66,
            height: 66,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: earned ? const Color(0xFFFFF1CC) : kTrack,
              shape: BoxShape.circle,
              border: Border.all(
                color: earned ? kYellow : kLocked,
                width: 3,
              ),
            ),
            child: asset == null
                ? const Icon(Icons.question_mark_rounded, color: kLockedDark)
                : Opacity(
                    opacity: earned ? 1 : 0.35,
                    child: Image.asset(asset!, cacheHeight: 200),
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: earned ? kInk : kMuted,
            ),
          ),
        ],
      ),
    );
  }
}
