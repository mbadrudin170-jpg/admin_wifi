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

---

### **File: `lib/halaman/pembantu/halaman_poin.dart`**

**Fitur:** Manajemen Poin Pelanggan

**Tujuan file ini dibuat:**
File ini bertujuan untuk menyediakan antarmuka (UI) yang lengkap bagi admin untuk mengelola dan memantau poin loyalitas dari seorang pelanggan spesifik. Halaman ini memungkinkan admin untuk melihat total poin yang dimiliki pelanggan, meninjau riwayat transaksi yang menghasilkan atau menggunakan poin, serta melihat daftar hadiah (paket) yang dapat ditukarkan beserta progres pencapaian untuk setiap hadiah.

---

### **Analisis Kode Rinci**

#### **1. `enum MenuPoin`**
*   **Tujuan:** Enumerasi ini digunakan sebagai saklar untuk mengontrol konten utama yang ditampilkan di halaman. Ini adalah cara yang bersih dan mudah dibaca untuk mengelola state tampilan antara dua mode yang berbeda.
*   **Nilai:**
    *   `penukaran`: Menandakan bahwa UI harus menampilkan widget `_listPaket`, yang berisi daftar hadiah/paket yang bisa ditukar.
    *   `riwayat`: Menandakan bahwa UI harus menampilkan widget `_riwayatTransaksi`, yang berisi histori perolehan poin pelanggan.

#### **2. `HalamanPoin` (StatefulWidget)**
*   **Tujuan:** Ini adalah widget utama yang membentuk kerangka halaman. Dideklarasikan sebagai `StatefulWidget` karena kontennya (seperti total poin, daftar paket, dan tab menu yang aktif) bersifat dinamis dan akan berubah selama interaksi pengguna atau setelah data dari database selesai dimuat.
*   **Properti:**
    *   `final String idPelanggan`: Properti ini wajib diisi (`required`) dan dikirim dari halaman sebelumnya (misalnya, dari halaman detail pelanggan). `idPelanggan` adalah kunci untuk mengambil data spesifik (total poin dan riwayat transaksi) untuk pelanggan yang bersangkutan.

#### **3. `_HalamanPoinState` (State Class)**
*   **Tujuan:** Kelas ini memegang semua data (state) dan logika bisnis untuk `HalamanPoin`. Semua perubahan data dan pembaruan UI diatur di dalam kelas ini.
*   **Properti State:**
    *   `final transaksiOperasi = TransaksiOperasi()`: Sebuah instance dari kelas `TransaksiOperasi` untuk berinteraksi dengan tabel transaksi di database, terutama untuk menghitung total poin dan mengambil riwayat transaksi.
    *   `final paketOperasi = PaketOperasi()`: Sebuah instance dari kelas `PaketOperasi` untuk mengambil data paket dari database, yang akan ditampilkan sebagai daftar hadiah yang bisa ditukar.
    *   `int totalPoin = 0`: Variabel untuk menyimpan jumlah total poin yang dimiliki pelanggan. Nilai awalnya adalah `0` dan akan diperbarui setelah data dari database berhasil diambil.
    *   `bool isLoading = true`: Sebuah flag boolean untuk mengontrol state pemuatan (loading). Saat `true`, UI akan menampilkan `CircularProgressIndicator`. Setelah data berhasil dimuat, nilainya diubah menjadi `false` untuk menampilkan konten utama.
    *   `List<PaketModel> daftarPaket = []`: Variabel untuk menampung daftar objek `PaketModel` yang diambil dari database. Daftar ini digunakan oleh widget `_listPaket`.
    *   `MenuPoin menuAktif = MenuPoin.riwayat`: Variabel yang menentukan tab mana (`penukaran` atau `riwayat`) yang sedang aktif. Secara default, halaman akan menampilkan tab `riwayat` terlebih dahulu.
