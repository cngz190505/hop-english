import 'package:flutter/material.dart';
import 'app_state.dart';
import 'theme.dart';
import 'welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState.instance.load(); // kayıtlı ilerlemeyi yükle
  runApp(const HopEnglishApp());
}

class HopEnglishApp extends StatelessWidget {
  const HopEnglishApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hop English',
      theme: buildTheme(),
      scrollBehavior: const BouncyScrollBehavior(),
      home: const WelcomeScreen(),
    );
  }
}
