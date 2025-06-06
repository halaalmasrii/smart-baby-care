import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/theme_provider.dart';
import 'utils/routes.dart';
import 'services/auth_service.dart'; // ✅ مهم جداً لإدارة تسجيل الدخول

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()), // ✅ أضفناه هنا
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
      initialRoute: AppRoutes.login, // يبدأ من شاشة تسجيل الدخول
    );
  }
}
