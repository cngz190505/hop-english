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
  final String blank; // Sadece cümle derslerinde: Boşluğu doldur sorusunda gizlenen kelime
  final String image; // Görsel dosya adı (assets/words/<image>.png). Cümle derslerinde ve soyut kelimelerde kullanılır
  final List<String> breakdown; // Soyut kelimelerde 2 örnek, parça parça: 'I=ben|have=sahibim|a duck=bir ördek'
  final String note; // Soyut kelimelerde (a, the, is...) ders kartında gösterilen Türkçe açıklama
  const Word({
    required this.en,
    required this.tr,
    required this.phonetic,
    required this.say,
    required this.example,
    required this.exampleTr,
    required this.emoji,
    this.blank = '',
    this.image = '',
    this.note = '',
    this.breakdown = const [],
  });

  /// Cümle dersindeki cümle mi? (kelime listesine, zor/hakimiyet kaydına girmez, Bölüm 13)
  bool get isSentence => blank.isNotEmpty;

  /// Soyut küçük kelime mi (a, the, is...)? Kendi görseli yok, örnek cümle görseli kullanır:
  /// quizde "Doğru görseli seç" sorusuna girmez.
  bool get isAbstract => note.isNotEmpty;

  /// Kelimenin resmi: assets/words/<kelime>.png (boşluksuz, küçük harf), örn. thankyou.png.
  /// Resim dosyası yoksa quizde emoji gösterilir.
  String get imagePath => image.isNotEmpty
      ? 'assets/words/$image.png'
      : 'assets/words/${en.replaceAll(' ', '').toLowerCase()}.png';
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
    say: 'wodırmelın',
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

/// 6. ders: Sayılar 1-10 (10 kelime, görseller: mavi rakam + o sayıda yıldız, çocuksuz)
const lesson6Words = [
  Word(
    en: 'one',
    tr: 'bir',
    phonetic: '/wʌn/',
    say: 'wan',
    example: 'I have one cat.',
    exampleTr: 'Bir kedim var.',
    emoji: '1️⃣',
  ),
  Word(
    en: 'two',
    tr: 'iki',
    phonetic: '/tuː/',
    say: 'tuu',
    example: 'I have two eyes.',
    exampleTr: 'İki gözüm var.',
    emoji: '2️⃣',
  ),
  Word(
    en: 'three',
    tr: 'üç',
    phonetic: '/θriː/',
    say: 'srii',
    example: 'I see three birds.',
    exampleTr: 'Üç kuş görüyorum.',
    emoji: '3️⃣',
  ),
  Word(
    en: 'four',
    tr: 'dört',
    phonetic: '/fɔːr/',
    say: 'for',
    example: 'I have four toys.',
    exampleTr: 'Dört oyuncağım var.',
    emoji: '4️⃣',
  ),
  Word(
    en: 'five',
    tr: 'beş',
    phonetic: '/faɪv/',
    say: 'fayv',
    example: 'I have five fingers.',
    exampleTr: 'Beş parmağım var.',
    emoji: '5️⃣',
  ),
  Word(
    en: 'six',
    tr: 'altı',
    phonetic: '/sɪks/',
    say: 'siks',
    example: 'I eat six apples.',
    exampleTr: 'Altı elma yiyorum.',
    emoji: '6️⃣',
  ),
  Word(
    en: 'seven',
    tr: 'yedi',
    phonetic: '/ˈsɛvən/',
    say: 'sevın',
    example: 'There are seven days.',
    exampleTr: 'Yedi gün var.',
    emoji: '7️⃣',
  ),
  Word(
    en: 'eight',
    tr: 'sekiz',
    phonetic: '/eɪt/',
    say: 'eyt',
    example: 'I see eight stars.',
    exampleTr: 'Sekiz yıldız görüyorum.',
    emoji: '8️⃣',
  ),
  Word(
    en: 'nine',
    tr: 'dokuz',
    phonetic: '/naɪn/',
    say: 'nayn',
    example: 'I have nine books.',
    exampleTr: 'Dokuz kitabım var.',
    emoji: '9️⃣',
  ),
  Word(
    en: 'ten',
    tr: 'on',
    phonetic: '/tɛn/',
    say: 'ten',
    example: 'I am ten years old.',
    exampleTr: 'On yaşındayım.',
    emoji: '🔟',
  ),
];

