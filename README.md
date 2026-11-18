# Laporan Perubahan Teknis: Refactoring & Perbaikan Bug

# Blueprint Proyek

Dokumen ini adalah sumber kebenaran tunggal untuk arsitektur, fitur, dan rencana kerja proyek.

---

11 mei

## Catatan Pekerjaan

### v1.0.4 (Standardisasi Logging Proyek)

- **lib/debug/log.dart**:
  - **Tujuan**: Memperbaiki dan memperluas kelas `Log` kustom agar lebih fleksibel dan dapat menerima konteks nama log dari pemanggil.
  - **Perubahan**:
    1.  Menambahkan parameter opsional `{String? name}` pada semua metode publik (`info`, `warning`, `error`, `api`).
    2.  Jika parameter `name` diberikan, ia akan digunakan sebagai nama logger. Jika tidak, akan digunakan nilai default (misalnya, 'INFO', 'WARN').
  - **Alasan**: Untuk memperbaiki serangkaian error `undefined_named_parameter` yang terjadi setelah proses refactoring. Ini memungkinkan kita mempertahankan konteks log yang berharga yang sudah ada di seluruh aplikasi sambil tetap menggunakan pembungkus (wrapper) kustom kita.

- **Proyek-lebar (Semua file di `lib/`)**:
  - **Tujuan**: Menyeragamkan seluruh sistem logging aplikasi agar mematuhi aturan #1.2.3 ("Gunakan `developer.log`") melalui kelas pembungkus terpusat.
  - **Perubahan**:
    1.  Secara sistematis mengganti semua pemanggilan `import 'dart:developer' as developer;` dengan `import 'package:admin_wifi/debug/log.dart';`.
    2.  Mengganti semua pemanggilan `developer.log(...)` dengan metode yang sesuai dari kelas `Log`, seperti `Log.info(...)`, `Log.warning(...)`, dan `Log.error(...)`.
  - **Alasan**: Untuk menciptakan sistem logging yang konsisten, terpusat, dan mudah dikelola. Dengan perubahan ini, semua format dan perilaku log dapat diubah dari satu file tunggal (`lib/debug/log.dart`), meningkatkan pemeliharaan dan keterbacaan kode.

### v1.0.3 (Perbaikan Kritis & Efisiensi Sinkronisasi)

- **lib/data/sync/unduh_data.dart**:
  - **Tujuan**: Mengoptimalkan proses unduh data agar hanya mengambil data yang benar-benar baru dari server, serta memperbaiki logika khusus pada tabel `pengaturan`.
  - **Perubahan**:
    1.  Mengintegrasikan `SyncManager` untuk mendapatkan _timestamp_ unduhan terakhir.
    2.  Memodifikasi fungsi `sinkronisasiKoleksi` untuk menambahkan filter `.where('diperbarui', isGreaterThan: waktuUnduhTerakhir)` pada query Firestore.
    3.  Memastikan `SyncManager` memperbarui _timestamp_ hanya setelah semua proses unduh berhasil.
    4.  Menghapus logika unduh yang berbeda untuk tabel `pengaturan` dan membuatnya konsisten dengan tabel lain.
  - **Alasan**: Mencegah pengunduhan seluruh data setiap kali sinkronisasi berjalan, yang sangat boros kuota baca Firebase dan memperlambat aplikasi. Perbaikan ini mengimplementasikan **unduhan inkremental** yang jauh lebih efisien.

- **lib/data/sync/unggah_data.dart**:
  - **Tujuan**: Memperbaiki bug kritis yang menyebabkan data diunggah berulang kali dan menyederhanakan logika unggah.
  - **Perubahan**:
    1.  Mengaktifkan kembali baris `_syncManager.setTerakhirUnggah()` yang sebelumnya dikomentari, untuk memastikan _timestamp_ unggah diperbarui setelah proses selesai.
    2.  Menghapus logika khusus yang tidak perlu untuk tabel `pengaturan`, membuatnya konsisten dengan tabel lain.
    3.  Menyederhanakan fungsi `unggahDataGenerik` untuk menghapus penanganan ID dokumen yang salah untuk tabel `pengaturan`.
  - **Alasan**: Memperbaiki bug yang menyebabkan pemborosan kuota tulis Firestore dan beban server yang tidak perlu. Tanpa perbaikan ini, sinkronisasi unggah tidak bekerja secara inkremental.

