import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'utils/theme_provider.dart';
import 'utils/routes.dart';
import 'services/auth_service.dart'; // إدارة الدخول

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones(); // ضروري قبل جدولة الإشعارات

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
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
