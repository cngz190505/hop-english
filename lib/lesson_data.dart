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

/// Tüm derslerin içeriği (sıra = ders numarası). Yeni ders eklenince buraya ekle.
const lessonsContent = [lesson1Words, lesson2Words];

/// Ders adları (lessonsContent ile aynı sırada, ana sayfa kartında görünür).
const lessonTitles = ['Selamlaşma', 'Kendini Tanıtma'];

/// Soru tipleri. Yeni tip eklenirse quiz_screen.dart içindeki switch'lere de eklenir.
enum QType {
  text, // Türkçesi gösterilir, İngilizce şık seçilir
  picture, // İngilizcesi gösterilir, 4 görselden biri seçilir
  listen, // Kelime sesli okunur, Türkçesi seçilir
  match, // 5 İngilizce kelime 5 Türkçe karşılığıyla eşleştirilir
  scramble, // Karışık harflerden kelime oluşturulur
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
  const QuizQuestion({
    required this.type,
    required this.word,
    this.options = const [],
    this.correct = 0,
    this.pictures = const [],
    this.pairs = const [],
    this.letters = const [],
  });
  bool get isPicture => type == QType.picture;

  /// Cevap kutusunda "Doğrusu: ..." olarak gösterilen metin.
  String get answerText => type == QType.listen ? '${word.en} (${word.tr})' : word.en;
}

/// Harf dizme sorusu için uygun mu? Tek kelime, sadece harf, 3-9 harf.
bool canScramble(Word w) =>
    !w.en.contains(RegExp(r'[^a-zA-Z]')) && w.en.length >= 3 && w.en.length <= 9;

List<String> _scrambleLetters(String s, int seed) {
  final chars = s.split('');
  final r = Random(seed);
  for (var t = 0; t < 8; t++) {
    chars.shuffle(r);
    if (chars.join() != s) return chars;
  }
  return chars.reversed.toList();
}

/// Dersin sorularını üretir. Rastgelelik sabit tohumlu: her seferinde aynı sonuç.
/// Her kelime için 1 soru: sırayla Dinle ve seç, Görseli seç, Doğru cevabı seç,
/// Harf dizme (kelime uygun değilse Doğru cevabı seç). Sonra her 5 kelime için
/// 1 Eşleştirme sorusu eklenir (ikisi varsa biri ortaya, biri sona).
List<QuizQuestion> buildQuiz(List<Word> words) {
  final n = words.length;
  final single = <QuizQuestion>[];
  for (var i = 0; i < n; i++) {
    final w = words[i];
    var kind = const [QType.listen, QType.picture, QType.text, QType.scramble][i % 4];
    if (kind == QType.picture && n < 4) kind = QType.text;
    if (kind == QType.scramble && !canScramble(w)) kind = QType.text;
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
      case QType.scramble:
        single.add(QuizQuestion(
          type: QType.scramble,
          word: w,
          letters: _scrambleLetters(w.en, 7 + i),
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
    for (var c = 0; c + 5 <= n; c += 5) {
      final pairs = words.sublist(c, c + 5);
      matches.add(QuizQuestion(type: QType.match, word: pairs.first, pairs: pairs));
    }
  }
  final out = [...single];
  if (matches.length > 1) out.insert(single.length ~/ 2, matches.removeAt(0));
  out.addAll(matches);
  return out;
}
