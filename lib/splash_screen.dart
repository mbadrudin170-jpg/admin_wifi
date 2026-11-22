// path: lib/splash_screen.dart

import 'dart:async';

import 'package:admin_wifi/data/sync/unduhan_awal.dart';
import 'package:admin_wifi/db/sqlite/sqflite.dart';
import 'package:admin_wifi/services/notifikasi/fungsi_menampilkan_notifikasi.dart';
import 'package:admin_wifi/home.dart';
import 'package:admin_wifi/services/cek_koneksi_internet.dart';
import 'package:admin_wifi/services/pembersihan_data_service.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:share_global_saya/src/utils/navigator_helper.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
    L.i(
      'Siklus hidup widget dimulai. Mempersiapkan animasi dan inisialisasi utama.',
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    L.i('AnimationController berhasil dibuat dengan durasi 500ms.');

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    L.i('Animasi fade (dari 0.0 ke 1.0) berhasil dibuat.');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      L.i(
        'Frame pertama selesai di-render, memulai proses inisialisasi aplikasi (_initializeAndNavigate).',
      );
      _initializeAndNavigate();
    });
  }

  void _tampilkanToast(String message) {
    L.i('Mencoba menampilkan pesan toast: "$message".');
    if (!mounted) {
      L.w('Batal menampilkan toast karena widget sudah tidak ter-mount.');
      return;
    }
    if (_showToast) {
      L.w('Batal menampilkan toast karena toast lain sedang aktif.');
      return;
    }

    L.i('Memperbarui state untuk menampilkan toast.');
    setState(() {
      _toastMessage = message;
      _showToast = true;
    });

    _animationController.forward();
    L.i('Memulai animasi fade-in untuk toast.');

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) {
        L.w(
          'Batal menyembunyikan toast setelah delay, widget sudah tidak ter-mount.',
        );
        return;
      }
      L.i(
        'Delay 4 detik selesai, memulai animasi fade-out untuk menyembunyikan toast.',
      );
      _animationController.reverse().then((_) {
        if (!mounted) {
          L.w(
            'Batal reset state toast setelah animasi reverse, widget tidak ter-mount.',
          );
          return;
        }
        setState(() {
          _showToast = false;
        });
        L.i('State toast berhasil di-reset, toast telah disembunyikan.');
      });
    });
  }

  void _updateLoading(String message) {
    if (!mounted) {
      L.w(
        'Batal memperbarui pesan loading ke "$message" karena widget tidak ter-mount.',
      );
      return;
    }
    L.i('Memperbarui pesan loading di UI menjadi: "$message".');
    setState(() {
      _loadingMessage = message;
    });
  }

  Future<void> _initializeAndNavigate() async {
    L.i('Memulai urutan inisialisasi aplikasi.');
    bool isOnline = false;

    try {
      // Firebase diinisialisasi di main() (hanya non-Web; di Web tidak ada
      // konfigurasi Firebase). Jangan akses Firebase di Web tanpa config.
      _updateLoading("Mengonfigurasi pengaturan lokal...");
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      await initializeDateFormatting('id_ID', null);
      L.i(
        'Konfigurasi zona waktu (Asia/Jakarta) dan format tanggal (id_ID) selesai.',
      );
      if (!mounted) return;

      _updateLoading("Mempersiapkan layanan aplikasi...");
      final notifikasiServis = NotifikasiServis();
      await notifikasiServis.inisialisasi();
      L.i('Layanan notifikasi berhasil diinisialisasi.');
      if (!mounted) return;

      final bool izinDiberikan = await notifikasiServis.requestPermissions();
      if (izinDiberikan) {
        L.i('Izin notifikasi telah diberikan oleh pengguna.');
      } else {
        L.w(
          'Izin notifikasi ditolak oleh pengguna. Menampilkan toast peringatan.',
        );
        _tampilkanToast(
          'Izin notifikasi ditolak. Beberapa fitur mungkin tidak akan berfungsi.',
        );
      }
      if (!mounted) return;

      _updateLoading("Mempersiapkan database lokal...");
      await DatabaseHelper.instance.database;
      L.i('Inisialisasi koneksi database SQLite berhasil.');
      if (!mounted) return;

      _updateLoading("Memeriksa data awal...");
      if (!kIsWeb) {
        await UnduhanAwalService().jalankanUnduhanAwal();
        L.i(
          'Layanan Unduhan Awal selesai dijalankan, memastikan data esensial tersedia.',
        );
      } else {
        L.i(
          'Mode Web: Firebase tidak tersedia, unduhan awal dilewati (aplikasi offline).',
        );
      }
      if (!mounted) return;

      L.i('Menjalankan layanan pembersihan data jika diperlukan.');
      PembersihanDataService().jalankanJikaPerlu();

      _updateLoading("Mengecek koneksi internet...");
      isOnline = await _koneksiService.cekKoneksi();
      L.i('Pengecekan koneksi internet selesai. Status online: $isOnline.');
      if (!mounted) return;

      _updateLoading("Selesai, membuka aplikasi...");
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e, s) {
      L.e(
        'Terjadi error kritis selama proses inisialisasi aplikasi. Proses dihentikan. Error: $e $s',
      );
      _updateLoading("Terjadi error, silakan mulai ulang aplikasi.");
      await Future.delayed(const Duration(seconds: 5));
    }

    if (!mounted) {
      L.w('Batal navigasi ke HalamanUtama karena widget tidak ter-mount.');
      return;
    }
    L.i(
      'Semua proses inisialisasi selesai. Menavigasi ke HalamanUtama dengan status offline: ${!isOnline}',
    );
    unawaited(
      Nav.toReplacement(context, Home(isOffline: !isOnline)).catchError((
        Object e,
        StackTrace s,
      ) {
        L.e('Navigasi gagal: $e $s');
        return null;
      }),
    );
  }

  @override
  void dispose() {
    L.i('Membersihkan resource. AnimationController akan di-dispose.');
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    L.i('Membangun UI untuk SplashScreen.');
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
                    L.i('Mendeteksi mode tema. Dark mode: $isDarkMode.');
                    final logoAsset = isDarkMode
                        ? 'assets/logo/ikon/ikon_apk.png'
                        : 'assets/logo/ikon/ikon_apk.png';
                    L.i('Memilih aset logo berdasarkan tema: $logoAsset.');
                    return Image.asset(logoAsset, width: 150);
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Admin WiFi',
                  style: GoogleFonts.roboto(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  _loadingMessage,
                  style: GoogleFonts.openSans(fontSize: 14),
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
                      style: GoogleFonts.openSans(color: Colors.white),
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
