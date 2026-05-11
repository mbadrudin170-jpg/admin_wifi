// path: lib/main_dev.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:admin_wifi/app.dart';
import 'package:admin_wifi/firebase_options_dev.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ditambah: Pemeriksaan untuk mencegah inisialisasi ganda saat Hot Restart.
  // Cukup periksa apakah ada instance, jika tidak ada, inisialisasi.
  // Jika sudah ada, tidak perlu melakukan apa-apa.
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(const MyApp());
}
