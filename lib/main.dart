// path: lib/main_prod.dart
import 'package:admin_wifi/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_global_saya/core_shared.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SQLite di Web berjalan lewat sqflite_common_ffi_web (IndexedDB).
  // Factory wajib diset sebelum database pertama dibuka (dokumen resmi).
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  // Di Android Firebase ter-inisialisasi otomatis oleh plugin Gradle
  // (google-services.json); panggilan ini hanya memastikan App default ada.
  // Di Web TIDAK ADA konfigurasi Firebase (tidak ada firebase_options.dart
  // dan index.html tidak memuat SDK), jadi dilewati dan aplikasi berjalan
  // offline — akses Firestore di Web akan gagal jika dipaksa.
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
      L.i('Firebase berhasil diinisialisasi.');
    } catch (e, s) {
      L.e('Firebase gagal diinisialisasi. Error: $e $s');
    }
  } else {
    L.i('Mode Web: Firebase tidak dikonfigurasi; aplikasi berjalan offline.');
  }

  await SharedPrefService.init();

  final container = ProviderContainer();
  L.init(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      // Overlay root manual berada di ATAS MaterialApp (yang menyediakan
      // Localizations/Directionality), jadi keduanya harus dipasang manual
      // di sini:
      // - Localizations: panel log debug memakai `SelectionArea`, yang
      //   membutuhkan MaterialLocalizations (diisi delegasi default
      //   framework, Bahasa Inggris — proyek ini tidak memuat
      //   flutter_localizations).
      // - Directionality: `_Theater` (bagian internal Overlay) mewajibkan
      //   ancestor Directionality.
      child: Localizations(
        locale: const Locale('en'),
        delegates: const [
          DefaultWidgetsLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
        ],
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Overlay(
            initialEntries: [
              OverlayEntry(
                // PengelolaOverlayLogDebug menyisipkan ikon/panel ke Overlay.maybeOf(context);
                // Overlay dibuat di root agar pemanggilannya menemukan ancestor (rootOverlay).
                builder: (context) =>
                    const PengelolaOverlayLogDebug(child: MyApp()),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
