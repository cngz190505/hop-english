import 'package:flutter/material.dart';
import 'lesson_data.dart';
import 'speech.dart';
import 'theme.dart';

const _purple = Color(0xFF7B5CE6);
const _purpleLight = Color(0xFFEDE7FF);

/// 1. dersi açar (ana sayfadaki buton ve ders haritası bunu kullanır).
void openLesson1(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const LessonScreen(words: lesson1Words),
    ),
  );
}

class LessonScreen extends StatefulWidget {
  final List<Word> words;
  const LessonScreen({super.key, required this.words});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _i = 0;

  void _next() {
    Speech.stop();
    if (_i < widget.words.length - 1) {
      setState(() => _i++);
    } else {
      // Geçici: quiz ekranı eklenince buradan quiz'e gidilecek.
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    Speech.stop();
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
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _purpleLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_rounded, size: 16, color: _purple),
                SizedBox(width: 6),
                Text(
                  'Yeni Kelime',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _purple,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            word.en,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: kInk,
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => Speech.speak(word.en),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.volume_up_rounded, size: 24, color: kBlue),
                  const SizedBox(width: 8),
                  Text(
                    word.phonetic,
                    style: const TextStyle(fontSize: 18, color: kMuted),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: BoxDecoration(
              color: _purpleLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              word.tr,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _purple,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _Illustration(text: _bubbleText(word.en)),
          const SizedBox(height: 14),
          _Sentence(word: word),
        ],
      ),
    );
  }

  static String _bubbleText(String en) =>
      '${en[0].toUpperCase()}${en.substring(1)}!';
}

class _Illustration extends StatelessWidget {
  final String text;
  const _Illustration({required this.text});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        height: 190,
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
                'assets/ready/mascot_main.png',
                height: 170,
                cacheHeight: 510,
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
      fontSize: 16,
      fontWeight: FontWeight.w700,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(text: TextSpan(style: base, children: spans)),
                const SizedBox(height: 4),
                Text(
                  word.exampleTr,
                  style: const TextStyle(fontSize: 13, color: kMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Speech.speak(word.example),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: kBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: kBlueDark, offset: Offset(0, 3)),
                    ],
                  ),
                  child: const Icon(
                    Icons.volume_up_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Dinle',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: kBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
