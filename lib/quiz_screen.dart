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
  final bool review; // tekrar dersi: ders sayılmaz, küçük ödül verir
  final Map<String, dynamic>? resume; // kaldığı yerden devam (AppState.resumeFor)
  const QuizScreen({
    super.key,
    required this.words,
    this.lessonIndex = 0,
    this.review = false,
    this.resume,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final List<QuizQuestion> _qs = buildQuiz(widget.words);
  late final int _baseTotal = _qs.length; // tekrar soruları hariç
  final List<String> _retryLog = []; // tekrar soruları: "kelime|tip" (kaldığı yeri geri kurmak için)
  final Set<String> _retried = {}; // tekrar sorusu eklenen kelimeler (her kelime 1 kez)
  int _streak = 0; // üst üste doğru
  final Map<String, int> _delta = {}; // kelime başına doğru(+1)/yanlış(-1), hakimiyet için
  int _i = 0;
  int? _sel; // seçmeli sorularda seçilen şık
  String? _answer; // harf dizmede oluşturulan kelime (tamamlanmadıysa null)
  String _typed = ''; // yazma sorusunda yazılan metin
  int _hints = 0; // bu soruda kullanılan ipucu sayısı
  final Set<int> _removed = {}; // ipucuyla elenen (yanlış) şıklar
  bool _checked = false;
  bool _matchRight = false; // eşleştirmede hiç hata yapılmadı mı
  int _correct = 0;
  final StudyTimer _timer = StudyTimer();
  final Set<String> _missedWords = {};
  final Set<String> _rightWords = {};

  /// Sadece henüz bitmemiş derslerde kaldığı yer tutulur (tekrar dersi ve eski dersler hariç).
  bool get _track =>
      !widget.review && widget.lessonIndex >= AppState.instance.completedLessons;

  @override
  void initState() {
    super.initState();
    // _baseTotal tekrar soruları eklenmeden ÖNCE hesaplanmalı (late: ilk okunuşta hesaplanır).
    if (_baseTotal <= 0) return;
    final r = widget.resume;
    if (r != null) _restore(r);
    if (_track) _saveResume();
  }

  void _saveResume() {
    AppState.instance.saveResume({
      'lesson': widget.lessonIndex,
      'stage': 'quiz',
      'n': widget.words.length,
      'i': _i,
      'total': _qs.length,
      'correct': _correct,
      'streak': _streak,
      'delta': Map<String, int>.of(_delta),
      'missed': _missedWords.toList(),
      'right': _rightWords.toList(),
      'retries': List<String>.of(_retryLog),
    });
  }

  /// Kaydedilen duruma döner. Herhangi bir uyuşmazlıkta sessizce baştan başlar.
  void _restore(Map<String, dynamic> r) {
    try {
      final extra = <QuizQuestion>[];
      final log = <String>[];
      for (final e in List<String>.from(r['retries'] as List)) {
        final k = e.lastIndexOf('|');
        final w = widget.words.firstWhere((x) => x.en == e.substring(0, k));
        extra.add(retryQuestion(widget.words, w, QType.values[int.parse(e.substring(k + 1))]));
        log.add(e);
      }
      final i = r['i'] as int;
      if (i < 0 || i >= _qs.length + extra.length) return;
      final delta = (r['delta'] as Map).map((k, v) => MapEntry('$k', v as int));
      final missed = List<String>.from(r['missed'] as List);
      final right = List<String>.from(r['right'] as List);
      final correct = r['correct'] as int;
      final streak = r['streak'] as int;
      // Hepsi geçerli: uygula.
      _qs.addAll(extra);
      _retryLog.addAll(log);
      for (final e in log) {
        _retried.add(e.substring(0, e.lastIndexOf('|')));
      }
      _delta.addAll(delta);
      _missedWords.addAll(missed);
      _rightWords.addAll(right);
      _correct = correct;
      _streak = streak;
      _i = i;
    } catch (_) {}
  }

  QuizQuestion get _q => _qs[_i];
  bool get _isRight {
    switch (_q.type) {
      case QType.match:
        return _matchRight;
      case QType.scramble:
        return _answer?.toLowerCase() == _q.word.en.toLowerCase();
      case QType.typing:
        return normalizeTyped(_typed) == normalizeTyped(_q.word.en);
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
      case QType.typing:
        return _typed.trim().isNotEmpty;
      default:
        return _sel != null;
    }
  }

  void _record(Iterable<String> right, Iterable<String> missed, bool ok,
      {bool hinted = false}) {
    // İpucuyla doğru bilinen soru puana ve hakimiyete sayılmaz, seri aynı kalır.
    if (hinted && ok) return;
    _rightWords.addAll(right);
    _missedWords.addAll(missed);
    for (final w in right) {
      _delta[w] = (_delta[w] ?? 0) + 1;
    }
    if (!_q.retry) {
      for (final w in missed) {
        _delta[w] = (_delta[w] ?? 0) - 1;
      }
    }
    if (ok && !_q.retry) _correct++;
    _streak = ok ? _streak + 1 : 0;
  }

  /// Yanlış yapılan kelime sınavın sonuna eklenir. Tekrar sorusu da yanlış yapılırsa
  /// (farklı tipte) yeniden sona eklenir: kelime doğru bilinene kadar tekrar gelir.
  void _queueRetry(Word w, QType failed) {
    if (!_q.retry && !_retried.add(w.en)) return;
    _qs.add(retryQuestion(widget.words, w, failed));
    _retryLog.add('${w.en}|${failed.index}');
  }

  /// Bu soruda en çok kaç ipucu alınabilir (eşleştirmede ipucu yok).
  int get _maxHints {
    switch (_q.type) {
      case QType.match:
        return 0;
      case QType.scramble:
        return _q.letters.length - 1;
      case QType.typing:
        return _q.word.en.replaceAll(' ', '').length - 1;
      default:
        return _q.options.length - 2; // her ipucu 1 yanlış şıkkı eler
    }
  }

  void _useHint() {
    if (_checked || _hints >= _maxHints) return;
    _timer.tap();
    setState(() {
      _hints++;
      final choice = _q.type != QType.scramble &&
          _q.type != QType.typing &&
          _q.type != QType.match;
      if (choice) {
        for (var k = 0; k < _q.options.length; k++) {
          if (k != _q.correct && k != _sel && !_removed.contains(k)) {
            _removed.add(k);
            break;
          }
        }
      }
    });
  }

  /// Yazma ipucu: ilk [_hints] harf açık, kalanlar "_" (örn. "h _ _ _ _").
  String get _typeHintText {
    var shown = 0;
    final b = StringBuffer();
    for (final ch in _q.word.en.split('')) {
      if (ch == ' ') {
        b.write('   ');
        continue;
      }
      if (shown < _hints) {
        b.write(ch);
        shown++;
      } else {
        b.write('_');
      }
      b.write(' ');
    }
    return b.toString().trimRight();
  }

  void _check() {
    if (!_canCheck) return;
    _timer.tap();
    FocusManager.instance.primaryFocus?.unfocus();
    final ok = _isRight;
    setState(() {
      _checked = true;
      _record(ok ? [_q.word.en] : [], ok ? [] : [_q.word.en], ok,
          hinted: _hints > 0);
      if (!ok) _queueRetry(_q.word, _q.type);
    });
    ok ? Fx.right() : Fx.wrong();
    Speech.speak(_q.type == QType.sentence ? _q.word.example : _q.word.en);
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
      for (final w in _q.pairs) {
        if (missed.contains(w.en)) _queueRetry(w, QType.match);
      }
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
        _typed = '';
        _hints = 0;
        _removed.clear();
        _checked = false;
        _matchRight = false;
      });
      if (_track) _saveResume();
    } else {
      // Bir kelime bir soruda yanlış, başka soruda doğruysa "zor" kalır.
      final missed = _missedWords.toList();
      final right = _rightWords.difference(_missedWords).toList();
      AppState.instance.applyMastery(_delta);
      final reward = widget.review
          ? AppState.instance.completeReview(missed: missed, correct: right)
          : AppState.instance.completeLesson(
              widget.lessonIndex,
              missed: missed,
              correct: right,
            );
      Fx.celebrate();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            reward: reward,
            correct: _correct,
            total: _baseTotal,
            words: widget.words,
            lessonIndex: widget.lessonIndex,
            review: widget.review,
            missed: missed,
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
                        target: scrambleTiles(_q.word),
                        hintTick: _hints,
                        separator: _q.word.en.contains(' ') ? ' ' : '',
                        locked: _checked,
                        right: _checked ? _isRight : null,
                        onChanged: (a) => setState(() => _answer = a),
                      ),
                    ] else if (_q.type == QType.typing) ...[
                      MascotBubble(
                        text: _q.word.tr,
                        image: _q.word.imagePath,
                        height: 150,
                        imageCacheHeight: 450,
                      ),
                      const SizedBox(height: 20),
                      if (_hints > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Center(
                            child: Text(
                              _typeHintText,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: kBlue,
                              ),
                            ),
                          ),
                        ),
                      TypeQuestion(
                        key: ValueKey(_i),
                        locked: _checked,
                        right: _checked ? _isRight : null,
                        onChanged: (t) => setState(() => _typed = t),
                        onSubmit: _check,
                      ),
                    ] else if (_q.type == QType.sentence) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: cardDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _q.sentence,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: kInk,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _q.word.exampleTr,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: kMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (var k = 0; k < _q.options.length; k++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _Option(
                            text: _q.options[k],
                            state: _stateOf(k),
                            dim: _removed.contains(k),
                            onTap: (_checked || _removed.contains(k))
                                ? null
                                : () => setState(() => _sel = k),
                          ),
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
                            dim: _removed.contains(k),
                            onTap: (_checked || _removed.contains(k))
                                ? null
                                : () => setState(() => _sel = k),
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
                                    dim: _removed.contains(r * 2 + c),
                                    onTap: (_checked || _removed.contains(r * 2 + c))
                                        ? null
                                        : () => setState(() => _sel = r * 2 + c),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ] else ...[
                    MascotBubble(
                      text: _q.word.tr,
                      image: _q.word.imagePath,
                      height: 170,
                      imageCacheHeight: 510,
                    ),
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
                            dim: _removed.contains(k),
                          onTap: (_checked || _removed.contains(k))
                                ? null
                                : () => setState(() => _sel = k),
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
                                ? (_hints > 0
                                    ? 'İpucuyla doğru!'
                                    : (_streak >= 3 ? '$_streak üst üste doğru!' : 'Harika!'))
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
                  if (!_checked && _maxHints > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _HintButton(
                        left: _maxHints - _hints,
                        onTap: _hints < _maxHints ? _useHint : null,
                      ),
                    ),
                  _button(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _title => _q.retry ? 'Tekrar: $_typeTitle' : _typeTitle;

  String get _typeTitle {
    switch (_q.type) {
      case QType.picture:
        return 'Doğru görseli seç';
      case QType.listen:
        return 'Dinle ve seç';
      case QType.match:
        return 'Eşleştir';
      case QType.scramble:
        if (_q.word.isSentence) return 'Cümleyi oluştur';
        return _q.word.en.contains(' ') ? 'İfadeyi oluştur' : 'Kelimeyi oluştur';
      case QType.sentence:
        return 'Boşluğu doldur';
      case QType.typing:
        return _q.word.en.contains(' ') ? 'İfadeyi yaz' : 'Kelimeyi yaz';
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
      onTap: () {
        Fx.tap();
        Speech.speak(word);
      },
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
  final bool dim; // ipucuyla elenen şık
  const _PicOption(
      {required this.word, required this.state, this.onTap, this.dim = false});

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
    final tile = GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              Fx.tap();
              onTap!();
            },
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
    return dim ? Opacity(opacity: 0.3, child: tile) : tile;
  }
}

class _Option extends StatelessWidget {
  final String text;
  final _OptState state;
  final VoidCallback? onTap;
  final bool dim; // ipucuyla elenen şık
  const _Option(
      {required this.text, required this.state, this.onTap, this.dim = false});

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
    final tile = GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              Fx.tap();
              onTap!();
            },
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
    return dim ? Opacity(opacity: 0.3, child: tile) : tile;
  }
}

/// "İpucu" butonu: kalan ipucu sayısını gösterir, bitince pasif olur.
class _HintButton extends StatelessWidget {
  final int left;
  final VoidCallback? onTap;
  const _HintButton({required this.left, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final on = onTap != null;
    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              Fx.tap();
              onTap!();
            },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: on ? const Color(0xFFFFF4D6) : kTrack,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: on ? const Color(0xFFFFC800) : kLocked,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lightbulb_rounded,
              size: 20,
              color: on ? const Color(0xFFE0A100) : kLockedDark,
            ),
            const SizedBox(width: 6),
            Text(
              on ? 'İpucu ($left)' : 'İpucu bitti',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: on ? const Color(0xFF9A6B00) : kLockedDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