/// 7. ders: Aile (10 kelime)
const lesson7Words = [
  Word(
    en: 'mother',
    tr: 'anne',
    phonetic: '/ˈmʌðər/',
    say: 'madır',
    example: 'I love my mother.',
    exampleTr: 'Annemi seviyorum.',
    emoji: '👩',
  ),
  Word(
    en: 'father',
    tr: 'baba',
    phonetic: '/ˈfɑːðər/',
    say: 'fadır',
    example: 'I love my father.',
    exampleTr: 'Babamı seviyorum.',
    emoji: '👨',
  ),
  Word(
    en: 'sister',
    tr: 'kız kardeş',
    phonetic: '/ˈsɪstər/',
    say: 'sistır',
    example: 'My sister is nice.',
    exampleTr: 'Kız kardeşim çok tatlı.',
    emoji: '👧',
  ),
  Word(
    en: 'brother',
    tr: 'erkek kardeş',
    phonetic: '/ˈbrʌðər/',
    say: 'bradır',
    example: 'My brother is nice.',
    exampleTr: 'Erkek kardeşim çok tatlı.',
    emoji: '👦',
  ),
  Word(
    en: 'baby',
    tr: 'bebek',
    phonetic: '/ˈbeɪbi/',
    say: 'beybi',
    example: 'The baby is happy.',
    exampleTr: 'Bebek mutlu.',
    emoji: '👶',
  ),
  Word(
    en: 'grandmother',
    tr: 'büyükanne',
    phonetic: '/ˈɡrænmʌðər/',
    say: 'grenmadır',
    example: 'I love my grandmother.',
    exampleTr: 'Büyükannemi seviyorum.',
    emoji: '👵',
  ),
  Word(
    en: 'grandfather',
    tr: 'büyükbaba',
    phonetic: '/ˈɡrænfɑːðər/',
    say: 'grenfadır',
    example: 'I love my grandfather.',
    exampleTr: 'Büyükbabamı seviyorum.',
    emoji: '👴',
  ),
  Word(
    en: 'family',
    tr: 'aile',
    phonetic: '/ˈfæməli/',
    say: 'femili',
    example: 'I love my family.',
    exampleTr: 'Ailemi seviyorum.',
    emoji: '👪',
  ),
  Word(
    en: 'boy',
    tr: 'erkek çocuk',
    phonetic: '/bɔɪ/',
    say: 'boy',
    example: 'The boy is happy.',
    exampleTr: 'Erkek çocuk mutlu.',
    emoji: '🧒',
  ),
  Word(
    en: 'girl',
    tr: 'kız çocuk',
    phonetic: '/ɡɜːrl/',
    say: 'gırl',
    example: 'The girl is happy.',
    exampleTr: 'Kız çocuk mutlu.',
    emoji: '👧',
  ),
];

/// 8. ders: Araçlar (10 kelime, görseller çocuksuz araç çizimi)
const lesson8Words = [
  Word(
    en: 'car',
    tr: 'araba',
    phonetic: '/kɑːr/',
    say: 'kar',
    example: 'The car is red.',
    exampleTr: 'Araba kırmızı.',
    emoji: '🚗',
  ),
  Word(
    en: 'bus',
    tr: 'otobüs',
    phonetic: '/bʌs/',
    say: 'bas',
    example: 'The bus is big.',
    exampleTr: 'Otobüs büyük.',
    emoji: '🚌',
  ),
  Word(
    en: 'train',
    tr: 'tren',
    phonetic: '/treɪn/',
    say: 'treyn',
    example: 'The train is fast.',
    exampleTr: 'Tren hızlı.',
    emoji: '🚆',
  ),
  Word(
    en: 'plane',
    tr: 'uçak',
    phonetic: '/pleɪn/',
    say: 'pleyn',
    example: 'I see a plane.',
    exampleTr: 'Bir uçak görüyorum.',
    emoji: '✈️',
  ),
  Word(
    en: 'boat',
    tr: 'tekne',
    phonetic: '/boʊt/',
    say: 'bowt',
    example: 'The boat is blue.',
    exampleTr: 'Tekne mavi.',
    emoji: '⛵',
  ),
  Word(
    en: 'bicycle',
    tr: 'bisiklet',
    phonetic: '/ˈbaɪsɪkəl/',
    say: 'baysıkıl',
    example: 'I have a bicycle.',
    exampleTr: 'Bir bisikletim var.',
    emoji: '🚲',
  ),
  Word(
    en: 'truck',
    tr: 'kamyon',
    phonetic: '/trʌk/',
    say: 'trak',
    example: 'The truck is yellow.',
    exampleTr: 'Kamyon sarı.',
    emoji: '🚚',
  ),
  Word(
    en: 'helicopter',
    tr: 'helikopter',
    phonetic: '/ˈhɛlɪˌkɑːptər/',
    say: 'helikaptır',
    example: 'The helicopter is green.',
    exampleTr: 'Helikopter yeşil.',
    emoji: '🚁',
  ),
  Word(
    en: 'motorcycle',
    tr: 'motosiklet',
    phonetic: '/ˈmoʊtərˌsaɪkəl/',
    say: 'mowdırsaykıl',
    example: 'The motorcycle is black.',
    exampleTr: 'Motosiklet siyah.',
    emoji: '🏍️',
  ),
  Word(
    en: 'taxi',
    tr: 'taksi',
    phonetic: '/ˈtæksi/',
    say: 'teksi',
    example: 'The taxi is here.',
    exampleTr: 'Taksi burada.',
    emoji: '🚕',
  ),
];

