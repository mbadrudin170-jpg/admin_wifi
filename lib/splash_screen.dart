// path: lib/splash_screen.dart

import 'dart:async';
import 'package:admin_wifi/data/sync/unduhan_awal.dart';
import 'package:admin_wifi/debug/log.dart';
import 'package:admin_wifi/halaman/tab/fungsi_menampilkan_notifikasi.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
    Log.info(
      'Siklus hidup widget dimulai. Mempersiapkan animasi dan inisialisasi utama.',
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    Log.info('AnimationController berhasil dibuat dengan durasi 500ms.');

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    Log.info('Animasi fade (dari 0.0 ke 1.0) berhasil dibuat.');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Log.info(
        'Frame pertama selesai di-render, memulai proses inisialisasi aplikasi (_initializeAndNavigate).',
      );
      _initializeAndNavigate();
    });
  }

  void _tampilkanToast(String message) {
    Log.info('Mencoba menampilkan pesan toast: "$message".');
    if (!mounted) {
      Log.warning(
        'Batal menampilkan toast karena widget sudah tidak ter-mount.',
      );
      return;
    }
    if (_showToast) {
      Log.warning('Batal menampilkan toast karena toast lain sedang aktif.');
      return;
    }

    Log.info('Memperbarui state untuk menampilkan toast.');
    setState(() {
      _toastMessage = message;
      _showToast = true;
    });

    _animationController.forward();
    Log.info('Memulai animasi fade-in untuk toast.');

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) {
        Log.warning(
          'Batal menyembunyikan toast setelah delay, widget sudah tidak ter-mount.',
        );
        return;
      }
      Log.info(
        'Delay 4 detik selesai, memulai animasi fade-out untuk menyembunyikan toast.',
      );
      _animationController.reverse().then((_) {
        if (!mounted) {
          Log.warning(
            'Batal reset state toast setelah animasi reverse, widget tidak ter-mount.',
          );
          return;
        }
        setState(() {
          _showToast = false;
        });
        Log.info('State toast berhasil di-reset, toast telah disembunyikan.');
      });
    });
  }

  void _updateLoading(String message) {
    if (!mounted) {
      Log.warning(
        'Batal memperbarui pesan loading ke "$message" karena widget tidak ter-mount.',
      );
      return;
    }
    Log.info('Memperbarui pesan loading di UI menjadi: "$message".');
    setState(() {
      _loadingMessage = message;
    });
  }

  Future<void> _initializeAndNavigate() async {
    Log.info('Memulai urutan inisialisasi aplikasi.');
    bool isOnline = false;

    try {
      _updateLoading("Menghubungkan ke layanan Google...");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      Log.info('Koneksi dan inisialisasi Firebase berhasil.');
      if (!mounted) return;

      _updateLoading("Mengonfigurasi pengaturan lokal...");
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      await initializeDateFormatting('id_ID', null);
      Log.info(
        'Konfigurasi zona waktu (Asia/Jakarta) dan format tanggal (id_ID) selesai.',
      );
      if (!mounted) return;

      _updateLoading("Mempersiapkan layanan aplikasi...");
      final notifikasiServis = NotifikasiServis();
      await notifikasiServis.inisialisasi();
      Log.info('Layanan notifikasi berhasil diinisialisasi.');
      if (!mounted) return;

      final bool izinDiberikan = await notifikasiServis.requestPermissions();
      if (izinDiberikan) {
        Log.info('Izin notifikasi telah diberikan oleh pengguna.');
      } else {
        Log.warning(
          'Izin notifikasi ditolak oleh pengguna. Menampilkan toast peringatan.',
        );
        _tampilkanToast(
          'Izin notifikasi ditolak. Beberapa fitur mungkin tidak akan berfungsi.',
        );
      }
      if (!mounted) return;

      _updateLoading("Mempersiapkan database lokal...");
      await DatabaseHelper.instance.database;
      Log.info('Inisialisasi koneksi database SQLite berhasil.');
      if (!mounted) return;

      _updateLoading("Memeriksa data awal...");
      await UnduhanAwalService().jalankanUnduhanAwal();
      Log.info(
        'Layanan Unduhan Awal selesai dijalankan, memastikan data esensial tersedia.',
      );
      if (!mounted) return;

      Log.info('Menjalankan layanan pembersihan data jika diperlukan.');
      PembersihanDataService().jalankanJikaPerlu();

      _updateLoading("Mengecek koneksi internet...");
      isOnline = await _koneksiService.cekKoneksi();
      Log.info(
        'Pengecekan koneksi internet selesai. Status online: $isOnline.',
      );
      if (!mounted) return;

      _updateLoading("Selesai, membuka aplikasi...");
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e, s) {
      Log.error(
        'Terjadi error kritis selama proses inisialisasi aplikasi. Proses dihentikan.',
        error: e,
        stackTrace: s,
      );
      _updateLoading("Terjadi error, silakan mulai ulang aplikasi.");
      await Future.delayed(const Duration(seconds: 5));
    }

    if (!mounted) {
      Log.warning(
        'Batal navigasi ke HalamanUtama karena widget tidak ter-mount.',
      );
      return;
    }
    Log.info(
      'Semua proses inisialisasi selesai. Menavigasi ke HalamanUtama dengan status offline: ${!isOnline}',
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
    Log.info('Membersihkan resource. AnimationController akan di-dispose.');
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun UI untuk SplashScreen.');
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
                    Log.info('Mendeteksi mode tema. Dark mode: $isDarkMode.');
                    final logoAsset = isDarkMode
                        ? 'assets/logo/ikon.ikon_apk.png'
                        : 'assets/logo/ikon.ikon_apk.png';
                    Log.info('Memilih aset logo berdasarkan tema: $logoAsset.');
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
