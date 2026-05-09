// path: lib/splash_screen.dart

import 'dart:async';
import 'package:admin_wifi/data/operasi/pengaturan_operasi.dart';
import 'package:admin_wifi/data/sync/unduhan_awal.dart';
import 'package:admin_wifi/services/servis_sinkronisasi.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:developer' as developer;

import 'package:admin_wifi/firebase_options.dart';
import 'package:admin_wifi/halaman_utama.dart';
import 'package:admin_wifi/services/notifikasi_servis.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/services/cek_koneksi_internet.dart';
import 'package:admin_wifi/services/pembersihan_data_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _loadingMessage = "Memulai aplikasi...";
  final KoneksiInternetService _koneksiService = KoneksiInternetService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndNavigate();
    });
  }

  void _updateLoading(String message) {
    if (!mounted) return;
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
      await notifikasiServis.requestPermissions();
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

      final sinkronisasiService = Provider.of<SinkronisasiService>(
        context,
        listen: false,
      );

      if (isOnline) {
        _updateLoading(
          "Memeriksa & mengunduh data...",
        ); // diubah: Pesan disesuaikan
        try {
          // diubah: Memanggil metode yang benar untuk proses unduh.
          await sinkronisasiService.jalankanProsesUnduh();
          _updateLoading("Unduh data selesai."); // diubah: Pesan disesuaikan
        } catch (e, s) {
          developer.log(
            'Gagal mengunduh data',
            error: e,
            stackTrace: s,
          ); // diubah: Pesan disesuaikan
          _updateLoading(
            "Gagal mengunduh data, melanjutkan offline...",
          ); // diubah: Pesan disesuaikan
        }
      }

      try {
        final pengaturan = await PengaturanOperasi().getPengaturan();
        // diubah: Memanggil metode yang benar untuk unduh otomatis.
        sinkronisasiService.mulaiUnduhOtomatis(
          interval: Duration(hours: pengaturan.intervalSinkronisasiOtomatis),
        );
      } catch (e) {
        developer.log('Gagal memulai unduh otomatis: $e', error: e);
        // diubah: Memanggil metode yang benar untuk unduh otomatis.
        sinkronisasiService.mulaiUnduhOtomatis(
          interval: const Duration(hours: 24),
        );
      }

      _updateLoading("Selesai, membuka aplikasi...");
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e, s) {
      developer.log('Inisialisasi gagal total', error: e, stackTrace: s);
      _updateLoading("Terjadi error, silakan mulai ulang aplikasi.");
      await Future.delayed(const Duration(seconds: 5));
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HalamanUtama(isOffline: !isOnline),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
    );
  }
}
