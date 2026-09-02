import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/supabase_service.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();
  runApp(const BaytiApp());
}

class BaytiApp extends StatelessWidget {
  const BaytiApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'بيتي',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: const Locale('ar'),
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const SplashScreen(),
    );
  }
}
