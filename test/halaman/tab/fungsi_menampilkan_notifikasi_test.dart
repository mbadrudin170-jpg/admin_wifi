// path: test/halaman/tab/fungsi_menampilkan_notifikasi_test.dart
// diubah: Memperbaiki stubbing untuk resolvePlatformSpecificImplementation dengan mencocokkan tipe generik secara spesifik.

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
  TestWidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

  late NotifikasiServis notifikasiServis;
  late MockFlutterLocalNotificationsPlugin mockPlugin;
  late MockAndroidFlutterLocalNotificationsPlugin mockAndroidPlugin;
  late MockIOSFlutterLocalNotificationsPlugin mockIOSPlugin;

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    mockAndroidPlugin = MockAndroidFlutterLocalNotificationsPlugin();
    mockIOSPlugin = MockIOSFlutterLocalNotificationsPlugin();
    notifikasiServis = NotifikasiServis.internal(mockPlugin);

    // diubah: Stubbing yang benar untuk method dengan parameter tipe generik.
    // Kita harus memastikan mockito mengembalikan tipe yang benar untuk setiap pemanggilan.
    when(
      mockPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >(),
    ).thenReturn(mockAndroidPlugin);
    when(
      mockPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >(),
    ).thenReturn(mockIOSPlugin);
  });

  group('Pengujian NotifikasiServis', () {
    test(
      'inisialisasi harus memanggil metode initialize pada plugin',
      () async {
        when(
          mockPlugin.initialize(
            settings: anyNamed('settings'),
            onDidReceiveNotificationResponse: anyNamed(
              'onDidReceiveNotificationResponse',
            ),
            onDidReceiveBackgroundNotificationResponse: anyNamed(
              'onDidReceiveBackgroundNotificationResponse',
            ),
          ),
        ).thenAnswer((_) async => true);

        await notifikasiServis.inisialisasi();

        verify(
          mockPlugin.initialize(
            settings: anyNamed('settings'),
            onDidReceiveNotificationResponse: anyNamed(
              'onDidReceiveNotificationResponse',
            ),
            onDidReceiveBackgroundNotificationResponse: anyNamed(
              'onDidReceiveBackgroundNotificationResponse',
            ),
          ),
        ).called(1);
      },
    );

    group('requestPermissions', () {
      test('harus mengembalikan true jika izin Android diberikan', () async {
        when(
          mockAndroidPlugin.requestNotificationsPermission(),
        ).thenAnswer((_) async => true);
        when(
          mockIOSPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ),
        ).thenAnswer((_) async => false);

        final hasil = await notifikasiServis.requestPermissions();

        expect(hasil, isTrue);
      });

      test('harus mengembalikan true jika izin iOS diberikan', () async {
        when(
          mockAndroidPlugin.requestNotificationsPermission(),
        ).thenAnswer((_) async => false);
        when(
          mockIOSPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ),
        ).thenAnswer((_) async => true);

        final hasil = await notifikasiServis.requestPermissions();

        expect(hasil, isTrue);
      });

      test('harus mengembalikan false jika semua izin ditolak', () async {
        when(
          mockAndroidPlugin.requestNotificationsPermission(),
        ).thenAnswer((_) async => false);
        when(
          mockIOSPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ),
        ).thenAnswer((_) async => false);

        final hasil = await notifikasiServis.requestPermissions();

        expect(hasil, isFalse);
      });

      test('harus mengembalikan false jika terjadi error', () async {
        when(
          mockAndroidPlugin.requestNotificationsPermission(),
        ).thenThrow(Exception('Test Error'));
        when(
          mockIOSPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ),
        ).thenAnswer((_) async => false);

        final hasil = await notifikasiServis.requestPermissions();

        expect(hasil, isFalse);
      });
    });

    test(
      'jadwalNotifikasi harus memanggil "zonedSchedule" pada plugin',
      () async {
        when(
          mockPlugin.zonedSchedule(
            id: anyNamed('id'),
            title: anyNamed('title'),
            body: anyNamed('body'),
            scheduledDate: anyNamed('scheduledDate'),
            notificationDetails: anyNamed('notificationDetails'),
            androidScheduleMode: anyNamed('androidScheduleMode'),
          ),
        ).thenAnswer((_) async {});

        final jadwal = DateTime.now().add(const Duration(seconds: 10));

        await notifikasiServis.jadwalNotifikasi(
          id: 1,
          title: 'Tes Judul',
          body: 'Tes Isi',
          jadwal: jadwal,
        );

        verify(
          mockPlugin.zonedSchedule(
            id: 1,
            title: 'Tes Judul',
            body: 'Tes Isi',
            scheduledDate: anyNamed('scheduledDate'),
            notificationDetails: anyNamed('notificationDetails'),
            androidScheduleMode: AndroidScheduleMode.inexact,
          ),
        ).called(1);
      },
    );

    test(
      'batalNotifikasi harus memanggil metode "cancel" pada plugin',
      () async {
        when(mockPlugin.cancel(id: anyNamed('id'))).thenAnswer((_) async {});

        await notifikasiServis.batalNotifikasi(123);

        verify(mockPlugin.cancel(id: 123)).called(1);
      },
    );

    test(
      'tampilkanNotifikasiLangsung harus memanggil metode "show" pada plugin',
      () async {
        when(
          mockPlugin.show(
            id: anyNamed('id'),
            title: anyNamed('title'),
            body: anyNamed('body'),
            notificationDetails: anyNamed('notificationDetails'),
          ),
        ).thenAnswer((_) async {});

        await notifikasiServis.tampilkanNotifikasiLangsung(
          id: 456,
          title: 'Notif Langsung',
          body: 'Ini notifikasi langsung.',
        );

        verify(
          mockPlugin.show(
            id: 456,
            title: 'Notif Langsung',
            body: 'Ini notifikasi langsung.',
            notificationDetails: anyNamed('notificationDetails'),
          ),
        ).called(1);
      },
    );
  });
}
