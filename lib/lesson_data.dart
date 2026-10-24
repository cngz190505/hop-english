import 'dart:math';

/// Ders içerikleri. Yeni kelime/ders eklemek için sadece bu dosyayı düzenle.
class Word {
  final String en; // İngilizce
  final String tr; // Türkçesi
  final String phonetic; // Okunuşu (IPA)
  final String say; // Türkçe okunuşu, örn. yuu
  final String example; // İngilizce örnek cümle
  final String exampleTr; // Örnek cümlenin Türkçesi
  final String emoji; // Kelime listesindeki simge
  const Word({
    required this.en,
    required this.tr,
    required this.phonetic,
    required this.say,
    required this.example,
    required this.exampleTr,
    required this.emoji,
  });

  /// Kelimenin resmi: assets/words/<kelime>.png (boşluksuz, küçük harf), örn. thankyou.png.
  /// Resim dosyası yoksa quizde emoji gösterilir.
  String get imagePath => 'assets/words/${en.replaceAll(' ', '').toLowerCase()}.png';
}

/// 1. ders: Selamlaşma (6 kelime)
const lesson1Words = [
  Word(
    en: 'hello',
    tr: 'merhaba',
    phonetic: '/həˈloʊ/',
    say: 'hılou',
    example: 'Hello! How are you?',
    exampleTr: 'Merhaba! Nasılsın?',
    emoji: '👋',
  ),
  Word(
    en: 'goodbye',
    tr: 'hoşça kal',
    phonetic: '/ɡʊdˈbaɪ/',
    say: 'gudbay',
    example: 'Goodbye! See you tomorrow.',
    exampleTr: 'Hoşça kal! Yarın görüşürüz.',
    emoji: '🚶',
  ),
  Word(
    en: 'thank you',
    tr: 'teşekkür ederim',
    phonetic: '/ˈθæŋk juː/',
    say: 'senk yuu',
    example: 'Thank you very much!',
    exampleTr: 'Çok teşekkür ederim!',
    emoji: '❤️',
  ),
  Word(
    en: 'please',
    tr: 'lütfen',
    phonetic: '/pliːz/',
    say: 'pliiz',
    example: 'Please sit down.',
    exampleTr: 'Lütfen otur.',
    emoji: '😊',
  ),
  Word(
    en: 'yes',
    tr: 'evet',
    phonetic: '/jɛs/',
    say: 'yes',
    example: 'Yes, I like it.',
    exampleTr: 'Evet, bunu beğendim.',
    emoji: '👍',
  ),
  Word(
    en: 'no',
    tr: 'hayır',
    phonetic: '/noʊ/',
    say: 'nou',
    example: 'No, thank you.',
    exampleTr: 'Hayır, teşekkürler.',
    emoji: '❌',
  ),
];

/// 2. ders: Kendini Tanıtma (10 kelime)
const lesson2Words = [
  Word(
    en: 'name',
    tr: 'isim',
    phonetic: '/neɪm/',
    say: 'neym',
    example: 'What is your name?',
    exampleTr: 'Adın ne?',
    emoji: '📛',
  ),
  Word(
    en: 'I',
    tr: 'ben',
    phonetic: '/aɪ/',
    say: 'ay',
    example: 'I am Ali.',
    exampleTr: "Ben Ali'yim.",
    emoji: '🙋',
  ),
  Word(
    en: 'you',
    tr: 'sen',
    phonetic: '/juː/',
    say: 'yuu',
    example: 'Are you ready?',
    exampleTr: 'Hazır mısın?',
    emoji: '👉',
  ),
  Word(
    en: 'my',
    tr: 'benim',
    phonetic: '/maɪ/',
    say: 'may',
    example: 'My name is Ali.',
    exampleTr: 'Benim adım Ali.',
    emoji: '🧸',
  ),
  Word(
    en: 'age',
    tr: 'yaş',
    phonetic: '/eɪdʒ/',
    say: 'eyc',
    example: 'What is your age?',
    exampleTr: 'Yaşın kaç?',
    emoji: '🎂',
  ),
  Word(
    en: 'from',
    tr: 'nereden',
    phonetic: '/frʌm/',
    say: 'fram',
    example: 'I am from Turkey.',
    exampleTr: "Ben Türkiye'denim.",
    emoji: '🌍',
  ),
  Word(
    en: 'nice to meet you',
    tr: 'memnun oldum',
    phonetic: '/naɪs tə miːt juː/',
    say: 'nays tı miit yuu',
    example: 'Nice to meet you, Ali.',
    exampleTr: 'Memnun oldum, Ali.',
    emoji: '🤝',
  ),
  Word(
    en: 'friend',
    tr: 'arkadaş',
    phonetic: '/frɛnd/',
    say: 'frend',
    example: 'You are my friend.',
    exampleTr: 'Sen benim arkadaşımsın.',
    emoji: '🧑‍🤝‍🧑',
  ),
  Word(
    en: 'student',
    tr: 'öğrenci',
    phonetic: '/ˈstuːdənt/',
    say: 'stuudınt',
    example: 'I am a student.',
    exampleTr: 'Ben öğrenciyim.',
    emoji: '🎒',
  ),
  Word(
    en: 'fine',
    tr: 'iyi',
    phonetic: '/faɪn/',
    say: 'fayn',
    example: 'I am fine, thank you.',
    exampleTr: 'İyiyim, teşekkür ederim.',
    emoji: '😌',
  ),
];

