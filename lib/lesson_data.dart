/// Ders içerikleri. Yeni kelime/ders eklemek için sadece bu dosyayı düzenle.
class Word {
  final String en; // İngilizce
  final String tr; // Türkçesi
  final String phonetic; // Okunuşu
  final String example; // İngilizce örnek cümle
  final String exampleTr; // Örnek cümlenin Türkçesi
  const Word({
    required this.en,
    required this.tr,
    required this.phonetic,
    required this.example,
    required this.exampleTr,
  });
}

/// 1. ders: Selamlaşma (6 kelime)
const lesson1Words = [
  Word(
    en: 'hello',
    tr: 'merhaba',
    phonetic: '/həˈloʊ/',
    example: 'Hello! How are you?',
    exampleTr: 'Merhaba! Nasılsın?',
  ),
  Word(
    en: 'goodbye',
    tr: 'hoşça kal',
    phonetic: '/ɡʊdˈbaɪ/',
    example: 'Goodbye! See you tomorrow.',
    exampleTr: 'Hoşça kal! Yarın görüşürüz.',
  ),
  Word(
    en: 'thank you',
    tr: 'teşekkür ederim',
    phonetic: '/ˈθæŋk juː/',
    example: 'Thank you very much!',
    exampleTr: 'Çok teşekkür ederim!',
  ),
  Word(
    en: 'please',
    tr: 'lütfen',
    phonetic: '/pliːz/',
    example: 'Please sit down.',
    exampleTr: 'Lütfen otur.',
  ),
  Word(
    en: 'yes',
    tr: 'evet',
    phonetic: '/jɛs/',
    example: 'Yes, I like it.',
    exampleTr: 'Evet, bunu beğendim.',
  ),
  Word(
    en: 'no',
    tr: 'hayır',
    phonetic: '/noʊ/',
    example: 'No, thank you.',
    exampleTr: 'Hayır, teşekkürler.',
  ),
];
