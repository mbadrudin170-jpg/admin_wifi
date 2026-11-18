// Kelas mock manual memakai `package:mocktail` (tanpa codegen).
// Berkas ini BUKAN file test (bukan `*_test.dart`) sehingga tidak dijalankan
// langsung oleh `flutter test`; import dari file test dengan `import '../mocks.dart';`.
//
// Catatan: kelas dengan hanya static method (mis. `SharedPrefService`,
// `ParserUtil`, `L`) TIDAK bisa di-mock dengan mocktail; abstraksikan ke
// kelas/instance eksternal bila perlu di-mock (lihat skill `pola-testing`
// bagian 4).

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mocktail/mocktail.dart';

// Mock untuk plugin notifikasi lokal agar dapat diinjeksikan ke
// `NotifikasiServis.internal` pada pengujian unit.
class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}
