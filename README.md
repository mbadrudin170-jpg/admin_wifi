## Dokumen Lengkap Proyek Saya per File

### **File: lib/main.dart**
**Fitur:** Inisialisasi Aplikasi & Konfigurasi Tema

**Tujuan file ini dibuat:** Sebagai titik masuk (entry point) aplikasi, menginisialisasi Flutter, dan mendefinisikan konfigurasi global seperti tema visual dan kunci navigasi.

**Daftar Fungsi/Class:**
- `main()`: Fungsi utama yang dieksekusi saat aplikasi pertama kali berjalan. Fungsi ini memastikan semua binding Flutter siap dan kemudian menjalankan widget `MyApp`.
- `class MyApp`: Ini adalah root widget dari aplikasi. Perannya adalah untuk membungkus seluruh aplikasi di dalam sebuah `MaterialApp`.
- `MyApp.build()`: Metode ini bertanggung jawab untuk membangun antarmuka pengguna utama aplikasi. Di sinilah tema global (`ThemeData`) didefinisikan dan diterapkan.
- `final ThemeData lightTheme`: Mendefinisikan keseluruhan tampilan dan nuansa untuk tema terang (light mode). Ini mencakup:
    - Skema warna yang dihasilkan dari `primarySeedColor` menggunakan Material 3.
    - Tipografi kustom (`appTextTheme`) yang menggunakan font 'Oswald', 'Roboto', dan 'Open Sans'.
    - Gaya spesifik untuk komponen UI seperti `AppBar` dan `ElevatedButton` untuk memastikan konsistensi di seluruh aplikasi.
- `return MaterialApp`: Mengembalikan widget `MaterialApp` yang telah dikonfigurasi dengan:
    - Judul aplikasi.
    - Tema yang telah didefinisikan.
    - `SplashScreen` sebagai halaman awal.
    - `navigatorKey` dari `NavigasiServis` untuk memungkinkan navigasi dari mana saja tanpa konteks (BuildContext).

**Catatan:**
- Aplikasi ini menggunakan `SplashScreen` untuk menangani tugas inisialisasi yang berat, yang merupakan praktik bagus untuk meningkatkan waktu startup aplikasi.
- Penggunaan `navigatorKey` global sangat berguna untuk melakukan navigasi dari dalam service atau model di luar pohon widget.

**Rules:**
- Semua halaman dan komponen di dalam aplikasi akan mewarisi gaya visual yang telah didefinisikan dalam `lightTheme` di file ini, kecuali jika di-override secara spesifik.

### **File: lib/splash_screen.dart**
**Fitur:** Layar Pemuatan dan Inisialisasi Aplikasi

**Tujuan file ini dibuat:** Untuk menampilkan layar pembuka (splash screen) sementara aplikasi melakukan serangkaian proses inisialisasi penting di latar belakang sebelum siap digunakan. Proses ini memastikan semua layanan dasar berfungsi dengan benar.

**Daftar Fungsi/Class:**
- `class SplashScreen`: Sebuah `StatefulWidget` yang menampilkan UI layar pemuatan.
- `class _SplashScreenState`: Mengelola state dan logika untuk proses inisialisasi.
- `initState()`: Metode ini dipanggil sekali saat widget dibuat. Di dalamnya, `_initializeAndNavigate()` dipanggil setelah frame pertama selesai dirender untuk memulai proses inisialisasi.
- `_initializeAndNavigate()`: Ini adalah fungsi inti yang melakukan tugas-tugas berikut secara berurutan:
    1.  **Inisialisasi Firebase**: Menghubungkan aplikasi dengan layanan Google Firebase.
    2.  **Pengaturan Lokal**: Mengatur zona waktu ke 'Asia/Jakarta' dan format tanggal ke standar Indonesia ('id_ID').
    3.  **Inisialisasi Layanan**: Mempersiapkan layanan notifikasi dan membuka koneksi ke database lokal (SQLite).
    4.  **Cek Koneksi & Sinkronisasi**: Memeriksa apakah perangkat terhubung ke internet.
        - Jika **online**, aplikasi akan mencoba menyinkronkan data lokal dengan server.
        - Jika **offline**, proses sinkronisasi akan dilewati.
    5.  **Navigasi**: Setelah semua langkah selesai, aplikasi akan mengarahkan pengguna ke `HalamanUtama` sambil memberikan informasi status koneksi (online/offline).