*   **Metode:**
    *   `initState()`: Metode ini dipanggil secara otomatis oleh Flutter saat widget pertama kali dibuat dan dimasukkan ke dalam pohon widget. Di dalamnya, ia memanggil `_loadData()` untuk memulai proses pengambilan data dari database.
    *   `_loadData()`:
        *   **Tujuan:** Fungsi asinkron untuk mengambil semua data yang diperlukan untuk halaman ini.
        *   **Proses:**
            1.  `await transaksiOperasi.getTotalPoin(widget.idPelanggan)`: Memanggil database untuk menghitung dan mengembalikan total poin dari pelanggan yang `id`-nya sesuai.
            2.  `await paketOperasi.getPaket()`: Memanggil database untuk mengambil semua daftar paket yang ada.
            3.  `if (!mounted) return;`: Pemeriksaan keamanan yang sangat penting. Ini memastikan bahwa jika pengguna meninggalkan halaman ini sebelum proses `await` selesai, `setState()` tidak akan dipanggil pada widget yang sudah tidak ada, sehingga mencegah error.
            4.  `setState(() { ... })`: Setelah kedua data di atas berhasil diambil, `setState` dipanggil untuk memperbarui nilai `totalPoin`, `daftarPaket`, dan mengubah `isLoading` menjadi `false`. Panggilan ini memberitahu Flutter untuk membangun ulang (rebuild) UI dengan data yang baru.
    *   `build(BuildContext context)`:
        *   **Tujuan:** Metode inti yang membangun antarmuka pengguna.
        *   **Logika Kondisional:** Pertama, ia memeriksa nilai `isLoading`. Jika `true`, ia hanya akan menampilkan `Scaffold` dengan indikator loading di tengah.
        *   **Struktur Utama (jika `isLoading` false):**
            *   `Scaffold`: Kerangka dasar halaman.
            *   `AppBar`: Judul halaman.
            *   `Column`: Layout utama yang menyusun widget secara vertikal.
                *   `_infoPoin(...)`: Memanggil widget untuk menampilkan kartu total poin.
                *   `Row`: Berisi dua `TextButton` ("Penukaran" dan "Riwayat"). Saat ditekan, `setState` dipanggil untuk mengubah nilai `menuAktif`, yang kemudian akan mengganti konten di bawahnya.
                *   `Expanded`: Memastikan widget di dalamnya (`_riwayatTransaksi` atau `_listPaket`) mengisi sisa ruang yang tersedia di layar. Kontennya ditentukan secara dinamis oleh nilai `menuAktif`.
    *   `_infoPoin(BuildContext context, int poin)`:
        *   **Tujuan:** Sebuah widget sederhana dan terisolasi yang hanya bertanggung jawab untuk menampilkan total poin dalam sebuah `Card` agar terlihat menonjol. Menerima `poin` sebagai parameter untuk ditampilkan.

#### **4. Fungsi dan Widget Top-Level**

*   `_hitungProgressPencapaian(int poinDimiliki, int poinDibutuhkan)`:
    *   **Tujuan:** Fungsi utilitas murni (pure function) untuk menghitung progres.
    *   **Logika:**
        1.  Ia melakukan pembagian antara `poinDimiliki` dengan `poinDibutuhkan`.
        2.  Terdapat pengaman `if (poinDibutuhkan <= 0)` untuk menghindari error pembagian dengan nol.
        3.  Menggunakan `.clamp(0.0, 1.0)` untuk memastikan outputnya selalu berada dalam rentang `0.0` hingga `1.0`, karena ini adalah rentang nilai yang diterima oleh properti `value` dari `LinearProgressIndicator`.
*   `_listPaket(...)`:
    *   **Tujuan:** Menampilkan daftar semua paket hadiah dalam bentuk `ListView`.
    *   **Logika:**
        1.  Jika `daftarPaket` kosong, tampilkan pesan informatif.
        2.  Menggunakan `ListView.builder` untuk performa yang efisien, terutama jika daftar paket sangat banyak.
        3.  Untuk setiap item `paket` dalam daftar:
            *   Ia membuat `Card` yang berisi `ListTile`.
            *   `bool bisaDitukar`: Logika untuk menentukan apakah poin pelanggan mencukupi untuk menukar paket.
            *   `LinearProgressIndicator`: Digunakan untuk memberikan visualisasi progres poin pelanggan terhadap poin yang dibutuhkan. Warnanya akan berubah menjadi hijau jika poin sudah mencukupi.
            *   Menampilkan pesan khusus jika `paket.isPublic` bernilai `false`, menandakan paket tersebut tidak tersedia untuk penukaran umum.
*   `_riwayatTransaksi(...)`:
    *   **Tujuan:** Menampilkan riwayat transaksi yang terkait dengan poin untuk pelanggan yang dipilih.
    *   **Logika:**
        1.  Menggunakan `FutureBuilder` karena proses pengambilan data dari database bersifat asinkron (`Future`). Ini adalah pola standar di Flutter untuk menangani UI yang bergantung pada data dari operasi yang memakan waktu.
        2.  `future`: Properti ini diisi dengan hasil panggilan ke `transaksiOperasi.ambilTransaksiByPelangganId(idPelanggan)`.
        3.  `builder`: Fungsi ini dipanggil setiap kali state dari `Future` berubah (misalnya, `waiting`, `done`, `error`).
            *   Saat `ConnectionState.waiting`, tampilkan `CircularProgressIndicator`.
            *   Jika `snapshot.hasError`, tampilkan pesan error.
            *   Jika data kosong (`snapshot.data ?? []`), tampilkan pesan informatif.
            *   Jika data tersedia, bangun `ListView.builder` untuk menampilkan setiap `transaksi` dalam `ListTile`, menunjukkan informasi seperti keterangan, ID, dan poin yang terlibat.
