# 🚀 Aplikasi Admin WiFi

![Versi Aplikasi](https://img.shields.io/badge/version-1.0.0-blue)
![Build Number](https://img.shields.io/badge/build-1-lightgrey)
![Lisensi](https://img.shields.io/badge/license-MIT-green)

Aplikasi manajemen pelanggan WiFi untuk membantu admin mengelola data pelanggan, paket langganan, dan tagihan secara efisien.

---

## 📜 Daftar Isi

- [Fitur Utama](#-fitur-utama)
- [Struktur Proyek](#-struktur-proyek)
- [Panduan Developer](#-panduan-developer)
  - [Aturan Umum](#aturan-umum)
  - [Manajemen State](#manajemen-state)
  - [Alur Kerja Git](#alur-kerja-git)
  - [Checklist Rilis](#checklist-rilis)
- [Dokumentasi Kode](#-dokumentasi-kode)
  - [/lib/data](#libdata)
  - [/lib/halaman](#libhalaman)
  - [/lib/model](#libmodel)
  - [/lib/services](#libservices)
  - [/lib/utils](#libutils)
  - [/lib/widget](#libwidget)
- [Kontribusi](#-kontribusi)
- [Lisensi](#-lisensi)

---

## ✨ Fitur Utama

- **Manajemen Pelanggan**: Menambah, mengubah, dan melihat data pelanggan.
- **Manajemen Paket**: Mengelola berbagai jenis paket internet yang ditawarkan.
- **Langganan Aktif**: Melacak pelanggan yang sedang aktif berlangganan.
- **Riwayat Langganan**: Menyimpan catatan riwayat semua transaksi dan langganan.
- **Notifikasi Otomatis**: Pengingat otomatis untuk tagihan yang akan jatuh tempo (H-1 dan H-3).
- **Pengarsipan Otomatis**: Pelanggan yang sudah tidak aktif akan diarsipkan secara otomatis.
- **Pencarian & Penyaringan**: Fitur pencarian dan pengurutan data yang komprehensif.
- **Sinkronisasi Firebase**: Data disinkronkan dengan Firestore untuk backup dan aksesibilitas.
- **Integrasi WhatsApp**: Mengirim rincian paket langsung ke pelanggan melalui WhatsApp.

---

## 📁 Struktur Proyek

```
lib/
├── data/
│   ├── operasi/      # Logika CRUD untuk interaksi database (SQLite & Firebase)
│   └── sqlite.dart   # Konfigurasi dan inisialisasi database SQLite
├── halaman/
│   ├── detail/       # Halaman untuk menampilkan detail item
│   ├── form/         # Formulir untuk menambah atau mengedit data
│   └── tab/          # Halaman utama yang berisi TabBarView
├── model/
│   ├── enum/         # Definisi Enum yang digunakan di seluruh aplikasi
│   └── *.dart        # Kelas-kelas model data (contoh: PelangganModel)
├── services/
│   └── *.dart        # Layanan background (notifikasi, sinkronisasi, dll.)
├── utils/
│   └── *.dart        # Fungsi-fungsi utilitas (format tanggal, perhitungan, dll.)
├── widget/
│   └── *.dart        # Widget-widget yang dapat digunakan kembali
├── main.dart         # Titik masuk utama aplikasi
└── whatsapp/
    └── *.dart        # Logika untuk integrasi dengan WhatsApp
```

---

## 👨‍💻 Panduan Developer

### Aturan Umum

1.  **Bahasa**: Seluruh kode (variabel, fungsi, file) dan komunikasi **wajib** menggunakan **Bahasa Indonesia**.
2.  **Komentar**: Setiap file wajib memiliki komentar path di baris atas (`// path: lib/...`). Setiap fungsi harus memiliki penjelasan tujuannya.
3.  **Async**: Semua operasi I/O (database, network) wajib menggunakan `async/await` dengan `Future`. Hindari `.then()`.
4.  **Safety**: Gunakan `if (!mounted) return;` untuk operasi `async` di dalam `StatefulWidget`.
5.  **Logging**: Gunakan `developer.log()` untuk debugging, bukan `print()`.

### Manajemen State

- **State Lokal**: Untuk state yang hanya relevan di dalam satu widget, gunakan `StatefulWidget` dengan `setState()`.
- **State Aplikasi**: Untuk state yang perlu dibagikan ke seluruh aplikasi, pertimbangkan arsitektur yang lebih solid seperti **Provider** atau **Riverpod** (saat ini belum diimplementasikan).

### Alur Kerja Git

1.  **Branch**:
    - `main`: Cabang utama yang stabil. Hanya menerima *merge* dari `develop`.
    - `develop`: Cabang pengembangan utama. Semua fitur baru di-*merge* ke sini.
    - `feature/<nama-fitur>`: Cabang untuk pengembangan fitur baru.
    - `bugfix/<deskripsi-bug>`: Cabang untuk perbaikan bug.
2.  **Commit**: Gunakan pesan commit yang deskriptif (contoh: `feat: Menambahkan fitur login pelanggan`).

### Checklist Rilis

- [ ] Pastikan semua pengujian (unit & integrasi) lolos.
- [ ] Jalankan `flutter analyze` dan pastikan tidak ada *issues*.
- [ ] Perbarui `CHANGELOG.md`.
- [ ] **Bugfix**: Naikkan `build number` di `pubspec.yaml`.
- [ ] **Fitur Baru**: Naikkan `version` dan `build number` di `pubspec.yaml`.
- [ ] Buat *tag* Git baru (`git tag -a v1.x.x -m "Rilis v1.x.x"`).
- [ ] *Merge* `develop` ke `main`.
- [ ] Jalankan perintah build:
      ```bash
      flutter clean && flutter pub get && flutter build apk --release --split-per-abi
      ```

---

##  документация кода

### /lib/data

#### `lib/data/sqlite.dart`
- **Fitur**: Database Management
- **Daftar Fungsi**:
  - `_initDatabase()`: Menginisialisasi dan membuat tabel-tabel yang diperlukan jika belum ada.
  - `_onUpgrade()`: Menangani migrasi skema database ketika versi berubah.
- **Catatan**: Pusat konfigurasi untuk database SQLite lokal.

#### `lib/data/operasi/pelanggan_operasi.dart`
- **Fitur**: CRUD Pelanggan
- **Daftar Fungsi**:
  - `createPelanggan()`: Menambah pelanggan baru ke database lokal.
  - `getPelanggan()`: Mengambil semua data pelanggan.
  - `getPelangganById()`: Mengambil pelanggan berdasarkan ID.
  - `updatePelanggan()`: Memperbarui data pelanggan.
  - `deletePelanggan()`: Menghapus data pelanggan.

#### `lib/data/operasi/paket_operasi.dart`
- **Fitur**: CRUD Paket
- **Daftar Fungsi**:
  - `createPaket()`: Menambah paket baru.
  - `getAllPaket()`: Mengambil semua paket yang tersedia.
  - `getPaketById()`: Mengambil paket berdasarkan ID.
  - `updatePaket()`: Memperbarui data paket.
  - `deletePaket()`: Menghapus paket.

#### `lib/data/operasi/pelanggan_aktif_operasi.dart`
- **Fitur**: Manajemen Langganan Aktif
- **Daftar Fungsi**:
  - `createPelangganAktif()`: Mendaftarkan pelanggan ke paket aktif.
  - `ambilSemuaPelangganAktif()`: Mengambil semua pelanggan yang sedang aktif.
  - `updatePelangganAktif()`: Memperbarui detail langganan (misal: perpanjang).
  - `arsipkanPelangganAktif()`: Mengarsipkan data pelanggan aktif secara manual (soft delete).
  - `arsipkanSemuaPelangganAktif()`: Mengarsipkan semua pelanggan aktif yang ada.
  - `arsipkanPelangganKadaluarsa()`: Mengarsipkan semua pelanggan yang masa aktifnya telah berakhir secara otomatis.
- **Rules**: Fungsi `create` dan `update` secara otomatis menjadwalkan notifikasi jatuh tempo.

#### `lib/data/operasi/riwayat_langganan_operasi.dart`
- **Fitur**: Manajemen Riwayat
- **Daftar Fungsi**:
  - `tambahRiwayatLangganan()`: Menambahkan catatan baru ke riwayat setelah langganan selesai atau diarsipkan.
  - `getRiwayatLangganan()`: Mengambil semua data riwayat.

---

*(Bagian dokumentasi untuk folder lain akan mengikuti format yang sama)*

---

## 🤝 Kontribusi

Kontribusi dalam bentuk *pull request* atau laporan *issue* sangat kami hargai. Mohon ikuti [Panduan Developer](#-panduan-developer) yang telah ditetapkan.

## 📄 Lisensi

Proyek ini dilisensikan di bawah [Lisensi MIT](LICENSE).
