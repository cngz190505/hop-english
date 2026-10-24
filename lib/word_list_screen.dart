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

class _Header {
  final int lesson;
  final int count;
  const _Header(this.lesson, this.count);
}

class _Item {
  final Word word;
  final int index; // tüm kelimeler içindeki sıra (renk için)
  const _Item(this.word, this.index);
}

/// Kelime Listem: özet kartı, arama, filtre sekmeleri ve derse göre gruplu liste.
class WordListTab extends StatefulWidget {
  const WordListTab({super.key});

  @override
  State<WordListTab> createState() => _WordListTabState();
}

class _WordListTabState extends State<WordListTab> {
  int _filter = 0;
  bool _searching = false;
  String _query = '';
  final _ctrl = TextEditingController();
  static const _tabs = ['Tümü', 'Yeni', 'Zor', 'Öğrenildi'];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final s = AppState.instance;
        final all = <_Item>[];
        final lessonOf = <String, int>{};
        for (var l = 0; l < lessonsContent.length; l++) {
          for (final w in lessonsContent[l]) {
            lessonOf[w.en] = l;
            all.add(_Item(w, all.length));
          }
        }
        bool learned(Word w) => s.isMastered(w.en);
        bool hard(Word w) => s.hardWords.contains(w.en);

        final learnedCount = all.where((e) => learned(e.word)).length;
        final hardCount = all.where((e) => hard(e.word)).length;
        final newCount = all.length - learnedCount;
        final starTotal = all.fold<int>(0, (a, e) => a + s.masteryOf(e.word.en));
        final counts = [all.length, newCount, hardCount, learnedCount];

        final q = _query.trim().toLowerCase();
        final shown = all.where((e) {
          final w = e.word;
          final okFilter = switch (_filter) {
            1 => !learned(w),
            2 => hard(w),
            3 => learned(w),
            _ => true,
          };
          if (!okFilter) return false;
          if (q.isEmpty) return true;
          return w.en.toLowerCase().contains(q) || w.tr.toLowerCase().contains(q);
        }).toList();

        // Derse göre grupla: başlık + kelimeler
        final rows = <Object>[];
        for (var l = 0; l < lessonsContent.length; l++) {
          final inLesson = shown.where((e) => lessonOf[e.word.en] == l).toList();
          if (inLesson.isEmpty) continue;
          rows.add(_Header(l, inLesson.length));
          rows.addAll(inLesson);
        }

