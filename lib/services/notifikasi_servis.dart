// path: lib/services/notifikasi_servis.dart
// diubah: Memperbaiki semua pemanggilan metode ke plugin untuk menggunakan argumen bernama yang benar.
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotifikasiServis {
  final FlutterLocalNotificationsPlugin plugin;

  NotifikasiServis() : plugin = FlutterLocalNotificationsPlugin();

  @visibleForTesting
  NotifikasiServis.internal(this.plugin);

  Future<void> inisialisasi() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await plugin.initialize(
      settings: settings, // diubah: menggunakan argumen bernama
      onDidReceiveNotificationResponse: (response) {
        developer.log(
          'Notifikasi diterima dengan payload: \${response.payload}',
        );
      },
    );
    developer.log('Layanan Notifikasi berhasil diinisialisasi.');
  }

  Future<NotificationAppLaunchDetails?> getDetailPeluncuranNotifikasi() async {
    return await plugin.getNotificationAppLaunchDetails();
  }

  Future<void> tampilkanNotifikasiLangsung({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'notifikasi_langsung',
      'Notifikasi Langsung',
      channelDescription: 'Channel untuk notifikasi yang ditampilkan segera.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    await plugin.show(
      id: id, // diubah: menggunakan argumen bernama
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  Future<void> jadwalNotifikasi({
    required int id,
    required String title,
    required String body,
    required DateTime jadwal,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'notifikasi_terjadwal',
      'Notifikasi Terjadwal',
      channelDescription: 'Channel untuk notifikasi yang dijadwalkan.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await plugin.zonedSchedule(
      id: id, // diubah: menggunakan argumen bernama
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(jadwal, tz.local),
      notificationDetails: notificationDetails,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      // dihapus: uiLocalNotificationDateInterpretation karena tidak ada di signature utama
    );
  }

  Future<void> perbaruiJadwalNotifikasi({
    required int id,
    required String title,
    required String body,
    required DateTime jadwal,
    String? payload,
  }) async {
    await batalNotifikasi(id);
    await jadwalNotifikasi(
      id: id,
      title: title,
      body: body,
      jadwal: jadwal,
      payload: payload,
    );
  }

  Future<void> batalNotifikasi(int id) async {
    await plugin.cancel(id: id); // diubah: menggunakan argumen bernama
  }

  Future<void> batalSemuaNotifikasi() async {
    await plugin.cancelAll();
  }
}
