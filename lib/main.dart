// lib/main.dart
import 'package:admin_wifi/debug/log.dart';
import 'package:admin_wifi/utils/sync_manager.dart'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_wifi/data/services/navigasi_servis.dart';
import 'package:admin_wifi/splash_screen.dart';

void main() {
  Log.info('Titik masuk aplikasi dimulai.');
  
  try {
    Log.info('Memastikan Flutter-bindings telah diinisialisasi.');
    WidgetsFlutterBinding.ensureInitialized();
    Log.info('Flutter-bindings berhasil diinisialisasi.');

    Log.info('Menjalankan root aplikasi (MyApp).');
    runApp(const MyApp());
  } catch (e, s) {
    Log.error('Terjadi error fatal saat inisialisasi aplikasi.', error: e, stackTrace: s);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun widget MyApp, menyiapkan MultiProvider.');
    return MultiProvider(
      providers: [
        Provider<SyncManager>(
          create: (_) {
            Log.info('Membuat dan menyediakan instance SyncManager.');
            return SyncManager();
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          Log.info('Membangun child dari MultiProvider, yaitu AppMaterial.');
          return const AppMaterial();
        }
      ),
    );
  }
}

class AppMaterial extends StatelessWidget {
  const AppMaterial({super.key});

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun struktur tema dan MaterialApp.');

    const Color primarySeedColor = Colors.deepPurple;
    Log.info('Menetapkan warna dasar (seed color) untuk tema: $primarySeedColor.');

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
    Log.info('Membuat definisi TextTheme kustom.');

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
    Log.info('Membuat objek ThemeData untuk mode terang (light theme).');

    Log.info('Mengembalikan widget MaterialApp sebagai root UI.');
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