/// 9. ders: Vücut (10 kelime, görseller aynı çocuk karakteri, parmakla gösteriyor)
const lesson9Words = [
  Word(
    en: 'head',
    tr: 'baş',
    phonetic: '/hed/',
    say: 'hed',
    example: 'Touch your head.',
    exampleTr: 'Başına dokun.',
    emoji: '🙂',
  ),
  Word(
    en: 'eye',
    tr: 'göz',
    phonetic: '/aɪ/',
    say: 'ay',
    example: 'This is my eye.',
    exampleTr: 'Bu benim gözüm.',
    emoji: '👁️',
  ),
  Word(
    en: 'ear',
    tr: 'kulak',
    phonetic: '/ɪr/',
    say: 'ir',
    example: 'Touch your ear.',
    exampleTr: 'Kulağına dokun.',
    emoji: '👂',
  ),
  Word(
    en: 'nose',
    tr: 'burun',
    phonetic: '/noʊz/',
    say: 'nouz',
    example: 'My nose is small.',
    exampleTr: 'Burnum küçük.',
    emoji: '👃',
  ),
  Word(
    en: 'mouth',
    tr: 'ağız',
    phonetic: '/maʊθ/',
    say: 'mauth',
    example: 'Open your mouth.',
    exampleTr: 'Ağzını aç.',
    emoji: '👄',
  ),
  Word(
    en: 'hand',
    tr: 'el',
    phonetic: '/hænd/',
    say: 'hend',
    example: 'Wave your hand.',
    exampleTr: 'Elini salla.',
    emoji: '✋',
  ),
  Word(
    en: 'arm',
    tr: 'kol',
    phonetic: '/ɑːrm/',
    say: 'arm',
    example: 'Raise your arm.',
    exampleTr: 'Kolunu kaldır.',
    emoji: '💪',
  ),
  Word(
    en: 'leg',
    tr: 'bacak',
    phonetic: '/leɡ/',
    say: 'leg',
    example: 'My leg is long.',
    exampleTr: 'Bacağım uzun.',
    emoji: '🦵',
  ),
  Word(
    en: 'foot',
    tr: 'ayak',
    phonetic: '/fʊt/',
    say: 'fut',
    example: 'Lift your foot.',
    exampleTr: 'Ayağını kaldır.',
    emoji: '🦶',
  ),
  Word(
    en: 'hair',
    tr: 'saç',
    phonetic: '/her/',
    say: 'her',
    example: 'My hair is brown.',
    exampleTr: 'Saçım kahverengi.',
    emoji: '💇',
  ),
];

/// 10. ders: Küçük Kelimeler (öğretici ders, Bölüm 15). Soyut kelimeler: kendi görseli yok,
/// örnek cümle görseli kullanılır (`image`), Türkçe açıklama `note` ile gösterilir.
/// Örnek cümleler sadece Ders 1-9'da öğrenilmiş kelimelerle kurulur.
const lesson10Words = [
  Word(
    en: 'a',
    tr: 'bir',
    phonetic: '/eɪ/',
    say: 'ey',
    example: 'a cat',
    exampleTr: 'bir kedi',
    emoji: '1️⃣',
    image: 'cat',
    note: "Bir tane kedi varsa a cat dersin. a cat = bir kedi.",
    breakdown: ['a=bir|cat=kedi'],
  ),
  Word(
    en: 'the',
    tr: 'belirli olan',
    phonetic: '/ðə/',
    say: 'dı',
    example: 'the dog',
    exampleTr: 'o köpek',
    emoji: '👉',
    image: 'dog',
    note: "Hangi kedi olduğunu biliyorsan the cat dersin. the cat = o kedi.",
    breakdown: ['the=o|dog=köpek'],
  ),
  Word(
    en: 'have',
    tr: 'sahip olmak',
    phonetic: '/hæv/',
    say: 'hev',
    example: 'I have a duck.',
    exampleTr: 'Bir ördeğim var.',
    emoji: '🤲',
    image: 'duck',
    note: "I have = bende var. I have a duck = Bir ördeğim var.",
    breakdown: ['I=ben|have=sahibim|a duck=bir ördek'],
  ),
  Word(
    en: 'like',
    tr: 'sevmek',
    phonetic: '/laɪk/',
    say: 'layk',
    example: 'I like apples.',
    exampleTr: 'Elmaları severim.',
    emoji: '❤️',
    image: 'apple',
    note: "I like = severim. I like apples = Elmaları severim.",
    breakdown: ['I=ben|like=severim|apples=elmalar'],
  ),
  Word(
    en: 'see',
    tr: 'görmek',
    phonetic: '/siː/',
    say: 'sii',
    example: 'I see a bird.',
    exampleTr: 'Bir kuş görüyorum.',
    emoji: '👀',
    image: 'bird',
    note: "I see = görüyorum. I see a bird = Bir kuş görüyorum.",
    breakdown: ['I=ben|see=görüyorum|a bird=bir kuş'],
  ),
  Word(
    en: 'want',
    tr: 'istemek',
    phonetic: '/wɑːnt/',
    say: 'wont',
    example: 'I want a pear.',
    exampleTr: 'Bir armut istiyorum.',
    emoji: '🙋',
    image: 'pear',
    note: "I want = istiyorum. I want a pear = Bir armut istiyorum.",
    breakdown: ['I=ben|want=istiyorum|a pear=bir armut'],
  ),
  Word(
    en: 'is',
    tr: '-dir',
    phonetic: '/ɪz/',
    say: 'iz',
    example: 'The apple is red.',
    exampleTr: 'Elma kırmızıdır.',
    emoji: '🟰',
    image: 'apple',
    note: "is = -dır demek. The apple is red = Elma kırmızıdır.",
    breakdown: ['The apple=elma|is=-dir|red=kırmızı'],
  ),
  Word(
    en: 'this',
    tr: 'bu',
    phonetic: '/ðɪs/',
    say: 'dis',
    example: 'This is a car.',
    exampleTr: 'Bu bir araba.',
    emoji: '👇',
    image: 'car',
    note: "Yakındaki şey için this dersin. This is a car = Bu bir araba.",
    breakdown: ['This=bu|is=-dir|a car=bir araba'],
  ),
  Word(
    en: 'that',
    tr: 'şu',
    phonetic: '/ðæt/',
    say: 'det',
    example: 'That is a bus.',
    exampleTr: 'Şu bir otobüs.',
    emoji: '👉',
    image: 'bus',
    note: "Uzaktaki şey için that dersin. That is a bus = Şu bir otobüs.",
    breakdown: ['That=şu|is=-dir|a bus=bir otobüs'],
  ),
  Word(
    en: 'and',
    tr: 've',
    phonetic: '/ænd/',
    say: 'end',
    example: 'I see mother and father.',
    exampleTr: 'Anneyi ve babayı görüyorum.',
    emoji: '➕',
    image: 'family',
    note: "and = ve. mother and father = anne ve baba.",
    breakdown: ['I see=ben görüyorum|mother=anne|and=ve|father=baba'],
  ),
];

