// Path: lib/halaman/tab/fungsi_menampilkan_notifikasi.dart
// diubah: Mengganti operator logika dari && menjadi || untuk izin.
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:developer' as developer;

@pragma('vm:entry-point')
void onDidReceiveNotificationResponse(
  NotificationResponse notificationResponse,
) async {
  developer.log(
    'Notifikasi di-tap: ID=${notificationResponse.id}, '
    'Payload=${notificationResponse.payload}',
    name: 'NotifikasiServis',
  );
  // TODO: Implementasikan logika navigasi atau aksi lainnya
}

class NotifikasiServis {
  final FlutterLocalNotificationsPlugin plugin;

  NotifikasiServis() : plugin = FlutterLocalNotificationsPlugin();

  @visibleForTesting
  NotifikasiServis.internal(this.plugin);

  Future<void> inisialisasi() async {
    try {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings darwinInitializationSettings =
          DarwinInitializationSettings();

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: androidInitializationSettings,
            iOS: darwinInitializationSettings,
          );

      await plugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
        onDidReceiveBackgroundNotificationResponse:
            onDidReceiveNotificationResponse,
      );

      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      developer.log('Timezone lokal diatur ke Asia/Jakarta.', name: 'NotifikasiServis');
      developer.log('Inisialisasi berhasil', name: 'NotifikasiServis');
    } catch (e, s) {
      developer.log('Error inisialisasi', name: 'NotifikasiServis', error: e, stackTrace: s);
    }
  }

  Future<bool> requestPermissions() async {
    try {
      bool? androidResult;
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          plugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      if (androidImplementation != null) {
        androidResult = await androidImplementation.requestNotificationsPermission();
      }

      bool? iosResult;
      final IOSFlutterLocalNotificationsPlugin? iOSImplementation =
          plugin.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();
      if (iOSImplementation != null) {
        iosResult = await iOSImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
      developer.log('Permintaan izin selesai.', name: 'NotifikasiServis');
      // diubah: Logika diubah dari && ke ||
      return (androidResult ?? false) || (iosResult ?? false);
    } catch (e, s) {
      developer.log('Gagal meminta izin notifikasi', name: 'NotifikasiServis', error: e, stackTrace: s);
      return false;
    }
  }

  Future<void> jadwalNotifikasi({
    required int id,
    required String title,
    required String body,
    required DateTime jadwal,
  }) async {
    try {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
            'id_kadaluarsa_paket',
            'Notifikasi Kadaluarsa Paket',
            channelDescription:
                'Channel untuk notifikasi paket yang akan berakhir',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false,
          );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
      );

      await plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(jadwal, tz.local),
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexact,
      );

      developer.log('Notifikasi dijadwalkan - ID: $id, Waktu: $jadwal', name: 'NotifikasiServis');
    } catch (e, s) {
      developer.log('Error jadwal notifikasi', name: 'NotifikasiServis', error: e, stackTrace: s);
    }
  }

  Future<void> batalNotifikasi(int id) async {
    try {
      await plugin.cancel(id: id);
      developer.log('Notifikasi dibatalkan - ID: $id', name: 'NotifikasiServis');
    } catch (e, s) {
      developer.log('Error membatalkan notifikasi', name: 'NotifikasiServis', error: e, stackTrace: s);
    }
  }

  Future<void> tampilkanNotifikasiLangsung({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
            'id_notifikasi_langsung',
            'Notifikasi Langsung',
            channelDescription:
                'Channel untuk notifikasi yang ditampilkan langsung',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
          );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
      );

      await plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
      );

      developer.log('Notifikasi langsung ditampilkan - ID: $id', name: 'NotifikasiServis');
    } catch (e, s) {
      developer.log('Error menampilkan notifikasi langsung', name: 'NotifikasiServis', error: e, stackTrace: s);
    }
  }
}
