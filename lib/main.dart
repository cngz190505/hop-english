import 'package:flutter/material.dart';
import 'app_state.dart';
import 'map_effects.dart';
import 'debug_tools.dart';
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
    // Performans ölçeri açılıp kapanınca sadece MaterialApp yenilenir (debug_tools.dart).
    return ValueListenableBuilder<bool>(
      valueListenable: showPerfOverlay,
      builder: (context, perf, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: perf,
        title: 'Hop English',
        theme: buildTheme(),
        scrollBehavior: const BouncyScrollBehavior(),
        navigatorObservers: [mapRouteObserver],
        home: const WelcomeScreen(),
      ),
    );
  }
}