/// 11. ders: Cümle Kurma 1 (Bölüm 13, 15). Yeni kelime YOK: sadece Ders 1-10'da öğrenilenler.
/// Her kalıbın ilk cümlesi kısa açıklama + 1 örnek taşır (`note`, `breakdown`).
const lesson11Words = [
  Word(
    en: 'I have a cat.',
    tr: 'Bir kedim var.',
    phonetic: '',
    say: 'ay hev ı ket',
    example: 'I have a cat.',
    exampleTr: 'Bir kedim var.',
    emoji: '🐱',
    blank: 'cat',
    image: 'cat',
    note: "I have = bende var. Sonuna şeyi ekle: I have a cat.",
    breakdown: ['I=ben|have=sahibim|a cat=bir kedi'],
  ),
  Word(
    en: 'I have two ducks.',
    tr: 'İki ördeğim var.',
    phonetic: '',
    say: 'ay hev tuu daks',
    example: 'I have two ducks.',
    exampleTr: 'İki ördeğim var.',
    emoji: '🦆',
    blank: 'ducks',
    image: 'duck',
    note: "I have = bende var.",
    breakdown: ['I=ben|have=sahibim|two ducks=iki ördek'],
  ),
  Word(
    en: 'I have a red apple.',
    tr: 'Kırmızı bir elmam var.',
    phonetic: '',
    say: 'ay hev ı red epıl',
    example: 'I have a red apple.',
    exampleTr: 'Kırmızı bir elmam var.',
    emoji: '🍎',
    blank: 'apple',
    image: 'apple',
    note: "I have = bende var.",
    breakdown: ['I=ben|have=sahibim|a red apple=kırmızı bir elma'],
  ),
  Word(
    en: 'I like bananas.',
    tr: 'Muzları severim.',
    phonetic: '',
    say: 'ay layk bınenız',
    example: 'I like bananas.',
    exampleTr: 'Muzları severim.',
    emoji: '🍌',
    blank: 'bananas',
    image: 'banana',
    note: "I like = severim. Sonuna sevdiğini ekle: I like apples.",
    breakdown: ['I=ben|like=severim|apples=elmalar'],
  ),
  Word(
    en: 'I like my family.',
    tr: 'Ailemi severim.',
    phonetic: '',
    say: 'ay layk may femıli',
    example: 'I like my family.',
    exampleTr: 'Ailemi severim.',
    emoji: '👨‍👩‍👧',
    blank: 'family',
    image: 'family',
    note: "I like = severim.",
    breakdown: ['I=ben|like=severim|my family=ailem'],
  ),
  Word(
    en: 'I see a bird.',
    tr: 'Bir kuş görüyorum.',
    phonetic: '',
    say: 'ay sii ı börd',
    example: 'I see a bird.',
    exampleTr: 'Bir kuş görüyorum.',
    emoji: '🐦',
    blank: 'bird',
    image: 'bird',
    note: "I see = görüyorum. Sonuna gördüğünü ekle: I see a bird.",
    breakdown: ['I=ben|see=görüyorum|a bird=bir kuş'],
  ),
  Word(
    en: 'I see three fish.',
    tr: 'Üç balık görüyorum.',
    phonetic: '',
    say: 'ay sii srii fiş',
    example: 'I see three fish.',
    exampleTr: 'Üç balık görüyorum.',
    emoji: '🐟',
    blank: 'three',
    image: 'fish',
    note: "I see = görüyorum.",
    breakdown: ['I=ben|see=görüyorum|three fish=üç balık'],
  ),
  Word(
    en: 'The lion is yellow.',
    tr: 'Aslan sarıdır.',
    phonetic: '',
    say: 'dı layın iz yelou',
    example: 'The lion is yellow.',
    exampleTr: 'Aslan sarıdır.',
    emoji: '🦁',
    blank: 'yellow',
    image: 'lion',
    note: "is = -dır demek. The lion is yellow = Aslan sarıdır.",
    breakdown: ['The lion=aslan|is=-dır|yellow=sarı'],
  ),
  Word(
    en: 'The car is blue.',
    tr: 'Araba mavidir.',
    phonetic: '',
    say: 'dı kar iz bluu',
    example: 'The car is blue.',
    exampleTr: 'Araba mavidir.',
    emoji: '🚗',
    blank: 'blue',
    image: 'car',
    note: "is = -dır demek.",
    breakdown: ['The car=araba|is=-dır|blue=mavi'],
  ),
  Word(
    en: 'The horse is brown.',
    tr: 'At kahverengidir.',
    phonetic: '',
    say: 'dı hors iz braun',
    example: 'The horse is brown.',
    exampleTr: 'At kahverengidir.',
    emoji: '🐴',
    blank: 'brown',
    image: 'horse',
    note: "is = -dır demek.",
    breakdown: ['The horse=at|is=-dır|brown=kahverengi'],
  ),
];

