// path: test/halaman/tab/fungsi_menampilkan_notifikasi_test.dart
// diperbaiki: Menambahkan mock yang benar untuk permission_handler.

import 'package:admin_wifi/services/notifikasi_servis.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:permission_handler/permission_handler.dart';

import 'fungsi_menampilkan_notifikasi_test.mocks.dart';

// Definisikan antarmuka abstrak untuk pembungkus statis
abstract class PermissionHandlerWrapper {
  Future<PermissionStatus> get notificationStatus;
  Future<Map<Permission, PermissionStatus>> requestPermissions(
      List<Permission> permissions);
}

// Buat mock dari antarmuka tersebut
@GenerateMocks([FlutterLocalNotificationsPlugin, PermissionHandlerWrapper])
void main() {
  late NotifikasiServis notifikasiServis;
  late MockFlutterLocalNotificationsPlugin mockPlugin;
  late MockPermissionHandlerWrapper mockPermissionHandler;

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    mockPermissionHandler = MockPermissionHandlerWrapper();
    notifikasiServis = NotifikasiServis.test(mockPlugin, mockPermissionHandler);
  });

  group('Pengujian NotifikasiServis', () {
    test('inisialisasi harus memanggil metode initialize pada plugin', () async {
      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('notification_icon'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      );

      when(mockPlugin.initialize(
        any,
        onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse'),
      )).thenAnswer((_) async => true);

      await notifikasiServis.inisialisasi();

      verify(mockPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse'),
      )).called(1);
    });

    test('requestPermissions harus mengembalikan true jika izin Android diberikan', () async {
      // Atur mock untuk status dan permintaan
      when(mockPermissionHandler.notificationStatus)
          .thenAnswer((_) async => PermissionStatus.granted);
          
      final result = await notifikasiServis.requestPermissions();

      expect(result, isTrue);
      verify(mockPermissionHandler.notificationStatus).called(1);
      verifyNever(mockPermissionHandler.requestPermissions(any));
    });

    test('requestPermissions harus mengembalikan true jika izin iOS diberikan', () async {
      // Atur mock untuk status dan permintaan
      when(mockPermissionHandler.notificationStatus)
          .thenAnswer((_) async => PermissionStatus.denied);
      when(mockPermissionHandler.requestPermissions([Permission.notification]))
          .thenAnswer((_) async => {Permission.notification: PermissionStatus.granted});

      final result = await notifikasiServis.requestPermissions();

      expect(result, isTrue);
      verify(mockPermissionHandler.notificationStatus).called(1);
      verify(mockPermissionHandler.requestPermissions([Permission.notification]))
          .called(1);
    });
    
    test('requestPermissions harus mengembalikan false jika semua izin ditolak', () async {
       when(mockPermissionHandler.notificationStatus)
          .thenAnswer((_) async => PermissionStatus.denied);
      when(mockPermissionHandler.requestPermissions([Permission.notification]))
          .thenAnswer((_) async => {Permission.notification: PermissionStatus.denied});

      final result = await notifikasiServis.requestPermissions();

      expect(result, isFalse);
    });

    test('requestPermissions harus mengembalikan false jika terjadi error', () async {
      when(mockPermissionHandler.notificationStatus).thenThrow(Exception('Test Error'));

      final result = await notifikasiServis.requestPermissions();

      expect(result, isFalse);
    });

  });
}
