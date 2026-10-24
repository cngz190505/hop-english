import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const shadow = [Shadow(color: Color(0x55000000), blurRadius: 10)];
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const RepaintBoundary(
            child: Image(
              image: ResizeImage(
                AssetImage('assets/ready/bg_london.png'),
                width: 1080,
              ),
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),
          // Üstte okunabilirlik için hafif mavi geçiş
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [Color(0x661C8CE0), Color(0x001C8CE0)],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
              child: Column(
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 52,
                        height: 1.0,
                        fontWeight: FontWeight.w900,
                        shadows: shadow,
                      ),
                      children: [
                        TextSpan(
                          text: 'Hop\n',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'English',
                          style: TextStyle(color: kYellow),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Daha iyi bir sen için\nİngilizce öğren!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: shadow,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: RepaintBoundary(
                        child: Image.asset(
                          'assets/ready/mascot_main.png',
                          height: 300,
                          cacheHeight: 600,
                          gaplessPlayback: true,
                        ),
                      ),
                    ),
                  ),
                  ChunkyButton(
                    text: 'Başlayalım  →',
                    color: kYellow,
                    shadowColor: kYellowDark,
                    textColor: const Color(0xFF3C3C3C),
                    height: 58,
                    fontSize: 20,
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Küçük adımlar, büyük hedefler',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      shadows: shadow,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
