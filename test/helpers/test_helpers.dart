// path: test/helpers/test_helpers.dart
import 'package:admin_wifi/data/operasi/versi_apk_user_operasi.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/data/sync/unggah_data.dart';
import 'package:admin_wifi/services/cek_koneksi_internet.dart';
import 'package:admin_wifi/utils/sync_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart';

// Anotasi ini memberitahu build_runner untuk membuat file `test_helpers.mocks.dart`
// yang berisi kelas-kelas mock dari daftar yang diberikan.
@GenerateMocks([
  // Mocks untuk database dan firestore
  DatabaseHelper,
  Database,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  WriteBatch,
  
  // Mocks untuk service dan operasi lain
  LayananUnggahData,
  KoneksiInternetService,
  SyncManager,
  VersiApkUserOperasi,
])
void main() {
  // File ini tidak perlu memiliki implementasi `main`.
  // Ini hanya digunakan sebagai titik konfigurasi untuk `build_runner`.
}