- **lib/enum/nama_tabel_enum.dart**:
  - **Tujuan**: Menjaga konsistensi antara `enum` dan skema database SQLite yang sesungguhnya.
  - **Perubahan**: Menghapus `riwayatLangganan` dan menambahkan `statusUnggah` agar `enum` mencerminkan tabel yang benar-benar ada.
  - **Alasan**: Mencegah potensi _runtime error_ dan memastikan bahwa semua layanan yang bergantung pada `enum` ini (seperti `PengecekanDataBaruService`) beroperasi dengan benar.

- **lib/data/services/pengecekan_data_baru.dart**:
  - **Tujuan**: Menyesuaikan fungsi konversi nama tabel dengan perubahan pada `enum NamaTabel`.
  - **Perubahan**: Memperbarui fungsi `_camelToSnake` untuk menangani kasus `statusUnggah` dan menghapus `riwayatLangganan`.
  - **Alasan**: Untuk menjaga sinkronisasi antara `enum`, konverter nama, dan skema database, memastikan layanan pengecekan data baru tetap berfungsi dengan benar setelah perubahan `enum`.

### v1.0.2 (Refactor Layanan Sinkronisasi)

- **lib/data/services/pengecekan_data_baru.dart**:
  - **Tujuan**: Memusatkan semua logika pengecekan data baru (baik dari server maupun lokal) ke dalam satu layanan tunggal.
  - **Perubahan**: Mengubah nama file dari `penecekan_data_baru_firebase.dart` menjadi `pengecekan_data_baru.dart`. Menambahkan metode baru `apakahSqliteAdaDataBaru()` yang berisi logika untuk memeriksa perubahan di database lokal. Mengganti daftar tabel _hardcoded_ dengan enum `NamaTabel` untuk meningkatkan keamanan dan keterbacaan.
  - **Alasan**: Mematuhi prinsip _Single Responsibility_. Satu layanan kini bertanggung jawab penuh untuk menjawab pertanyaan "apakah ada data baru?", yang menyederhanakan arsitektur dan mengurangi duplikasi.

- **lib/data/services/pengecekan_waktu_sync_services.dart**:
  - **Tujuan**: Melakukan refactor pada layanan orkestrasi sinkronisasi agar lebih ramping dan hanya fokus pada pengambilan keputusan.
  - **Perubahan**: Menghapus logika implementasi pengecekan data (yang kini sudah dipindahkan ke `PengecekanDataBaruService`). Sekarang, layanan ini hanya memanggil metode dari `PengecekanDataBaruService` untuk memutuskan apakah proses unggah atau unduh perlu dijalankan.
  - **Alasan**: Meningkatkan keterbacaan dan pemisahan tanggung jawab. Layanan ini sekarang bertindak murni sebagai "pengatur lalu lintas" sinkronisasi, bukan sebagai pelaksana pengecekan.

### v1.0.1 (Refactor Penyimpanan Lokal)

- **lib/data/services/preferensi_service.dart**:
  - **Tujuan**: Membuat sebuah service terpusat untuk mengelola semua data yang disimpan di penyimpanan lokal menggunakan SharedPreferences. Ini menggantikan pemanggilan langsung ke SharedPreferences di berbagai bagian aplikasi.
  - **Perubahan**: Menambahkan kelas `PreferensiService` yang menggunakan `SharedPreferencesAsync`. Ini adalah API modern yang direkomendasikan untuk menghindari masalah cache dan inkonsistensi data.
  - **Alasan**: Untuk menciptakan arsitektur yang lebih bersih, lebih mudah dikelola, dan lebih andal. Memusatkan logika penyimpanan lokal mengurangi duplikasi kode dan mempermudah debugging.

- **lib/utils/sync_manager.dart**:
  - **Tujuan**: Melakukan refactor pada `SyncManager` agar tidak lagi bertanggung jawab atas implementasi penyimpanan lokal.
  - **Perubahan**: Mengubah `SyncManager` menjadi fasad (facade) yang mendelegasikan semua panggilannya ke `PreferensiService`. Semua logika `SharedPreferences` telah dihapus dari file ini.
  - **Alasan**: Untuk mematuhi prinsip pemisahan tanggung jawab (Separation of Concerns). `SyncManager` sekarang hanya fokus pada tugasnya sebagai "penjaga" timestamp sinkronisasi, bukan pada bagaimana data itu disimpan.

### v1.0.0 (Inisialisasi)

