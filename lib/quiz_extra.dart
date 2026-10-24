import 'dart:math';

import 'package:flutter/material.dart';
import 'fx.dart';
import 'lesson_data.dart';
import 'speech.dart';
import 'theme.dart';

// Yeni soru tipleri: Dinle ve seç (üst kısım), Eşleştirme, Harf dizme.
// Animasyon yok. Her widget kendi küçük durumunu tutar, setState sadece kendini yeniler.

const _okBg = Color(0xFFE3FFD0);
const _badBg = Color(0xFFFFE9E9);
const _selBg = Color(0xFFE6F5FF);
const _lineColor = Color(0xFFD5E4F0);

/// Dinle ve seç: büyük hoparlör butonu. Soru açılınca kelime bir kez otomatik okunur.
class ListenBig extends StatefulWidget {
  final String word;
  const ListenBig({super.key, required this.word});

  @override
  State<ListenBig> createState() => _ListenBigState();
}

class _ListenBigState extends State<ListenBig> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => Speech.speak(widget.word));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => Speech.speak(widget.word),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: kBlue,
            borderRadius: BorderRadius.circular(40),
            boxShadow: const [BoxShadow(color: kBlueDark, offset: Offset(0, 6))],
          ),
          child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 80),
        ),
      ),
    );
  }
}

/// Eşleştirme: solda İngilizce, sağda Türkçe. Biri, sonra diğeri seçilir (sıra fark etmez).
/// Doğru çift yeşil olup kilitlenir, yanlış çift kırmızı görünür ve sonraki dokunuşta temizlenir.
/// Hepsi bitince [onDone] yanlış yapılan İngilizce kelimelerle çağrılır.
class MatchQuestion extends StatefulWidget {
  final List<Word> pairs;
  final void Function(Set<String> missed) onDone;
  const MatchQuestion({super.key, required this.pairs, required this.onDone});

  @override
  State<MatchQuestion> createState() => _MatchQuestionState();
}

class _MatchQuestionState extends State<MatchQuestion> {
  late final List<int> _left;
  late final List<int> _right;
  final Set<int> _matched = {};
  final Set<String> _missed = {};
  int? _selL;
  int? _selR;
  int? _wrongL;
  int? _wrongR;

  @override
  void initState() {
    super.initState();
    final m = widget.pairs.length;
    // Sabit tohumlu karıştırma: sağ ve sol sıra farklı, her seferinde aynı.
    _left = List.generate(m, (k) => k)..shuffle(Random(11));
    _right = List.generate(m, (k) => k)..shuffle(Random(23));
  }

  void _tap(bool left, int p) {
    if (_matched.contains(p)) return;
    setState(() {
      _wrongL = null;
      _wrongR = null;
      if (left) {
        _selL = p;
        Speech.speak(widget.pairs[p].en);
      } else {
        _selR = p;
      }
      final l = _selL;
      final r = _selR;
      if (l == null || r == null) return;
      _selL = null;
      _selR = null;
      if (l == r) {
        _matched.add(l);
        if (_matched.length == widget.pairs.length) {
          // setState sırasında üst widget'ı güncellememek için olay sonrası çağır.
          WidgetsBinding.instance
              .addPostFrameCallback((_) => widget.onDone(Set.of(_missed)));
        }
      } else {
        _wrongL = l;
        _wrongR = r;
        _missed.add(widget.pairs[l].en);
        Fx.wrong();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.pairs.length;
    return Column(
      children: [
        for (var k = 0; k < m; k++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: _MatchTile(
                    text: widget.pairs[_left[k]].en,
                    state: _stateOf(_left[k], true),
                    onTap: () => _tap(true, _left[k]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MatchTile(
                    text: widget.pairs[_right[k]].tr,
                    state: _stateOf(_right[k], false),
                    onTap: () => _tap(false, _right[k]),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  _TileState _stateOf(int p, bool left) {
    if (_matched.contains(p)) return _TileState.done;
    if (left ? _wrongL == p : _wrongR == p) return _TileState.wrong;
    if (left ? _selL == p : _selR == p) return _TileState.selected;
    return _TileState.normal;
  }
}

enum _TileState { normal, selected, done, wrong }

class _MatchTile extends StatelessWidget {
  final String text;
  final _TileState state;
  final VoidCallback onTap;
  const _MatchTile({required this.text, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color bg;
    var textColor = kInk;
    switch (state) {
      case _TileState.normal:
        border = _lineColor;
        bg = Colors.white;
      case _TileState.selected:
        border = kBlue;
        bg = _selBg;
      case _TileState.done:
        border = kGreen;
        bg = _okBg;
        textColor = kMuted;
      case _TileState.wrong:
        border = kRed;
        bg = _badBg;
    }
    return GestureDetector(
      onTap: state == _TileState.done ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 58,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 2),
          boxShadow: [BoxShadow(color: border, offset: const Offset(0, 3))],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor),
        ),
      ),
    );
  }
}

/// Harf dizme: karışık harflere dokunarak kelime oluşturulur.
/// Yerleşen harfe dokununca geri alınır. Tüm harfler dolunca [onChanged] kelimeyle,
/// eksikse null ile çağrılır. [locked] true ise (kontrol sonrası) dokunuş kapanır.
class ScrambleQuestion extends StatefulWidget {
  final List<String> letters;
  final bool locked;
  final bool? right; // kontrol sonrası renk için
  final void Function(String? answer) onChanged;
  const ScrambleQuestion({
    super.key,
    required this.letters,
    required this.locked,
    required this.right,
    required this.onChanged,
  });

  @override
  State<ScrambleQuestion> createState() => _ScrambleQuestionState();
}

class _ScrambleQuestionState extends State<ScrambleQuestion> {
  final List<int> _placed = []; // yerleşen harflerin sırası (letters indeksi)

  void _report() {
    final full = _placed.length == widget.letters.length;
    widget.onChanged(full ? _placed.map((i) => widget.letters[i]).join() : null);
  }

  void _add(int i) {
    if (widget.locked || _placed.contains(i)) return;
    setState(() => _placed.add(i));
    _report();
  }

  void _removeAt(int slot) {
    if (widget.locked || slot >= _placed.length) return;
    setState(() => _placed.removeAt(slot));
    _report();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.letters.length;
    final Color slotBorder = widget.locked
        ? (widget.right == true ? kGreen : kRed)
        : kBlue;
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var s = 0; s < n; s++)
              GestureDetector(
                onTap: () => _removeAt(s),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 44,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: s < _placed.length ? Colors.white : kTrack,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: s < _placed.length ? slotBorder : _lineColor,
                      width: 2,
                    ),
                    boxShadow: s < _placed.length
                        ? [BoxShadow(color: slotBorder, offset: const Offset(0, 3))]
                        : null,
                  ),
                  child: Text(
                    s < _placed.length ? widget.letters[_placed[s]] : '',
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
        const SizedBox(height: 28),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < n; i++)
              GestureDetector(
                onTap: () => _add(i),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 44,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _placed.contains(i) ? kTrack : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _lineColor, width: 2),
                    boxShadow: _placed.contains(i)
                        ? null
                        : const [BoxShadow(color: _lineColor, offset: Offset(0, 3))],
                  ),
                  child: Text(
                    _placed.contains(i) ? '' : widget.letters[i],
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
      ],
    );
  }
}
