import 'package:flutter/material.dart';
import 'app_state.dart';
import 'lesson_data.dart';
import 'quiz_screen.dart';
import 'speech.dart';
import 'theme.dart';

// Her kelime sırayla bu renklerden birini alır: (açık ton, koyu ton)
const _palette = [
  (Color(0xFFEDE7FF), Color(0xFF7B5CE6)), // mor
  (Color(0xFFE1F3FF), Color(0xFF1288C9)), // mavi
  (Color(0xFFE3F8D2), Color(0xFF3F8F00)), // yeşil
  (Color(0xFFFFEBD6), Color(0xFFE07B00)), // turuncu
  (Color(0xFFFFE4F0), Color(0xFFD6277A)), // pembe
  (Color(0xFFD9F7F2), Color(0xFF0F8F82)), // turkuaz
];

/// Tekrar sekmesi: Kelime Listem (Tümü / Zor / Öğrenildi).
class WordListTab extends StatefulWidget {
  const WordListTab({super.key});

  @override
  State<WordListTab> createState() => _WordListTabState();
}

class _WordListTabState extends State<WordListTab> {
  int _filter = 0;
  static const _tabs = ['Tümü', 'Zor', 'Öğrenildi'];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final s = AppState.instance;
        final all = [for (final l in lessonsContent) ...l];
        // "Öğrenildi" = 3 yıldız (kelime hakimiyeti). Yıldızlar quizde doğru bildikçe dolar.
        final learned = {for (final w in all) if (s.isMastered(w.en)) w.en};
        final List<Word> list;
        switch (_filter) {
          case 1:
            list = all.where((w) => s.hardWords.contains(w.en)).toList();
          case 2:
            list = all.where((w) => learned.contains(w.en)).toList();
          default:
            list = all;
        }
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Text(
                'Kelime Listem',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: kInk,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCEBF7),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < _tabs.length; i++)
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _filter = i),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _filter == i ? kBlue : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              _tabs[i],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: _filter == i ? Colors.white : kMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (s.learnedWords.length >= 5)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: ChunkyButton(
                  text: 'Tekrar Dersi',
                  color: kBlue,
                  shadowColor: kBlueDark,
                  height: 46,
                  fontSize: 16,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => QuizScreen(
                        words: pickReviewWords(s.learnedWords, s.hardWords),
                        review: true,
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          _filter == 1
                              ? 'Zor kelime yok, harika gidiyorsun!'
                              : 'Henüz 3 yıldızlı kelime yok.\nDers ve tekrar derslerinde doğru bil!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: kMuted,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: list.length,
                      itemBuilder: (context, i) => _WordRow(
                        word: list[i],
                        colors: _palette[all.indexOf(list[i]) % _palette.length],
                        learned: learned.contains(list[i].en),
                        hard: s.hardWords.contains(list[i].en),
                        stars: s.masteryOf(list[i].en),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _WordRow extends StatelessWidget {
  final Word word;
  final (Color, Color) colors;
  final bool learned;
  final bool hard;
  final int stars; // 0..3
  const _WordRow({
    required this.word,
    required this.colors,
    required this.learned,
    required this.hard,
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    final (light, dark) = colors;
    return GestureDetector(
      onTap: () => Speech.speak(word.en),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: light, width: 2),
          boxShadow: [
            BoxShadow(color: light, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: light,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(word.emoji, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.en,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: kInk,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: light,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          word.tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: dark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      for (var k = 0; k < 3; k++)
                        Icon(
                          Icons.star_rounded,
                          size: 20,
                          color: k < stars ? kYellow : kLocked,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (hard)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.flag_rounded, size: 20, color: kRed),
              ),
            Icon(
              learned
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 30,
              color: learned ? kGreen : kLocked,
            ),
          ],
        ),
      ),
    );
  }
}
