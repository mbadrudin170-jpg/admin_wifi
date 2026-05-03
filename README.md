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
unduh_data.dart   unggah_data.dart

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
## Dokumentasi File

### File: lib/data/sync/unduh_data.dart
*   **Fitur**: Menyediakan layanan terpusat untuk mengunduh (sinkronisasi) semua data dari Firestore ke database SQLite lokal.
*   **Daftar Fungsi**:
    *   `unduhSemuaData()`: Fungsi utama yang memanggil unduhan untuk setiap koleksi data secara paralel.
    *   `_unduhKoleksi<T>()`: Fungsi generik privat yang menangani logika untuk mengambil data dari satu koleksi Firestore, mengubah setiap dokumen menjadi objek model Dart, dan menyimpannya ke tabel SQLite yang sesuai secara massal (batch).
*   **Catatan**: File ini adalah bagian dari refaktorisasi arsitektur sinkronisasi. Tujuannya adalah untuk memisahkan logika unduh dari Firebase, membuatnya menjadi satu proses yang terkoordinasi.

### File: lib/data/sync/unggah_data.dart
*   **Fitur**: Menyediakan layanan terpusat untuk mengunggah semua data dari database SQLite lokal ke Firestore.
*   **Daftar Fungsi**:
    *   `unggahSemuaPerubahan()`: Fungsi utama yang memulai proses unggah untuk semua jenis data (dompet, kategori, paket, dll.) secara paralel.
    *   `_unggahPerubahan<T>()`: Fungsi generik privat yang mengambil semua data dari satu tabel SQLite, mengubahnya menjadi format `Map`, dan mengunggahnya ke koleksi Firestore. Proses ini menggunakan ID dokumen untuk menimpa data yang ada, memastikan konsistensi.
*   **Catatan**: File ini menangani alur sinkronisasi dari lokal ke remote (Firebase). Ini menyederhanakan logika di seluruh aplikasi, karena komponen UI tidak perlu lagi tahu cara mengunggah data.

### File: lib/data/services/sinkronisasi_database.dart
*   **Fitur**: Mengorkestrasi proses sinkronisasi data antara aplikasi dan Firebase.
*   **Daftar Fungsi**:
    *   `sinkronisasiData()`: Memeriksa apakah ini adalah sinkronisasi pertama kali. Jika ya, akan memulai `_sinkronisasiAwal`.
    *   `_sinkronisasiAwal()`: Menjalankan proses unduh data dari semua koleksi di Firebase ke database lokal.
*   **Catatan**: Logika sinkronisasi inkremental telah dihapus untuk simplifikasi. File ini sekarang hanya bertanggung jawab untuk memastikan data awal dari Firebase tersedia di perangkat lokal saat aplikasi pertama kali dijalankan.

### File: lib/data/operasi/pelanggan_aktif_operasi.dart
*   **Fitur**: Operasi data untuk pelanggan yang sedang memiliki paket aktif.
*   **Daftar Fungsi**:
    *   `createPelangganAktif()`: Membuat data pelanggan aktif baru.
    *   `ambilSemuaPelangganAktif()`: Mengambil semua data pelanggan aktif.
    *   `updatePelangganAktif()`: Memperbarui data pelanggan aktif.
    *   `hapusPelangganAktif()`: Menghapus data pelanggan aktif secara permanen (*hard delete*).
    *   `sisipkanAtauPerbaruiBatch()`: Memasukkan/memperbarui data secara massal.
*   **Catatan**: Semua logika `SyncStatus` dan fungsi terkait sinkronisasi (`unggahKeFirebase`, `unduhPelangganAktif`) telah dihapus. Operasi sekarang langsung ke database lokal.

### File: lib/model/pelanggan_aktif_model.dart
*   **Fitur**: Model data untuk entitas Pelanggan Aktif.
*   **Catatan**: Properti `syncStatus` yang sebelumnya melacak status sinkronisasi data telah dihapus sepenuhnya untuk menyederhanakan model.

### File: lib/data/operasi/transaksi_operasi.dart
*   **Fitur**: Operasi CRUD (Create, Read, Update, Delete) untuk data transaksi keuangan.
*   **Daftar Fungsi**:
    *   `tambahTransaksi()`, `ambilSemuaTransaksi()`, `updateTransaksi()`, `deleteTransaksi()`: Fungsi dasar CRUD.
    *   `getTotalPemasukan()`, `getTotalPengeluaran()`, `getNetTotal()`: Fungsi agregasi untuk perhitungan saldo.
    *   `sisipkanAtauPerbaruiBatch()`: Menyisipkan atau memperbarui beberapa data transaksi sekaligus.
*   **Catatan**: Nama fungsi `sisipkanBatch` diubah menjadi `sisipkanAtauPerbaruiBatch` untuk konsistensi dan memperbaiki error analisis.

### File: lib/halaman/form/form_pelanggan_aktif.dart
*   **Fitur**: Menyediakan formulir untuk menambah atau mengedit data pelanggan aktif.
*   **Catatan**: Referensi ke `SyncStatus` telah dihapus sepenuhnya dari file ini. Saat menyimpan data, objek `PelangganAktifModel` dibuat tanpa properti `syncStatus`, menyederhanakan proses penyimpanan.

### File: lib/halaman/tab/dompet.dart
*   **Fitur**: Menampilkan daftar dompet dan ringkasan keuangan.
*   **Catatan**: Fungsi untuk memicu unggah data ke Firebase (`_unggahKeFirebase`) beserta tombol dan indikator loading di `AppBar` telah dihapus. Sinkronisasi tidak lagi dikontrol dari halaman ini.

### File: lib/halaman/tab/pelanggan_aktif.dart
*   **Fitur**: Menampilkan daftar semua pelanggan yang paketnya sedang aktif.
*   **Catatan**: Semua fungsionalitas yang terkait dengan sinkronisasi manual (`_sinkronkanDataKeFirebase`), filter untuk data yang belum sinkron, dan ikon status sinkronisasi pada item daftar telah dihapus. `RefreshIndicator` sekarang hanya berfungsi untuk memuat ulang data dari database lokal.

### File: lib/services/cek_langganan_kadaluarsa_service.dart
*   **Fitur**: Layanan untuk memeriksa dan mengarsipkan langganan yang telah habis masa berlakunya secara otomatis.
*   **Catatan**: Logika pengecekan `syncStatus` telah dihapus. Proses pengarsipan sekarang hanya didasarkan pada `tanggalBerakhir` tanpa mempedulikan status sinkronisasi data.