/// 3. ders: Meyveler (10 kelime)
const lesson3Words = [
  Word(
    en: 'apple',
    tr: 'elma',
    phonetic: '/ˈæpəl/',
    say: 'epıl',
    example: 'I eat an apple every day.',
    exampleTr: 'Her gün bir elma yerim.',
    emoji: '🍎',
  ),
  Word(
    en: 'banana',
    tr: 'muz',
    phonetic: '/bəˈnænə/',
    say: 'bınena',
    example: 'A banana is yellow.',
    exampleTr: 'Muz sarıdır.',
    emoji: '🍌',
  ),
  Word(
    en: 'orange',
    tr: 'portakal',
    phonetic: '/ˈɔːrɪndʒ/',
    say: 'orınc',
    example: 'This orange is sweet.',
    exampleTr: 'Bu portakal tatlı.',
    emoji: '🍊',
  ),
  Word(
    en: 'grapes',
    tr: 'üzüm',
    phonetic: '/ɡreɪps/',
    say: 'greyps',
    example: 'I like grapes.',
    exampleTr: 'Üzüm severim.',
    emoji: '🍇',
  ),
  Word(
    en: 'strawberry',
    tr: 'çilek',
    phonetic: '/ˈstrɔːbɛri/',
    say: 'strobıri',
    example: 'The strawberry is red.',
    exampleTr: 'Çilek kırmızıdır.',
    emoji: '🍓',
  ),
  Word(
    en: 'watermelon',
    tr: 'karpuz',
    phonetic: '/ˈwɔːtərˌmɛlən/',
    say: 'wotırmelın',
    example: 'The watermelon is big.',
    exampleTr: 'Karpuz büyük.',
    emoji: '🍉',
  ),
  Word(
    en: 'lemon',
    tr: 'limon',
    phonetic: '/ˈlɛmən/',
    say: 'lemın',
    example: 'I like lemon in my tea.',
    exampleTr: 'Çayımda limon severim.',
    emoji: '🍋',
  ),
  Word(
    en: 'pear',
    tr: 'armut',
    phonetic: '/pɛr/',
    say: 'per',
    example: 'The pear is green.',
    exampleTr: 'Armut yeşildir.',
    emoji: '🍐',
  ),
  Word(
    en: 'cherry',
    tr: 'kiraz',
    phonetic: '/ˈtʃɛri/',
    say: 'çeri',
    example: 'The cherry is small.',
    exampleTr: 'Kiraz küçüktür.',
    emoji: '🍒',
  ),
  Word(
    en: 'peach',
    tr: 'şeftali',
    phonetic: '/piːtʃ/',
    say: 'piitş',
    example: 'This peach is very sweet.',
    exampleTr: 'Bu şeftali çok tatlı.',
    emoji: '🍑',
  ),
];

