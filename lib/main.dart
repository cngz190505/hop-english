import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';

void main() => runApp(const HopEnglishApp());

class HopEnglishApp extends StatelessWidget {
  const HopEnglishApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hop English',
      home: WelcomeScreen(),
    );
  }
}