- **lib/data/services/penecekan_data_baru_firebase.dart**:
  - **Tujuan**: Membuat layanan untuk memeriksa apakah ada data baru di server Firebase secara efisien.
  - **Perubahan**: Menambahkan kelas `PengecekanDataBaruService` dengan metode `apakahAdaDataBaru`. Metode ini membandingkan timestamp sinkronisasi lokal dengan timestamp pembaruan global di Firebase.
  - **Alasan**: Untuk menghindari pengecekan setiap koleksi secara manual, yang boros biaya dan waktu. Ini adalah implementasi dari strategi "penanda status global".

---

## Struktur Direktori

### `lib/`

```
lib/:
data
debug
enum
firebase_options.dart
halaman
halaman_utama.dart
lainnya.dart
main.dart
migrasi_diarsipkan.dart
model
server
services
splash_screen.dart
utils
whatsapp
widget

lib/data:
operasi
services
sqlite.dart
sync

lib/data/operasi:
dompet_operasi.dart
kategori_operasi.dart
kritik_saran_operasi.dart
paket_operasi.dart
pelanggan_aktif_operasi.dart
pelanggan_operasi.dart
pembersihan_data_operasi.dart
pengaturan_operasi.dart
pesanan_operasi.dart
riwayat_langganan_operasi.dart
status_unggah_operasi.dart
sub_kategori_operasi.dart
transaksi_operasi.dart
versi_apk_user_operasi.dart

lib/data/services:
navigasi_servis.dart
pengecekan_data_baru.dart
pengecekan_waktu_sync_services.dart
preferensi_service.dart

lib/data/sync:
unduhan_awal.dart
unduh_data.dart
unggah_data.dart

lib/debug:
log.dart

lib/enum:
arsitektur_apk_enum.dart
enum.dart
nama_tabel_enum.dart
status_pembayaran.dart
tipe_transaksi_enum.dart

lib/halaman:
detail
form
lainnya
pembantu
tab
tes

lib/halaman/detail:
detail_dompet.dart
detail_kritik_saran.dart
detail_paket.dart
detail_pelanggan_aktif.dart
detail_pelanggan.dart
detail_riwayat_langganan.dart
detail_transaksi.dart
detail_versi_apk_user.dart

lib/halaman/form:
form_dompet.dart
form_edit_riwayat_langganan.dart
form_kategori.dart
form_paket.dart
form_pelanggan.dart
form_pengaturan.dart
form_transaksi.dart
form_versi_apk_user.dart

lib/halaman/lainnya:
kategori.dart
kritik_saran.dart
paket.dart
pelanggan.dart
pengaturan.dart
riwayat_aktivasi_paket.dart
tentang_aplikasi.dart
ubah_data.dart
versi_apk_user.dart

lib/halaman/pembantu:
halaman_poin.dart

lib/halaman/tab:
dompet.dart
fungsi_menampilkan_notifikasi.dart
lainnya.dart
pelanggan_aktif_screen.dart
pesanan.dart
transaksi.dart

lib/halaman/tes:
contoh_simpan_status.dart
detail_pelanggan_uji.dart
halaman_tes.dart

lib/model:
dompet_model.dart
hasil_simpan_model.dart
kategori_model.dart
kritik_saran_model.dart
paket_model.dart
pelanggan_aktif_model.dart
pelanggan_model.dart
pengaturan_model.dart
pesanan_model.dart
riwayat_langganan_model.dart
status_unggah_model.dart
sub_kategori_model.dart
transaksi_model.dart
versi_apk_user_model.dart

lib/server:
server_lokal.dart

lib/services:
cek_koneksi_internet.dart
cek_langganan_kadaluarsa_service.dart
firebase_migration
kontrol_aplikasi_service.dart
notifikasi
pembersihan_data_service.dart
servis_sinkronisasi.dart
sync

lib/services/firebase_migration:
firebase_migration_service.dart

lib/services/notifikasi:
notifikasi_servis.dart

lib/services/sync:

lib/utils:
colors.dart
format_util.dart
perhitungan_util.dart
sync_manager.dart

lib/whatsapp:
info_paket.dart

lib/widget:
info_ringkasan_widget.dart
nama_dari_id.dart
nama_paket.dart
nama_pelanggan.dart
thousands_input_formatter.dart
transaksi_list_widgets.dart
```

---

## Dokumentasi File

### Folder: `lib/debug/`

