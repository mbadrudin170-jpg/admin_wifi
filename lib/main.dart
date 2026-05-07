// lib/main.dart
import 'package:admin_wifi/services/servis_sinkronisasi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_wifi/data/services/navigasi_servis.dart';
import 'package:admin_wifi/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SinkronisasiService>(
          create: (_) => SinkronisasiService(),
          dispose: (_, service) => service.dispose(),
        ),
        // Tambahkan provider lain di sini jika perlu
      ],
      child: const AppMaterial(),
    );
  }
}

class AppMaterial extends StatelessWidget {
  const AppMaterial({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Colors.deepPurple;

    final TextTheme appTextTheme = const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Oswald',
        fontSize: 57,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(fontFamily: 'Open Sans', fontSize: 14),
    );

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
      ),
      textTheme: appTextTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontFamily: 'Oswald',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primarySeedColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );

    return MaterialApp(
      title: 'Admin Wifi',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
      navigatorKey: NavigasiServis.navigatorKey,
    );
  }
}
