import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // تهيئة قاعدة البيانات المحلية قبل تشغيل التطبيق
  await StorageService.init();
  runApp(const TransportTrackerApp());
}

class TransportTrackerApp extends StatelessWidget {
  const TransportTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تتبع الدوام والمواصلات',
      debugShowCheckedModeBanner: false,

      // دعم اللغة العربية واتجاه الكتابة من اليمين لليسار
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),

      home: Directionality(
        textDirection: TextDirection.rtl,
        child: const HomeScreen(),
      ),
    );
  }
}
