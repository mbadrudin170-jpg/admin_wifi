// path: test/services/notifikasi_servis_test.dart
// diubah: Konversi dari Mockito (@GenerateMocks + build_runner) ke Mocktail (mock manual).
// diubah: Mock plugin dipindah ke test/mocks.dart; registerFallbackValue didaftarkan di setUpAll.

import 'package:admin_wifi/services/notifikasi/notifikasi_servis.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../mocks.dart';

void main() {
  // Inisialisasi awal
  TestWidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

  late NotifikasiServis notifikasiServis;
  late MockFlutterLocalNotificationsPlugin mockPlugin;

  setUpAll(() {
    // Nilai fallback wajib didaftarkan untuk tipe non-nullable custom yang
    // dipakai dengan `any(named: ...)`.
    registerFallbackValue(const InitializationSettings());
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(tz.TZDateTime(tz.local, 2026));
    registerFallbackValue(AndroidScheduleMode.inexactAllowWhileIdle);
  });

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    // Gunakan konstruktor internal untuk injeksi mock
    notifikasiServis = NotifikasiServis.internal(mockPlugin);
  });

  group('Pengujian NotifikasiServis', () {
    test(
      'inisialisasi harus memanggil metode initialize pada plugin',
      () async {
        // Arrange
        when(
          () => mockPlugin.initialize(
            settings: any(named: 'settings'),
            onDidReceiveNotificationResponse: any(
              named: 'onDidReceiveNotificationResponse',
            ),
          ),
        ).thenAnswer((_) async => true);

        // Act
        await notifikasiServis.inisialisasi();

        // Assert
        verify(
          () => mockPlugin.initialize(
            settings: any(named: 'settings'),
            onDidReceiveNotificationResponse: any(
              named: 'onDidReceiveNotificationResponse',
            ),
          ),
        ).called(1);
      },
    );

    test(
      'tampilkanNotifikasiLangsung harus memanggil metode "show" dengan benar',
      () async {
        // Arrange
        when(
          () => mockPlugin.show(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            notificationDetails: any(named: 'notificationDetails'),
            payload: any(named: 'payload'),
          ),
        ).thenAnswer((_) async {});

        // Act
        await notifikasiServis.tampilkanNotifikasiLangsung(
          id: 1,
          title: 'Judul',
          body: 'Isi',
          payload: 'data-payload',
        );

        // Assert
        verify(
          () => mockPlugin.show(
            id: 1,
            title: 'Judul',
            body: 'Isi',
            notificationDetails: any(named: 'notificationDetails'),
            payload: 'data-payload',
          ),
        ).called(1);
      },
    );

    test(
      'jadwalNotifikasi harus memanggil "zonedSchedule" dengan benar',
      () async {
        // Arrange
        when(
          () => mockPlugin.zonedSchedule(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            payload: any(named: 'payload'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
          ),
        ).thenAnswer((_) async {});

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
        verify(
          () => mockPlugin.zonedSchedule(
            id: 2,
            title: 'Judul Jadwal',
            body: 'Isi Jadwal',
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            payload: 'jadwal-payload',
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          ),
        ).called(1);
      },
    );

    test(
      'batalNotifikasi harus memanggil "cancel" dengan id yang benar',
      () async {
        // Arrange
        when(
          () => mockPlugin.cancel(id: any(named: 'id')),
        ).thenAnswer((_) async {});

        // Act
        await notifikasiServis.batalNotifikasi(3);

        // Assert
        verify(() => mockPlugin.cancel(id: 3)).called(1);
      },
    );

    test(
      'perbaruiJadwalNotifikasi harus memanggil "cancel" dan "zonedSchedule" ',
      () async {
        // Arrange
        when(
          () => mockPlugin.cancel(id: any(named: 'id')),
        ).thenAnswer((_) async {});
        when(
          () => mockPlugin.zonedSchedule(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            payload: any(named: 'payload'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
          ),
        ).thenAnswer((_) async {});

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
        verify(() => mockPlugin.cancel(id: 4)).called(1);
        verify(
          () => mockPlugin.zonedSchedule(
            id: 4,
            title: 'Judul Baru',
            body: 'Isi Baru',
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            payload: 'perbarui-payload',
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          ),
        ).called(1);
      },
    );
  });
}
