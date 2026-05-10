# Blueprint Proyek

Dokumen ini adalah sumber kebenaran tunggal untuk arsitektur, fitur, dan rencana kerja proyek.

---

## Catatan Pekerjaan

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
penecekan_data_baru_firebase.dart
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
status_unduh_model.dart
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
notifikasi_servis.dart
pembersihan_data_service.dart
servis_sinkronisasi.dart

lib/services/firebase_migration:
firebase_migration_service.dart

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

### Folder: `lib/data/services/`

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

**File**: `lib/data/services/penecekan_data_baru_firebase.dart`
**Fitur**: Pengecekan Sinkronisasi Data
**Tujuan file ini dibuat**: Untuk menyediakan sebuah mekanisme yang efisien dalam memeriksa apakah ada data baru di server Firebase yang perlu diunduh ke aplikasi klien.
**Kode A**: `class PengecekanDataBaruService`
- **Penjelasan**: Kelas utama yang menampung semua logika terkait pengecekan data baru. Ini dibuat sebagai kelas servis untuk memisahkan logika dari UI dan memudahkan penggunaan kembali.
**Kode B**: `Future<bool> apakahAdaDataBaru({required String namaKoleksi, required String idDokumen})`
- **Penjelasan**: Fungsi inti dari servis ini. Fungsi ini melakukan langkah-langkah berikut:
  1. Mengambil *timestamp* sinkronisasi terakhir yang tersimpan di perangkat melalui `SyncManager`.
  2. Melakukan **satu kali pembacaan** ke dokumen status global di Firebase (ditentukan oleh `namaKoleksi` dan `idDokumen`).
  3. Membandingkan *timestamp* `diperbarui` dari dokumen Firebase dengan *timestamp* lokal.
  4. Mengembalikan `true` jika data di Firebase lebih baru, dan `false` jika tidak atau terjadi error. Ini mencegah pembacaan yang tidak perlu dan menghemat sumber daya.
