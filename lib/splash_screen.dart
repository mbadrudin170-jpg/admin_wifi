// path: lib/splash_screen.dart

import 'dart:async';
import 'package:admin_wifi/data/sync/unduhan_awal.dart';
import 'package:admin_wifi/halaman/tab/fungsi_menampilkan_notifikasi.dart';
// diubah: path import diperbaiki ke nama file yang benar
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:developer' as developer;

import 'package:admin_wifi/firebase_options.dart';
import 'package:admin_wifi/halaman_utama.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/services/cek_koneksi_internet.dart';
import 'package:admin_wifi/services/pembersihan_data_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  String _loadingMessage = "Memulai aplikasi...";
  final KoneksiInternetService _koneksiService = KoneksiInternetService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showToast = false;
  String _toastMessage = '';

  @override
  void initState() {
    super.initState();
    developer.log(
      '🚀 [SplashScreen] -> [initState] -> Memulai siklus hidup SplashScreen',
      name: 'SplashScreen.Lifecycle',
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndNavigate();
    });
  }

  void _tampilkanToast(String message) {
    if (!mounted || _showToast) return;
    developer.log(
      '🍞 [SplashScreen] -> [_tampilkanToast] -> Menampilkan pesan: $message',
      name: 'SplashScreen.UI',
    );
    setState(() {
      _toastMessage = message;
      _showToast = true;
    });
    _animationController.forward();
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      _animationController.reverse().then((_) {
        if (!mounted) return;
        setState(() {
          _showToast = false;
        });
      });
    });
  }

  void _updateLoading(String message) {
    if (!mounted) return;
    developer.log(
      '🔄 [SplashScreen] -> [_updateLoading] -> $message',
      name: 'SplashScreen.Progress',
    );
    setState(() {
      _loadingMessage = message;
    });
  }

  Future<void> _initializeAndNavigate() async {
    bool isOnline = false;

    try {
      _updateLoading("Menghubungkan ke layanan Google...");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      developer.log(
        '🔥 [SplashScreen] -> [_initializeAndNavigate] -> Firebase Berhasil Terhubung',
        name: 'SplashScreen.Firebase',
      );
      if (!mounted) return;

      _updateLoading("Mengonfigurasi pengaturan lokal...");
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      await initializeDateFormatting('id_ID', null);
      if (!mounted) return;

      _updateLoading("Mempersiapkan layanan aplikasi...");
      final notifikasiServis = NotifikasiServis();
      await notifikasiServis.inisialisasi();
      if (!mounted) return;

      final bool izinDiberikan = await notifikasiServis.requestPermissions();
      if (!izinDiberikan) {
        developer.log(
          '⚠️ [SplashScreen] -> [_initializeAndNavigate] -> Izin notifikasi ditolak oleh user',
          name: 'SplashScreen.Alert',
        );
        _tampilkanToast(
          'Izin notifikasi ditolak. Beberapa fitur mungkin tidak akan berfungsi.',
        );
      }
      if (!mounted) return;

      _updateLoading("Mempersiapkan database lokal...");
      await DatabaseHelper.instance.database;
      if (!mounted) return;

      _updateLoading("Memeriksa data awal...");
      await UnduhanAwalService().jalankanUnduhanAwal();
      if (!mounted) return;

      PembersihanDataService().jalankanJikaPerlu();
      _updateLoading("Mengecek koneksi internet...");
      isOnline = await _koneksiService.cekKoneksi();
      if (!mounted) return;

      // final sinkronisasiService = Provider.of<SinkronisasiService>(
      //   context,
      //   listen: false,
      // );

      // // TODO: Logika sinkronisasi di splash screen perlu ditinjau ulang
      // // Logika di bawah ini mungkin sudah usang setelah refactoring

      // if (isOnline) {
      //   _updateLoading("Memeriksa & mengunduh data...");
      //   try {
      //     await sinkronisasiService.jalankanProsesUnduh();
      //     _updateLoading("Unduh data selesai.");
      //   } catch (e, s) {
      //     developer.log(
      //       '❌ [SplashScreen] -> [_initializeAndNavigate] -> Gagal mengunduh data cloud',
      //       name: 'SplashScreen.Error',
      //       error: e,
      //       stackTrace: s,
      //     );
      //     _updateLoading("Gagal mengunduh data, melanjutkan offline...");
      //   }
      // }

      // try {
      //   final pengaturan = await PengaturanOperasi().getPengaturan();
      //   sinkronisasiService.mulaiUnduhOtomatis(
      //     interval: Duration(hours: pengaturan.intervalSinkronisasiOtomatis),
      //   );
      // } catch (e) {
      //   developer.log(
      //     '⚠️ [SplashScreen] -> [_initializeAndNavigate] -> Gagal memuat interval custom, gunakan default 24 jam',
      //     name: 'SplashScreen.Alert',
      //   );
      //   sinkronisasiService.mulaiUnduhOtomatis(
      //     interval: const Duration(hours: 24),
      //   );
      // }

      _updateLoading("Selesai, membuka aplikasi...");
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e, s) {
      developer.log(
        '🚨 [SplashScreen] -> [_initializeAndNavigate] -> Inisialisasi Gagal Total',
        name: 'SplashScreen.Critical',
        error: e,
        stackTrace: s,
      );
      _updateLoading("Terjadi error, silakan mulai ulang aplikasi.");
      await Future.delayed(const Duration(seconds: 5));
    }

    if (!mounted) return;
    developer.log(
      '🏁 [SplashScreen] -> [_initializeAndNavigate] -> Navigasi ke HalamanUtama (Offline: ${!isOnline})',
      name: 'SplashScreen.Navigation',
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HalamanUtama(isOffline: !isOnline),
      ),
    );
  }

  @override
  void dispose() {
    developer.log(
      '🗑️ [SplashScreen] -> [dispose] -> Membersihkan AnimationController',
      name: 'SplashScreen.Lifecycle',
    );
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Builder(
                  builder: (context) {
                    final isDarkMode =
                        MediaQuery.of(context).platformBrightness ==
                        Brightness.dark;
                    final logoAsset = isDarkMode
                        ? 'assets/logo/splash_screen/logo_splash_screen_terang.png'
                        : 'assets/logo/splash_screen/logo_splash_screen_gelap.png';
                    return Image.asset(logoAsset, width: 300);
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Admin WiFi',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 40),
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  _loadingMessage,
                  style: const TextStyle(fontSize: 14, fontFamily: 'Open Sans'),
                ),
              ],
            ),
          ),
          if (_showToast)
            Positioned(
              bottom: 50,
              left: 24,
              right: 24,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[800]?.withAlpha(242),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _toastMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Open Sans',
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
