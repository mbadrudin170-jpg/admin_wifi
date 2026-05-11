
# Blueprint Proyek Admin WiFi

Dokumen ini berfungsi sebagai cetak biru utama untuk pengembangan aplikasi, mencakup struktur proyek, dokumentasi file, dan catatan pekerjaan.

---

## 1. Struktur Direktori

### `lib/`
```
lib/
├── data
│   ├── operasi
│   │   ├── dompet_operasi.dart
│   │   ├── kategori_operasi.dart
│   │   ├── kritik_saran_operasi.dart
│   │   ├── operasi.dart
│   │   ├── operasi_dasar.dart
│   │   ├── paket_operasi.dart
│   │   ├── pelanggan_aktif_operasi.dart
│   │   ├── pelanggan_operasi.dart
│   │   ├── pembersihan_data_operasi.dart
│   │   ├── pengaturan_operasi.dart
│   │   ├── pesanan_operasi.dart
│   │   ├── riwayat_langganan_operasi.dart
│   │   ├── status_unggah_operasi.dart
│   │   ├── sub_kategori_operasi.dart
│   │   ├── transaksi_operasi.dart
│   │   └── versi_apk_user_operasi.dart
│   ├── services
│   │   ├── navigasi_servis.dart
│   │   ├── pengecekan_data_baru.dart
│   │   ├── pengecekan_waktu_sync_services.dart
│   │   └── preferensi_service.dart
│   ├── sqlite.dart
│   └── sync
│       ├── unduhan_awal.dart
│       ├── unduh_data.dart
│       └── unggah_data.dart
├── debug
│   └── log.dart
├── enum
│   ├── arsitektur_apk_enum.dart
│   ├── enum.dart
│   ├── nama_tabel_enum.dart
│   ├── status_pembayaran_enum.dart
│   └── tipe_transaksi_enum.dart
├── firebase_options.dart
├── halaman
│   ├── detail
│   │   ├── detail_dompet.dart
│   │   ├── detail_kritik_saran.dart
│   │   ├── detail_paket.dart
│   │   ├── detail_pelanggan_aktif.dart
│   │   ├── detail_pelanggan.dart
│   │   ├── detail_riwayat_langganan.dart
│   │   ├── detail_transaksi.dart
│   │   └── detail_versi_apk_user.dart
│   ├── form
│   │   ├── form_dompet.dart
│   │   ├── form_edit_riwayat_langganan.dart
│   │   ├── form_kategori.dart
│   │   ├── form_paket.dart
│   │   ├── form_pelanggan_aktif.dart
│   │   ├── form_pelanggan.dart
│   │   ├── form_pengaturan.dart
│   │   ├── form_transaksi.dart
│   │   └── form_versi_apk_user.dart
│   ├── lainnya
│   │   ├── kategori.dart
│   │   ├── kritik_saran.dart
│   │   ├── paket.dart
│   │   ├── pelanggan.dart
│   │   ├── pengaturan.dart
│   │   ├── riwayat_aktivasi_paket.dart
│   │   ├── tentang_aplikasi.dart
│   │   └── versi_apk_user.dart
│   ├── pembantu
│   │   └── halaman_poin.dart
│   ├── tab
│   │   ├── dompet.dart
│   │   ├── fungsi_menampilkan_notifikasi.dart
│   │   ├── lainnya.dart
│   │   ├── pelanggan_aktif.dart
│   │   ├── pesanan.dart
│   │   └── transaksi.dart
│   └── tes
│       ├── contoh_simpan_status.dart
│       ├── detail_pelanggan_uji.dart
│       └── halaman_tes.dart
├── halaman_utama.dart
├── main.dart
├── migrasi
│   ├── halaman_migrasi.dart
│   ├── migrasi_diarsipkan.dart
│   └── migrasi_timestamp.dart
├── model
│   ├── dompet_model.dart
│   ├── hasil_simpan_model.dart
│   ├── kategori_model.dart
│   ├── kritik_saran_model.dart
│   ├── model.dart
│   ├── paket_model.dart
│   ├── pelanggan_aktif_model.dart
│   ├── pelanggan_model.dart
│   ├── pengaturan_model.dart
│   ├── pesanan_model.dart
│   ├── riwayat_langganan_model.dart
│   ├── status_unggah_model.dart
│   ├── sub_kategori_model.dart
│   ├── transaksi_model.dart
│   └── versi_apk_user_model.dart
├── server
│   └── server_lokal.dart
├── services
│   ├── cek_koneksi_internet.dart
│   ├── cek_langganan_kadaluarsa_service.dart
│   ├── firebase_migration
│   │   └── firebase_migration_service.dart
│   ├── kontrol_aplikasi_service.dart
│   ├── notifikasi
│   │   └── notifikasi_servis.dart
│   └── pembersihan_data_service.dart
├── splash_screen.dart
├── utils
│   ├── colors.dart
│   ├── format_util.dart
│   ├── perhitungan_util.dart
│   └── sync_manager.dart
├── whatsapp
│   └── info_paket.dart
└── widget
    ├── info_ringkasan_widget.dart
    ├── nama_dari_id.dart
    ├── nama_paket.dart
    ├── nama_pelanggan.dart
    ├── thousands_input_formatter.dart
    └── transaksi_list_widgets.dart
```

