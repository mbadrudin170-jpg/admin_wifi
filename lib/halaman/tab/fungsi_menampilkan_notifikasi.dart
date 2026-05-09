// Path: lib/halaman/tab/fungsi_menampilkan_notifikasi.dart
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
    '🔔 [NotifikasiServis] -> [onDidReceiveNotificationResponse] -> Notifikasi di-tap. '
    'ID: ${notificationResponse.id}, Payload: ${notificationResponse.payload}',
    name: 'Notifikasi.Interaction',
  );
}

class NotifikasiServis {
  final FlutterLocalNotificationsPlugin plugin;

  NotifikasiServis() : plugin = FlutterLocalNotificationsPlugin();

  @visibleForTesting
  NotifikasiServis.internal(this.plugin);

  Future<void> inisialisasi() async {
    developer.log(
      '🏗️ [NotifikasiServis] -> [inisialisasi] -> Memulai konfigurasi plugin',
      name: 'Notifikasi.Lifecycle',
    );
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

      developer.log(
        '✅ [NotifikasiServis] -> [inisialisasi] -> Berhasil. Timezone: Asia/Jakarta',
        name: 'Notifikasi.Success',
      );
    } catch (e, s) {
      developer.log(
        '❌ [NotifikasiServis] -> [inisialisasi] -> Error',
        name: 'Notifikasi.Error',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<bool> requestPermissions() async {
    developer.log(
      '🔐 [NotifikasiServis] -> [requestPermissions] -> Meminta izin ke sistem',
      name: 'Notifikasi.Permission',
    );
    try {
      bool? androidResult;
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      if (androidImplementation != null) {
        androidResult = await androidImplementation
            .requestNotificationsPermission();
        developer.log(
          '🤖 [NotifikasiServis] -> Permission Android: $androidResult',
          name: 'Notifikasi.Permission',
        );
      }

      bool? iosResult;
      final IOSFlutterLocalNotificationsPlugin? iOSImplementation = plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (iOSImplementation != null) {
        iosResult = await iOSImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        developer.log(
          '🍎 [NotifikasiServis] -> Permission iOS: $iosResult',
          name: 'Notifikasi.Permission',
        );
      }

      final bool finalResult = (androidResult ?? false) || (iosResult ?? false);
      developer.log(
        '📊 [NotifikasiServis] -> Hasil akhir izin: $finalResult',
        name: 'Notifikasi.Permission',
      );
      return finalResult;
    } catch (e, s) {
      developer.log(
        '❌ [NotifikasiServis] -> [requestPermissions] -> Gagal meminta izin',
        name: 'Notifikasi.Error',
        error: e,
        stackTrace: s,
      );
      return false;
    }
  }

  Future<void> jadwalNotifikasi({
    required int id,
    required String title,
    required String body,
    required DateTime jadwal,
  }) async {
    developer.log(
      '📅 [NotifikasiServis] -> [jadwalNotifikasi] -> Mencoba menjadwalkan. ID: $id, Judul: $title, Waktu: $jadwal',
      name: 'Notifikasi.Action',
    );
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

      developer.log(
        '✅ [NotifikasiServis] -> [jadwalNotifikasi] -> Sukses dijadwalkan untuk ID: $id',
        name: 'Notifikasi.Success',
      );
    } catch (e, s) {
      developer.log(
        '❌ [NotifikasiServis] -> [jadwalNotifikasi] -> Gagal menjadwalkan ID: $id',
        name: 'Notifikasi.Error',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> batalNotifikasi(int id) async {
    developer.log(
      '🚫 [NotifikasiServis] -> [batalNotifikasi] -> Membatalkan ID: $id',
      name: 'Notifikasi.Action',
    );
    try {
      await plugin.cancel(id: id);
      developer.log(
        '🗑️ [NotifikasiServis] -> [batalNotifikasi] -> Sukses dibatalkan untuk ID: $id',
        name: 'Notifikasi.Success',
      );
    } catch (e, s) {
      developer.log(
        '❌ [NotifikasiServis] -> [batalNotifikasi] -> Gagal membatalkan ID: $id',
        name: 'Notifikasi.Error',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> tampilkanNotifikasiLangsung({
    required int id,
    required String title,
    required String body,
  }) async {
    developer.log(
      '⚡ [NotifikasiServis] -> [tampilkanNotifikasiLangsung] -> Menampilkan sekarang. ID: $id, Judul: $title',
      name: 'Notifikasi.Action',
    );
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

      developer.log(
        '✅ [NotifikasiServis] -> [tampilkanNotifikasiLangsung] -> Sukses muncul. ID: $id',
        name: 'Notifikasi.Success',
      );
    } catch (e, s) {
      developer.log(
        '❌ [NotifikasiServis] -> [tampilkanNotifikasiLangsung] -> Gagal memunculkan ID: $id',
        name: 'Notifikasi.Error',
        error: e,
        stackTrace: s,
      );
    }
  }
}
