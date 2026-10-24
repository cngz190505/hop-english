import 'package:flutter/material.dart';
import 'app_state.dart';
import 'lesson_data.dart';
import 'lesson_screen.dart';
import 'result_screen.dart';
import 'speech.dart';
import 'theme.dart';

const _okBg = Color(0xFFD7FFB8);
const _okText = Color(0xFF3F8F00);
const _badBg = Color(0xFFFFDFE0);
const _badText = Color(0xFFD33030);

class QuizScreen extends StatefulWidget {
  final List<Word> words;
  const QuizScreen({super.key, required this.words});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final List<QuizQuestion> _qs = buildQuiz(widget.words);
  int _i = 0;
  int? _sel;
  bool _checked = false;
  int _correct = 0;
  final StudyTimer _timer = StudyTimer();
  final List<String> _missedWords = [];
  final List<String> _rightWords = [];

  QuizQuestion get _q => _qs[_i];
  bool get _isRight => _sel == _q.correct;

  void _check() {
    if (_sel == null) return;
    _timer.tap();
    setState(() {
      _checked = true;
      if (_isRight) {
        _correct++;
        _rightWords.add(_q.word.en);
      } else {
        _missedWords.add(_q.word.en);
      }
    });
    Speech.speak(_q.word.en);
  }

  void _next() {
    _timer.tap();
    Speech.stop();
    if (_i < _qs.length - 1) {
      setState(() {
        _i++;
        _sel = null;
        _checked = false;
      });
    } else {
      final reward = AppState.instance.completeLesson(
        0,
        missed: _missedWords,
        correct: _rightWords,
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            reward: reward,
            correct: _correct,
            total: _qs.length,
            words: widget.words,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer.finish();
    Speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = _qs.length;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final panelColor =
        _checked ? (_isRight ? _okBg : _badBg) : Colors.transparent;
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        bottom: false,
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Doğru cevabı seç',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: kInk,
                      ),
                    ),
                    const SizedBox(height: 14),
                    MascotBubble(text: _q.word.tr, height: 170),
                    const SizedBox(height: 16),
                    const Text(
                      'İngilizcesi hangisi?',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: kInk,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (var k = 0; k < _q.options.length; k++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _Option(
                          text: _q.options[k],
                          state: _stateOf(k),
                          onTap: _checked ? null : () => setState(() => _sel = k),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, 14, 16, 16 + bottomInset),
              color: panelColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_checked) ...[
                    Row(
                      children: [
                        Icon(
                          _isRight
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          color: _isRight ? _okText : _badText,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _isRight ? 'Harika!' : 'Doğrusu: ${_q.word.en}',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: _isRight ? _okText : _badText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  _button(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _button() {
    if (_checked) {
      return ChunkyButton(
        text: 'Devam Et',
        color: _isRight ? kGreen : kRed,
        shadowColor: _isRight ? kGreenDark : kRedDark,
        onPressed: _next,
      );
    }
    if (_sel == null) {
      return ChunkyButton(
        text: 'Kontrol Et',
        color: kTrack,
        shadowColor: kLocked,
        textColor: kLockedDark,
        onPressed: () {},
      );
    }
    return ChunkyButton(text: 'Kontrol Et', onPressed: _check);
  }

  _OptState _stateOf(int k) {
    if (_checked) {
      if (k == _q.correct) return _OptState.right;
      if (k == _sel) return _OptState.wrong;
      return _OptState.normal;
    }
    return k == _sel ? _OptState.selected : _OptState.normal;
  }
}

enum _OptState { normal, selected, right, wrong }

class _Option extends StatelessWidget {
  final String text;
  final _OptState state;
  final VoidCallback? onTap;
  const _Option({required this.text, required this.state, this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color bg;
    Widget? icon;
    switch (state) {
      case _OptState.normal:
        border = const Color(0xFFD5E4F0);
        bg = Colors.white;
      case _OptState.selected:
        border = kBlue;
        bg = const Color(0xFFE6F5FF);
      case _OptState.right:
        border = kGreen;
        bg = const Color(0xFFE3FFD0);
        icon = const Icon(Icons.check_circle_rounded, color: kGreen, size: 26);
      case _OptState.wrong:
        border = kRed;
        bg = const Color(0xFFFFE9E9);
        icon = const Icon(Icons.cancel_rounded, color: kRed, size: 26);
    }
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border, width: 2),
          boxShadow: [BoxShadow(color: border, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: kInk,
                ),
              ),
            ),
            if (icon != null) icon,
          ],
        ),
      ),
    );
  }
}
