import 'package:flutter/material.dart';
import 'app_state.dart';
import 'fx.dart';
import 'lesson_data.dart';
import 'lesson_screen.dart';
import 'quiz_extra.dart';
import 'result_screen.dart';
import 'speech.dart';
import 'theme.dart';

const _okBg = Color(0xFFD7FFB8);
const _okText = Color(0xFF3F8F00);
const _badBg = Color(0xFFFFDFE0);
const _badText = Color(0xFFD33030);

class QuizScreen extends StatefulWidget {
  final List<Word> words;
  final int lessonIndex;
  const QuizScreen({super.key, required this.words, this.lessonIndex = 0});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final List<QuizQuestion> _qs = buildQuiz(widget.words);
  int _i = 0;
  int? _sel; // seçmeli sorularda seçilen şık
  String? _answer; // harf dizmede oluşturulan kelime (tamamlanmadıysa null)
  bool _checked = false;
  bool _matchRight = false; // eşleştirmede hiç hata yapılmadı mı
  int _correct = 0;
  final StudyTimer _timer = StudyTimer();
  final Set<String> _missedWords = {};
  final Set<String> _rightWords = {};

  QuizQuestion get _q => _qs[_i];
  bool get _isRight {
    switch (_q.type) {
      case QType.match:
        return _matchRight;
      case QType.scramble:
        return _answer?.toLowerCase() == _q.word.en.toLowerCase();
      default:
        return _sel == _q.correct;
    }
  }

  /// Kontrol Et'e basılabilir mi? (Eşleştirmede buton yok, bitince kendiliğinden kontrol olur.)
  bool get _canCheck {
    switch (_q.type) {
      case QType.match:
        return false;
      case QType.scramble:
        return _answer != null;
      default:
        return _sel != null;
    }
  }

  void _record(Iterable<String> right, Iterable<String> missed, bool ok) {
    _rightWords.addAll(right);
    _missedWords.addAll(missed);
    if (ok) _correct++;
  }

  void _check() {
    if (!_canCheck) return;
    _timer.tap();
    final ok = _isRight;
    setState(() {
      _checked = true;
      _record(ok ? [_q.word.en] : [], ok ? [] : [_q.word.en], ok);
    });
    ok ? Fx.right() : Fx.wrong();
    Speech.speak(_q.word.en);
  }

  void _onMatchDone(Set<String> missed) {
    if (!mounted || _checked) return;
    _timer.tap();
    final all = [for (final w in _q.pairs) w.en];
    final ok = missed.isEmpty;
    setState(() {
      _checked = true;
      _matchRight = ok;
      _record(all.where((w) => !missed.contains(w)), missed, ok);
    });
    if (ok) Fx.right();
  }

  void _next() {
    _timer.tap();
    Speech.stop();
    if (_i < _qs.length - 1) {
      setState(() {
        _i++;
        _sel = null;
        _answer = null;
        _checked = false;
        _matchRight = false;
      });
    } else {
      // Bir kelime bir soruda yanlış, başka soruda doğruysa "zor" kalır.
      final reward = AppState.instance.completeLesson(
        widget.lessonIndex,
        missed: _missedWords.toList(),
        correct: _rightWords.difference(_missedWords).toList(),
      );
      Fx.celebrate();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            reward: reward,
            correct: _correct,
            total: _qs.length,
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
                    Text(
                      _title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: kInk,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (_q.type == QType.match)
                      MatchQuestion(
                        key: ValueKey(_i),
                        pairs: _q.pairs,
                        onDone: _onMatchDone,
                      )
                    else if (_q.type == QType.scramble) ...[
                      MascotBubble(
                        text: _q.word.tr,
                        image: _q.word.imagePath,
                        height: 170,
                        imageCacheHeight: 510,
                      ),
                      const SizedBox(height: 24),
                      ScrambleQuestion(
                        key: ValueKey(_i),
                        letters: _q.letters,
                        locked: _checked,
                        right: _checked ? _isRight : null,
                        onChanged: (a) => setState(() => _answer = a),
                      ),
                    ] else if (_q.type == QType.listen) ...[
                      ListenBig(key: ValueKey(_i), word: _q.word.en),
                      const SizedBox(height: 24),
                      const Text(
                        'Türkçesi hangisi?',
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
                    ] else if (_q.isPicture) ...[
                      _ListenWord(word: _q.word.en),
                      const SizedBox(height: 16),
                      for (var r = 0; r < 2; r++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              for (var c = 0; c < 2; c++) ...[
                                if (c == 1) const SizedBox(width: 12),
                                Expanded(
                                  child: _PicOption(
                                    word: _q.pictures[r * 2 + c],
                                    state: _stateOf(r * 2 + c),
                                    onTap: _checked
                                        ? null
                                        : () => setState(() => _sel = r * 2 + c),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ] else ...[
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
                            _isRight
                                ? 'Harika!'
                                : (_q.type == QType.match
                                    ? 'Bazı eşleşmeler yanlıştı'
                                    : 'Doğrusu: ${_q.answerText}'),
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

  String get _title {
    switch (_q.type) {
      case QType.picture:
        return 'Doğru görseli seç';
      case QType.listen:
        return 'Dinle ve seç';
      case QType.match:
        return 'Eşleştir';
      case QType.scramble:
        return 'Kelimeyi oluştur';
      case QType.text:
        return 'Doğru cevabı seç';
    }
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
    if (!_canCheck) {
      return ChunkyButton(
        text: _q.type == QType.match ? 'Çiftleri eşleştir' : 'Kontrol Et',
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

/// Görselli soruda İngilizce kelime + dinle butonu.
class _ListenWord extends StatelessWidget {
  final String word;
  const _ListenWord({required this.word});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Speech.speak(word),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kBlue,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Color(0xFF1899D6), offset: Offset(0, 4))],
            ),
            child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              word,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: kInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Görselli soru şıkkı: büyük simge + Türkçe adı.
class _PicOption extends StatelessWidget {
  final Word word;
  final _OptState state;
  final VoidCallback? onTap;
  const _PicOption({required this.word, required this.state, this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color bg;
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
      case _OptState.wrong:
        border = kRed;
        bg = const Color(0xFFFFE9E9);
    }
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border, width: 2),
          boxShadow: [BoxShadow(color: border, offset: const Offset(0, 3))],
        ),
        child: Column(
          children: [
            SizedBox(
              height: 120,
              child: Image.asset(
                word.imagePath,
                height: 120,
                cacheHeight: 360,
                fit: BoxFit.contain,
                // Resim dosyası yoksa emoji gösterilir.
                errorBuilder: (_, __, ___) =>
                    Center(child: Text(word.emoji, style: const TextStyle(fontSize: 60))),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              word.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: kInk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