        return Column(
          children: [
            // Başlık + arama
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Kelime Listem',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: kInk,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      _searching = !_searching;
                      if (!_searching) {
                        _query = '';
                        _ctrl.clear();
                      }
                    }),
                    icon: Icon(
                      _searching ? Icons.close_rounded : Icons.search_rounded,
                      size: 28,
                      color: kInk,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: _searching
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: TextField(
                        controller: _ctrl,
                        autofocus: true,
                        onChanged: (v) => setState(() => _query = v),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: kInk,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Kelime ara (İngilizce / Türkçe)',
                          hintStyle: const TextStyle(color: kMuted),
                          prefixIcon: const Icon(Icons.search_rounded, color: kMuted),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(color: Color(0xFFE3EEF8), width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(color: kBlue, width: 2),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
            // Filtre sekmeleri (sayılı)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
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
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _filter == i ? kBlue : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              '${_tabs[i]} ${counts[i]}',
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 13,
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
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: rows.length + 1 + (rows.isEmpty ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return _SummaryCard(
                      learned: learnedCount,
                      total: all.length,
                      stars: starTotal,
                      hard: hardCount,
                      canReview: s.learnedWords.length >= 5,
                      onReview: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(
                            words: pickReviewWords(s.learnedWords, s.hardWords),
                            review: true,
                          ),
                        ),
                      ),
                    );
                  }
                  if (rows.isEmpty) {
                    return _Empty(filter: _filter, searching: q.isNotEmpty);
                  }
                  final r = rows[i - 1];
                  if (r is _Header) return _LessonHeader(r);
                  final e = r as _Item;
                  return _Appear(
                    key: ValueKey('${e.word.en}-$_filter'),
                    delay: ((i - 1) % 8) * 40,
                    child: _WordRow(
                      word: e.word,
                      colors: _palette[e.index % _palette.length],
                      learned: learned(e.word),
                      hard: hard(e.word),
                      stars: s.masteryOf(e.word.en),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Üstteki renkli özet kartı.
class _SummaryCard extends StatelessWidget {
  final int learned, total, stars, hard;
  final bool canReview;
  final VoidCallback onReview;
  const _SummaryCard({
    required this.learned,
    required this.total,
    required this.stars,
    required this.hard,
    required this.canReview,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final p = total == 0 ? 0.0 : learned / total;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF58CC02), Color(0xFF1CB0F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0x331C6BA8), blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📚', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$learned / $total kelime öğrenildi',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: p),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: v,
                minHeight: 12,
                color: kYellow,
                backgroundColor: const Color(0x55FFFFFF),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Chip(icon: Icons.star_rounded, color: kYellow, text: '$stars yıldız'),
              const SizedBox(width: 8),
              _Chip(icon: Icons.flag_rounded, color: kRed, text: '$hard zor'),
            ],
          ),
          if (canReview) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: onReview,
              child: Container(
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Tekrar Dersi  →',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: kBlueDark,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _Chip({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0x33FFFFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonHeader extends StatelessWidget {
  final _Header h;
  const _LessonHeader(this.h);

  @override
  Widget build(BuildContext context) {
    final c = _palette[h.lesson % _palette.length];
    final title = h.lesson < lessonTitles.length ? lessonTitles[h.lesson] : 'Ders';
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 14, 2, 10),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c.$2, shape: BoxShape.circle),
            child: Text(
              '${h.lesson + 1}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: kInk,
              ),
            ),
          ),
          Text(
            '${h.count} kelime',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: kMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final int filter;
  final bool searching;
  const _Empty({required this.filter, required this.searching});

  @override
  Widget build(BuildContext context) {
    final (emoji, text) = searching
        ? ('🔍', 'Aradığın kelime bulunamadı.')
        : switch (filter) {
            2 => ('🎉', 'Zor kelime yok, harika gidiyorsun!'),
            3 => ('⭐', 'Henüz 3 yıldızlı kelime yok.\nDers ve tekrar derslerinde doğru bil!'),
            _ => ('📚', 'Burada gösterilecek kelime yok.'),
          };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Satır belirirken hafifçe yukarı kayıp açılır (sıralı giriş).
class _Appear extends StatelessWidget {
  final int delay;
  final Widget child;
  const _Appear({super.key, required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * 14), child: c),
      ),
      child: child,
    );
  }
}

class _WordRow extends StatefulWidget {
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
  State<_WordRow> createState() => _WordRowState();
}

class _WordRowState extends State<_WordRow> {
  bool _down = false;
  bool _playing = false;

  Future<void> _play() async {
    setState(() => _playing = true);
    Speech.speak(widget.word.en);
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() => _playing = false);
  }

  @override
  Widget build(BuildContext context) {
    final (light, dark) = widget.colors;
    final w = widget.word;
    // Durum rozeti
    final (label, bg, fg) = widget.learned
        ? ('Öğrenildi', const Color(0xFFE3F8D2), const Color(0xFF3F8F00))
        : widget.hard
            ? ('Zor', const Color(0xFFFFE1E1), kRedDark)
            : widget.stars > 0
                ? ('Öğreniyor', const Color(0xFFFFF3CC), const Color(0xFFB88500))
                : ('Yeni', const Color(0xFFE1F3FF), kBlueDark);

    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: _play,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: _playing ? dark : light,
              width: 2,
            ),
            boxShadow: [BoxShadow(color: light, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: light,
                  shape: BoxShape.circle,
                ),
                child: Text(w.emoji, style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            w.en,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: kInk,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        AnimatedScale(
                          scale: _playing ? 1.3 : 1,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutBack,
                          child: Icon(
                            _playing
                                ? Icons.volume_up_rounded
                                : Icons.volume_up_outlined,
                            size: 20,
                            color: _playing ? dark : kLocked,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      w.tr,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: dark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        for (var k = 0; k < 3; k++)
                          Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: k < widget.stars ? kYellow : kLocked,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.hard && !widget.learned)
                      const Padding(
                        padding: EdgeInsets.only(right: 3),
                        child: Icon(Icons.flag_rounded, size: 14, color: kRedDark),
                      ),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: fg,
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
