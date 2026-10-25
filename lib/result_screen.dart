import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_state.dart';
import 'lesson_data.dart';
import 'lesson_screen.dart';
import 'theme.dart';

/// Konfeti parçası (sabit, animasyon yok): konum Alignment, açı, renk, boyut.
class _Confetti {
  final double x;
  final double y;
  final double angle;
  final Color color;
  final double w;
  final double h;
  const _Confetti(this.x, this.y, this.angle, this.color, this.w, this.h);
}

const _confetti = [
  _Confetti(-0.92, -0.95, 0.6, Color(0xFFFFC800), 10, 18),
  _Confetti(-0.70, -0.70, -0.8, Color(0xFFFF4B8B), 9, 16),
  _Confetti(-0.45, -0.98, 1.1, Color(0xFFFFFFFF), 8, 14),
  _Confetti(-0.18, -0.80, -0.4, Color(0xFFB36BFF), 10, 17),
  _Confetti(0.12, -0.96, 0.9, Color(0xFFFFC800), 9, 15),
  _Confetti(0.40, -0.74, -1.0, Color(0xFFFF9600), 10, 18),
  _Confetti(0.68, -0.97, 0.5, Color(0xFFFF4B8B), 8, 14),
  _Confetti(0.93, -0.72, -0.7, Color(0xFFFFFFFF), 10, 16),
  _Confetti(-0.97, -0.45, -0.3, Color(0xFFB36BFF), 9, 15),
  _Confetti(0.97, -0.40, 1.0, Color(0xFFFFC800), 9, 16),
  _Confetti(-0.80, -0.20, 0.8, Color(0xFFFFFFFF), 8, 14),
  _Confetti(0.82, -0.12, -0.9, Color(0xFFFF9600), 9, 15),
  _Confetti(-0.58, -0.40, -0.6, Color(0xFFFF4B8B), 8, 13),
  _Confetti(0.58, -0.42, 0.4, Color(0xFFB36BFF), 8, 13),
];

class ResultScreen extends StatelessWidget {
  final Reward reward;
  final int correct;
  final int total;
  final List<Word> words;
  final int lessonIndex;
  final bool review; // tekrar dersi mi
  final List<String> missed; // quizde yanlış yapılan kelimeler (İngilizce)
  const ResultScreen({
    super.key,
    required this.reward,
    required this.correct,
    required this.total,
    required this.words,
    this.lessonIndex = 0,
    this.review = false,
    this.missed = const [],
  });

  void _home(BuildContext context) =>
      Navigator.of(context).popUntil((r) => r.isFirst);

  /// Sıradaki ders (içeriği hazırsa). Tekrar dersinde yok.
  int? get _nextLesson {
    if (review) return null;
    final n = lessonIndex + 1;
    return n < lessonsContent.length ? n : null;
  }

  void _openNext(BuildContext context, int n) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LessonScreen(words: lessonsContent[n], lessonIndex: n),
      ),
    );
  }

  void _repeat(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LessonScreen(words: words, lessonIndex: lessonIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextLesson;
    const shadow = [Shadow(color: Color(0x40000000), offset: Offset(0, 2), blurRadius: 4)];
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1B9CF0), Color(0xFF45B8F5), Color(0xFF58CC02)],
              stops: [0, 0.5, 1],
            ),
          ),
          child: Stack(
            children: [
              // Sabit konfeti (animasyon yok), tek katmanda çizilir.
              Positioned.fill(
                child: IgnorePointer(
                  child: RepaintBoundary(
                    child: FractionallySizedBox(
                      alignment: Alignment.topCenter,
                      heightFactor: 0.5,
                      child: Stack(
                        children: [
                          for (final c in _confetti)
                            Align(
                              alignment: Alignment(c.x, c.y),
                              child: Transform.rotate(
                                angle: c.angle,
                                child: Container(
                                  width: c.w,
                                  height: c.h,
                                  decoration: BoxDecoration(
                                    color: c.color,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
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
                                height: 220,
                                cacheHeight: 660,
                                gaplessPlayback: true,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tebrikler!',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                shadows: shadow,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              review ? 'Tekrar dersini tamamladın!' : 'Dersi tamamladın!',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                shadows: shadow,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$total sorudan $correct tanesini doğru yaptın',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE8F6FF),
                                shadows: shadow,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Ödül kartı: tek beyaz kart, 3 sütun, aralarında ince çizgi.
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: cardDecoration(),
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    _RewardCol(
                                      asset: 'assets/ready/icon_star.png',
                                      value: '+${reward.xp} XP',
                                      label: 'Puan',
                                    ),
                                    const _RewardDivider(),
                                    _RewardCol(
                                      asset: 'assets/ready/icon_flame.png',
                                      value: reward.streakGained ? '+1' : '${reward.streak}',
                                      label: 'Günlük seri',
                                    ),
                                    const _RewardDivider(),
                                    _RewardCol(
                                      asset: 'assets/ready/icon_gem.png',
                                      value: '+${reward.gems}',
                                      label: 'Elmas',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _SummaryCard(words: words, missed: missed),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Column(
                        children: [
                          ChunkyButton(
                            text: next != null ? 'Sonraki Ders  →' : 'Ana Sayfaya Dön',
                            onPressed: () =>
                                next != null ? _openNext(context, next) : _home(context),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (next != null)
                                TextButton(
                                  onPressed: () => _home(context),
                                  child: const Text(
                                    'Ana Sayfaya Dön',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              if (next != null && !review)
                                const Text('•', style: TextStyle(color: Colors.white)),
                              if (!review)
                                TextButton(
                                  onPressed: () => _repeat(context),
                                  child: const Text(
                                    'Dersi Tekrarla',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
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

/// Ders sonu özeti: kaç kelime görüldü, hangileri zor geldi.
class _SummaryCard extends StatelessWidget {
  final List<Word> words;
  final List<String> missed;
  const _SummaryCard({required this.words, required this.missed});

  @override
  Widget build(BuildContext context) {
    final hard = [for (final w in words) if (missed.contains(w.en)) w];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Özet',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: kInk),
          ),
          const SizedBox(height: 6),
          Text(
            'Bu derste ${words.length} ${words.first.isSentence ? "cümle" : "kelime"} çalıştın.',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kMuted),
          ),
          const SizedBox(height: 6),
          if (hard.isEmpty)
            Text(
              words.first.isSentence ? 'Hiç cümle kaçırmadın, harika!' : 'Hiç kelime kaçırmadın, harika!',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: kGreen),
            )
          else ...[
            Text(
              words.first.isSentence ? 'Zorlandığın cümleler:' : 'Zorlandığın kelimeler:',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kRed),
            ),
            const SizedBox(height: 4),
            for (final w in hard)
              Text(
                '${w.en} = ${w.tr}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kInk),
              ),
            if (!words.first.isSentence) ...[
              const SizedBox(height: 4),
              const Text(
                'Bunlar Tekrar sekmesinde "Zor" listesine eklendi.',
                style: TextStyle(fontSize: 12, color: kMuted),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _RewardDivider extends StatelessWidget {
  const _RewardDivider();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1.5, color: const Color(0xFFE3EEF8));
}

class _RewardCol extends StatelessWidget {
  final String asset;
  final String value;
  final String label;
  const _RewardCol({
    required this.asset,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Image.asset(asset, height: 38, cacheHeight: 114),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: kInk,
            ),
          ),
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
    );
  }
}
