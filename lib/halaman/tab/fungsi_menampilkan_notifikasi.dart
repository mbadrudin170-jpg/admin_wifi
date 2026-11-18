// Path: lib/halaman/tab/fungsi_menampilkan_notifikasi.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
void onDidReceiveNotificationResponse(
  NotificationResponse notificationResponse,
) async {
  L.i(
    'Notifikasi di-tap oleh pengguna. '
    'ID Notifikasi: ${notificationResponse.id}, '
    'Payload: ${notificationResponse.payload ?? "Tidak ada payload"}. '
    'Fungsi ini dipanggil saat aplikasi menerima respons dari notifikasi yang diklik pengguna.',
  );
}

class NotifikasiServis {
  final FlutterLocalNotificationsPlugin plugin;

  NotifikasiServis() : plugin = FlutterLocalNotificationsPlugin() {
    L.i(
      'NotifikasiServis instance dibuat. '
      'Menggunakan FlutterLocalNotificationsPlugin default.',
    );
  }

  @visibleForTesting
  NotifikasiServis.internal(this.plugin) {
    L.i(
      'NotifikasiServis instance dibuat (internal/testing). '
      'Menggunakan FlutterLocalNotificationsPlugin yang di-inject. '
      'Instance plugin: ${plugin.hashCode}',
    );
  }

  Future<void> inisialisasi() async {
    L.i(
      'Memulai konfigurasi dan inisialisasi plugin notifikasi lokal. '
      'Proses ini mencakup pengaturan channel Android, pengaturan iOS, '
      'dan inisialisasi zona waktu.',
    );
    try {
      L.i(
        'Membuat konfigurasi inisialisasi untuk platform Android. '
        'Menggunakan icon @mipmap/ic_launcher sebagai ikon notifikasi.',
      );
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      L.i('Membuat konfigurasi inisialisasi untuk platform iOS (Darwin).');
      const DarwinInitializationSettings darwinInitializationSettings =
          DarwinInitializationSettings();

      L.i(
        'Menggabungkan konfigurasi Android dan iOS ke dalam InitializationSettings.',
      );
      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: androidInitializationSettings,
            iOS: darwinInitializationSettings,
          );

      L.i(
        'Memanggil plugin.initialize() dengan konfigurasi yang telah dibuat. '
        'Mendaftarkan callback onDidReceiveNotificationResponse untuk menangani notifikasi yang di-tap.',
      );
      await plugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
        onDidReceiveBackgroundNotificationResponse:
            onDidReceiveNotificationResponse,
      );
      L.i(
        'Plugin notifikasi berhasil diinisialisasi. '
        'Callback untuk notifikasi foreground dan background telah terdaftar.',
      );

      L.i(
        'Menginisialisasi data zona waktu dari package timezone. '
        'Ini diperlukan untuk menjadwalkan notifikasi berdasarkan waktu lokal.',
      );
      tz.initializeTimeZones();

      L.i('Mengatur lokasi zona waktu default ke Asia/Jakarta (WIB).');
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

