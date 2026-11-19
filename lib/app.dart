// path: lib/app.dart
import 'package:admin_wifi/data/services/navigasi_servis.dart';
import 'package:admin_wifi/splash_screen.dart';
import 'package:admin_wifi/utils/sync_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:share_global_saya/src/utils/l.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    L.i('Membangun widget MyApp, menyiapkan MultiProvider.');
    return MultiProvider(
      providers: [
        Provider<SyncManager>(
          create: (_) {
            L.i('Membuat dan menyediakan instance SyncManager.');
            return SyncManager();
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          L.i('Membangun child dari MultiProvider, yaitu AppMaterial.');
          return const AppMaterial();
        },
      ),
    );
  }
}

class AppMaterial extends StatelessWidget {
  const AppMaterial({super.key});

  @override
  Widget build(BuildContext context) {
    L.i('Membangun struktur tema dan MaterialApp.');

    const Color primarySeedColor = Colors.deepPurple;
    L.i('Menetapkan warna dasar (seed color) untuk tema: $primarySeedColor.');

    final TextTheme appTextTheme = TextTheme(
      displayLarge: GoogleFonts.oswald(
        fontSize: 57,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.openSans(fontSize: 14),
    );
    L.i('Membuat definisi TextTheme kustom.');

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.oswald(
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
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
    L.i('Membuat objek ThemeData untuk mode terang (light theme).');

    L.i('Mengembalikan widget MaterialApp sebagai root UI.');
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
