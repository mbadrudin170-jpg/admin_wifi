// path : lib/splash_screen.dart
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:admin_wifi/firebase_options.dart';
import 'package:admin_wifi/halaman_utama.dart';
import 'package:admin_wifi/services/notifikasi_servis.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/services/cek_koneksi_internet.dart';
import 'package:admin_wifi/data/services/sinkronisasi_database.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _loadingMessage = "Memulai aplikasi...";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndNavigate();
    });
  }

  Future<void> _initializeAndNavigate() async {
    bool isOnline = false;

    try {
      // [OPTIMASI PERFORMA] Langkah 0: Inisialisasi Firebase
      setState(() => _loadingMessage = "Menghubungkan ke layanan Google...");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // 1. Inisialisasi Lokal (Cepat)
      setState(() => _loadingMessage = "Menginisialisasi zona waktu...");
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

      setState(() => _loadingMessage = "Menginisialisasi format tanggal...");
      await initializeDateFormatting('id_ID', null);

      // 2. Inisialisasi Servis Kritis
      setState(() => _loadingMessage = "Mempersiapkan notifikasi...");
      final notifikasiServis = NotifikasiServis();
      await notifikasiServis.inisialisasi();
      await notifikasiServis.requestPermissions();

      setState(() => _loadingMessage = "Membuka database lokal...");
      await DatabaseHelper.instance.database;

      // 3. Pengecekan Koneksi & Sinkronisasi Data
      setState(() => _loadingMessage = "Mengecek koneksi internet...");
      isOnline = await KoneksiInternetService.cekKoneksi();

      if (isOnline) {
        // diubah: menjalankan proses sinkronisasi jika online
        setState(() => _loadingMessage = "Memeriksa & sinkronisasi data...");
        try {
          await LayananSinkronisasi().sinkronisasiData();
          setState(() => _loadingMessage = "Sinkronisasi data selesai.");
        } catch (e) {
          debugPrint("Error saat sinkronisasi: $e");
          setState(
            () => _loadingMessage = "Gagal sinkronisasi, melanjutkan...",
          );
        }
      } else {
        setState(
          () => _loadingMessage = "Mode offline, melewati sinkronisasi...",
        );
      }

      setState(() => _loadingMessage = "Selesai, membuka aplikasi...");
      await Future.delayed(const Duration(milliseconds: 250));
    } catch (e) {
      debugPrint("Error saat inisialisasi: $e");
      setState(() => _loadingMessage = "Terjadi error, tetap mencoba...");
    }

    // 5. Navigasi
    if (!mounted) return;

    // diubah: Mengirim status koneksi ke HalamanUtama dan menghapus blok .then()
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
            const FlutterLogo(size: 80),
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
