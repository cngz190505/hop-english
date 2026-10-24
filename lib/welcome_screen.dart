import 'package:flutter/material.dart';
import 'floating.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const shadow = [Shadow(color: Colors.black38, blurRadius: 8)];
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/ready/bg_london.png', fit: BoxFit.cover),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'Hop English',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: shadow,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Daha iyi bir sen için\nİngilizce öğren!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      shadows: shadow,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Floating(
                        distance: 16,
                        child: Image.asset(
                          'assets/ready/mascot_main.png',
                          height: 300,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC800),
                        foregroundColor: const Color(0xFF3C3C3C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const HomeScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Başlayalım  →',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Küçük adımlar, büyük hedefler',
                    style: TextStyle(color: Colors.white, shadows: shadow),
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
