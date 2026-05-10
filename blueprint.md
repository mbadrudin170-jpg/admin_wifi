# Blueprint Proyek

Dokumen ini adalah sumber kebenaran tunggal untuk arsitektur, fitur, dan rencana kerja proyek.

---

## Catatan Pekerjaan

### v1.0.3 (Perbaikan Kritis & Efisiensi Sinkronisasi)
- **lib/data/sync/unduh_data.dart**:
  - **Tujuan**: Mengoptimalkan proses unduh data agar hanya mengambil data yang benar-benar baru dari server, serta memperbaiki logika khusus pada tabel `pengaturan`.
  - **Perubahan**:
    1.  Mengintegrasikan `SyncManager` untuk mendapatkan *timestamp* unduhan terakhir.
    2.  Memodifikasi fungsi `sinkronisasiKoleksi` untuk menambahkan filter `.where('diperbarui', isGreaterThan: waktuUnduhTerakhir)` pada query Firestore.
    3.  Memastikan `SyncManager` memperbarui *timestamp* hanya setelah semua proses unduh berhasil.
    4.  Menghapus logika unduh yang berbeda untuk tabel `pengaturan` dan membuatnya konsisten dengan tabel lain.
  - **Alasan**: Mencegah pengunduhan seluruh data setiap kali sinkronisasi berjalan, yang sangat boros kuota baca Firebase dan memperlambat aplikasi. Perbaikan ini mengimplementasikan **unduhan inkremental** yang jauh lebih efisien.

- **lib/data/sync/unggah_data.dart**:
  - **Tujuan**: Memperbaiki bug kritis yang menyebabkan data diunggah berulang kali dan menyederhanakan logika unggah.
  - **Perubahan**:
    1.  Mengaktifkan kembali baris `_syncManager.setTerakhirUnggah()` yang sebelumnya dikomentari, untuk memastikan *timestamp* unggah diperbarui setelah proses selesai.
    2.  Menghapus logika khusus yang tidak perlu untuk tabel `pengaturan`, membuatnya konsisten dengan tabel lain.
    3.  Menyederhanakan fungsi `unggahDataGenerik` untuk menghapus penanganan ID dokumen yang salah untuk tabel `pengaturan`.
  - **Alasan**: Memperbaiki bug yang menyebabkan pemborosan kuota tulis Firestore dan beban server yang tidak perlu. Tanpa perbaikan ini, sinkronisasi unggah tidak bekerja secara inkremental.

- **lib/enum/nama_tabel_enum.dart**:
  - **Tujuan**: Menjaga konsistensi antara `enum` dan skema database SQLite yang sesungguhnya.
  - **Perubahan**: Menghapus `riwayatLangganan` dan menambahkan `statusUnggah` agar `enum` mencerminkan tabel yang benar-benar ada.
  - **Alasan**: Mencegah potensi *runtime error* dan memastikan bahwa semua layanan yang bergantung pada `enum` ini (seperti `PengecekanDataBaruService`) beroperasi dengan benar.

- **lib/data/services/pengecekan_data_baru.dart**:
  - **Tujuan**: Menyesuaikan fungsi konversi nama tabel dengan perubahan pada `enum NamaTabel`.
  - **Perubahan**: Memperbarui fungsi `_camelToSnake` untuk menangani kasus `statusUnggah` dan menghapus `riwayatLangganan`.
  - **Alasan**: Untuk menjaga sinkronisasi antara `enum`, konverter nama, dan skema database, memastikan layanan pengecekan data baru tetap berfungsi dengan benar setelah perubahan `enum`.


