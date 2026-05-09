# Laporan Perubahan Teknis: Refactoring Layanan Pembersihan Data Otomatis

**Tanggal:** 26 Juli 2024

### **Ringkasan Eksekutif**

Telah dilakukan refactoring pada fitur pembersihan data arsip otomatis untuk menghilangkan nilai *hardcoded* dan membuatnya sepenuhnya dinamis berdasarkan konfigurasi yang tersimpan di database. Pekerjaan ini berhasil menutup celah inkonsistensi antara `PengaturanModel` dan implementasi logika di `PembersihanDataService`, menghasilkan sistem yang lebih fleksibel, dapat diandalkan, dan mudah dipelihara.

---

### **1. File yang Dimodifikasi: `lib/data/operasi/pembersihan_data_operasi.dart`**

File ini bertanggung jawab untuk mengeksekusi query SQL penghapusan data secara langsung.

#### **Masalah Awal:**

Fungsi `hapusSemuaDataArsipKadaluarsa()` menggunakan nilai tetap `-30 days` di dalam query SQL-nya. Ini membuatnya tidak fleksibel dan tidak sesuai dengan nilai `hapusOtomatisDataArsip` yang ada di `PengaturanModel`.

```dart
// Kode LAMA (Sebelum Perubahan)
Future<int> hapusSemuaDataArsipKadaluarsa() async {
  // ...
  final hasil = await db.rawDelete(\'\'\'
    DELETE FROM $tabel
    WHERE diarsipkan IS NOT NULL
    AND diarsipkan <= datetime('now', '-30 days') // <- Nilai Hardcoded
  \'\'\');
  // ...
}
```

#### **Detail Perubahan:**

1.  **Fungsi Dibuat Dinamis:**
    *   Tanda tangan (signature) fungsi diubah dari `Future<int> hapusSemuaDataArsipKadaluarsa()` menjadi `Future<int> hapusSemuaDataArsipKadaluarsa({required int batasHari})`.
    *   Ini memaksa siapa pun yang memanggil fungsi ini untuk menyediakan nilai `batasHari` secara eksplisit.

2.  **Query SQL Diperbarui:**
    *   Nilai *hardcoded* `-30 days` diganti dengan *placeholder* `?` yang aman (`'-? days'`).
    *   Nilai `batasHari` yang diterima fungsi kemudian diteruskan sebagai parameter ke dalam `db.rawDelete()`, yang secara aman menggantikan `?` dengan nilai tersebut.

3.  **Perbaikan Sintaks (Post-Analysis):**
    *   Setelah analisis awal, ditemukan `warning` "variabel `tabel` tidak digunakan". Ini disebabkan oleh kesalahan penempatan karakter `\` pada interpolasi string.
    *   **Diperbaiki:** `DELETE FROM \\$tabel` diubah menjadi `DELETE FROM $tabel` untuk memastikan nama tabel dimasukkan dengan benar ke dalam string query SQL.

#### **Hasil Akhir (Kode Baru):**

```dart
// path: lib/data/operasi/pembersihan_data_operasi.dart

import 'package:admin_wifi/data/sqlite.dart';
import 'dart:developer' as developer;

class PembersihanDataOperasi {
  final dbHelper = DatabaseHelper.instance;

