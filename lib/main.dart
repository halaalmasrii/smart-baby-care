import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'utils/theme_provider.dart';
import 'utils/routes.dart';
import 'services/auth_service.dart'; // إدارة الدخول

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones(); // ضروري قبل جدولة الإشعارات

  final authService = AuthService();
  await authService.autoLogin();            // تسجيل الدخول التلقائي
  await authService.loadSelectedBabyId();   // ✅ تحميل معرف الطفل من SharedPreferences

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<AuthService>.value(value: authService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'BabyCare',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeData,
      routes: AppRoutes.routes,
      initialRoute: AppRoutes.login,
    );
  }
}
