import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const NeuroBridgeApp());
}

class NeuroBridgeApp extends StatelessWidget {
  const NeuroBridgeApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NeuroBridge',
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}