**File**: `lib/debug/log.dart`
**Fitur**: Utilitas Logging Kustom
**Tujuan file ini dibuat**: Untuk menyediakan sebuah kelas pembungkus (wrapper) di atas `dart:developer` yang terpusat dan dapat dikonfigurasi. Ini memungkinkan logging yang konsisten, berwarna, dan informatif di seluruh aplikasi, yang hanya aktif pada mode debug.
**Kode A**: `class Log`

- **Penjelasan**: Kelas statis yang berisi semua metode logging, sehingga tidak perlu diinstansiasi untuk digunakan.
  **Kode B**: `static void info(String message, {String? name})`
- **Penjelasan**: Mencatat pesan informasi (level 800) dengan ikon centang hijau. Menerima `name` opsional untuk memberikan konteks tambahan pada log, yang sangat berguna untuk pemfilteran di konsol developer.
  **Kode C**: `static void warning(String message, {String? name})`
- **Penjelasan**: Mencatat pesan peringatan (level 900) dengan ikon peringatan kuning. Berguna untuk menandai kondisi yang tidak terduga tetapi tidak menyebabkan aplikasi crash.
  **Kode D**: `static void error(String message, {Object? error, StackTrace? stackTrace, String? name})`
- **Penjelasan**: Mencatat pesan kesalahan fatal (level 1000) dengan ikon silang merah. Metode ini juga menerima objek `error` dan `stackTrace` untuk memberikan detail lengkap tentang sumber masalah.
  **Kode E**: `static void _logCustom(...)`
- **Penjelasan**: Metode pribadi internal yang menjadi inti dari semua logging. Ia bertanggung jawab untuk:
  - Menambahkan kode warna ANSI untuk membedakan tipe log.
  - Menambahkan ikon emoji sebagai penanda visual.
  - Secara otomatis mendeteksi lokasi pemanggil (nama file dan metode) untuk memudahkan pelacakan.
  - Meneruskan semua informasi ke `dart:developer.log`.

### Folder: `lib/data/sync/`

**File**: `lib/data/sync/unduh_data.dart`
**Fitur**: Sinkronisasi Data (Unduh Inkremental)
**Tujuan file ini dibuat**: Untuk mengelola proses pengunduhan data dari Firestore ke database SQLite lokal secara efisien.
**Kode A**: `class LayananUnduhData`

- **Penjelasan**: Kelas utama yang bertanggung jawab untuk mengunduh semua data yang relevan dari server.
  **Kode B**: `Future<void> unduhSemuaData()`
- **Penjelasan**: Metode orkestrasi utama. Metode ini mengambil _timestamp_ unduhan terakhir dari `SyncManager`, memulai proses unduhan untuk semua koleksi secara bersamaan, dan jika berhasil, memperbarui _timestamp_ unduhan ke waktu saat ini.
  **Kode C**: `Future<void> sinkronisasiKoleksi<T>(...)`
- **Penjelasan**: Fungsi inti yang generik untuk mengunduh data dari satu koleksi. Fungsi ini sekarang menerima `waktuUnduhTerakhir` dan menggunakannya untuk memfilter query ke Firestore dengan klausa `.where('diperbarui', isGreaterThan: waktuUnduhTerakhir)`. Ini adalah kunci dari mekanisme unduhan inkremental, memastikan hanya data baru yang diambil.

**File**: `lib/data/sync/unggah_data.dart`
**Fitur**: Sinkronisasi Data (Unggah Inkremental)
**Tujuan file ini dibuat**: Untuk mengelola proses pengunggahan data dari SQLite lokal ke Firestore secara efisien dan aman.
**Kode A**: `class LayananUnggahData`

- **Penjelasan**: Kelas yang bertanggung jawab untuk mengirimkan semua perubahan data lokal ke server.
  **Kode B**: `Future<void> unggahSemuaData()`
- **Penjelasan**: Metode orkestrator yang mengumpulkan semua data yang perlu diunggah. Perbaikan kritis dilakukan di sini untuk memastikan `_syncManager.setTerakhirUnggah()` dipanggil setelah semua unggahan berhasil, yang mencegah data yang sama diunggah berulang kali.
  **Kode C**: `Future<void> unggahDataGenerik<T>(...)`
