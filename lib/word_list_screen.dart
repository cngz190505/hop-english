import 'package:flutter/material.dart';
import 'app_state.dart';
import 'lesson_data.dart';
import 'speech.dart';
import 'theme.dart';

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
        final learned = s.learnedWords.map((w) => w.en).toSet();
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
            const SizedBox(height: 12),
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          _filter == 1
                              ? 'Zor kelime yok, harika gidiyorsun!'
                              : 'Henüz öğrenilen kelime yok.\nBir ders tamamla!',
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
                        learned: learned.contains(list[i].en),
                        hard: s.hardWords.contains(list[i].en),
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
  final bool learned;
  final bool hard;
  const _WordRow({
    required this.word,
    required this.learned,
    required this.hard,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Speech.speak(word.en),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF6FF),
                shape: BoxShape.circle,
              ),
              child: Text(word.emoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.en,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: kInk,
                    ),
                  ),
                  Text(
                    word.tr,
                    style: const TextStyle(fontSize: 13, color: kMuted),
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
              size: 28,
              color: learned ? kGreen : kLocked,
            ),
          ],
        ),
      ),
    );
  }
}