/// 4. ders: Hayvanlar (10 kelime)
const lesson4Words = [
  Word(
    en: 'cat',
    tr: 'kedi',
    phonetic: '/kæt/',
    say: 'ket',
    example: 'The cat is on the sofa.',
    exampleTr: 'Kedi koltukta.',
    emoji: '🐱',
  ),
  Word(
    en: 'dog',
    tr: 'köpek',
    phonetic: '/dɔːɡ/',
    say: 'dog',
    example: 'I have a dog.',
    exampleTr: 'Bir köpeğim var.',
    emoji: '🐶',
  ),
  Word(
    en: 'bird',
    tr: 'kuş',
    phonetic: '/bɜːrd/',
    say: 'börd',
    example: 'The bird can fly.',
    exampleTr: 'Kuş uçabilir.',
    emoji: '🐦',
  ),
  Word(
    en: 'fish',
    tr: 'balık',
    phonetic: '/fɪʃ/',
    say: 'fiş',
    example: 'The fish is in the water.',
    exampleTr: 'Balık suyun içinde.',
    emoji: '🐟',
  ),
  Word(
    en: 'rabbit',
    tr: 'tavşan',
    phonetic: '/ˈræbɪt/',
    say: 'rebit',
    example: 'The rabbit eats a carrot.',
    exampleTr: 'Tavşan havuç yer.',
    emoji: '🐰',
  ),
  Word(
    en: 'horse',
    tr: 'at',
    phonetic: '/hɔːrs/',
    say: 'hors',
    example: 'I ride a horse.',
    exampleTr: 'Ben ata binerim.',
    emoji: '🐴',
  ),
  Word(
    en: 'cow',
    tr: 'inek',
    phonetic: '/kaʊ/',
    say: 'kau',
    example: 'The cow gives milk.',
    exampleTr: 'İnek süt verir.',
    emoji: '🐮',
  ),
  Word(
    en: 'duck',
    tr: 'ördek',
    phonetic: '/dʌk/',
    say: 'dak',
    example: 'The duck can swim.',
    exampleTr: 'Ördek yüzebilir.',
    emoji: '🦆',
  ),
  Word(
    en: 'lion',
    tr: 'aslan',
    phonetic: '/ˈlaɪən/',
    say: 'layın',
    example: 'The lion is strong.',
    exampleTr: 'Aslan güçlüdür.',
    emoji: '🦁',
  ),
  Word(
    en: 'elephant',
    tr: 'fil',
    phonetic: '/ˈɛlɪfənt/',
    say: 'elifınt',
    example: 'The elephant is very big.',
    exampleTr: 'Fil çok büyüktür.',
    emoji: '🐘',
  ),
];

/// 5. ders: Renkler (10 kelime, görseller çocuksuz nesne)
const lesson5Words = [
  Word(
    en: 'red',
    tr: 'kırmızı',
    phonetic: '/rɛd/',
    say: 'red',
    example: 'The apple is red.',
    exampleTr: 'Elma kırmızı.',
    emoji: '❤️',
  ),
  Word(
    en: 'blue',
    tr: 'mavi',
    phonetic: '/bluː/',
    say: 'bluu',
    example: 'The sky is blue.',
    exampleTr: 'Gökyüzü mavi.',
    emoji: '🎈',
  ),
  Word(
    en: 'green',
    tr: 'yeşil',
    phonetic: '/ɡriːn/',
    say: 'griin',
    example: 'The grass is green.',
    exampleTr: 'Çimen yeşil.',
    emoji: '🍃',
  ),
  Word(
    en: 'yellow',
    tr: 'sarı',
    phonetic: '/ˈjɛloʊ/',
    say: 'yelou',
    example: 'The banana is yellow.',
    exampleTr: 'Muz sarı.',
    emoji: '☀️',
  ),
  Word(
    en: 'black',
    tr: 'siyah',
    phonetic: '/blæk/',
    say: 'blek',
    example: 'The cat is black.',
    exampleTr: 'Kedi siyah.',
    emoji: '🎩',
  ),
  Word(
    en: 'white',
    tr: 'beyaz',
    phonetic: '/waɪt/',
    say: 'wayt',
    example: 'The cow is white.',
    exampleTr: 'İnek beyaz.',
    emoji: '☁️',
  ),
  Word(
    en: 'pink',
    tr: 'pembe',
    phonetic: '/pɪŋk/',
    say: 'pink',
    example: 'My bag is pink.',
    exampleTr: 'Çantam pembe.',
    emoji: '🍭',
  ),
  Word(
    en: 'purple',
    tr: 'mor',
    phonetic: '/ˈpɜːrpəl/',
    say: 'pörpıl',
    example: 'The grapes are purple.',
    exampleTr: 'Üzümler mor.',
    emoji: '💜',
  ),
  Word(
    en: 'brown',
    tr: 'kahverengi',
    phonetic: '/braʊn/',
    say: 'braun',
    example: 'The horse is brown.',
    exampleTr: 'At kahverengi.',
    emoji: '🍫',
  ),
  Word(
    en: 'gray',
    tr: 'gri',
    phonetic: '/ɡreɪ/',
    say: 'grey',
    example: 'The elephant is gray.',
    exampleTr: 'Fil gri.',
    emoji: '🪨',
  ),
];

/// Tüm derslerin içeriği (sıra = ders numarası). Yeni ders eklenince buraya ekle.
const lessonsContent = [lesson1Words, lesson2Words, lesson3Words, lesson4Words, lesson5Words];