- **Penjelasan**: Fungsi inti yang generik untuk mengunggah data dari satu tabel lokal. Fungsi ini mengambil semua data dari tabel SQLite yang memiliki `diperbarui` lebih baru dari _timestamp_ unggah terakhir dan mengirimkannya ke Firestore menggunakan operasi `batch.set` dengan `SetOptions(merge: true)`. Logika khusus yang salah untuk tabel `pengaturan` telah dihapus.

### Folder: `lib/enum/`

**File**: `lib/enum/nama_tabel_enum.dart`
**Fitur**: Enum Konfigurasi
**Tujuan file ini dibuat**: Untuk menyediakan daftar semua tabel database SQLite dalam bentuk enum yang aman-tipe (type-safe). Ini mencegah kesalahan pengetikan nama tabel di seluruh aplikasi.
**Kode A**: `enum NamaTabel`

- **Penjelasan**: Enum yang berisi semua nama tabel yang ada dalam database. `riwayatLangganan` telah dihapus dan `statusUnggah` telah ditambahkan untuk mencerminkan skema database yang sebenarnya.

### Folder: `lib/data/services/`

**File**: `lib/data/services/pengecekan_data_baru.dart`
**Fitur**: Pengecekan Sinkronisasi Data
**Tujuan file ini dibuat**: Untuk memusatkan semua logika yang terkait dengan pengecekan ketersediaan data baru, baik di server (Firebase) maupun di database lokal (SQLite).
**Kode A**: `class PengecekanDataBaruService`

- **Penjelasan**: Kelas utama yang menyediakan dua fungsi utama untuk sinkronisasi, yaitu memeriksa data baru di lokal dan di server.
  **Kode B**: `Future<bool> apakahSqliteAdaDataBaru()`
- **Penjelasan**: Fungsi ini memeriksa semua tabel di database SQLite untuk mencari data yang telah diperbarui sejak terakhir kali proses unggah (upload) berhasil. Ini dilakukan dengan:
  1. Mengambil _timestamp_ unggah terakhir dari `SyncManager`.
  2. Mengambil daftar nama tabel secara dinamis dari enum `NamaTabel` (untuk menghindari kesalahan pengetikan) dan mengubahnya ke format `snake_case`.
  3. Melakukan query `COUNT(*)` pada setiap tabel untuk mencari record dengan `diperbarui` lebih baru dari _timestamp_ unggah terakhir.
  4. Mengembalikan `true` segera setelah menemukan perubahan di salah satu tabel.
     **Kode C**: `Future<bool> apakahFirebaseAdaDataBaru(...)`
- **Penjelasan**: Fungsi ini memeriksa apakah ada data baru di server Firebase dengan cara membandingkan _timestamp_ `diperbarui` dari dokumen status global di Firestore dengan _timestamp_ unduh terakhir yang disimpan secara lokal.

**File**: `lib/data/services/pengecekan_waktu_sync_services.dart`
**Fitur**: Orkestrasi Sinkronisasi Data
**Tujuan file ini dibuat**: Untuk bertindak sebagai pengatur utama (orkestrator) yang memutuskan kapan proses sinkronisasi (baik unggah maupun unduh) harus dijalankan.
**Kode A**: `class PengecekanWaktuSyncService`

- **Penjelasan**: Kelas ini tidak berisi logika pengecekan data secara langsung. Sebaliknya, ia mendelegasikan tugas tersebut ke `PengecekanDataBaruService`.
  **Kode B**: `Future<void> _cekDanJalankanUnggah()`
- **Penjelasan**: Metode ini memanggil `_pengecekanDataBaru.apakahSqliteAdaDataBaru()`. Jika hasilnya `true`, maka ia akan memicu `LayananUnggahData` untuk memulai proses unggah ke server.
  **Kode C**: `Future<void> _cekDanJalankanUnduh()`
- **Penjelasan**: Metode ini memanggil `_pengecekanDataBaru.apakahFirebaseAdaDataBaru(...)`. Jika hasilnya `true`, maka ia akan memicu `LayananUnguhData` untuk memulai proses unduh dari server.

**File**: `lib/data/services/preferensi_service.dart`
**Fitur**: Manajemen Penyimpanan Lokal
**Tujuan file ini dibuat**: Untuk menyediakan satu titik akses (single source of truth) untuk semua operasi penyimpanan lokal (key-value) di seluruh aplikasi. Ini memastikan konsistensi, keamanan, dan kemudahan pengelolaan data preferensi.
**Kode A**: `class PreferensiService`

