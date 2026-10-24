import 'dart:math';

import 'package:flutter/material.dart';
import 'app_state.dart';
import 'fx.dart';
import 'lesson_data.dart';
import 'speech.dart';
import 'theme.dart';

/// Kelime Küpleri oyunu: karışık harf küplerini sürükleyip (ya da dokunup) doğru sıraya diz.
/// Kelimeler derslerden gelir (öğrenilenler önce). 1 seviye = 5 kelime, seviye bitince +20 XP.
/// Animasyon yok, ek paket yok. Küp renkleri/stili theme.dart'tan gelir.

const _roundsPerLevel = 5;

class _CubeColor {
  final Color base;
  final Color dark;
  const _CubeColor(this.base, this.dark);
}

const _cubeColors = [
  _CubeColor(kBlue, kBlueDark),
  _CubeColor(kGreen, kGreenDark),
  _CubeColor(kPurple, kPurpleDark),
  _CubeColor(kYellow, kYellowDark),
  _CubeColor(kRed, kRedDark),
];

/// Oyunda kullanılacak kelimeler: tek kelime, sadece harf, 3-8 harf. Öğrenilenler önce gelir.
List<Word> _gamePool() {
  bool ok(Word w) => RegExp(r'^[a-zA-Z]{3,8}$').hasMatch(w.en);
  final learned = AppState.instance.learnedWords.where(ok).toList();
  final rest = [
    for (final l in lessonsContent)
      for (final w in l)
        if (ok(w) && !learned.contains(w)) w,
  ];
  return [...learned, ...rest];
}

List<Word> _levelWords(int level) {
  final pool = _gamePool();
  if (pool.isEmpty) return const [];
  final n = min(_roundsPerLevel, pool.length);
  final start = ((level - 1) * _roundsPerLevel) % pool.length;
  return [for (var i = 0; i < n; i++) pool[(start + i) % pool.length]];
}

/// Tek harf küpü (3D "basılabilir" görünüm, theme.dart'taki ChunkyButton ile aynı mantık).
class CubeTile extends StatelessWidget {
  final String letter;
  final int color;
  final double size;
  final bool selected;
  const CubeTile({
    super.key,
    required this.letter,
    required this.color,
    required this.size,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = _cubeColors[color % _cubeColors.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(c.base, Colors.white, 0.28)!, c.base],
        ),
        borderRadius: BorderRadius.circular(size * 0.24),
        border: selected ? Border.all(color: kInk, width: 3) : null,
        boxShadow: [BoxShadow(color: c.dark, offset: Offset(0, size * 0.09))],
      ),
      child: Text(
        letter.toUpperCase(),
        style: TextStyle(
          fontSize: size * 0.55,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          height: 1,
          shadows: [Shadow(color: c.dark, offset: const Offset(0, 2))],
        ),
      ),
    );
  }
}

/// Ana sayfadaki oyun kartında kullanılan küçük küp dizisi.
class CubeStrip extends StatelessWidget {
  const CubeStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CubeTile(letter: 'A', color: 0, size: 34),
        SizedBox(width: 5),
        CubeTile(letter: 'B', color: 1, size: 34),
        SizedBox(width: 5),
        CubeTile(letter: 'C', color: 4, size: 34),
      ],
    );
  }
}

class CubeGameScreen extends StatefulWidget {
  const CubeGameScreen({super.key});

  @override
  State<CubeGameScreen> createState() => _CubeGameScreenState();
}

class _CubeGameScreenState extends State<CubeGameScreen> {
  final StudyTimer _timer = StudyTimer();
  late int _level = AppState.instance.gameLevel;
  late List<Word> _words = _levelWords(_level);
  int _round = 0;
  bool _levelDone = false;

  @override
  void dispose() {
    _timer.finish();
    super.dispose();
  }

  void _next() {
    _timer.tap();
    if (_round + 1 < _words.length) {
      setState(() => _round++);
    } else {
      // Seviye bitti: XP ver (sadece dokunuş olayından çağrılır).
      AppState.instance.finishGameLevel();
      Fx.celebrate();
      setState(() => _levelDone = true);
    }
  }

  void _nextLevel() {
    setState(() {
      _level = AppState.instance.gameLevel;
      _words = _levelWords(_level);
      _round = 0;
      _levelDone = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          const Positioned.fill(
            child: RepaintBoundary(
              child: Image(
                image: ResizeImage(AssetImage('assets/ready/bg_london.png'), width: 1080),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                gaplessPlayback: true,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _Header(onClose: () => Navigator.of(context).pop()),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    decoration: BoxDecoration(
                      color: const Color(0xF2F4FAFF),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: _words.isEmpty
                        ? const Center(
                            child: Text(
                              'Oyun için henüz kelime yok.',
                              style: TextStyle(color: kMuted, fontWeight: FontWeight.w700),
                            ),
                          )
                        : _levelDone
                            ? _LevelDone(
                                level: _level,
                                onNext: _nextLevel,
                                onExit: () => Navigator.of(context).pop(),
                              )
                            : _Round(
                                key: ValueKey('$_level-$_round'),
                                word: _words[_round],
                                seed: _level * 100 + _round,
                                level: _level,
                                round: _round,
                                total: _words.length,
                                onTap: _timer.tap,
                                onNext: _next,
                              ),
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

class _Header extends StatelessWidget {
  final VoidCallback onClose;
  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 12, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Fx.tap();
              onClose();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: Color(0xCCFFFFFF), shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded, color: kInk),
            ),
          ),
          const SizedBox(width: 8),
          Image.asset('assets/ready/mascot_main.png', height: 56, cacheHeight: 168),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Kelime Küpleri',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [Shadow(color: Color(0xFF1B5FB5), offset: Offset(0, 3))],
              ),
            ),
          ),
          const _XpChip(),
        ],
      ),
    );
  }
}

