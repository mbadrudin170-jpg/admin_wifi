// path: test/services/notifikasi_servis_test.dart
// diubah: Perbaikan total dengan anotasi, injeksi dependensi, dan argumen bernama yang benar.
// diubah: Menghapus impor yang tidak digunakan.
// ignore_for_file: prefer_const_constructors

import 'package:admin_wifi/services/notifikasi/notifikasi_servis.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Impor file mock yang akan dibuat
import 'notifikasi_servis_test.mocks.dart';

@GenerateMocks([FlutterLocalNotificationsPlugin])
void main() {
  // Inisialisasi awal
  TestWidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

  late NotifikasiServis notifikasiServis;
  late MockFlutterLocalNotificationsPlugin mockPlugin;

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    // Gunakan konstruktor internal untuk injeksi mock
    notifikasiServis = NotifikasiServis.internal(mockPlugin);
  });

  group('Pengujian NotifikasiServis', () {
    test('inisialisasi harus memanggil metode initialize pada plugin', () async {
      // Arrange
      when(mockPlugin.initialize(
        settings: anyNamed('settings'),
        onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse'),
      )).thenAnswer((_) async => true);
      when(mockPlugin.getNotificationAppLaunchDetails())
          .thenAnswer((_) async => const NotificationAppLaunchDetails(false));

      // Act
      await notifikasiServis.inisialisasi();

      // Assert
      verify(mockPlugin.initialize(
        settings: anyNamed('settings'),
        onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse'),
      )).called(1);
    });

    test('tampilkanNotifikasiLangsung harus memanggil metode "show" dengan benar', () async {
      // Arrange
      when(mockPlugin.show(
        id: anyNamed('id'), 
        title: anyNamed('title'), 
        body: anyNamed('body'), 
        notificationDetails: anyNamed('notificationDetails'), 
        payload: anyNamed('payload')
      )).thenAnswer((_) async {});

      // Act
      await notifikasiServis.tampilkanNotifikasiLangsung(
        id: 1,
        title: 'Judul',
        body: 'Isi',
        payload: 'data-payload',
      );

      // Assert
      verify(mockPlugin.show(
        id: 1, 
        title: 'Judul', 
        body: 'Isi', 
        notificationDetails: anyNamed('notificationDetails'), 
        payload: 'data-payload'
      )).called(1);
    });

    test('jadwalNotifikasi harus memanggil "zonedSchedule" dengan benar', () async {
      // Arrange
      when(mockPlugin.zonedSchedule(
        id: anyNamed('id'),
        title: anyNamed('title'),
        body: anyNamed('body'),
        scheduledDate: anyNamed('scheduledDate'),
        notificationDetails: anyNamed('notificationDetails'),
        payload: anyNamed('payload'),
        androidScheduleMode: anyNamed('androidScheduleMode'),
      )).thenAnswer((_) async {});

      final jadwal = DateTime.now().add(const Duration(seconds: 5));

      // Act
      await notifikasiServis.jadwalNotifikasi(
        id: 2,
        title: 'Judul Jadwal',
        body: 'Isi Jadwal',
        jadwal: jadwal,
        payload: 'jadwal-payload',
      );

      // Assert
      verify(mockPlugin.zonedSchedule(
        id: 2, 
        title: 'Judul Jadwal', 
        body: 'Isi Jadwal', 
        scheduledDate: anyNamed('scheduledDate'), 
        notificationDetails: anyNamed('notificationDetails'),
        payload: 'jadwal-payload',
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      )).called(1);
    });

    test('batalNotifikasi harus memanggil "cancel" dengan id yang benar', () async {
      // Arrange
      when(mockPlugin.cancel(id: anyNamed('id'))).thenAnswer((_) async {});

      // Act
      await notifikasiServis.batalNotifikasi(3);

      // Assert
      verify(mockPlugin.cancel(id: 3)).called(1);
    });

    test('perbaruiJadwalNotifikasi harus memanggil "cancel" dan "zonedSchedule" ', () async {
      // Arrange
      when(mockPlugin.cancel(id: anyNamed('id'))).thenAnswer((_) async {});
      when(mockPlugin.zonedSchedule(
        id: anyNamed('id'),
        title: anyNamed('title'),
        body: anyNamed('body'),
        scheduledDate: anyNamed('scheduledDate'),
        notificationDetails: anyNamed('notificationDetails'),
        payload: anyNamed('payload'),
        androidScheduleMode: anyNamed('androidScheduleMode'),
      )).thenAnswer((_) async {});

      final jadwal = DateTime.now().add(const Duration(minutes: 2));

      // Act
      await notifikasiServis.perbaruiJadwalNotifikasi(
        id: 4,
        title: 'Judul Baru',
        body: 'Isi Baru',
        jadwal: jadwal,
        payload: 'perbarui-payload',
      );

      // Assert
      verify(mockPlugin.cancel(id: 4)).called(1);
      verify(mockPlugin.zonedSchedule(
        id: 4, 
        title: 'Judul Baru', 
        body: 'Isi Baru', 
        scheduledDate: anyNamed('scheduledDate'), 
        notificationDetails: anyNamed('notificationDetails'),
        payload: 'perbarui-payload',
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      )).called(1);
    });
  });
}