- **Penjelasan**: Kelas statis yang bertindak sebagai pembungkus (wrapper) untuk `SharedPreferencesAsync`. Dibuat statis agar tidak perlu diinstansiasi dan dapat diakses secara global.
  **Kode B**: `static final SharedPreferencesAsync _prefs = SharedPreferencesAsync();`
- **Penjelasan**: Menggunakan `SharedPreferencesAsync` yang merupakan API modern yang direkomendasikan. Ini memastikan semua operasi bersifat asinkron dan langsung mengakses penyimpanan platform, menghindari masalah inkonsistensi yang bisa terjadi dengan cache.
  **Kode C**: `static Future<void> simpanTemaGelap(bool nilai)` dan `static Future<bool> ambilTemaGelap()`
- **Penjelasan**: Contoh metode untuk menyimpan dan mengambil preferensi sederhana seperti mode tema. Semua metode mengikuti pola `async/await` untuk konsistensi.
  **Kode D**: `static Future<DateTime> getTerakhirUnduh()` dan `static Future<void> setTerakhirUnduh(DateTime waktu)`
- **Penjelasan**: Metode yang spesifik untuk logika sinkronisasi aplikasi. Ini menunjukkan bagaimana `PreferensiService` dapat dengan mudah diperluas untuk menangani berbagai jenis data.

**Tanggal:** 9 Mei 2026

---

### **Ringkasan Eksekutif**

Telah dilakukan dua pekerjaan utama:

1.  **Refactoring Layanan Pembersihan Data Otomatis:** Menghilangkan nilai _hardcoded_ dan membuatnya dinamis berdasarkan konfigurasi dari database, meningkatkan fleksibilitas dan keandalan.
2.  **Perbaikan Bug Kritis pada Form Pelanggan Aktif:** Memperbaiki logika yang menyebabkan transaksi duplikat saat mengedit data aktivasi, memastikan konsistensi data antara aktivasi dan transaksi terkait.

---

### **1. File yang Dimodifikasi: `lib/data/operasi/pembersihan_data_operasi.dart`**

File ini bertanggung jawab untuk mengeksekusi query SQL penghapusan data secara langsung.

#### **Masalah Awal:**

Fungsi `hapusSemuaDataArsipKadaluarsa()` menggunakan nilai tetap `-30 days` di dalam query SQL-nya, membuatnya tidak fleksibel.

#### **Detail Perubahan:**

- **Fungsi Dibuat Dinamis:** Tanda tangan fungsi diubah menjadi `hapusSemuaDataArsipKadaluarsa({required int batasHari})` untuk menerima parameter dinamis.
- **Query SQL Diperbarui:** Nilai _hardcoded_ diganti dengan _placeholder_ `?` yang aman untuk diisi oleh parameter `batasHari`.

#### **Hasil Akhir (Kode Baru):**

```dart
// path: lib/data/operasi/pembersihan_data_operasi.dart
Future<int> hapusSemuaDataArsipKadaluarsa({required int batasHari}) async {
  // ...
  final hasil = await db.rawDelete('''
    DELETE FROM $tabel
    WHERE diarsipkan IS NOT NULL
    AND diarsipkan <= datetime('now', '-? days')
  ''', [batasHari]);
  // ...
}
```

---

### **2. File yang Dimodifikasi: `lib/services/pembersihan_data_service.dart`**

File ini adalah orkestrator yang memutuskan kapan proses pembersihan perlu dijalankan.

#### **Masalah Awal:**

Fungsi `jalankanJikaPerlu()` memanggil fungsi operasi tanpa parameter, sehingga masih bergantung pada nilai _hardcoded_.

#### **Detail Perubahan:**

- **Pengambilan Pengaturan:** Logika ditambahkan untuk mengambil `PengaturanModel` dari database.
- **Pemanggilan Fungsi Dinamis:** Nilai `hapusOtomatisDataArsip` dari pengaturan kini diteruskan sebagai parameter `batasHari` saat memanggil `hapusSemuaDataArsipKadaluarsa`.

#### **Hasil Akhir (Kode Baru):**

```dart
// path: lib/services/pembersihan_data_service.dart
Future<void> jalankanJikaPerlu() async {
  // ...
  final PengaturanModel pengaturan = await _pengaturanOperasi.getPengaturan();
  final int batasHari = pengaturan.hapusOtomatisDataArsip;

  final totalTerhapus = await _operasi.hapusSemuaDataArsipKadaluarsa(
    batasHari: batasHari,
  );
  // ...
}
```

