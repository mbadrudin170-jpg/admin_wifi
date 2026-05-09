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
    developer.log('[NotifikasiServis]-[inisialisasi] 🔍 : Memulai proses inisialisasi pengaturan notifikasi...');
    
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    try {
      await plugin.initialize(
        settings: settings, // diubah: menggunakan argumen bernama
        onDidReceiveNotificationResponse: (response) {
          developer.log(
            '[NotifikasiServis]-[onDidReceiveNotificationResponse] 📩 : Notifikasi diklik oleh pengguna. Payload: ${response.payload}',
          );
        },
      );
      developer.log('[NotifikasiServis]-[inisialisasi] ✅ : Layanan Notifikasi berhasil diinisialisasi.');
    } catch (e, s) {
      developer.log(
        '[NotifikasiServis]-[inisialisasi] ❌ : Gagal melakukan inisialisasi layanan notifikasi',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<NotificationAppLaunchDetails?> getDetailPeluncuranNotifikasi() async {
    developer.log('[NotifikasiServis]-[getDetailPeluncuranNotifikasi] 📱 : Memeriksa apakah aplikasi diluncurkan melalui notifikasi...');
    final details = await plugin.getNotificationAppLaunchDetails();
    
    if (details != null && details.didNotificationLaunchApp) {
      developer.log('[NotifikasiServis]-[getDetailPeluncuranNotifikasi] 🚀 : Aplikasi diluncurkan dari notifikasi dengan ID: ${details.notificationResponse?.id}');
    } else {
      developer.log('[NotifikasiServis]-[getDetailPeluncuranNotifikasi] 🏠 : Aplikasi diluncurkan secara normal (bukan dari notifikasi).');
    }
    
    return details;
  }

  Future<void> tampilkanNotifikasiLangsung({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    developer.log('[NotifikasiServis]-[tampilkanNotifikasiLangsung] 🔔 : Mengirim notifikasi langsung (ID: $id, Judul: $title)');
    
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
      developer.log('[NotifikasiServis]-[tampilkanNotifikasiLangsung] ✨ : Notifikasi langsung berhasil ditampilkan di layar.');
    } catch (e, s) {
      developer.log(
        '[NotifikasiServis]-[tampilkanNotifikasiLangsung] ❌ : Gagal menampilkan notifikasi langsung',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> jadwalNotifikasi({
    required int id,
    required String title,
    required String body,
    required DateTime jadwal,
    String? payload,
  }) async {
    developer.log('[NotifikasiServis]-[jadwalNotifikasi] 📅 : Merencanakan notifikasi terjadwal (ID: $id) pada waktu: $jadwal');
    
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
      developer.log('[NotifikasiServis]-[jadwalNotifikasi] ✅ : Notifikasi terjadwal berhasil didaftarkan ke sistem.');
    } catch (e, s) {
      developer.log(
        '[NotifikasiServis]-[jadwalNotifikasi] ❌ : Gagal mendaftarkan jadwal notifikasi',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> perbaruiJadwalNotifikasi({
    required int id,
    required String title,
    required String body,
    required DateTime jadwal,
    String? payload,
  }) async {
    developer.log('[NotifikasiServis]-[perbaruiJadwalNotifikasi] 🔄 : Memulai pembaruan jadwal notifikasi untuk ID: $id');
    
    await batalNotifikasi(id);
    await jadwalNotifikasi(
      id: id,
      title: title,
      body: body,
      jadwal: jadwal,
      payload: payload,
    );
    
    developer.log('[NotifikasiServis]-[perbaruiJadwalNotifikasi] ✨ : Pembaruan jadwal selesai dilakukan.');
  }

  Future<void> batalNotifikasi(int id) async {
    developer.log('[NotifikasiServis]-[batalNotifikasi] 🗑️ : Membatalkan notifikasi aktif/terjadwal dengan ID: $id');
    try {
      await plugin.cancel(id: id); // diubah: menggunakan argumen bernama
      developer.log('[NotifikasiServis]-[batalNotifikasi] ✅ : Notifikasi ID: $id telah dihapus.');
    } catch (e, s) {
      developer.log(
        '[NotifikasiServis]-[batalNotifikasi] ❌ : Gagal membatalkan notifikasi ID: $id',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> batalSemuaNotifikasi() async {
    developer.log('[NotifikasiServis]-[batalSemuaNotifikasi] 🧹 : Membersihkan semua notifikasi yang ada (aktif maupun terjadwal)...');
    try {
      await plugin.cancelAll();
      developer.log('[NotifikasiServis]-[batalSemuaNotifikasi] ✅ : Seluruh notifikasi berhasil dibersihkan.');
    } catch (e, s) {
      developer.log(
        '[NotifikasiServis]-[batalSemuaNotifikasi] ❌ : Terjadi kesalahan saat membersihkan semua notifikasi',
        error: e,
        stackTrace: s,
      );
    }
  }
}