/// 12. ders: Günlük İfadeler (10 ifade). Örnek cümleler sadece Ders 1-11 kelimeleriyle kurulu.
const lesson12Words = [
  Word(
    en: 'good morning',
    tr: 'günaydın',
    phonetic: '/ɡʊd ˈmɔːrnɪŋ/',
    say: 'gud mornin',
    example: 'Good morning, mother!',
    exampleTr: 'Günaydın anne!',
    emoji: '🌅',
  ),
  Word(
    en: 'good night',
    tr: 'iyi geceler',
    phonetic: '/ɡʊd naɪt/',
    say: 'gud nayt',
    example: 'Good night, father.',
    exampleTr: 'İyi geceler baba.',
    emoji: '🌙',
  ),
  Word(
    en: 'how are you',
    tr: 'nasılsın',
    phonetic: '/haʊ ɑːr juː/',
    say: 'hau ar yuu',
    example: 'Hello! How are you?',
    exampleTr: 'Merhaba! Nasılsın?',
    emoji: '❓',
  ),
  Word(
    en: "I'm fine",
    tr: 'iyiyim',
    phonetic: '/aɪm faɪn/',
    say: 'aym fayn',
    example: "I'm fine, thank you.",
    exampleTr: 'İyiyim, teşekkür ederim.',
    emoji: '👍',
    image: 'imfine',
  ),
  Word(
    en: 'sorry',
    tr: 'özür dilerim',
    phonetic: '/ˈsɑːri/',
    say: 'sori',
    example: 'Sorry, mother.',
    exampleTr: 'Özür dilerim anne.',
    emoji: '🙏',
  ),
  Word(
    en: 'excuse me',
    tr: 'affedersiniz',
    phonetic: '/ɪkˈskjuːz miː/',
    say: 'ikskyuuz mii',
    example: 'Excuse me, please.',
    exampleTr: 'Affedersiniz, lütfen.',
    emoji: '🙋',
  ),
  Word(
    en: 'welcome',
    tr: 'hoş geldin',
    phonetic: '/ˈwelkəm/',
    say: 'welkım',
    example: 'Welcome, my friend!',
    exampleTr: 'Hoş geldin arkadaşım!',
    emoji: '🤗',
  ),
  Word(
    en: 'see you',
    tr: 'görüşürüz',
    phonetic: '/siː juː/',
    say: 'sii yuu',
    example: 'Goodbye! See you!',
    exampleTr: 'Hoşça kal! Görüşürüz!',
    emoji: '👋',
  ),
  Word(
    en: 'good luck',
    tr: 'iyi şanslar',
    phonetic: '/ɡʊd lʌk/',
    say: 'gud lak',
    example: 'Good luck, brother!',
    exampleTr: 'İyi şanslar kardeşim!',
    emoji: '🍀',
  ),
  Word(
    en: 'happy birthday',
    tr: 'doğum günün kutlu olsun',
    phonetic: '/ˈhæpi ˈbɜːrθdeɪ/',
    say: 'hepi börtdey',
    example: 'Happy birthday, grandmother!',
    exampleTr: 'Doğum günün kutlu olsun büyükanne!',
    emoji: '🎂',
  ),
];