      L.i(
        'Inisialisasi NotifikasiServis BERHASIL. '
        'Plugin siap digunakan untuk menjadwalkan dan menampilkan notifikasi. '
        'Timezone: Asia/Jakarta.',
      );
    } catch (e, s) {
      L.e(
        'Gagal menginisialisasi plugin notifikasi lokal. '
        'Proses inisialisasi mengalami kegagalan. '
        'Kemungkinan penyebab: plugin tidak terpasang dengan benar, '
        'konfigurasi platform tidak valid, atau zona waktu gagal diinisialisasi. '
        'Notifikasi tidak akan berfungsi sampai masalah ini diperbaiki. Error: $e $s',
      );
    }
  }

  Future<bool> requestPermissions() async {
    L.i(
      'Meminta izin notifikasi dari sistem operasi. '
      'Proses ini akan memeriksa dan meminta izin untuk platform Android dan iOS.',
    );
    try {
      L.i(
        'Memeriksa apakah platform Android tersedia dan meminta izin notifikasi.',
      );
      bool? androidResult;
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      if (androidImplementation != null) {
        L.i(
          'Implementasi Android ditemukan. Meminta izin notifikasi Android...',
        );
        androidResult = await androidImplementation
            .requestNotificationsPermission();
        L.i(
          'Hasil permintaan izin Android: ${androidResult == true ? "DIBERIKAN" : "DITOLAK"}.',
        );
      } else {
        L.i(
          'Implementasi Android tidak ditemukan. Melewati permintaan izin Android.',
        );
      }

      L.i(
        'Memeriksa apakah platform iOS tersedia dan meminta izin notifikasi.',
      );
      bool? iosResult;
      final IOSFlutterLocalNotificationsPlugin? iOSImplementation = plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (iOSImplementation != null) {
        L.i(
          'Implementasi iOS ditemukan. Meminta izin notifikasi iOS (alert, badge, sound)...',
        );
        iosResult = await iOSImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        L.i(
          'Hasil permintaan izin iOS: ${iosResult == true ? "DIBERIKAN" : "DITOLAK"}.',
        );
      } else {
        L.i('Implementasi iOS tidak ditemukan. Melewati permintaan izin iOS.');
      }

      final bool finalResult = (androidResult ?? false) || (iosResult ?? false);
      L.i(
        'Hasil akhir permintaan izin notifikasi: ${finalResult ? "IZIN DIBERIKAN (minimal satu platform memberikan izin)" : "IZIN DITOLAK (semua platform menolak izin)"}. '
        'Android: ${androidResult ?? "tidak tersedia"}, '
        'iOS: ${iosResult ?? "tidak tersedia"}.',
      );
      return finalResult;
    } catch (e, s) {
      L.e(
        'Gagal meminta izin notifikasi dari sistem operasi. '
        'Proses permintaan izin mengalami kegagalan. '
        'Kemungkinan penyebab: plugin tidak mendukung platform saat ini, '
        'terjadi error saat berkomunikasi dengan sistem operasi, '
        'atau pengguna telah menolak izin secara permanen. Error: $e $s',
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
    L.i(
      'Mencoba menjadwalkan notifikasi baru. '
      'ID Notifikasi: $id, '
      'Judul: "$title", '
      'Isi: "$body", '
      'Waktu Dijadwalkan: $jadwal (${jadwal.toIso8601String()}).',
    );
    try {
      L.i(
        'Membuat konfigurasi detail notifikasi untuk platform Android. '
        'Channel ID: id_kadaluarsa_paket, '
        'Channel Name: Notifikasi Kadaluarsa Paket, '
        'Importance: max, '
        'Priority: high.',
      );
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

      L.i('Membungkus konfigurasi Android ke dalam NotificationDetails.');
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
      );

      L.i(
        'Mengkonversi DateTime menjadi TZDateTime dengan zona waktu lokal (Asia/Jakarta).',
      );
      final tzDateTime = tz.TZDateTime.from(jadwal, tz.local);
      L.i('TZDateTime berhasil dibuat: ${tzDateTime.toIso8601String()}.');

      L.i(
        'Memanggil plugin.zonedSchedule() untuk menjadwalkan notifikasi. '
        'Mode penjadwalan Android: inexact (untuk efisiensi baterai).',
      );
      await plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzDateTime,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexact,
      );

      L.i(
        'Notifikasi BERHASIL dijadwalkan. '
        'ID: $id, '
        'Judul: "$title", '
        'Akan muncul pada: $jadwal (${jadwal.toIso8601String()}).',
      );
    } catch (e, s) {
      L.e(
        'Gagal menjadwalkan notifikasi dengan ID: $id. '
        'Proses penjadwalan notifikasi mengalami kegagalan. '
        'Kemungkinan penyebab: ID duplikat, waktu yang sudah lewat, '
        'plugin belum diinisialisasi, atau izin notifikasi belum diberikan. Error: $e $s',
      );
    }
  }

  Future<void> batalNotifikasi(int id) async {
    L.i(
      'Mencoba membatalkan notifikasi yang telah dijadwalkan. '
      'ID Notifikasi yang akan dibatalkan: $id.',
    );
    try {
      L.i(
        'Memanggil plugin.cancel() untuk membatalkan notifikasi dengan ID: $id.',
      );
      await plugin.cancel(id: id);
      L.i(
        'Notifikasi dengan ID: $id BERHASIL dibatalkan. '
        'Notifikasi tidak akan muncul pada waktu yang telah dijadwalkan.',
      );
    } catch (e, s) {
      L.e(
        'Gagal membatalkan notifikasi dengan ID: $id. '
        'Proses pembatalan notifikasi mengalami kegagalan. '
        'Kemungkinan penyebab: notifikasi dengan ID tersebut tidak ditemukan, '
        'plugin belum diinisialisasi, atau terjadi error sistem. Error: $e $s',
      );
    }
  }

  Future<void> tampilkanNotifikasiLangsung({
    required int id,
    required String title,
    required String body,
  }) async {
    L.i(
      'Mencoba menampilkan notifikasi secara langsung (segera). '
      'ID Notifikasi: $id, '
      'Judul: "$title", '
      'Isi: "$body".',
    );
    try {
      L.i(
        'Membuat konfigurasi detail notifikasi langsung untuk platform Android. '
        'Channel ID: id_notifikasi_langsung, '
        'Channel Name: Notifikasi Langsung, '
        'Importance: max, '
        'Priority: high, '
        'showWhen: true.',
      );
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

      L.i('Membungkus konfigurasi Android ke dalam NotificationDetails.');
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
      );

      L.i(
        'Memanggil plugin.show() untuk menampilkan notifikasi secara langsung.',
      );
      await plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
      );

      L.i(
        'Notifikasi langsung BERHASIL ditampilkan. '
        'ID: $id, '
        'Judul: "$title", '
        'Isi: "$body". '
        'Notifikasi akan muncul di notification tray pengguna.',
      );
    } catch (e, s) {
      L.e(
        'Gagal menampilkan notifikasi langsung dengan ID: $id. '
        'Proses menampilkan notifikasi secara langsung mengalami kegagalan. '
        'Kemungkinan penyebab: plugin belum diinisialisasi, '
        'izin notifikasi belum diberikan, atau channel belum terdaftar. Error: $e $s',
      );
    }
  }
}
