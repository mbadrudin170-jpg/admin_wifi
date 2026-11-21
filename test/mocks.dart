// Kelas mock manual memakai `package:mocktail` (tanpa codegen).
// Berkas ini BUKAN file test (bukan `*_test.dart`) sehingga tidak dijalankan
// langsung oleh `flutter test`; import dari file test dengan `import '../mocks.dart';`.
//
// Catatan: kelas dengan hanya static method (mis. `SharedPrefService`,
// `ParserUtil`, `L`) TIDAK bisa di-mock dengan mocktail; abstraksikan ke
// kelas/instance eksternal bila perlu di-mock (lihat skill `aturan-testing`
// bagian 4).

import 'package:admin_wifi/data/operasi/operasi_dasar.dart';
import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/data/operasi/versi_apk_user_operasi.dart';
import 'package:admin_wifi/db/sqlite/sqflite.dart';
import 'package:admin_wifi/services/notifikasi/notifikasi_servis.dart';
import 'package:admin_wifi/utils/sync_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/widgets.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mock untuk plugin notifikasi lokal agar dapat diinjeksikan ke
// `NotifikasiServis.internal` pada pengujian unit.
class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockDatabaseHelper extends Mock implements DatabaseHelper {}

class MockSyncManager extends Mock implements SyncManager {}

class MockOperasiDasar extends Mock implements OperasiDasar {}

class MockPaketOperasi extends Mock implements PaketOperasi {}

class MockVersiApkUserOperasi extends Mock implements VersiApkUserOperasi {}

class MockNotifikasiServis extends Mock implements NotifikasiServis {}

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}
