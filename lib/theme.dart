import 'package:flutter/material.dart';
import 'fx.dart';

// Renk paleti
const kGreen = Color(0xFF58CC02);
const kGreenDark = Color(0xFF46A302);
const kBlue = Color(0xFF1CB0F6);
const kYellow = Color(0xFFFFC800);
const kYellowDark = Color(0xFFE0A800);
const kInk = Color(0xFF1F2D3D);
const kMuted = Color(0xFF7A8A99);
const kBg = Color(0xFFEFF7FF);
const kTrack = Color(0xFFDDE7EF);
const kBlueDark = Color(0xFF1288C9);
const kRed = Color(0xFFFF4B4B);
const kRedDark = Color(0xFFEA2B2B);
const kLocked = Color(0xFFB8C4CF);
const kLockedDark = Color(0xFF93A1AE);

/// Sayfa geçişlerinde animasyon olmasın.
class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

/// Listelerde iOS gibi yaylanarak kaydırma (BU ÖZELLİK KALACAK, kapatma).
/// Başa/sona gelince geri yaylanır, mavi parlama çıkmaz.
class BouncyScrollBehavior extends MaterialScrollBehavior {
  const BouncyScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: kGreen),
    scaffoldBackgroundColor: kBg,
    // Animasyonlar kapalı
    splashFactory: NoSplash.splashFactory,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: NoTransitionsBuilder(),
        TargetPlatform.iOS: NoTransitionsBuilder(),
      },
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      indicatorColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final on = states.contains(WidgetState.selected);
        return IconThemeData(color: on ? kGreen : kMuted, size: 28);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final on = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: on ? FontWeight.w800 : FontWeight.w600,
          color: on ? kGreen : kMuted,
        );
      }),
    ),
  );
}

/// Duolingo tarzı "basılabilir" 3D buton.
class ChunkyButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color shadowColor;
  final Color textColor;
  final double height;
  final double fontSize;

  const ChunkyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = kGreen,
    this.shadowColor = kGreenDark,
    this.textColor = Colors.white,
    this.height = 54,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Fx.press();
        onPressed();
      },
      child: Container(
        width: double.infinity,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: shadowColor, offset: const Offset(0, 4))],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

BoxDecoration cardDecoration() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFE3EEF8), width: 1.5),
      boxShadow: const [
        BoxShadow(color: Color(0x1A1C6BA8), blurRadius: 10, offset: Offset(0, 5)),
      ],
    );

/// Bulanık gölge yerine sert (blur'suz) gölge: GPU'yu yormaz, Duolingo tarzı "basılı" görünür.
/// Çok kartlı, kaydırılan sayfalarda (Ana Sayfa) kullanılır.
BoxDecoration cardDecorationHard() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFE3EEF8), width: 1.5),
      boxShadow: const [
        BoxShadow(color: Color(0xFFDCEAF6), offset: Offset(0, 4)),
      ],
    );

class ProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final Color color;
  const ProgressBar({
    super.key,
    required this.value,
    this.height = 10,
    this.color = kGreen,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value,
        minHeight: height,
        color: color,
        backgroundColor: kTrack,
      ),
    );
  }
}
