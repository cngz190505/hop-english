/// Ders içerikleri. Yeni kelime/ders eklemek için sadece bu dosyayı düzenle.
class Word {
  final String en; // İngilizce
  final String tr; // Türkçesi
  final String phonetic; // Okunuşu
  final String example; // İngilizce örnek cümle
  final String exampleTr; // Örnek cümlenin Türkçesi
  final String emoji; // Kelime listesindeki simge
  const Word({
    required this.en,
    required this.tr,
    required this.phonetic,
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
    example: 'Hello! How are you?',
    exampleTr: 'Merhaba! Nasılsın?',
    emoji: '👋',
  ),
  Word(
    en: 'goodbye',
    tr: 'hoşça kal',
    phonetic: '/ɡʊdˈbaɪ/',
    example: 'Goodbye! See you tomorrow.',
    exampleTr: 'Hoşça kal! Yarın görüşürüz.',
    emoji: '🚶',
  ),
  Word(
    en: 'thank you',
    tr: 'teşekkür ederim',
    phonetic: '/ˈθæŋk juː/',
    example: 'Thank you very much!',
    exampleTr: 'Çok teşekkür ederim!',
    emoji: '❤️',
  ),
  Word(
    en: 'please',
    tr: 'lütfen',
    phonetic: '/pliːz/',
    example: 'Please sit down.',
    exampleTr: 'Lütfen otur.',
    emoji: '😊',
  ),
  Word(
    en: 'yes',
    tr: 'evet',
    phonetic: '/jɛs/',
    example: 'Yes, I like it.',
    exampleTr: 'Evet, bunu beğendim.',
    emoji: '👍',
  ),
  Word(
    en: 'no',
    tr: 'hayır',
    phonetic: '/noʊ/',
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
    example: 'What is your name?',
    exampleTr: 'Adın ne?',
    emoji: '📛',
  ),
  Word(
    en: 'I',
    tr: 'ben',
    phonetic: '/aɪ/',
    example: 'I am Ali.',
    exampleTr: "Ben Ali'yim.",
    emoji: '🙋',
  ),
  Word(
    en: 'you',
    tr: 'sen',
    phonetic: '/juː/',
    example: 'Are you ready?',
    exampleTr: 'Hazır mısın?',
    emoji: '👉',
  ),
  Word(
    en: 'my',
    tr: 'benim',
    phonetic: '/maɪ/',
    example: 'My name is Ali.',
    exampleTr: 'Benim adım Ali.',
    emoji: '🧸',
  ),
  Word(
    en: 'age',
    tr: 'yaş',
    phonetic: '/eɪdʒ/',
    example: 'What is your age?',
    exampleTr: 'Yaşın kaç?',
    emoji: '🎂',
  ),
  Word(
    en: 'from',
    tr: 'nereden',
    phonetic: '/frʌm/',
    example: 'I am from Turkey.',
    exampleTr: "Ben Türkiye'denim.",
    emoji: '🌍',
  ),
  Word(
    en: 'nice to meet you',
    tr: 'memnun oldum',
    phonetic: '/naɪs tə miːt juː/',
    example: 'Nice to meet you, Ali.',
    exampleTr: 'Memnun oldum, Ali.',
    emoji: '🤝',
  ),
  Word(
    en: 'friend',
    tr: 'arkadaş',
    phonetic: '/frɛnd/',
    example: 'You are my friend.',
    exampleTr: 'Sen benim arkadaşımsın.',
    emoji: '🧑‍🤝‍🧑',
  ),
  Word(
    en: 'student',
    tr: 'öğrenci',
    phonetic: '/ˈstuːdənt/',
    example: 'I am a student.',
    exampleTr: 'Ben öğrenciyim.',
    emoji: '🎒',
  ),
  Word(
    en: 'fine',
    tr: 'iyi',
    phonetic: '/faɪn/',
    example: 'I am fine, thank you.',
    exampleTr: 'İyiyim, teşekkür ederim.',
    emoji: '😌',
  ),
];

/// Tüm derslerin içeriği (sıra = ders numarası). Yeni ders eklenince buraya ekle.
const lessonsContent = [lesson1Words, lesson2Words];

/// Quiz sorusu: Türkçesi gösterilir, doğru İngilizce karşılığı seçilir.
class QuizQuestion {
  final Word word;
  final List<String> options;
  final int correct; // doğru şıkkın sırası
  /// Doluysa "Doğru görseli seç" sorusudur: İngilizcesi gösterilir, 4 görselden biri seçilir.
  final List<Word> pictures;
  const QuizQuestion(this.word, this.options, this.correct,
      {this.pictures = const []});
  bool get isPicture => pictures.isNotEmpty;
}

/// Her kelime için 1 soru üretir. Yanlış şıklar diğer kelimelerden gelir.
/// Doğru şıkkın yeri sırayla değişir (rastgelelik yok, hep aynı sonuç).
List<QuizQuestion> buildQuiz(List<Word> words) {
  final n = words.length;
  return [
    for (var i = 0; i < n; i++)
      () {
        // Tek numaralı sorular görselli (4 kelime olmalı), diğerleri yazılı.
        if (i.isOdd && n >= 4) {
          final pos = i % 4;
          final pics = [
            words[(i + 1) % n],
            words[(i + 2) % n],
            words[(i + 4) % n],
          ]..insert(pos, words[i]);
          return QuizQuestion(words[i], [for (final w in pics) w.en], pos,
              pictures: pics);
        }
        final pos = i % 3;
        final options = [words[(i + 1) % n].en, words[(i + 3) % n].en]
          ..insert(pos, words[i].en);
        return QuizQuestion(words[i], options, pos);
      }(),
  ];
}