/// Ders adları (lessonsContent ile aynı sırada, ana sayfa kartında görünür).
const lessonTitles = ['Selamlaşma', 'Kendini Tanıtma', 'Meyveler', 'Hayvanlar', 'Renkler'];

/// Soru tipleri. Yeni tip eklenirse quiz_screen.dart içindeki switch'lere de eklenir.
enum QType {
  text, // Türkçesi gösterilir, İngilizce şık seçilir
  picture, // İngilizcesi gösterilir, 4 görselden biri seçilir
  listen, // Kelime sesli okunur, Türkçesi seçilir
  match, // 5 İngilizce kelime 5 Türkçe karşılığıyla eşleştirilir
  scramble, // Karışık harflerden kelime oluşturulur
  sentence, // Örnek cümlede boşluğa doğru kelime seçilir
  typing, // Türkçesi gösterilir, İngilizcesi klavyeyle yazılır
}

/// Quiz sorusu.
class QuizQuestion {
  final QType type;
  final Word word; // sorunun kelimesi (eşleştirmede ilk kelime)
  final List<String> options; // şıklar (text, picture, listen)
  final int correct; // doğru şıkkın sırası
  final List<Word> pictures; // picture: 4 görsel
  final List<Word> pairs; // match: eşleştirilecek kelimeler
  final List<String> letters; // scramble: karışık harfler
  final bool retry; // yanlış yapılan sorunun tekrarı (puana sayılmaz)
  final String sentence; // sentence: boşluklu örnek cümle (___)
  const QuizQuestion({
    required this.type,
    required this.word,
    this.options = const [],
    this.correct = 0,
    this.pictures = const [],
    this.pairs = const [],
    this.letters = const [],
    this.retry = false,
    this.sentence = '',
  });
  bool get isPicture => type == QType.picture;

  /// Cevap kutusunda "Doğrusu: ..." olarak gösterilen metin.
  String get answerText => type == QType.listen ? '${word.en} (${word.tr})' : word.en;
}

/// Yanlış yapılan kelimenin tekrar sorusu: farklı tipte (yazılı yanlıştıysa dinle ve seç,
/// diğerlerinde yazılı) tek soru. Puana sayılmaz ([QuizQuestion.retry]).
QuizQuestion retryQuestion(List<Word> words, Word w, QType failed) {
  final n = words.length;
  final i = words.indexOf(w).clamp(0, n - 1);
  final pos = (i + 1) % 3;
  if (failed == QType.text || failed == QType.sentence) {
    final others = [for (var k = 1; k < n; k++) words[(i + k) % n]];
    final options = [others[0].tr, others[others.length > 2 ? 2 : 1].tr]
      ..insert(pos, w.tr);
    return QuizQuestion(
        type: QType.listen, word: w, options: options, correct: pos, retry: true);
  }
  final options = [words[(i + 1) % n].en, words[(i + 3) % n].en]..insert(pos, w.en);
  return QuizQuestion(
      type: QType.text, word: w, options: options, correct: pos, retry: true);
}

/// Tekrar dersi için en çok 10 kelime seçer: önce "zor" kelimeler, sonra diğerleri
/// (diğerleri günün tarihine göre kaydırılır, her gün farklı kelimeler öne gelir).
List<Word> pickReviewWords(List<Word> learned, Set<String> hard) {
  final h = [for (final w in learned) if (hard.contains(w.en)) w];
  final rest = [for (final w in learned) if (!hard.contains(w.en)) w];
  if (rest.isNotEmpty) {
    final r = DateTime.now().day % rest.length;
    rest.setAll(0, [...rest.sublist(r), ...rest.sublist(0, r)]);
  }
  return [...h, ...rest].take(10).toList();
}

/// Cümle tamamlama için: örnek cümlede kelime TAM BİR kez geçiyorsa, o yer "_____" olur.
/// Uygun değilse (kelime geçmiyor ya da birden çok geçiyor) null.
String? blankSentence(Word w) {
  final re = RegExp('(?<![A-Za-z])${RegExp.escape(w.en)}(?![A-Za-z])',
      caseSensitive: false);
  final ms = re.allMatches(w.example).toList();
  if (ms.length != 1) return null;
  return w.example.replaceRange(ms.first.start, ms.first.end, '_____');
}

/// Günün kelimesi: tarihe göre listeden seçilir, gün içinde hep aynıdır.
Word wordOfDay(List<Word> pool) {
  final now = DateTime.now();
  final day = now.difference(DateTime(now.year)).inDays;
  return pool[day % pool.length];
}

/// Harf dizme parçaları: tek kelimede harfler, ifadede (boşluk varsa) kelimeler.
List<String> scrambleTiles(Word w) =>
    w.en.contains(' ') ? w.en.split(' ') : w.en.split('');