---

### **3. File yang Dimodifikasi: `lib/fitur/pelanggan_aktif/screens/form_pelanggan_aktif.dart`**

**Fitur:** Formulir Aktivasi Pelanggan

#### **Masalah Awal (Bug):**

Saat data `PelangganAktif` diedit, transaksi yang terkait tidak ikut terbarui. Sebaliknya, sistem malah membuat transaksi baru setiap kali ada penyimpanan, menyebabkan duplikasi data. Ini terjadi karena `idTransaksi` tidak disimpan di `PelangganAktifModel`, sehingga hubungan antara keduanya putus saat diedit.

#### **Detail Perubahan (Perbaikan Bug):**

1.  **Penentuan ID Transaksi di Awal:** Logika diubah untuk menentukan `idTransaksi` di awal `_saveForm()`. Jika mode edit, ID lama digunakan kembali; jika mode baru, UUID baru dibuat.
2.  **Menyimpan Referensi ID:** `PelangganAktifModel` kini selalu diisi dengan `idTransaksi` saat disimpan, memastikan catatan aktivasi memiliki penunjuk ke transaksinya.
3.  **Penyimpanan Data Terpadu:** Logika `create` dan `update` untuk `PelangganAktif` dan `Transaksi` disatukan untuk memperjelas alur kerja.

#### **Hasil Akhir (Kode Baru di `_saveForm()`):**

```dart
// diubah: Tentukan ID transaksi di awal untuk menjaga konsistensi.
final String transaksiId =
    _isEditMode && widget.pelangganAktif?.idTransaksi != null
        ? widget.pelangganAktif!.idTransaksi!
        : const Uuid().v4();

final pelangganAktifData = PelangganAktifModel(
  // ... data lain
  idTransaksi: transaksiId, // ditambahkan: Menyimpan referensi ID transaksi
);

final transaksiData = TransaksiModel(
  id: transaksiId, // diubah: Menggunakan ID yang sudah ditentukan
  // ... data lain
);

// diubah: Logika penyimpanan digabung untuk memastikan atomicity
if (_isEditMode) {
  await widget.pelangganAktifOperasi.updatePelangganAktif(pelangganAktifData);
  await widget.transaksiOperasi.updateTransaksi(transaksiId, transaksiData);
} else {
  await widget.pelangganAktifOperasi.createPelangganAktif(pelangganAktifData);
  await widget.transaksiOperasi.tambahTransaksi(transaksiData);
}
```

---

### **4. File: `lib/halaman/pembantu/halaman_poin.dart`**

**Fitur:** Manajemen Poin Pelanggan

**Tujuan file ini dibuat:**
Menyediakan antarmuka (UI) bagi admin untuk mengelola dan memantau poin loyalitas pelanggan, melihat riwayat perolehan/penggunaan poin, dan melihat daftar hadiah yang dapat ditukarkan.

---

### **Analisis Kode Rinci `halaman_poin.dart`**

#### **1. `enum MenuPoin`**

- **Tujuan:** Mengontrol konten yang ditampilkan antara mode `penukaran` (daftar hadiah) dan `riwayat` (histori poin).

#### **2. `HalamanPoin` (StatefulWidget)**

- **Tujuan:** Kerangka utama halaman yang state-nya dinamis. Membutuhkan `idPelanggan` untuk mengambil data yang relevan.

#### **3. `_HalamanPoinState` (State Class)**

- **Tujuan:** Memegang semua data dan logika, termasuk total poin, daftar paket, dan menu yang aktif.
- **Metode Utama:**
  - `_loadData()`: Mengambil total poin pelanggan dan daftar paket dari database secara asinkron.
  - `build()`: Membangun UI, menampilkan indikator loading saat data diambil, dan kemudian menampilkan konten utama yang terdiri dari info total poin, tombol menu, dan daftar riwayat atau daftar paket.

#### **4. Fungsi dan Widget Pendukung**