/// 13. ders: Günlük İfadeler Cümleleri (Bölüm 13, 15: konu biter bitmez cümle dersi). Yeni kelime YOK.
const lesson13Words = [
  Word(
    en: 'Good morning, friend!',
    tr: 'Günaydın arkadaşım!',
    phonetic: '',
    say: 'gud mornin frend',
    example: 'Good morning, friend!',
    exampleTr: 'Günaydın arkadaşım!',
    emoji: '🌅',
    blank: 'morning',
    image: 'goodmorning',
    note: "Good morning = Günaydın. Sonuna ismi ekle: Good morning, Ali.",
    breakdown: ['Good morning=günaydın|friend=arkadaş'],
  ),
  Word(
    en: 'Good night, grandmother.',
    tr: 'İyi geceler büyükanne.',
    phonetic: '',
    say: 'gud nayt grendmadır',
    example: 'Good night, grandmother.',
    exampleTr: 'İyi geceler büyükanne.',
    emoji: '🌙',
    blank: 'night',
    image: 'goodnight',
    note: "Good night = İyi geceler.",
    breakdown: ['Good night=iyi geceler|grandmother=büyükanne'],
  ),
  Word(
    en: 'Happy birthday, mother!',
    tr: 'Doğum günün kutlu olsun anne!',
    phonetic: '',
    say: 'hepi börtdey madır',
    example: 'Happy birthday, mother!',
    exampleTr: 'Doğum günün kutlu olsun anne!',
    emoji: '🎂',
    blank: 'birthday',
    image: 'happybirthday',
    note: "Happy birthday = Doğum günün kutlu olsun.",
    breakdown: ['Happy birthday=doğum günün kutlu olsun|mother=anne'],
  ),
  Word(
    en: 'Welcome, father!',
    tr: 'Hoş geldin baba!',
    phonetic: '',
    say: 'welkım fadır',
    example: 'Welcome, father!',
    exampleTr: 'Hoş geldin baba!',
    emoji: '🤗',
    blank: 'father',
    image: 'welcome',
    note: "Welcome = Hoş geldin.",
    breakdown: ['Welcome=hoş geldin|father=baba'],
  ),
  Word(
    en: 'Good luck, sister!',
    tr: 'İyi şanslar kız kardeşim!',
    phonetic: '',
    say: 'gud lak sistır',
    example: 'Good luck, sister!',
    exampleTr: 'İyi şanslar kız kardeşim!',
    emoji: '🍀',
    blank: 'luck',
    image: 'goodluck',
    note: "Good luck = İyi şanslar.",
    breakdown: ['Good luck=iyi şanslar|sister=kız kardeş'],
  ),
  Word(
    en: 'How are you, mother?',
    tr: 'Nasılsın anne?',
    phonetic: '',
    say: 'hau ar yuu madır',
    example: 'How are you, mother?',
    exampleTr: 'Nasılsın anne?',
    emoji: '❓',
    blank: 'mother',
    image: 'howareyou',
    note: "How are you? = Nasılsın? Cevap: I'm fine = İyiyim.",
    breakdown: ['How are you=nasılsın|father=baba'],
  ),
  Word(
    en: "I'm fine, thank you.",
    tr: 'İyiyim, teşekkür ederim.',
    phonetic: '',
    say: 'aym fayn senk yuu',
    example: "I'm fine, thank you.",
    exampleTr: 'İyiyim, teşekkür ederim.',
    emoji: '👍',
    blank: 'fine',
    image: 'imfine',
    note: "I'm fine = İyiyim. Teşekkür için thank you ekle.",
    breakdown: ["I'm fine=iyiyim|thank you=teşekkür ederim"],
  ),
  Word(
    en: 'Excuse me, please.',
    tr: 'Affedersiniz, lütfen.',
    phonetic: '',
    say: 'ikskyuuz mii pliiz',
    example: 'Excuse me, please.',
    exampleTr: 'Affedersiniz, lütfen.',
    emoji: '🙋',
    blank: 'please',
    image: 'excuseme',
    note: "Excuse me = Affedersiniz. Rica ederken please (lütfen) ekle.",
    breakdown: ['Excuse me=affedersiniz|please=lütfen'],
  ),
  Word(
    en: 'Sorry, brother.',
    tr: 'Özür dilerim kardeşim.',
    phonetic: '',
    say: 'sori brodır',
    example: 'Sorry, brother.',
    exampleTr: 'Özür dilerim kardeşim.',
    emoji: '🙏',
    blank: 'brother',
    image: 'sorry',
    note: "Sorry = Özür dilerim.",
    breakdown: ['Sorry=özür dilerim|brother=erkek kardeş'],
  ),
  Word(
    en: 'Goodbye! See you, friend!',
    tr: 'Hoşça kal! Görüşürüz arkadaşım!',
    phonetic: '',
    say: 'gudbay sii yuu frend',
    example: 'Goodbye! See you, friend!',
    exampleTr: 'Hoşça kal! Görüşürüz arkadaşım!',
    emoji: '👋',
    blank: 'friend',
    image: 'seeyou',
    note: "See you = Görüşürüz.",
    breakdown: ['Goodbye=hoşça kal|See you=görüşürüz'],
  ),
];