### v1.0.2 (Refactor Layanan Sinkronisasi)
- **lib/data/services/pengecekan_data_baru.dart**:
  - **Tujuan**: Memusatkan semua logika pengecekan data baru (baik dari server maupun lokal) ke dalam satu layanan tunggal.
  - **Perubahan**: Mengubah nama file dari `penecekan_data_baru_firebase.dart` menjadi `pengecekan_data_baru.dart`. Menambahkan metode baru `apakahSqliteAdaDataBaru()` yang berisi logika untuk memeriksa perubahan di database lokal. Mengganti daftar tabel *hardcoded* dengan enum `NamaTabel` untuk meningkatkan keamanan dan keterbacaan.
  - **Alasan**: Mematuhi prinsip *Single Responsibility*. Satu layanan kini bertanggung jawab penuh untuk menjawab pertanyaan "apakah ada data baru?", yang menyederhanakan arsitektur dan mengurangi duplikasi.

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
form_pelanggan_aktif.dart
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
pelanggan_aktif.dart
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

### Folder: `lib/data/sync/`

**File**: `lib/data/sync/unduh_data.dart`
**Fitur**: Sinkronisasi Data (Unduh Inkremental)
**Tujuan file ini dibuat**: Untuk mengelola proses pengunduhan data dari Firestore ke database SQLite lokal secara efisien.
**Kode A**: `class LayananUnduhData`
- **Penjelasan**: Kelas utama yang bertanggung jawab untuk mengunduh semua data yang relevan dari server.
**Kode B**: `Future<void> unduhSemuaData()`
- **Penjelasan**: Metode orkestrasi utama. Metode ini mengambil *timestamp* unduhan terakhir dari `SyncManager`, memulai proses unduhan untuk semua koleksi secara bersamaan, dan jika berhasil, memperbarui *timestamp* unduhan ke waktu saat ini.
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
- **Penjelasan**: Fungsi inti yang generik untuk mengunggah data dari satu tabel lokal. Fungsi ini mengambil semua data dari tabel SQLite yang memiliki `diperbarui` lebih baru dari *timestamp* unggah terakhir dan mengirimkannya ke Firestore menggunakan operasi `batch.set` dengan `SetOptions(merge: true)`. Logika khusus yang salah untuk tabel `pengaturan` telah dihapus.

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
  1. Mengambil *timestamp* unggah terakhir dari `SyncManager`.
  2. Mengambil daftar nama tabel secara dinamis dari enum `NamaTabel` (untuk menghindari kesalahan pengetikan) dan mengubahnya ke format `snake_case`.
  3. Melakukan query `COUNT(*)` pada setiap tabel untuk mencari record dengan `diperbarui` lebih baru dari *timestamp* unggah terakhir.
  4. Mengembalikan `true` segera setelah menemukan perubahan di salah satu tabel.
**Kode C**: `Future<bool> apakahFirebaseAdaDataBaru(...)`
- **Penjelasan**: Fungsi ini memeriksa apakah ada data baru di server Firebase dengan cara membandingkan *timestamp* `diperbarui` dari dokumen status global di Firestore dengan *timestamp* unduh terakhir yang disimpan secara lokal.

**File**: `lib/data/services/pengecekan_waktu_sync_services.dart`
**Fitur**: Orkestrasi Sinkronisasi Data
**Tujuan file ini dibuat**: Untuk bertindak sebagai pengatur utama (orkestrator) yang memutuskan kapan proses sinkronisasi (baik unggah maupun unduh) harus dijalankan.
**Kode A**: `class PengecekanWaktuSyncService`
- **Penjelasan**: Kelas ini tidak berisi logika pengecekan data secara langsung. Sebaliknya, ia mendelegasikan tugas tersebut ke `PengecekanDataBaruService`.
**Kode B**: `Future<void> _cekDanJalankanUnggah()`
- **Penjelasan**: Metode ini memanggil `_pengecekanDataBaru.apakahSqliteAdaDataBaru()`. Jika hasilnya `true`, maka ia akan memicu `LayananUnggahData` untuk memulai proses unggah ke server.
**Kode C**: `Future<void> _cekDanJalankanUnduh()`
- **Penjelasan**: Metode ini memanggil `_pengecekanDataBaru.apakahFirebaseAdaDataBaru(...)`. Jika hasilnya `true`, maka ia akan memicu `LayananUnduhData` untuk memulai proses unduh dari server.

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