/// Yazma sorusunda cevap karşılaştırması: büyük/küçük harf, baştaki/sondaki boşluk,
/// fazla boşluk ve kıvrık tırnak farkı yok sayılır.
String normalizeTyped(String s) => s
    .replaceAll('\u2019', "'")
    .replaceAll('\u2018', "'")
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'\s+'), ' ');

/// Harf dizme TÜM kelimelerde çıkar. Tek istisna: tek parçalı kelime (örn. "I").
bool canScramble(Word w) => scrambleTiles(w).length >= 2;

List<String> _shuffleTiles(Word w, int seed) {
  final tiles = scrambleTiles(w);
  final sep = w.en.contains(' ') ? ' ' : '';
  final r = Random(seed);
  for (var t = 0; t < 8; t++) {
    tiles.shuffle(r);
    if (tiles.join(sep) != w.en) return tiles;
  }
  return tiles.reversed.toList();
}

/// Dersin sorularını üretir. Rastgelelik sabit tohumlu: her seferinde aynı sonuç.
/// Sıra: 1) Her kelime için 1 tanıma sorusu (Dinle ve seç, Görseli seç, Cümle tamamlama,
/// Doğru cevabı seç döngüsü), 2) Eşleştirme, 3) HER kelime için Harf dizme, 4) 2. Eşleştirme.
/// Eşleştirme: 5+ kelimede 1, 6+ kelimede 2 tane (ilk 5 ve son 5 kelime).
List<QuizQuestion> buildQuiz(List<Word> words) {
  final n = words.length;
  final single = <QuizQuestion>[];
  for (var i = 0; i < n; i++) {
    final w = words[i];
    var kind = const [
      QType.listen,
      QType.picture,
      QType.sentence,
      QType.text,
    ][i % 4];
    if (kind == QType.picture && n < 4) kind = QType.text;
    if (kind == QType.sentence && blankSentence(w) == null) kind = QType.text;
    switch (kind) {
      case QType.listen:
        final others = [for (var k = 1; k < n; k++) words[(i + k) % n]];
        final lpos = i % 3;
        final lopts = [others[0].tr, others[others.length > 2 ? 2 : 1].tr]
          ..insert(lpos, w.tr);
        single.add(QuizQuestion(
            type: QType.listen, word: w, options: lopts, correct: lpos));
      case QType.picture:
        final ppos = i % 4;
        final pics = [
          words[(i + 1) % n],
          words[(i + 2) % n],
          words[(i + 4) % n],
        ]..insert(ppos, w);
        single.add(QuizQuestion(
          type: QType.picture,
          word: w,
          options: [for (final p in pics) p.en],
          correct: ppos,
          pictures: pics,
        ));
      case QType.sentence:
        final spos = (i + 2) % 3;
        final sopts = [words[(i + 1) % n].en, words[(i + 3) % n].en]
          ..insert(spos, w.en);
        single.add(QuizQuestion(
          type: QType.sentence,
          word: w,
          options: sopts,
          correct: spos,
          sentence: blankSentence(w)!,
        ));
      default:
        final dpos = i % 3;
        final dopts = [words[(i + 1) % n].en, words[(i + 3) % n].en]
          ..insert(dpos, w.en);
        single.add(QuizQuestion(
            type: QType.text, word: w, options: dopts, correct: dpos));
    }
  }
  final matches = <QuizQuestion>[];
  if (n >= 5) {
    // 1. eşleştirme ilk 5 kelime, 2. eşleştirme son 5 kelime (6-9 kelimede kelimeler tekrar eder).
    final starts = n >= 6 ? [0, n - 5] : [0];
    for (final c in starts) {
      final pairs = words.sublist(c, c + 5);
      matches.add(QuizQuestion(type: QType.match, word: pairs.first, pairs: pairs));
    }
  }
  final scrambles = [
    for (var i = 0; i < n; i++)
      if (canScramble(words[i]))
        QuizQuestion(
          type: QType.scramble,
          word: words[i],
          letters: _shuffleTiles(words[i], 7 + i),
        ),
  ];
  // Yazma: her 2 kelimeden birinde (tek sıralı kelimeler), klavyeyle İngilizcesi yazılır.
  final typings = [
    for (var i = 1; i < n; i += 2)
      QuizQuestion(type: QType.typing, word: words[i]),
  ];
  final out = [...single];
  if (matches.isNotEmpty) out.add(matches.first);
  out.addAll(scrambles);
  out.addAll(typings);
  if (matches.length > 1) out.add(matches.last);
  return out;
}