- `build()`: Metode ini merender antarmuka pengguna (UI) dari splash screen, yang menampilkan:
    - Logo Flutter.
    - Nama aplikasi "Admin WiFi".
    - Indikator pemuatan (`CircularProgressIndicator`).
    - Pesan teks yang dinamis (`_loadingMessage`) untuk memberi tahu pengguna tentang proses yang sedang berjalan.

**Catatan:**
- Logika inisialisasi yang berat sengaja ditempatkan di sini untuk mempercepat waktu startup awal aplikasi (`main.dart`) dan memberikan umpan balik visual yang jelas kepada pengguna.
- File ini secara efektif bertindak sebagai gerbang utama sebelum pengguna dapat berinteraksi dengan fitur-fitur inti aplikasi.

**Rules:**
- Semua layanan krusial (seperti database, notifikasi, dan pengaturan lokasi) harus berhasil diinisialisasi di file ini sebelum aplikasi dapat melanjutkan ke halaman utama.

### **File: lib/halaman_utama.dart**
**Fitur:** Navigasi Utama Aplikasi (Bottom Navigation)

**Tujuan file ini dibuat:** Sebagai kerangka utama aplikasi setelah proses inisialisasi selesai. File ini mengatur navigasi antar tab utama menggunakan `BottomNavigationBar` dan menampilkan halaman yang sesuai.

**Daftar Fungsi/Class:**
- `class HalamanUtama`: Sebuah `StatefulWidget` yang menerima status koneksi (`isOffline`) dari `SplashScreen`.
- `class _HalamanUtamaState`: Mengelola state dari `HalamanUtama`, termasuk tab yang sedang aktif (`_selectedIndex`).
- `final List<Widget> _widgetOptions`: Sebuah list yang berisi empat widget halaman utama yang akan ditampilkan sesuai dengan tab yang dipilih:
    1. `PelangganAktifPage()`: Menampilkan daftar pelanggan yang sedang aktif.
    2. `DompetPage()`: Menampilkan informasi keuangan atau dompet.
    3. `TransaksiPage()`: Menampilkan riwayat transaksi.
    4. `LainnyaPage()`: Menampilkan menu-menu atau opsi lainnya.
- `initState()`: Dipanggil saat halaman pertama kali dimuat. Fungsi ini melakukan dua hal:
    1.  Menjalankan `_cekDanTampilkanPesanOffline()` untuk memberitahu pengguna jika aplikasi dalam mode offline.
    2.  Memanggil `CekLanggananKadaluarsaService()` untuk memulai proses pengecekan pelanggan yang langganannya sudah habis.
- `_onItemTapped(int index)`: Mengubah `_selectedIndex` saat pengguna mengetuk salah satu item di `BottomNavigationBar`, yang kemudian memicu `build()` untuk menampilkan halaman yang benar.
- `_cekDanTampilkanPesanOffline()`: Menampilkan sebuah `SnackBar` berwarna oranye di bagian bawah layar untuk menginformasikan pengguna bahwa mereka sedang dalam mode offline.
- `build()`: Merender UI yang terdiri dari `Scaffold` dengan:
    - `body`: Menampilkan widget dari `_widgetOptions` berdasarkan `_selectedIndex`.
    - `bottomNavigationBar`: Sebuah `BottomNavigationBar` dengan empat ikon (Aktif, Dompet, Transaksi, Lainnya) yang memungkinkan pengguna untuk berpindah antar halaman utama.

**Catatan:**
- Halaman ini adalah pusat navigasi aplikasi. Logika untuk menampilkan halaman yang berbeda dikelola di sini.
- Adanya pengecekan status offline memberikan pengalaman pengguna yang lebih baik karena pengguna sadar bahwa data yang ditampilkan mungkin tidak yang terbaru.

**Rules:**
- Setiap halaman utama yang ingin ditambahkan ke navigasi tab harus didaftarkan di dalam list `_widgetOptions`.
- Warna item yang dipilih dan tidak dipilih pada `BottomNavigationBar` diatur oleh tema global yang didefinisikan di `main.dart`.