class _XpChip extends StatelessWidget {
  const _XpChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xE6FFFFFF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/ready/icon_star.png', height: 20, cacheHeight: 60),
          const SizedBox(width: 4),
          const Text(
            '+${AppState.gameXp} XP',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: kBlueDark),
          ),
        ],
      ),
    );
  }
}

enum _Status { playing, wrong, right }

class _Cube {
  final String ch;
  final int color;
  const _Cube(this.ch, this.color);
}

/// Tek kelimelik tur. Küp sırası ve durum burada tutulur; setState sadece bu parçayı yeniler.
class _Round extends StatefulWidget {
  final Word word;
  final int seed;
  final int level;
  final int round;
  final int total;
  final VoidCallback onTap;
  final VoidCallback onNext;
  const _Round({
    super.key,
    required this.word,
    required this.seed,
    required this.level,
    required this.round,
    required this.total,
    required this.onTap,
    required this.onNext,
  });

  @override
  State<_Round> createState() => _RoundState();
}

class _RoundState extends State<_Round> {
  late List<_Cube> _order;
  int? _sel;
  _Status _status = _Status.playing;

  String get _target => widget.word.en.toLowerCase();
  bool get _locked => _status == _Status.right;

  @override
  void initState() {
    super.initState();
    final cubes = [
      for (var i = 0; i < _target.length; i++) _Cube(_target[i], i % _cubeColors.length),
    ];
    final rnd = Random(widget.seed);
    var tries = 0;
    do {
      cubes.shuffle(rnd);
      tries++;
    } while (cubes.map((c) => c.ch).join() == _target && tries < 20);
    _order = cubes;
  }

  void _swap(int a, int b) {
    if (_locked || a == b) return;
    Fx.tap();
    setState(() {
      final t = _order[a];
      _order[a] = _order[b];
      _order[b] = t;
      _sel = null;
      _status = _Status.playing;
    });
  }

  void _tapCube(int i) {
    if (_locked) return;
    if (_sel == null) {
      Fx.tap();
      setState(() => _sel = i);
    } else if (_sel == i) {
      setState(() => _sel = null);
    } else {
      _swap(_sel!, i);
    }
  }

  void _check() {
    widget.onTap();
    final ok = _order.map((c) => c.ch).join() == _target;
    if (ok) {
      Fx.right();
      Speech.speak(widget.word.en);
      setState(() {
        _status = _Status.right;
        _sel = null;
      });
    } else {
      Fx.wrong();
      setState(() {
        _status = _Status.wrong;
        _sel = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = widget.round + 1 >= widget.total;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/ready/icon_target.png', height: 30, cacheHeight: 90),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Küpleri doğru sıraya diz!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kBlueDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _CluePill(word: widget.word),
        const SizedBox(height: 10),
        Expanded(child: _Tower(order: _order, solved: _status == _Status.right)),
        const SizedBox(height: 10),
        _TrayCard(
          order: _order,
          selected: _sel,
          locked: _locked,
          status: _status,
          onTapCube: _tapCube,
          onSwap: _swap,
        ),
        const SizedBox(height: 10),
        _ProgressRow(level: widget.level, round: widget.round, total: widget.total),
        const SizedBox(height: 10),
        ChunkyButton(
          text: _status == _Status.right
              ? (last ? 'SEVİYEYİ BİTİR  →' : 'DEVAM ET  →')
              : 'KONTROL ET  →',
          onPressed: _status == _Status.right ? widget.onNext : _check,
        ),
      ],
    );
  }
}

class _CluePill extends StatelessWidget {
  final Word word;
  const _CluePill({required this.word});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Fx.tap();
        Speech.speak(word.en);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F0FF),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              word.en.toUpperCase(),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kBlueDark),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('=', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kMuted)),
            ),
            Flexible(
              child: Text(
                word.tr.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kMuted),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.volume_up_rounded, size: 22, color: kBlue),
          ],
        ),
      ),
    );
  }
}

/// Küplerin şu anki sırayla dizildiği kule (canlı önizleme). Satırlar: 1, 2, 2, 2, ...
class _Tower extends StatelessWidget {
  final List<_Cube> order;
  final bool solved;
  const _Tower({required this.order, required this.solved});

