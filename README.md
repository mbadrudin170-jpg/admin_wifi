# Struktur proyek


admin-flutter-61275337:~/myapp{main}$ ls -R lib/
lib/:
data                   halaman_utama.dart       model     splash_screen.dart  widget
firebase_options.dart  main.dart                server    utils
halaman                migrasi_diarsipkan.dart  services  whatsapp

lib/data:
operasi  services  sqlite.dart  sync

lib/data/operasi:
dompet_operasi.dart        paket_operasi.dart            pesan_operasi.dart
kategori_operasi.dart      pelanggan_aktif_operasi.dart  riwayat_langganan_operasi.dart
kritik_saran_operasi.dart  pelanggan_operasi.dart        transaksi_operasi.dart

lib/data/services:
navigasi_servis.dart  sinkronisasi_database.dart

lib/data/sync:
unggah_data.dart

lib/halaman:
detail  form  lainnya  tab

lib/halaman/detail:
detail_dompet.dart        detail_pelanggan_aktif.dart    detail_transaksi.dart
detail_kritik_saran.dart  detail_pelanggan.dart
detail_paket.dart         detail_riwayat_langganan.dart

lib/halaman/form:
form_dompet.dart                  form_kategori.dart  form_pelanggan_aktif.dart  form_transaksi.dart
form_edit_riwayat_langganan.dart  form_paket.dart     form_pelanggan.dart

lib/halaman/lainnya:
kategori.dart      paket.dart      riwayat_aktivasi_paket.dart
kritik_saran.dart  pelanggan.dart  tentang_aplikasi.dart

lib/halaman/tab:
dompet.dart                         home.dart     pelanggan_aktif.dart  transaksi.dart
fungsi_menampilkan_notifikasi.dart  lainnya.dart  pesan.dart

lib/model:
dompet_model.dart    kritik_saran_model.dart     pelanggan_model.dart          transaksi_model.dart
enum                 paket_model.dart            pesanan_model.dart
kategori_model.dart  pelanggan_aktif_model.dart  riwayat_langganan_model.dart

lib/model/enum:
status_pembayaran.dart

lib/server:
server_lokal.dart

lib/services:
cek_koneksi_internet.dart  cek_langganan_kadaluarsa_service.dart  notifikasi_servis.dart

lib/utils:
colors.dart  format_util.dart  perhitungan_util.dart  sync_manager.dart

lib/whatsapp:
info_paket.dart

lib/widget:
nama_dari_id.dart  nama_paket.dart  nama_pelanggan.dart  thousands_input_formatter.dart
admin-flutter-61275337:~/myapp{main}$ 

---
## Dokumentasi File Model

Berikut adalah dokumentasi untuk setiap file model yang telah diubah:

**File: lib/model/dompet_model.dart**
*   **Fitur**: Dompet
*   **Daftar Fungsi**:
    *   `DompetModel()`: Konstruktor untuk membuat instance Dompet.
    *   `copyWith()`: Menyalin instance dengan nilai properti yang diperbarui.
    *   `fromMap()`: Membuat instance DompetModel dari sebuah map (dari database).
    *   `toMap()`: Mengonversi instance DompetModel menjadi sebuah map (untuk database).
*   **Catatan**: Model ini merepresentasikan sebuah dompet untuk menyimpan uang. Properti `syncStatus` telah dihapus karena tidak lagi digunakan.

**File: lib/model/kategori_model.dart**
*   **Fitur**: Kategori & Sub-Kategori
*   **Daftar Fungsi**:
    *   `KategoriModel()`: Konstruktor untuk membuat instance Kategori.
    *   `copyWith()`: Menyalin instance KategoriModel.
    *   `fromMap()`: Membuat instance KategoriModel dari map.
    *   `toMap()`: Mengonversi KategoriModel ke map.
    *   `SubKategoriModel()`: Konstruktor untuk membuat instance SubKategori.
    *   `copyWith()`: Menyalin instance SubKategoriModel.
    *   `fromMap()`: Membuat instance SubKategoriModel dari map.
    *   `toMap()`: Mengonversi SubKategoriModel ke map.
*   **Catatan**: Mengelola data kategori dan sub-kategori untuk transaksi. Kedua model kini mendukung soft delete (`isDeleted`) dan pengarsipan (`diarsipkan`).

**File: lib/model/pelanggan_model.dart**
*   **Fitur**: Pelanggan
*   **Daftar Fungsi**:
    *   `PelangganModel()`: Konstruktor untuk membuat instance Pelanggan.
    *   `copyWith()`: Menyalin instance dengan nilai properti yang diperbarui.
    *   `fromMap()`: Membuat instance PelangganModel dari map.
    *   `toMap()`: Mengonversi PelangganModel ke map.
*   **Catatan**: Model ini merepresentasikan data master pelanggan. Telah dilengkapi metode `copyWith` untuk konsistensi dan sudah mendukung status `aktif` dan `diarsip`.

**File: lib/model/pesanan_model.dart**
*   **Fitur**: Pesanan
*   **Daftar Fungsi**:
    *   `PesananModel()`: Konstruktor untuk membuat instance Pesanan.
    *   `copyWith()`: Menyalin instance dengan nilai properti yang diperbarui.
    *   `fromMap()`: Membuat instance PesananModel dari map (diadaptasi untuk SQLite dan Firestore).
    *   `toMap()`: Mengonversi PesananModel ke map.
*   **Catatan**: Model ini merepresentasikan pesanan paket oleh pelanggan. Telah diselaraskan dengan model lain dengan penambahan `diperbarui`, `isDeleted`, dan `diarsipkan` untuk mendukung pelacakan perubahan, soft delete, dan pengarsipan.

**File: lib/model/pelanggan_aktif_model.dart**
*   **Fitur**: Pelanggan Aktif
*   **Daftar Fungsi**:
    *   `PelangganAktifModel()`: Konstruktor untuk membuat instance Pelanggan Aktif.
    *   `copyWith()`: Menyalin instance dengan nilai properti yang diperbarui.
    *   `fromMap()`: Membuat instance PelangganAktifModel dari sebuah map (dari database).
    *   `toMap()`: Mengonversi instance PelangganAktifModel menjadi sebuah map (untuk database).
*   **Catatan**: Model ini merepresentasikan langganan aktif seorang pelanggan. Properti `syncStatus` telah dihapus.

**File: lib/model/transaksi_model.dart**
*   **Fitur**: Transaksi
*   **Daftar Fungsi**:
    *   `TransaksiModel()`: Konstruktor untuk membuat instance Transaksi.
    *   `salinDengan()`: Menyalin instance dengan nilai properti yang diperbarui.
    *   `fromMap()`: Membuat instance TransaksiModel dari sebuah map (dari database).
    *   `toMap()`: Mengonversi instance TransaksiModel menjadi sebuah map (untuk database).
*   **Catatan**: Model ini merepresentasikan transaksi keuangan. Properti `syncStatus` telah dihapus.