- `_hitungProgressPencapaian()`: Fungsi utilitas untuk menghitung progres poin pelanggan terhadap poin yang dibutuhkan untuk menukar hadiah.
- `_listPaket()`: Menampilkan daftar paket hadiah, lengkap dengan `LinearProgressIndicator` untuk visualisasi progres.
- `_riwayatTransaksi()`: Menggunakan `FutureBuilder` untuk menampilkan riwayat transaksi poin pelanggan secara efisien.
  File: lib/model/transaksi_model.dart
  Fitur: Model Data Transaksi Terpadu
  Tujuan file ini dibuat: File ini mendefinisikan `TransaksiModel`, yang merupakan struktur data inti untuk semua jenis transaksi dalam aplikasi. Model ini telah direfaktor secara signifikan untuk menggabungkan data dari `RiwayatLanggananModel` yang sebelumnya terpisah. Tujuannya adalah untuk menjadi _single source of truth_ (sumber kebenaran tunggal) yang mencatat tidak hanya transaksi finansial (pemasukan, pengeluaran), tetapi juga semua aktivitas langganan paket. File ini menyediakan logika untuk membuat, mengubah, serta mengonversi data transaksi antara format aplikasi, format database SQLite lokal, dan format Firebase (Firestore).

---

### Analisis Kode Rinci

#### **enum `TipeTransaksi`**

- **Tujuan:** Mendefinisikan kategori utama dari setiap transaksi. Penambahan tipe `langganan` adalah bagian dari refactoring besar, yang memungkinkan sistem untuk mencatat aktivasi atau perpanjangan paket sebagai sebuah transaksi, bukan lagi sebagai entitas terpisah. Ini menyatukan logika bisnis dan mempermudah pelacakan.

#### **Class `TransaksiModel`**

- **Tujuan:** Kelas utama yang merepresentasikan satu entitas transaksi dengan semua atribut yang diperlukan.
- **Properti Inti:** Berisi field fundamental seperti `id`, `tanggal`, `keterangan`, `jumlah`, `tipe`, `idDompet`, dan `idKategori` yang menjadi dasar dari setiap transaksi.
- **Properti Tergabung (Hasil Denormalisasi):** Penambahan field `durasiPaket`, `tipeDurasiPaket`, `tanggalMulai`, dan `tanggalBerakhir`. Properti ini dipindahkan dari `RiwayatLanggananModel` dan digabungkan ke sini. Tujuannya adalah untuk menghilangkan kebutuhan join data dan membuat setiap record transaksi langganan menjadi mandiri dan lengkap.

#### **Metode `_parseDateTime(dynamic dateValue)`**

- **Tujuan:** Fungsi helper statis yang dirancang untuk mengonversi nilai tanggal dari berbagai format (seperti `Timestamp` dari Firebase, `String` dari SQLite, atau `DateTime` dari aplikasi) menjadi objek `DateTime` yang konsisten. Ini membuat model lebih tangguh terhadap berbagai sumber data.

#### **Factory `TransaksiModel.fromSqlite(Map<String, dynamic> map)`**

- **Tujuan:** Konstruktor pabrik yang bertugas membuat instance `TransaksiModel` dari data `Map` yang dibaca dari database SQLite. Metode ini secara spesifik memetakan nama kolom di tabel SQLite (misalnya, `id_dompet`, `tanggal_mulai`) ke properti yang sesuai di dalam model.

#### **Metode `toSqlite()`**

- **Tujuan:** Mengonversi objek `TransaksiModel` kembali menjadi sebuah `Map` dengan format kunci dan nilai yang sesuai untuk disimpan atau diperbarui ke dalam tabel di database SQLite. Objek `DateTime` diubah menjadi format string ISO 8601.

#### **Factory `TransaksiModel.fromFirebase(String id, Map<String, dynamic> data)`**

- **Tujuan:** Konstruktor pabrik yang membuat instance `TransaksiModel` dari data `Map` yang diterima dari dokumen Firestore. Metode ini menangani konversi tipe data spesifik Firebase seperti `Timestamp` menjadi `DateTime`.

#### **Metode `toFirebase()`**

- **Tujuan:** Mengonversi objek `TransaksiModel` menjadi `Map` untuk disimpan di Firestore. Metode ini menggunakan fitur spesifik Firebase seperti `FieldValue.serverTimestamp()` untuk mengisi field `diperbarui` secara otomatis di sisi server dan mengonversi `DateTime` ke `Timestamp` untuk konsistensi data.

#### **Metode `copyWith({...})`**

- **Tujuan:** Sebuah metode utilitas yang sangat penting untuk mendukung pola _immutability_. Metode ini memungkinkan pembuatan salinan (kloning) dari sebuah objek `TransaksiModel` sambil mengubah nilai dari satu atau beberapa propertinya. Ini sangat berguna di state management untuk memicu pembaruan UI secara efisien.
