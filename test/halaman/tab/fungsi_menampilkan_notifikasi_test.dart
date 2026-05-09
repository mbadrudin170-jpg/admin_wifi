// path: test/halaman/tab/fungsi_menampilkan_notifikasi_test.dart
// diubah: Merevisi total file test untuk membuatnya lebih robust dengan mock yang benar dan verifikasi.

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:admin_wifi/halaman/tab/fungsi_menampilkan_notifikasi.dart';
import 'fungsi_menampilkan_notifikasi_test.mocks.dart';

@GenerateMocks([
  FlutterLocalNotificationsPlugin,
  AndroidFlutterLocalNotificationsPlugin,
  IOSFlutterLocalNotificationsPlugin,
])
void main() {
  // Inisialisasi awal sekali jalan
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
  });

  late NotifikasiServis notifikasiServis;
  late MockFlutterLocalNotificationsPlugin mockPlugin;
  late MockAndroidFlutterLocalNotificationsPlugin mockAndroidPlugin;
  late MockIOSFlutterLocalNotificationsPlugin mockIOSPlugin;

  // Dijalankan sebelum setiap test
  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    mockAndroidPlugin = MockAndroidFlutterLocalNotificationsPlugin();
    mockIOSPlugin = MockIOSFlutterLocalNotificationsPlugin();
    notifikasiServis = NotifikasiServis.internal(mockPlugin);

    // Stubbing untuk platform-specific implementations
    when(mockPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>(),)
        .thenReturn(mockAndroidPlugin);
    when(mockPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>(),)
        .thenReturn(mockIOSPlugin);
  });

  group('Pengujian NotifikasiServis', () {
    test('inisialisasi harus memanggil metode initialize pada plugin', () async {
      // Arrange
      when(mockPlugin.initialize(
        settings: anyNamed('settings'),
        onDidReceiveNotificationResponse:
            anyNamed('onDidReceiveNotificationResponse'),
        onDidReceiveBackgroundNotificationResponse:
            anyNamed('onDidReceiveBackgroundNotificationResponse'),
      )).thenAnswer((_) async => true);

      // Act
      await notifikasiServis.inisialisasi();

      // Assert
      verify(mockPlugin.initialize(
        settings: anyNamed('settings'),
        onDidReceiveNotificationResponse:
            anyNamed('onDidReceiveNotificationResponse'),
        onDidReceiveBackgroundNotificationResponse:
            anyNamed('onDidReceiveBackgroundNotificationResponse'),
      )).called(1);
    });

    group('requestPermissions', () {
      test('harus mengembalikan true jika izin Android diberikan', () async {
        // Arrange: Simulasikan Android memberi izin, iOS menolak
        when(mockAndroidPlugin.requestNotificationsPermission())
            .thenAnswer((_) async => true);
        when(mockIOSPlugin.requestPermissions(
          alert: anyNamed('alert'),
          badge: anyNamed('badge'),
          sound: anyNamed('sound'),
        )).thenAnswer((_) async => false);

        // Act
        final hasil = await notifikasiServis.requestPermissions();

        // Assert: Hasil harus true karena satu izin diberikan (logika OR)
        expect(hasil, isTrue);
        verify(mockAndroidPlugin.requestNotificationsPermission()).called(1);
        verify(mockIOSPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        )).called(1);
      });

      test('harus mengembalikan true jika izin iOS diberikan', () async {
        // Arrange: Simulasikan Android menolak, iOS memberi izin
        when(mockAndroidPlugin.requestNotificationsPermission())
            .thenAnswer((_) async => false);
        when(mockIOSPlugin.requestPermissions(
          alert: anyNamed('alert'),
          badge: anyNamed('badge'),
          sound: anyNamed('sound'),
        )).thenAnswer((_) async => true);

        // Act
        final hasil = await notifikasiServis.requestPermissions();

        // Assert: Hasil harus true karena satu izin diberikan (logika OR)
        expect(hasil, isTrue);
        verify(mockAndroidPlugin.requestNotificationsPermission()).called(1);
        verify(mockIOSPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        )).called(1);
      });

      test('harus mengembalikan false jika semua izin ditolak', () async {
        // Arrange: Simulasikan keduanya menolak izin
        when(mockAndroidPlugin.requestNotificationsPermission())
            .thenAnswer((_) async => false);
        when(mockIOSPlugin.requestPermissions(
          alert: anyNamed('alert'),
          badge: anyNamed('badge'),
          sound: anyNamed('sound'),
        )).thenAnswer((_) async => false);

        // Act
        final hasil = await notifikasiServis.requestPermissions();

        // Assert
        expect(hasil, isFalse);
      });

      test('harus mengembalikan false jika terjadi error', () async {
        // Arrange: Simulasikan terjadi error saat meminta izin
        when(mockAndroidPlugin.requestNotificationsPermission())
            .thenThrow(Exception('Test Error'));

        // Act
        final hasil = await notifikasiServis.requestPermissions();

        // Assert
        expect(hasil, isFalse);
      });
    });

    // ... tes lainnya tetap sama ...
  });
}