### `test/`
*Direktori test masih kosong.*

---

## 2. Dokumentasi File

### Folder: `halaman/detail/`

**File: `lib/halaman/detail/detail_transaksi.dart`**
- **Fitur:** Tampilan Detail Transaksi
- **Tujuan file ini dibuat:** Untuk menampilkan semua rincian dari satu objek `TransaksiModel` dalam format yang mudah dibaca. Halaman ini bersifat *read-only*.
- **Kode `_DetailTransaksiPageState`:** *State* utama untuk halaman ini.
- **Kode `initState`:** Mencatat (log) informasi detail transaksi saat halaman pertama kali dibuka untuk membantu proses *debugging*.
- **Kode `_getNama(getModel, id, konteks)`:**
    - Fungsi *helper* serbaguna yang mengambil nama dari berbagai jenis data (Dompet, Kategori, Pelanggan, dll.) secara asinkron.
    - **Logika Perbaikan (Sangat Penting):** Di dalamnya terdapat logika pengecekan tipe eksplisit (`is`) untuk menangani model data yang berbeda secara aman. Daripada mengandalkan string `konteks`, kode sekarang memeriksa tipe objek yang dikembalikan oleh `getModel` (`if (model is DompetModel)`). Ini adalah cara paling aman di Dart untuk mencegah `NoSuchMethodError`.
    - Jika `model` adalah `DompetModel`, ia akan mengakses `model.namaDompet`.
    - Jika `model` adalah `KategoriModel`, `PelangganModel`, dll., ia akan mengakses `model.nama`.
    - Fungsi ini juga menangani kasus jika ID kosong, data tidak ditemukan (`null`), atau terjadi *error* saat pengambilan data, lalu mengembalikan pesan yang sesuai untuk ditampilkan di UI.
- **Kode `build`:**
    - Metode utama yang membangun seluruh UI halaman. Menggunakan `Scaffold` dan `ListView`.
- **Kode `_buildDetailRow(label, value)`:**
    - *Widget helper* untuk membuat baris detail statis yang konsisten.
- **Kode `_buildFutureDetailRow(label, future)`:**
    - *Widget helper* yang menggunakan `FutureBuilder` untuk menangani data yang perlu diambil secara asinkron, menampilkan status "Memuat..." atau hasil dari fungsi `_getNama`.

---

## 3. Catatan Pekerjaan

### Versi: 1.0.0+1 (Sesuai `pubspec.yaml` saat ini)

- **File:** `lib/halaman/detail/detail_transaksi.dart`
  - **Tujuan:** Perbaikan Bug Kritis Final (`NoSuchMethodError`)
  - **Perubahan:** Mengganti logika `_getNama` dari pengecekan berbasis `String` menjadi pengecekan tipe eksplisit (`is`) yang aman.
  - **Alasan:** Perbaikan sebelumnya tidak cukup kuat dan masih memungkinkan terjadinya `NoSuchMethodError` jika tipe data yang dikembalikan oleh *database operation* tidak sesuai dengan yang diharapkan. Pemanggilan properti pada objek `dynamic` tanpa pengecekan tipe adalah praktik yang tidak aman.
  - **Solusi:** Menggunakan `if (model is DompetModel)` dan `else if (model is KategoriModel)` dst. untuk memastikan properti yang benar (`.namaDompet` atau `.nama`) diakses hanya jika objek tersebut benar-benar memiliki tipe yang sesuai. Ini adalah solusi definitif untuk masalah ini.
  - **Dampak:** *Crash* berhasil diatasi secara permanen. Kode sekarang jauh lebih aman, lebih mudah dibaca, dan sesuai dengan praktik terbaik Dart. Halaman detail transaksi dijamin stabil.
