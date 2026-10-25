import 'package:flutter/material.dart';
import 'fx.dart';
import 'app_state.dart';
import 'lesson_data.dart';
import 'quiz_screen.dart';
import 'speech.dart';
import 'theme.dart';

const _purple = Color(0xFF7B5CE6);
const _purpleLight = Color(0xFFEDE7FF);

/// [index]. dersi açar (0 = 1. ders). Ana sayfa butonu ve ders haritası bunu kullanır.
void openLesson(BuildContext context, int index) {
  final i = index.clamp(0, lessonsContent.length - 1);
  // Yarıda bırakılmışsa kaldığı yerden devam eder.
  final r = AppState.instance.resumeFor(i);
  final Widget page;
  if (r != null && r['stage'] == 'quiz') {
    page = QuizScreen(words: lessonsContent[i], lessonIndex: i, resume: r);
  } else {
    final start = (r != null && r['i'] is int) ? (r['i'] as int) : 0;
    page = LessonScreen(
      words: lessonsContent[i],
      lessonIndex: i,
      startIndex: start.clamp(0, lessonsContent[i].length - 1),
    );
  }
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
}

class LessonScreen extends StatefulWidget {
  final List<Word> words;
  final int lessonIndex;
  final int startIndex; // kaldığı kelime
  const LessonScreen({
    super.key,
    required this.words,
    this.lessonIndex = 0,
    this.startIndex = 0,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late int _i = widget.startIndex;
  final StudyTimer _timer = StudyTimer();

  /// Sadece henüz bitmemiş derslerde kaldığı yer tutulur (tekrarlarda tutulmaz).
  bool get _track => widget.lessonIndex >= AppState.instance.completedLessons;

  void _saveResume() {
    if (!_track) return;
    AppState.instance.saveResume({
      'lesson': widget.lessonIndex,
      'stage': 'lesson',
      'n': widget.words.length,
      'i': _i,
    });
  }

  void _next() {
    _timer.tap();
    Speech.stop();
    if (_i < widget.words.length - 1) {
      setState(() => _i++);
      _saveResume();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => QuizScreen(
            words: widget.words,
            lessonIndex: widget.lessonIndex,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer.finish();
    Speech.stop();
    AppState.instance.refreshLater();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.words.length;
    final word = widget.words[_i];
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 28),
                    color: kMuted,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(child: ProgressBar(value: _i / total, height: 12)),
                  const SizedBox(width: 12),
                  Text(
                    '${_i + 1}/$total',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: kMuted,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: _WordCard(word: word),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: ChunkyButton(text: 'Devam Et  →', onPressed: _next),
            ),
          ],
        ),
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  final Word word;
  const _WordCard({required this.word});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Column(
        children: [
          // 1) Büyük kelime görseli (balon yok, iç içe kart yok).
          RepaintBoundary(
            child: Container(
              width: double.infinity,
              height: 190,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFBFE4FF), Color(0xFFE6F5FF)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Image.asset(
                word.imagePath,
                height: 172,
                cacheHeight: 516,
                gaplessPlayback: true,
              ),
            ),
          ),
          const SizedBox(height: 14),
          // 2) İngilizce kelime (en büyük yazı)
          Text(
            word.en,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: word.isSentence ? 30 : 46,
              height: 1.1,
              fontWeight: FontWeight.w900,
              color: kInk,
            ),
          ),
          // 3) Türkçe okunuş (küçük, mavi). IPA çocuklar için karışık, gösterilmez.
          Text(
            word.say,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: kBlue,
            ),
          ),
          const SizedBox(height: 8),
          // 4) Türkçe anlamı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
            decoration: BoxDecoration(
              color: _purpleLight,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              word.tr,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: _purple,
              ),
            ),
          ),
          const SizedBox(height: 14),
          // 5) Tek büyük Dinle + küçük Yavaş butonu
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Fx.tap();
                    Speech.speak(word.en);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: kBlue,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: kBlueDark, offset: Offset(0, 4)),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.volume_up_rounded, color: Colors.white, size: 26),
                        SizedBox(width: 8),
                        Text(
                          'Dinle',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Yavaş dinle: sesler net anlaşılsın diye daha yavaş okur.
              GestureDetector(
                onTap: () {
                  Fx.tap();
                  Speech.speak(word.en, slow: true);
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 62,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F5FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kBlue, width: 2),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.slow_motion_video_rounded, color: kBlue, size: 22),
                      Text(
                        'Yavaş',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: kBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // 6) Örnek cümle: tek satır kutu, dokununca okunur (cümle derslerinde gösterilmez).
          if (!word.isSentence) ...[
            const SizedBox(height: 14),
            _Sentence(word: word),
          ],
        ],
      ),
    );
  }
}

/// Maskot + konuşma balonu kartı (ders ve quiz ekranlarında ortak).
class MascotBubble extends StatelessWidget {
  final String text;
  final double height;
  /// Soldaki resim. Verilmezse ejderha maskotu görünür.
  final String image;
  final int imageCacheHeight;
  const MascotBubble({
    super.key,
    required this.text,
    this.height = 190,
    this.image = 'assets/ready/mascot_main.png',
    this.imageCacheHeight = 510,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFBFE4FF), Color(0xFFE6F5FF)],
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 16,
              bottom: 8,
              child: Image.asset(
                image,
                height: height - 20,
                cacheHeight: imageCacheHeight,
                gaplessPlayback: true,
              ),
            ),
            Positioned(
              right: 16,
              top: 22,
              left: 150,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFB5DCF5), width: 2),
                ),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: kInk,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sentence extends StatelessWidget {
  final Word word;
  const _Sentence({required this.word});

  @override
  Widget build(BuildContext context) {
    final lower = word.example.toLowerCase();
    final at = lower.indexOf(word.en.toLowerCase());
    const base = TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w800,
      color: kInk,
    );
    final spans = at < 0
        ? [TextSpan(text: word.example)]
        : [
            TextSpan(text: word.example.substring(0, at)),
            TextSpan(
              text: word.example.substring(at, at + word.en.length),
              style: const TextStyle(color: kBlue, fontWeight: FontWeight.w900),
            ),
            TextSpan(text: word.example.substring(at + word.en.length)),
          ];
    return GestureDetector(
      onTap: () {
        Fx.tap();
        Speech.speak(word.example);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F0FF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(text: TextSpan(style: base, children: spans)),
                  const SizedBox(height: 3),
                  // Türkçe karşılık mor: ana ekrandaki "anlam" etiketiyle aynı renk.
                  Text(
                    word.exampleTr,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _purple,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.volume_up_rounded, size: 26, color: kBlue),
          ],
        ),
      ),
    );
  }
}
