# admin_wifi

Aplikasi Flutter untuk mengelola pelanggan WiFi: aktivasi dan pemantauan paket langganan, pencatatan dompet & transaksi, pengelolaan katalog paket/kategori/pelanggan, serta sinkronisasi dua arah antara basis data lokal (SQLite) dan Firebase Firestore. Aplikasi ini dikembangkan untuk perangkat Android (dengan dukungan web melalui `sqflite_common_ffi_web`), bersifat internal/private, dan **tidak diterbitkan ke pub.dev** (`publish_to: "none"`).

## Tujuan Proyek

- Menyediakan alat kerja tunggal bagi admin WiFi untuk mengelola pelanggan aktif: pendaftaran, perpanjangan, pelacakan tanggal berakhir, dan arsip langganan yang sudah kedaluwarsa.
- Menyediakan pencatatan keuangan sederhana (dompet) dan riwayat transaksi pemasukan/pengeluaran yang terhubung dengan aktivitas langganan.
- Menjaga data tetap selaras antara perangkat admin dan server Firebase melalui mekanisme sinkronisasi dua arah dengan pengecekan "ada data baru?" yang hemat baca/tulis.

## Fitur

### Navigasi utama (bottom navigation, 5 tab)

- **Aktif** — daftar pelanggan aktif (paket, sisa masa aktif, batas berakhir, status pembayaran). Mendukung pencarian, pengurutan (tanggal berakhir/mulai/diperbarui, nama A–Z/Z–A, status pembayaran lunas/belum lunas, paket aktif/tidak aktif), buka detail, tambah, arsip (satuan, semua, atau khusus yang kedaluwarsa). Sumber data: `penggunaAktifProvider` (Riverpod codegen) dengan satu sumber kebenaran dari SQLite.
- **Dompet** — daftar dompet, ringkasan saldo/pemasukan/pengeluaran, detail dompet beserta riwayat transaksi per dompet.
- **Transaksi** — daftar transaksi pemasukan/pengeluaran, detail transaksi (termasuk relasi dompet, kategori, dan pelanggan).
- **WiFi** — analisis jaringan WiFi: informasi jaringan terhubung (SSID, BSSID, IP, band, frekuensi, channel, sinyal), ping router (ICMP dengan fallback TCP), daftar access point di sekitar (SSID, BSSID, band, frekuensi, channel, sinyal), serta daftar perangkat terhubung ke WiFi yang sama (IP, nama, MAC, vendor, latensi) dengan pemindaian otomatis dan auto-refresh berkala.
- **Lainnya** — pintu masuk ke semua pengaturan dan menu sekunder:
  - Daftar Pesanan (filter status, ubah status, hapus pesanan).
  - Kelola Kategori (termasuk sub-kategori).
  - Kelola Paket WiFi (harga, durasi, status aktif/publik).
  - Daftar Pelanggan (tampilan, detail, form tambah/edit).
  - Riwayat Aktivasi Paket (riwayat perpanjangan/aktivasi).
  - Kritik & Saran (unduh & tampilkan data dari Firestore).
  - Versi Aplikasi Pengguna (pengelolaan versi APK: ikon, label, tautan, ukuran).
  - Pengaturan Aplikasi (preferensi, hapus data otomatis, dll.).
  - Tentang Aplikasi.
  - **[DEBUG] Alat Migrasi Data** — alat migrasi timestamp dokumen Firestore.
  - **[DEBUG] Data Dummy** — tambah/riset/hapus data dummy (eksklusif data dummy yang dikenal ID-nya; data pengguna biasa tidak tersentuh) untuk kebutuhan pengembangan.

### Integrasi dan layanan

- **Sinkronisasi dua arah SQLite ↔ Firebase Firestore** berdasarkan field `diperbarui` (inkremental untuk unduh, batch `set(merge: true)` untuk unggah), dilengkapi `SyncManager`/`PreferensiService` (timestamp terakhir), `PengecekanDataBaruService` (deteksi "ada data baru?" di lokal maupun server), dan orkestrator `PengecekanWaktuSyncService`.
- **Notifikasi lokal terjadwal** untuk pengingat kedaluwarsa paket (`flutter_local_notifications` + `timezone`, dengan deteksi zona waktu perangkat).
- **Deteksi koneksi internet** (`connectivity_plus`) dengan mode offline — aplikasi tetap berjalan menampilkan data lokal.
- **Pesanan via TCP lokal** — server soket lokal (port 8080) yang menerima pesanan dari perangkat pelanggan (`lib/server/server_lokal.dart`, `PesananModel`).
- **Pengiriman rincian paket via WhatsApp** (`url_launcher`) kepada pelanggan (`lib/whatsapp/info_paket.dart`).
- **Pembersihan data otomatis** berdasarkan pengaturan (`PembersihanDataService` + `PembersihanDataOperasi`).
- **Cek langganan kedaluwarsa** (`cek_langganan_kadaluarsa_service.dart`) saat berpindah tab.
- **Logging terpusat** melalui paket `share_global_saya` (`L`, lihat `lib/main.dart` untuk inisialisasi `L.init(container)`); log ditampilkan lewat overlay debug `PengelolaOverlayLogDebug`.

### Layar bantu pengembangan

- Layar migrasi timestamp Firestore (`lib/migrasi/`).
- Layar Data Dummy (`lib/dummy/dummy_screen.dart`) dan dummy pelanggan aktif (`lib/fitur/pelanggan_aktif/dummy/pelanggan_aktif_dummy.dart`).

