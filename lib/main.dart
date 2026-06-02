import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // Karşılama ekranı eklendi

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LibDiary', // Uygulama Başlığı
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
        useMaterial3: true,
      ),
      home:
          const SplashScreen(), // Uygulama artık Karşılama Ekranı ile başlıyor
    );
  }
}