  /// Fungsi utama untuk menghapus semua data arsip
  /// yang sudah lebih tua dari [batasHari] di semua tabel yang relevan.
  Future<int> hapusSemuaDataArsipKadaluarsa({required int batasHari}) async {
    final db = await dbHelper.database;
    int totalTerhapus = 0;

    final List<String> daftarTabel = [
      'pelanggan',
      'pelanggan_aktif',
      'paket',
      'kategori',
      'sub_kategori',
      'transaksi',
      'dompet',
      'riwayat_langganan',
      'pesanan',
      'versi_apk_user',
    ];

    for (final tabel in daftarTabel) {
      try {
        // diperbaiki: Menggunakan parameter 'batasHari' dan sintaks string yang benar.
        final hasil = await db.rawDelete(\'\'\'
          DELETE FROM $tabel
          WHERE diarsipkan IS NOT NULL
          AND diarsipkan <= datetime('now', '-? days')
        \'\'\', [batasHari]);

        if (hasil > 0) {
          developer.log(
            'Menghapus $hasil baris dari tabel $tabel yang diarsipkan lebih dari $batasHari hari.',
            name: 'PembersihanDataOperasi',
          );
        }
        totalTerhapus += hasil;
      } catch (e, s) {
        developer.log(
          'Gagal membersihkan tabel $tabel',
          error: e,
          stackTrace: s,
          name: 'PembersihanDataOperasi.Error',
        );
        continue;
      }
    }
    return totalTerhapus;
  }
}
```

---

### **2. File yang Dimodifikasi: `lib/services/pembersihan_data_service.dart`**

File ini adalah orkestrator yang memutuskan kapan proses pembersihan perlu dijalankan.

#### **Masalah Awal:**

Fungsi `jalankanJikaPerlu()` memanggil `_operasi.hapusSemuaDataArsipKadaluarsa()` tanpa parameter. Ini membuatnya bergantung pada implementasi di level operasi, yang saat itu masih menggunakan nilai *hardcoded*.

```dart
// Kode LAMA (Sebelum Perubahan)
Future<void> jalankanJikaPerlu() async {
  // ... (pengecekan waktu)

  // ✅ Jalankan pembersihan (tanpa parameter)
  final totalTerhapus = await _operasi.hapusSemuaDataArsipKadaluarsa();

  // ...
}
```

#### **Detail Perubahan:**

1.  **Import Dependensi Baru:**
    *   Ditambahkan `import 'package:admin_wifi/data/operasi/pengaturan_operasi.dart';` dan `import 'package:admin_wifi/model/pengaturan_model.dart';` untuk dapat mengakses data pengaturan.

2.  **Inisialisasi Operasi Pengaturan:**
    *   Sebuah instance `final PengaturanOperasi _pengaturanOperasi = PengaturanOperasi();` dibuat.

3.  **Logika Pengambilan Pengaturan:**
    *   Sebelum memanggil fungsi pembersihan, logika baru ditambahkan untuk:
        a. Memanggil `_pengaturanOperasi.getPengaturan()` untuk mengambil model pengaturan terbaru dari database.
        b. Mengekstrak nilai `pengaturan.hapusOtomatisDataArsip` ke dalam variabel `batasHari`.

4.  **Pemanggilan Fungsi Dinamis:**
    *   Pemanggilan fungsi pembersihan diubah dari `_operasi.hapusSemuaDataArsipKadaluarsa()` menjadi `_operasi.hapusSemuaDataArsipKadaluarsa(batasHari: batasHari)`.
    *   Ini secara efektif menghubungkan nilai dari database pengaturan langsung ke dalam query SQL.

5.  **Peningkatan Logging:**
    *   Pesan log ditambahkan untuk memberikan informasi detail tentang setiap langkah: kapan proses dimulai, apakah perlu dijalankan, berapa nilai `batasHari` yang digunakan, dan apakah ada data yang berhasil dihapus.

#### **Hasil Akhir (Kode Baru):**

```dart
// path: lib/services/pembersihan_data_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin_wifi/data/operasi/pembersihan_data_operasi.dart';
import 'package:admin_wifi/data/operasi/pengaturan_operasi.dart';
import 'package:admin_wifi/model/pengaturan_model.dart';
import 'dart:developer' as developer;

class PembersihanDataService {
  static const String _keyLastCleanup = 'last_cleanup_timestamp';
  final PembersihanDataOperasi _operasi = PembersihanDataOperasi();
  final PengaturanOperasi _pengaturanOperasi = PengaturanOperasi();
  static bool _sedangBerjalan = false;

  Future<void> jalankanJikaPerlu() async {
    if (_sedangBerjalan) {
      developer.log('Pembersihan data sudah berjalan, skip eksekusi baru.', name: 'PembersihanDataService');
      return;
    }
    _sedangBerjalan = true;
    developer.log('Memulai pengecekan untuk pembersihan data.', name: 'PembersihanDataService');

    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final lastCleanupMillis = prefs.getInt(_keyLastCleanup);

      if (lastCleanupMillis != null) {
        final lastCleanup = DateTime.fromMillisecondsSinceEpoch(lastCleanupMillis);
        final selisih = now.difference(lastCleanup);
        if (selisih < const Duration(hours: 24)) {
          developer.log('Pembersihan data tidak diperlukan, belum 24 jam.', name: 'PembersihanDataService');
          return;
        }
      }

      developer.log('Pembersihan data diperlukan, memulai proses...', name: 'PembersihanDataService');
      
      // ditambahkan: Mengambil pengaturan untuk mendapatkan batas hari dinamis.
      final PengaturanModel pengaturan = await _pengaturanOperasi.getPengaturan();
      final int batasHari = pengaturan.hapusOtomatisDataArsip;

      developer.log('Batas hari untuk penghapusan arsip: $batasHari hari.', name: 'PembersihanDataService');
      
      await prefs.setInt(_keyLastCleanup, now.millisecondsSinceEpoch);

      // diubah: Memanggil fungsi dengan parameter 'batasHari' dari pengaturan.
      final totalTerhapus = await _operasi.hapusSemuaDataArsipKadaluarsa(
        batasHari: batasHari,
      );

      if (totalTerhapus > 0) {
        developer.log('Pembersihan data berhasil. Total terhapus: $totalTerhapus item.', name: 'PembersihanDataService');
      } else {
        developer.log('Pembersihan data dijalankan, tidak ada item kadaluarsa yang ditemukan.', name: 'PembersihanDataService');
      }
    } catch (e, s) {
      developer.log(
        'Error saat pembersihan data',
        error: e,
        stackTrace: s,
        name: 'PembersihanDataService.Error',
      );
    } finally {
      _sedangBerjalan = false;
    }
  }
}
```