/// 14. ders: Ev (10 kelime, görseller çocuksuz ev eşyası çizimi, kullanıcı getirdi)
const lesson14Words = [
  Word(
    en: 'house',
    tr: 'ev',
    phonetic: '/haʊs/',
    say: 'haus',
    example: 'The house is big.',
    exampleTr: 'Ev büyük.',
    emoji: '🏠',
  ),
  Word(
    en: 'door',
    tr: 'kapı',
    phonetic: '/dɔːr/',
    say: 'dor',
    example: 'The door is brown.',
    exampleTr: 'Kapı kahverengi.',
    emoji: '🚪',
  ),
  Word(
    en: 'window',
    tr: 'pencere',
    phonetic: '/ˈwɪndoʊ/',
    say: 'windo',
    example: 'The window is open.',
    exampleTr: 'Pencere açık.',
    emoji: '🪟',
  ),
  Word(
    en: 'bed',
    tr: 'yatak',
    phonetic: '/bed/',
    say: 'bed',
    example: 'The bed is soft.',
    exampleTr: 'Yatak yumuşak.',
    emoji: '🛏️',
  ),
  Word(
    en: 'table',
    tr: 'masa',
    phonetic: '/ˈteɪbəl/',
    say: 'teybıl',
    example: 'The table is small.',
    exampleTr: 'Masa küçük.',
    emoji: '🍽️',
  ),
  Word(
    en: 'chair',
    tr: 'sandalye',
    phonetic: '/tʃer/',
    say: 'çer',
    example: 'The chair is brown.',
    exampleTr: 'Sandalye kahverengi.',
    emoji: '🪑',
  ),
  Word(
    en: 'kitchen',
    tr: 'mutfak',
    phonetic: '/ˈkɪtʃɪn/',
    say: 'kiçın',
    example: 'The kitchen is clean.',
    exampleTr: 'Mutfak temiz.',
    emoji: '🍳',
  ),
  Word(
    en: 'bathroom',
    tr: 'banyo',
    phonetic: '/ˈbæθruːm/',
    say: 'bethrum',
    example: 'The bathroom is white.',
    exampleTr: 'Banyo beyaz.',
    emoji: '🛁',
  ),
  Word(
    en: 'garden',
    tr: 'bahçe',
    phonetic: '/ˈɡɑːrdn/',
    say: 'gardın',
    example: 'The garden is pretty.',
    exampleTr: 'Bahçe güzel.',
    emoji: '🌷',
  ),
  Word(
    en: 'lamp',
    tr: 'lamba',
    phonetic: '/læmp/',
    say: 'lemp',
    example: 'The lamp is on.',
    exampleTr: 'Lamba açık.',
    emoji: '💡',
  ),
];

/// 15. ders: Yiyecekler (10 kelime, görseller çocuksuz yiyecek çizimi, kullanıcı getirdi)
const lesson15Words = [
  Word(
    en: 'bread',
    tr: 'ekmek',
    phonetic: '/bred/',
    say: 'bred',
    example: 'The bread is fresh.',
    exampleTr: 'Ekmek taze.',
    emoji: '🍞',
  ),
  Word(
    en: 'milk',
    tr: 'süt',
    phonetic: '/mɪlk/',
    say: 'milk',
    example: 'The milk is cold.',
    exampleTr: 'Süt soğuk.',
    emoji: '🥛',
  ),
  Word(
    en: 'egg',
    tr: 'yumurta',
    phonetic: '/eɡ/',
    say: 'eg',
    example: 'The egg is white.',
    exampleTr: 'Yumurta beyaz.',
    emoji: '🥚',
  ),
  Word(
    en: 'cheese',
    tr: 'peynir',
    phonetic: '/tʃiːz/',
    say: 'çiiz',
    example: 'The cheese is yellow.',
    exampleTr: 'Peynir sarı.',
    emoji: '🧀',
  ),
  Word(
    en: 'water',
    tr: 'su',
    phonetic: '/ˈwɔːtər/',
    say: 'wotır',
    example: 'The water is clean.',
    exampleTr: 'Su temiz.',
    emoji: '💧',
  ),
  Word(
    en: 'rice',
    tr: 'pilav',
    phonetic: '/raɪs/',
    say: 'rays',
    example: 'The rice is hot.',
    exampleTr: 'Pilav sıcak.',
    emoji: '🍚',
  ),
  Word(
    en: 'soup',
    tr: 'çorba',
    phonetic: '/suːp/',
    say: 'suup',
    example: 'The soup is red.',
    exampleTr: 'Çorba kırmızı.',
    emoji: '🍲',
  ),
  Word(
    en: 'cake',
    tr: 'kek',
    phonetic: '/keɪk/',
    say: 'keyk',
    example: 'The cake is sweet.',
    exampleTr: 'Kek tatlı.',
    emoji: '🍰',
  ),
  Word(
    en: 'pizza',
    tr: 'pizza',
    phonetic: '/ˈpiːtsə/',
    say: 'piitsı',
    example: 'The pizza is round.',
    exampleTr: 'Pizza yuvarlak.',
    emoji: '🍕',
  ),
  Word(
    en: 'cookie',
    tr: 'kurabiye',
    phonetic: '/ˈkʊki/',
    say: 'kuki',
    example: 'The cookie is big.',
    exampleTr: 'Kurabiye büyük.',
    emoji: '🍪',
  ),
];