## Teknologi

| Komponen       | Keterangan                                                                                                                                                                |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Framework      | Flutter (Material), Dart `^3.9.0`                                                                                                                                         |
| State          | `flutter_riverpod` + `riverpod_annotation` (codegen); layar lama memakai `provider` (transisi sedang berlangsung)                                                         |
| Model          | Freezed (`freezed_annotation`/`freezed`), `json_serializable`                                                                                                             |
| Basis data     | SQLite (`sqflite`, `sqflite_common_ffi`, `sqflite_common_ffi_web`) dengan skema berversi di `lib/db/`                                                                     |
| Backend        | Firebase Core + Cloud Firestore (`cloud_firestore`, `firebase_core`, `firebase_options.dart`)                                                                             |
| Utilitas       | `intl`, `jiffy`, `uuid`, `shared_preferences`, `google_fonts`, `connectivity_plus`, `fluttertoast`, `url_launcher`, `package_info_plus`, `device_info_plus`, `pub_semver` |
| Lint & codegen | `flutter_lints`, `build_runner`, `riverpod_generator`, `dependency_validator`, `mockito`/`mocktail`, `fake_cloud_firestore`                                               |

## Struktur Proyek

```text
lib/
  app.dart, main.dart, home.dart, splash_screen.dart   # Entry, shell, navigasi utama
  db/                     # DatabaseHelper, pembuatan & migrasi skema SQLite (berversi)
  data/
    operasi/              # Lapisan operasi tulis/baca per tabel (operasi_dasar + *_operasi.dart)
    services/             # PreferensiService, pengecekan data baru, orkestrator sinkronisasi
    sync/                 # unduh_data.dart, unggah_data.dart, unduhan_awal.dart
  fitur/
    pelanggan_aktif/      # screens/, notifier/, state/, dummy/ (fitur pelanggan aktif)
    pelanggan/            # Fitur pelanggan
    paket/                # Fitur paket
    wifi_analyzer/        # screens/, notifier/, state/, model/, widget/ (analisis WiFi, ping, scan perangkat)
  halaman/
    tab/                  # Tab utama (transaksi, dompet, pesanan, lainnya)
    form/                 # Form tambah/edit per entitas
    detail/               # Layar detail per entitas
    lainnya/              # Halaman sekunder tab Lainnya
    pembantu/, tes/       # Halaman bantu & halaman pengujian
  model/                  # Model data (*_model.dart; relasi SQLite/Firestore via fromSqlite/fromFirebase/toSqlite)
  services/               # Koneksi internet, langganan kadaluarsa, notifikasi, pembersihan data
  whatsapp/               # Pesan informasi paket via WhatsApp (url_launcher)
  server/                 # Server TCP lokal (port 8080) untuk menerima pesanan dari perangkat pelanggan
  migrasi/                # Alat migrasi data Firestore (mis. timestamp)
  dummy/                  # DummyHelper dan layar Data Dummy untuk pengembangan (bukan UI produksi)
  enum/                   # Enum (mis. nama_tabel, status_pembayaran, tipe_transaksi)
  utils/                  # format_util, perhitungan_util, sync_manager, colors
  widget/                 # Widget bersama (mis. nama_paket, nama_pelanggan, transaksi_list_widgets)
```

## Instalasi dan Menjalankan

Prasyarat: Flutter SDK (Dart `^3.9.0`), Android SDK untuk build Android, Git.

```bash
# 1. Clone (submodule diinisialisasi otomatis lewat recurse-submodules)
git clone --recurse-submodules https://github.com/mbadrudin170-jpg/admin_wifi.git
cd admin_wifi

# 2. Ambil dependensi
flutter pub get

# 3. Jalankan (Android/perangkat fisik atau emulator)
flutter run
```

Build APK rilis dilakukan lewat GitHub Actions (`.github/workflows/build-apk.yml`, `--split-per-abi --target-platform android-arm64`, artefak `app-release-apk`); pemicu manual via `gh workflow run`.

## Pengujian dan Kualitas Kode

```bash
# Format & analisis statis
dart format lib
dart analyze

# Regenerasi kode (Freezed/Riverpod/JSON)
dart run build_runner build --delete-conflicting-outputs

# Seluruh test
flutter test
```

- `dart analyze` bersih pada `lib/` (terakhir diperiksa 2026-11-18).
- `flutter test` pada 2026-11-18: **+105 test lulus, −24 kegagalan pra-eksisting** (di luar perubahan terbaru; antara lain `form_paket`, `form_pelanggan_aktif`, `versi_apk_user`, `transaksi`, `dompet`, dan `sqlite_common_ffi` — "no such table: transaksi"). Kegagalan ini bukan regresi dari migrasi logging maupun fitur `Data Dummy`.
- Test memakai dummy data dari `lib/fitur/*/dummy/` dan mock kustom di `test/mocks.dart`.

## Catatan Lainnya

- Path dependency `share_global_saya` menunjuk submodule bertetangga (`../share_global_saya`); pastikan submodule tersebut tersedia saat `flutter pub get`.
- Logging dan overlay debug tersedia hanya untuk mode debug (`kDebugMode`).
- Bahasa utama aplikasi dan komentar kode: Indonesia.

## Pengelola

Dikelola oleh `mbadrudin170-jpg`. Pustaka bersama `share_global_saya` dipakai lintas proyek dan juga belum diterbitkan ke pub.dev.