  @override
  Widget build(BuildContext context) {
    final n = order.length;
    final rows = <int>[1];
    var left = n - 1;
    while (left > 0) {
      final k = min(2, left);
      rows.add(k);
      left -= k;
    }
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8FD3FF), Color(0xFFD6F0FF)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: solved ? kGreen : Colors.white,
          width: solved ? 3 : 2,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final size = max(
            24.0,
            min(66.0, min((box.maxHeight - 40) / rows.length - 4, (box.maxWidth - 40) / 2 - 4)),
          );
          var idx = 0;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final k in rows)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var j = 0; j < k; j++)
                        Padding(
                          padding: EdgeInsets.only(left: j == 0 ? 0 : 4),
                          child: () {
                            final c = order[idx++];
                            return CubeTile(letter: c.ch, color: c.color, size: size);
                          }(),
                        ),
                    ],
                  ),
                ),
              Container(
                width: size * 2 + 44,
                height: 16,
                decoration: BoxDecoration(
                  color: kGreen,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [BoxShadow(color: kGreenDark, offset: Offset(0, 4))],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TrayCard extends StatelessWidget {
  final List<_Cube> order;
  final int? selected;
  final bool locked;
  final _Status status;
  final void Function(int) onTapCube;
  final void Function(int, int) onSwap;
  const _TrayCard({
    required this.order,
    required this.selected,
    required this.locked,
    required this.status,
    required this.onTapCube,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color labelColor;
    final IconData icon;
    switch (status) {
      case _Status.right:
        label = 'Harika! Doğru sıra!';
        labelColor = kGreenDark;
        icon = Icons.check_circle_rounded;
      case _Status.wrong:
        label = 'Henüz doğru değil, tekrar dene';
        labelColor = kRedDark;
        icon = Icons.refresh_rounded;
      case _Status.playing:
        label = 'Küpleri sürükle ve sırala';
        labelColor = kBlueDark;
        icon = Icons.open_with_rounded;
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD6E8F8), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: labelColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: labelColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, box) {
              const gap = 6.0;
              final n = order.length;
              final size = min(60.0, (box.maxWidth - gap * (n - 1)) / n);
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < n; i++)
                    Padding(
                      padding: EdgeInsets.only(left: i == 0 ? 0 : gap),
                      child: _slot(i, size),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _slot(int i, double size) {
    final c = order[i];
    final tile = CubeTile(letter: c.ch, color: c.color, size: size, selected: selected == i);
    if (locked) return tile;
    return DragTarget<int>(
      onAcceptWithDetails: (d) => onSwap(d.data, i),
      builder: (context, candidates, _) {
        return Draggable<int>(
          data: i,
          // Küp parmağın hemen üstünde görünür, parmak altında kalmaz.
          dragAnchorStrategy: (d, ctx, pos) => Offset(size * 0.6, size * 1.3),
          feedback: Material(
            type: MaterialType.transparency,
            child: CubeTile(letter: c.ch, color: c.color, size: size * 1.2),
          ),
          childWhenDragging: Opacity(opacity: 0.3, child: tile),
          child: GestureDetector(
            onTap: () => onTapCube(i),
            child: candidates.isNotEmpty
                ? CubeTile(letter: c.ch, color: c.color, size: size, selected: true)
                : tile,
          ),
        );
      },
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final int level;
  final int round;
  final int total;
  const _ProgressRow({required this.level, required this.round, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD6E8F8), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: kGreen, shape: BoxShape.circle),
            child: Text(
              '$level',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seviye $level  •  ${round + 1}/$total',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kInk),
                ),
                const SizedBox(height: 4),
                ProgressBar(value: (round + 1) / total, height: 10),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Image.asset('assets/ready/icon_star.png', height: 24, cacheHeight: 72),
          const SizedBox(width: 4),
          const Text(
            '+${AppState.gameXp} XP',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: kInk),
          ),
        ],
      ),
    );
  }
}

class _LevelDone extends StatelessWidget {
  final int level;
  final VoidCallback onNext;
  final VoidCallback onExit;
  const _LevelDone({required this.level, required this.onNext, required this.onExit});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RepaintBoundary(
          child: Image.asset('assets/ready/mascot_star.png', height: 150, cacheHeight: 450),
        ),
        const SizedBox(height: 12),
        const Text(
          'Tebrikler!',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: kBlueDark),
        ),
        const SizedBox(height: 4),
        Text(
          'Seviye $level tamamlandı',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: kMuted),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD6E8F8), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/ready/icon_star.png', height: 30, cacheHeight: 90),
              const SizedBox(width: 8),
              const Text(
                '+${AppState.gameXp} XP',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kInk),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        ChunkyButton(text: 'SONRAKİ SEVİYE  →', onPressed: onNext),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            Fx.tap();
            onExit();
          },
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'Ana Sayfaya Dön',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kBlueDark),
            ),
          ),
        ),
      ],
    );
  }
}