/// Tüm derslerin içeriği (sıra = ders numarası). Yeni ders eklenince buraya ekle.
const lessonsContent = [lesson1Words, lesson2Words, lesson3Words, lesson4Words, lesson5Words, lesson6Words, lesson7Words, lesson8Words, lesson9Words, lesson12Words, lesson14Words, lesson15Words];

/// Ders adları (lessonsContent ile aynı sırada, ana sayfa kartında görünür).
const lessonTitles = ['Selamlaşma', 'Kendini Tanıtma', 'Meyveler', 'Hayvanlar', 'Renkler', 'Sayılar', 'Aile', 'Araçlar', 'Vücut', 'Günlük İfadeler', 'Ev', 'Yiyecekler'];

/// Cümle derslerindeki cümleler. Kelime listesine, zor listesine ve hakimiyet yıldızlarına girmez.
final Set<String> sentenceKeys = {
  for (final l in lessonsContent)
    for (final w in l)
      if (w.isSentence) w.en,
};

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
  // Cümle dersinde cümlenin kendisi (en) içinden `blank` kelimesi gizlenir.
  final target = w.isSentence ? w.blank : w.en;
  final text = w.isSentence ? w.en : w.example;
  final re = RegExp('(?<![A-Za-z])${RegExp.escape(target)}(?![A-Za-z])',
      caseSensitive: false);
  final ms = re.allMatches(text).toList();
  if (ms.length != 1) return null;
  return text.replaceRange(ms.first.start, ms.first.end, '_____');
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
  if (words.isNotEmpty && words.first.isSentence) return _buildSentenceQuiz(words);
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
    if (kind == QType.picture && (n < 4 || w.isAbstract)) kind = QType.text;
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
        // Soyut kelimelerin görseli başka kelimeyle aynı olabilir: şık olarak girmez.
        final pool = [for (var k = 1; k < n; k++) if (!words[(i + k) % n].isAbstract) words[(i + k) % n]];
        if (pool.length < 3) {
          final dpos0 = i % 3;
          final dopts0 = [words[(i + 1) % n].en, words[(i + 3) % n].en]..insert(dpos0, w.en);
          single.add(QuizQuestion(type: QType.text, word: w, options: dopts0, correct: dpos0));
          break;
        }
        final pics = [pool[0], pool[1], pool[2]]..insert(ppos, w);
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

/// Cümle dersinin soruları (Bölüm 13). Her cümle için 1 tanıma sorusu (Dinle ve seç = Türkçesini seç,
/// Boşluğu doldur, Doğru cevabı seç döngüsü), sonra HER cümle için Cümleyi oluştur (parça dizme).
/// 10 cümle = 20 soru. Görselli, eşleştirme ve yazma sorusu yok. Sabit tohum, her seferinde aynı sonuç.
List<QuizQuestion> _buildSentenceQuiz(List<Word> words) {
  final n = words.length;
  final out = <QuizQuestion>[];
  for (var i = 0; i < n; i++) {
    final w = words[i];
    var kind = const [QType.listen, QType.sentence, QType.text][i % 3];
    if (kind == QType.sentence && blankSentence(w) == null) kind = QType.text;
    switch (kind) {
      case QType.listen:
        final lpos = i % 3;
        final lopts = [words[(i + 1) % n].tr, words[(i + 3) % n].tr]..insert(lpos, w.tr);
        out.add(QuizQuestion(type: QType.listen, word: w, options: lopts, correct: lpos));
      case QType.sentence:
        final spos = (i + 2) % 3;
        final sopts = [words[(i + 1) % n].blank, words[(i + 3) % n].blank]
          ..insert(spos, w.blank);
        out.add(QuizQuestion(
          type: QType.sentence,
          word: w,
          options: sopts,
          correct: spos,
          sentence: blankSentence(w)!,
        ));
      default:
        final dpos = i % 3;
        final dopts = [words[(i + 1) % n].en, words[(i + 3) % n].en]..insert(dpos, w.en);
        out.add(QuizQuestion(type: QType.text, word: w, options: dopts, correct: dpos));
    }
  }
  for (var i = 0; i < n; i++) {
    out.add(QuizQuestion(
      type: QType.scramble,
      word: words[i],
      letters: _shuffleTiles(words[i], 7 + i),
    ));
  }
  return out;
}
