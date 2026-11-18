// path: lib/services/notifikasi_servis.dart
// diubah: Memperbaiki semua pemanggilan metode ke plugin untuk menggunakan argumen bernama yang benar.
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:timezone/timezone.dart' as tz;

class NotifikasiServis {
  final FlutterLocalNotificationsPlugin plugin;

  NotifikasiServis() : plugin = FlutterLocalNotificationsPlugin();

  @visibleForTesting
  NotifikasiServis.internal(this.plugin);

  Future<void> inisialisasi() async {
    L.i('Memulai proses inisialisasi pengaturan notifikasi...');

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    try {
      await plugin.initialize(
        settings: settings, // diubah: menggunakan argumen bernama
        onDidReceiveNotificationResponse: (response) {
          L.i('Notifikasi diklik oleh pengguna. Payload: ${response.payload}');
        },
      );
      L.i('Layanan Notifikasi berhasil diinisialisasi.');
    } catch (e, s) {
      L.e('Gagal melakukan inisialisasi layanan notifikasi Error: $e $s');
    }
  }

  Future<NotificationAppLaunchDetails?> getDetailPeluncuranNotifikasi() async {
    L.i('Memeriksa apakah aplikasi diluncurkan melalui notifikasi...');
    final details = await plugin.getNotificationAppLaunchDetails();

    if (details != null && details.didNotificationLaunchApp) {
      L.i(
        'Aplikasi diluncurkan dari notifikasi dengan ID: ${details.notificationResponse?.id}',
      );
    } else {
      L.i('Aplikasi diluncurkan secara normal (bukan dari notifikasi).');
    }

    return details;
  }

  Future<void> tampilkanNotifikasiLangsung({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    L.i('Mengirim notifikasi langsung (ID: $id, Judul: $title)');

    const androidDetails = AndroidNotificationDetails(
      'notifikasi_langsung',
      'Notifikasi Langsung',
      channelDescription: 'Channel untuk notifikasi yang ditampilkan segera.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    try {
      await plugin.show(
        id: id, // diubah: menggunakan argumen bernama
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload,
      );
      L.i('Notifikasi langsung berhasil ditampilkan di layar.');
    } catch (e, s) {
      L.e('Gagal menampilkan notifikasi langsung Error: $e $s');
    }
  }

  Future<void> jadwalNotifikasi({
    required int id,
    required String title,
    required String body,
    required DateTime jadwal,
    String? payload,
  }) async {
    L.i('Merencanakan notifikasi terjadwal (ID: $id) pada waktu: $jadwal');

    const androidDetails = AndroidNotificationDetails(
      'notifikasi_terjadwal',
      'Notifikasi Terjadwal',
      channelDescription: 'Channel untuk notifikasi yang dijadwalkan.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    try {
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
      L.i('Notifikasi terjadwal berhasil didaftarkan ke sistem.');
    } catch (e, s) {
      L.e('Gagal mendaftarkan jadwal notifikasi Error: $e $s');
    }
  }

  Future<void> perbaruiJadwalNotifikasi({
    required int id,
    required String title,
    required String body,
    required DateTime jadwal,
    String? payload,
  }) async {
    L.i('Memulai pembaruan jadwal notifikasi untuk ID: $id');

    await batalNotifikasi(id);
    await jadwalNotifikasi(
      id: id,
      title: title,
      body: body,
      jadwal: jadwal,
      payload: payload,
    );

    L.i('Pembaruan jadwal selesai dilakukan.');
  }

  Future<void> batalNotifikasi(int id) async {
    L.i('Membatalkan notifikasi aktif/terjadwal dengan ID: $id');
    try {
      await plugin.cancel(id: id); // diubah: menggunakan argumen bernama
      L.i('Notifikasi ID: $id telah dihapus.');
    } catch (e, s) {
      L.e('Gagal membatalkan notifikasi ID: $id Error: $e $s');
    }
  }

  Future<void> batalSemuaNotifikasi() async {
    L.i('Membersihkan semua notifikasi yang ada (aktif maupun terjadwal)...');
    try {
      await plugin.cancelAll();
      L.i('Seluruh notifikasi berhasil dibersihkan.');
    } catch (e, s) {
      L.e('Terjadi kesalahan saat membersihkan semua notifikasi Error: $e $s');
    }
  }
}
