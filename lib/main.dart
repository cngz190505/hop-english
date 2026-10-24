import 'package:flutter/material.dart';
import 'bouncy_scroll.dart';
import 'welcome_screen.dart';

void main() => runApp(const HopEnglishApp());

class HopEnglishApp extends StatelessWidget {
  const HopEnglishApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hop English',
      scrollBehavior: BouncyScrollBehavior(),
      home: WelcomeScreen(),
    );
  }
}
