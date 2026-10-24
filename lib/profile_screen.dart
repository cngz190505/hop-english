import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_state.dart';
import 'debug_tools.dart';
import 'fx.dart';
import 'theme.dart';

/// Profil sekmesi: lacivert üst bölüm (avatar, ad, seviye), istatistik kartları, rozetler.
/// Animasyon yok, blur yok. Her bölüm ListView'ın kendi elemanı (ayrı çizim katmanı).
/// Üst bölüm durum çubuğunun altına kadar uzanır, bu yüzden home_screen.dart bu sekmeyi
/// SafeArea İÇİNE KOYMAZ; üst boşluk burada MediaQuery ile verilir.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  static const _navyTop = Color(0xFF0F2C5C);
  static const _navyBottom = Color(0xFF1D5AA8);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Koyu zeminde saat/pil simgeleri açık renk olsun.
      value: SystemUiOverlayStyle.light,
      child: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) {
          final s = AppState.instance;
          // Rozetler: kazanıldı mı? (sırası ekrandaki sırayla aynı)
          final earned = [
            s.completedLessons >= 1,
            s.streak >= 5,
            s.learnedWords.length >= 10,
            s.goalReached,
          ];
          final earnedCount = earned.where((e) => e).length;
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            cacheExtent: 800,
            children: [
              // 1) Lacivert üst bölüm
              Container(
                padding: EdgeInsets.fromLTRB(20, top + 20, 20, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_navyTop, _navyBottom],
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const CircleAvatar(
                            radius: 38,
                            backgroundColor: Color(0xFFD7EEFF),
                            backgroundImage: ResizeImage(
                              AssetImage('assets/ready/girl_hi.png'),
                              width: 240,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Uzun basınca performans ölçeri açılır/kapanır (debug_tools.dart).
                              GestureDetector(
                                onLongPress: () {
                                  Fx.press();
                                  showPerfOverlay.value = !showPerfOverlay.value;
                                },
                                behavior: HitTestBehavior.opaque,
                                child: const Text(
                                  'Yeni Başlangıç',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'English Learner',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFA9D4FF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Image.asset(
                          'assets/ready/icon_star.png',
                          height: 24,
                          cacheHeight: 72,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Seviye ${s.level}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${s.xpInLevel} / ${AppState.xpPerLevel} XP',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFA9D4FF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _DarkBar(value: s.xpInLevel / AppState.xpPerLevel),
                  ],
                ),
              ),
              // 2) İstatistikler
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                child: Row(
                  children: [
                    _StatCard(
                      asset: 'assets/ready/icon_flame.png',
                      value: '${s.streak}',
                      label: 'Günlük Seri',
                    ),
                    const SizedBox(width: 10),
                    _StatCard(
                      asset: 'assets/ready/icon_gem.png',
                      value: '${s.gems}',
                      label: 'Elmas',
                    ),
                    const SizedBox(width: 10),
                    _StatCard(
                      asset: 'assets/ready/badge_star.png',
                      value: '$earnedCount',
                      label: 'Rozet',
                    ),
                  ],
                ),
              ),
              // 3) Başarılarım
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Başarılarım',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: kInk,
                        ),
                      ),
                    ),
                    Text(
                      '$earnedCount / ${earned.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: kBlue,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                  decoration: cardDecoration(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Badge(
                        asset: 'assets/ready/badge_star.png',
                        label: 'İlk Adım',
                        earned: earned[0],
                        color: const Color(0xFFFFE3B3),
                      ),
                      _Badge(
                        asset: 'assets/ready/icon_flame.png',
                        label: '5 Gün',
                        earned: earned[1],
                        color: const Color(0xFFFFE9A8),
                      ),
                      _Badge(
                        asset: 'assets/ready/badge_book.png',
                        label: '10 Kelime',
                        earned: earned[2],
                        color: const Color(0xFFCDEBFF),
                      ),
                      _Badge(
                        asset: 'assets/ready/icon_target.png',
                        label: 'Hedefe Ulaş',
                        earned: earned[3],
                        color: const Color(0xFFD7F5BC),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Koyu zeminde ilerleme çubuğu (açık iz, yeşil dolgu).
class _DarkBar extends StatelessWidget {
  final double value;
  const _DarkBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 12,
        color: const Color(0x33FFFFFF),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: value.clamp(0.0, 1.0),
          child: Container(color: kGreen),
        ),
      ),
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: cardDecoration(),
        child: Column(
          children: [
            Image.asset(asset, height: 38, cacheHeight: 114),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: kInk,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: kMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String asset;
  final String label;
  final bool earned;
  final Color color; // kazanılınca daire rengi
  const _Badge({
    required this.asset,
    required this.label,
    required this.earned,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: earned ? color : kTrack,
              shape: BoxShape.circle,
              border: Border.all(
                color: earned ? Colors.white : kLocked,
                width: 3,
              ),
              boxShadow: earned
                  ? [BoxShadow(color: color, offset: const Offset(0, 3))]
                  : null,
            ),
            // Kazanılmayan rozet: soluk görsel (sabit opaklık, animasyon yok).
            child: Opacity(
              opacity: earned ? 1 : 0.3,
              child: Image.asset(asset, cacheHeight: 186),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: earned ? kInk : kMuted,
            ),
          ),
        ],
      ),
    );
  }
}
