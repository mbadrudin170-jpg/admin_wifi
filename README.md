## Dokumen Lengkap Proyek Saya per File

### **File: lib/halaman/form/form_versi_apk_user.dart**
**Fitur:** Formulir Tambah/Edit Versi APK
**Tujuan file ini dibuat:** Untuk menyediakan antarmuka bagi admin untuk menambah data versi APK baru atau mengubah data versi yang sudah ada. Formulir ini menangani input untuk semua detail versi, termasuk nomor versi, catatan rilis, tautan unduhan untuk berbagai arsitektur (universal, 32-bit, 64-bit), dan nomor build.

**Penjelasan Kode:**
- **Mode Operasi**: Widget ini dapat beroperasi dalam dua mode: "Tambah" (jika `versiApkUser` null) atau "Edit" (jika `versiApkUser` disediakan).
- **Inisialisasi Form**:
    - **Mode Tambah**: Memanggil `_muatDataVersiTerakhir()` untuk mengambil data versi terbaru dari `VersiApkUserOperasi`. Ini digunakan untuk secara otomatis mengisi field versi dan menyarankan nomor build berikutnya, memudahkan admin.
    - **Mode Edit**: Memanggil `_populateControllers()` untuk mengisi semua `TextFormField` dengan data dari `versiApkUser` yang ada.
- **Manajemen Input**: Menggunakan `TextEditingController` terpisah untuk setiap field input, termasuk setiap varian build dan tautan unduhan. Ini memberikan kontrol penuh atas data form.
- **`_simpanForm()`**: Logika utama untuk menyimpan data. Alurnya adalah sebagai berikut:
    1.  **Validasi Form**: Memeriksa apakah semua field yang wajib diisi (seperti versi dan catatan rilis) sudah valid.
    2.  **Dialog Konfirmasi**: Menampilkan `AlertDialog` untuk meminta konfirmasi akhir dari pengguna ("Apakah semua data yang Anda masukkan sudah benar?"). Ini mencegah kesalahan simpan yang tidak disengaja.
    3.  **Pengumpulan Data**: Jika pengguna mengonfirmasi, data dari semua `TextEditingController` dikumpulkan dan disusun ke dalam `Map` untuk `nomorBuildTerbaru` dan `tautanUnduhan`.
    4.  **Pembuatan Model**: Membuat objek `VersiApkUserModel` baru dari data yang dikumpulkan.
    5.  **Operasi Database**: Memanggil `tambahVersiApkUser` atau `perbaruiVersiApkUser` dari `VersiApkUserOperasi`, tergantung pada mode operasinya.
    6.  **Umpan Balik & Navigasi**: Menampilkan `SnackBar` (hijau untuk sukses, merah untuk gagal) dan, jika berhasil, kembali ke halaman sebelumnya dengan membawa data yang baru saja disimpan.
- **UI Layout**:
    - **`SingleChildScrollView`**: Memastikan form dapat di-scroll pada layar kecil.
    - **Tombol Simpan**: `ElevatedButton` "Simpan" ditempatkan di bagian bawah form untuk aksesibilitas yang mudah, menggantikan `IconButton` di `AppBar`.
    - **Indikator Loading**: Menampilkan overlay loading (`CircularProgressIndicator`) saat proses penyimpanan sedang berlangsung.

---

## Catatan Pengembangan v1.0.9+5

- **Peningkatan UX Form Versi APK**:
    - **`lib/halaman/form/form_versi_apk_user.dart`**:
        - **Pemindahan Tombol Simpan**: Memindahkan tombol "Simpan" dari `AppBar` ke bagian bawah form. Ini meningkatkan alur kerja pengguna, terutama pada perangkat mobile, karena tombol lebih mudah dijangkau setelah mengisi semua field.
        - **Penambahan Dialog Konfirmasi**: Mengimplementasikan `AlertDialog` yang muncul saat tombol "Simpan" ditekan. Pengguna harus mengonfirmasi kebenaran data sebelum proses penyimpanan dilanjutkan. Ini berfungsi sebagai lapisan pengaman untuk mencegah kesalahan input data.
    - **`test/halaman/form/form_versi_apk_user_test.dart`**:
        - **Pembaruan Pengujian UI**: Memperbarui file pengujian untuk mencerminkan perubahan UI. Pengujian sekarang memverifikasi keberadaan `ElevatedButton` di bawah form, bukan `IconButton` di `AppBar`.
        - **Penyesuaian Alur Pengujian**: Menambahkan langkah-langkah baru dalam pengujian untuk menangani interaksi dengan dialog konfirmasi. Ini termasuk mensimulasikan penekanan tombol "Ya" dan "Tidak".
        - **Perbaikan `Hit Test`**: Mengatasi `hit test warning` dengan menggunakan `tester.ensureVisible()` untuk melakukan scroll otomatis ke tombol "Simpan" sebelum menekannya, memastikan tombol tersebut terlihat dalam viewport pengujian.
        - **Perbaikan Logika Verifikasi**: Memperbaiki logika verifikasi `NavigatorObserver` untuk secara akurat menghitung jumlah `pop` yang terjadi setelah dialog dan form ditutup.

### **File: lib/halaman/lainnya/versi_apk_user.dart**
**Fitur:** Halaman Daftar Versi APK
**Tujuan file ini dibuat:** Untuk menampilkan daftar semua data versi APK yang tersedia. Halaman ini berfungsi sebagai halaman utama untuk manajemen versi, memungkinkan pengguna untuk melihat daftar versi, menambah versi baru, dan menavigasi ke halaman detail untuk melihat rincian setiap versi.

**Penjelasan Kode:**
- **State Management**: Menggunakan `StatefulWidget` untuk mengelola state seperti daftar versi APK (`_daftarVersiApk`), status loading (`_isLoading`), dan pesan error (`_error`).
- **`_loadData()`**: Fungsi ini mengambil daftar versi APK dari `VersiApkUserOperasi.ambilSemuaVersiApk()` dan memperbarui state.
- **`_keDetail()`**: Fungsi ini menangani navigasi ke halaman `DetailVersiApkUser`, dengan membawa data `VersiApkUserModel` yang dipilih.
- **`_buildContent()`**: Logika utama untuk menampilkan UI. Berdasarkan state, widget ini akan menampilkan `CircularProgressIndicator`, pesan error, atau `ListView.builder` yang menampilkan daftar versi APK.
- **`ListView.builder`**: Digunakan untuk menampilkan daftar versi APK secara efisien. Setiap item dalam daftar adalah sebuah `Card` dengan `ListTile` yang menampilkan versi dan catatan rilis, dan dapat di-klik untuk membuka halaman detail.
- **`FloatingActionButton`**: Digunakan untuk menavigasi ke halaman `FormVersiApkUser` untuk menambahkan data versi APK baru. Setelah penambahan berhasil, halaman ini akan memuat ulang datanya.

### **File: lib/halaman/detail/detail_versi_apk_user.dart**
**Fitur:** Halaman Detail Versi APK
**Tujuan file ini dibuat:** Untuk menampilkan semua rincian informasi dari satu `VersiApkUserModel`. Halaman ini bersifat read-only dan menerima data dari halaman sebelumnya.

**Penjelasan Kode:**
- **StatelessWidget**: Halaman ini adalah `StatelessWidget` karena hanya menampilkan data yang diterima dan tidak mengelola state internal.
- **`versiApk`**: Menerima objek `VersiApkUserModel` melalui konstruktor.
- **`_buildInfoRow()`**: Sebuah fungsi helper untuk membuat baris informasi yang terdiri dari label dan nilai, untuk menjaga konsistensi tampilan.
- **`ListView`**: Digunakan untuk menampilkan semua detail versi APK, seperti versi terbaru, catatan rilis, nomor build, tautan unduhan, dan tutorial YouTube.

### **File: lib/data/operasi/versi_apk_user_operasi.dart**
**Fitur:** Operasi Database untuk Versi APK
**Tujuan file ini dibuat:** Untuk menyediakan sekumpulan fungsi yang melakukan operasi Create, Read, Update, Delete (CRUD) pada data `VersiApkUserModel`.
**Daftar Fungsi/Class:**
- `class VersiApkUserOperasi`: Kelas yang berisi semua metode untuk berinteraksi dengan data versi APK.
- `ambilVersiApkUser()`: Mengambil satu data versi APK (saat ini dari data dummy).
- `ambilSemuaVersiApk()`: **(Baru)** Mengambil semua data versi APK dalam bentuk `List<VersiApkUserModel>` (saat ini dari data dummy).
- `updateVersiApkUser()`: Menyimpan atau memperbarui data versi APK.


---
## Catatan Pengembangan v1.0.9+4

- **Perbaikan & Refaktorisasi Halaman Kontrol APK**:
    - **`lib/halaman/lainnya/versi_apk_user.dart`**: Melakukan refaktorisasi besar pada halaman ini. Menghapus penggunaan `FutureBuilder` yang tidak efisien dan menggantinya dengan manajemen state manual (`_isLoading`, `_versiApkUser`, `_error`). Logika pemuatan data diubah untuk menggunakan `Future.wait`, mengambil data versi APK (dari SQLite) dan status maintenance (dari Firebase) secara bersamaan, meningkatkan kecepatan load halaman.
    - **Perbaikan Runtime Error**: Mengidentifikasi dan memperbaiki `_CompileTimeError` yang muncul saat runtime karena referensi ke variabel lama (`_versiApkUserFuture`) yang masih tersisa di cache build. Masalah diselesaikan dengan melakukan `flutter clean` dan me-restart aplikasi.
- **Refaktorisasi Model Sub-Kategori**:
    - **`lib/model/sub_kategori_model.dart`**: Membuat file model baru yang didedikasikan untuk `SubKategoriModel`. Ini meningkatkan modularitas dan memisahkan concern, membuat struktur model lebih bersih. Model ini berisi `id`, `idKategori`, dan `nama`.
    - **`lib/model/kategori_model.dart`**: Merapikan file ini dengan menghapus definisi kelas `SubKategoriModel` dan menggantinya dengan impor dari file yang baru dibuat.
- **Implementasi Operasi Sub-Kategori**:
    - **`lib/data/operasi/sub_kategori_operasi.dart`**: Membuat file operasi baru untuk menangani semua interaksi database (CRUD) untuk sub-kategori. Ini mencakup fungsi-fungsi penting seperti `createSubKategori`, `getSubKategoriByKategoriId`, `updateSubKategori`, `deleteSubKategori`, dan `sisipkanAtauPerbaruiBatch` untuk sinkronisasi data.
- **Penambahan Fitur UI**:
    - **`lib/halaman/tab/lainnya.dart`**: Menambahkan tombol navigasi baru di halaman "Pengaturan & Lainnya" yang mengarah ke halaman "Versi Aplikasi Pengguna". Hal ini meningkatkan aksesibilitas ke fitur tersebut.

---

## Dokumen Lengkap Proyek Saya per File (Lama)


### **File: lib/halaman/tab/pelanggan_aktif.dart**
**Fitur:** Halaman Manajemen Pelanggan Aktif
**Tujuan file ini dibuat:** Untuk menampilkan daftar semua pelanggan yang memiliki langganan aktif, menyediakan fungsionalitas pencarian, pengurutan, penambahan, dan pengarsipan pelanggan.

**Penjelasan Kode:**
- `class PelangganAktifPage` & `_PelangganAktifPageState`: Mengelola keseluruhan state dan UI halaman, termasuk data pelanggan, status loading, dan logika interaksi pengguna.
- `_loadData({bool forceRefresh = false})`: Fungsi inti untuk memuat data. Fungsi ini telah diperbarui dengan logika yang lebih tangguh:
    - **Timeout Refresh**: Jika pengguna melakukan *pull-to-refresh* (`forceRefresh = true`) dan koneksi internet sangat lambat, proses sinkronisasi akan dibatalkan setelah 15 detik untuk mencegah *loading* tanpa henti. Pengguna akan menerima pesan error.
    - **Penanganan Offline**: Jika pengguna mencoba melakukan *refresh* tanpa koneksi internet, aplikasi akan menampilkan pesan "Jaringan tidak tersedia" dan lanjut menampilkan data yang tersimpan di database lokal, sehingga aplikasi tetap responsif.
- `_applyFilterAndSort()`: Menerapkan logika pencarian (berdasarkan nama) dan pengurutan pada daftar pelanggan. Mendukung berbagai kriteria urut seperti tanggal berakhir, nama, status pembayaran, dan status paket.
- `_arsipkanPelanggan()`: Menangani proses pengarsipan satu pelanggan aktif setelah mendapatkan konfirmasi dari pengguna melalui dialog.
- `_showUrutkanDialog()`: Menampilkan dialog yang memungkinkan pengguna memilih metode pengurutan data.
- `_tambahPelangganAktif()`: Menavigasi ke halaman `FormPelangganAktif` untuk menambahkan langganan baru. Jika berhasil, data di halaman ini akan dimuat ulang.
- `_opsiLanjutan()`: Menampilkan menu untuk tindakan massal, seperti mengarsipkan semua pelanggan yang sudah kedaluwarsa atau menghapus semua data pelanggan aktif.
- `_buildAppBar()`, `_buildSearchField()`, `_buildSearchActions()`, `_buildDefaultActions()`: Kumpulan fungsi yang secara dinamis membangun `AppBar`, beralih antara mode tampilan normal dan mode pencarian.
- `build()`: Merender keseluruhan UI, termasuk `RefreshIndicator` untuk `pull-to-refresh`, `ListView.builder` untuk menampilkan daftar pelanggan dalam bentuk `Card`, dan `FloatingActionButton` untuk menambah pelanggan baru.

**Catatan:**
- Halaman ini menggunakan `AutomaticKeepAliveClientMixin` untuk menjaga state-nya (seperti posisi scroll dan hasil filter) bahkan ketika pengguna berpindah ke tab lain, memberikan pengalaman navigasi yang mulus.
- Logika pada fungsi `_loadData` telah ditingkatkan secara signifikan untuk memberikan umpan balik yang lebih baik kepada pengguna dalam berbagai kondisi jaringan (online, offline, atau koneksi lambat).

### **File: lib/halaman/lainnya/pelanggan.dart**
**Fitur:** Halaman Manajemen Pelanggan
**Tujuan file ini dibuat:** Untuk menampilkan daftar semua pelanggan yang terdaftar (baik yang aktif maupun tidak), serta menyediakan fungsionalitas pencarian, penambahan pelanggan baru, dan interaksi lanjutan melalui gestur tekan-lama (`onLongPress`).

**Penjelasan Kode:**
- **State Management**: Menggunakan `StatefulWidget` untuk mengelola state UI secara lokal, seperti mode pencarian (`_isSearching`), daftar pelanggan yang telah difilter (`_filteredPelanggan`), dan status pemuatan data (`_isLoading`).
- **AppBar Dinamis (`_buildAppBar`)**: Fungsi ini secara cerdas mengubah tampilan `AppBar`.
    - **Mode Normal**: Menampilkan judul 'Pelanggan' dan ikon pencarian.
    - **Mode Pencarian**: Mengganti judul dengan `TextField` untuk input pencarian dan mengubah ikon menjadi tombol 'tutup' (close).
- **Logika Pencarian**: 
    - `_searchController` mendengarkan setiap perubahan pada `TextField`.
    - `_filterPelanggan()` dipicu untuk memfilter daftar `_allPelanggan` berdasarkan nama, dan hasilnya disimpan di `_filteredPelanggan` untuk ditampilkan di UI.
- **Interaksi Pengguna**:
    - `onTap`: Mengetuk item akan menavigasi pengguna ke halaman `DetailPelangganPage`.
    - `onLongPress`: Menekan lama pada sebuah item akan memicu `_showDialogOpsi`, yang menampilkan dialog dengan pilihan "Edit Pelanggan" atau "Arsipkan Pelanggan". Ini adalah alternatif modern pengganti `PopupMenuButton`.
- **Manajemen Data**: Fungsi `_refreshPelangganList()` mengambil data dari `PelangganOperasi`, mengurutkannya berdasarkan nama, dan memperbarui state UI. Ini dipanggil saat inisialisasi dan setelah ada aksi yang mengubah data (seperti menambah atau mengarsipkan pelanggan).

**Catatan:**
- Halaman ini tidak lagi menggunakan `FutureBuilder` untuk menampilkan daftar utama, melainkan mengelola daftar pelanggan dalam state lokal (`_allPelanggan` dan `_filteredPelanggan`). Pendekatan ini memberikan kontrol yang lebih baik untuk fitur dinamis seperti pencarian.
- Penggunaan `onLongPress` untuk menampilkan opsi membuat antarmuka lebih bersih dan minimalis.

### **File: perintah_terminal.md**
**Fitur:** Dokumentasi Perintah Terminal
**Tujuan file ini dibuat:** Untuk menyediakan daftar perintah terminal yang sering digunakan dalam pengembangan aplikasi Flutter, mencakup manajemen proyek, dependensi, proses build, analisis kode, dan diagnostik. Ini berfungsi sebagai panduan cepat (quick reference) bagi developer.
**Isi File:**
- **Manajemen Proyek & Dependensi**: Perintah seperti `flutter clean`, `flutter pub get`, `flutter pub add`, dll.
- **Proses Build & Menjalankan Aplikasi**: Perintah seperti `flutter build apk`, `flutter run`, dll.
- **Analisis & Kualitas Kode**: Perintah seperti `flutter analyze`, `flutter test`, `dart format .`.
- **Pembuatan Kode**: Perintah untuk `build_runner`.
- **Diagnostik & Pemecahan Masalah**: Perintah seperti `flutter doctor` dan beberapa tips untuk pemecahan masalah.

### **File: rencana.md**
**Fitur:** Rencana Kerja Jangka Pendek
**Tujuan file ini dibuat:** Untuk mencatat tugas-tugas spesifik yang harus segera dikerjakan oleh AI. File ini bersifat sementara dan akan dihapus setelah tugas-tugas di dalamnya selesai dilaksanakan.
**Isi File Saat Ini:**
- Tugas utama yang tercatat adalah "mengosongkan isi dalam kolom `diarsipkan` di Firebase pada koleksi `riwayat_langganan`". Ini adalah tugas pemeliharaan data.

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

### **File: lib/halaman/tab/dompet.dart**
**Fitur:** Halaman Manajemen Dompet
**Tujuan file ini dibuat:** Untuk menampilkan halaman dompet yang berisi ringkasan keuangan (pemasukan, pengeluaran, total), daftar semua dompet yang tersedia, dan menyediakan fungsionalitas untuk menambah, mengarsipkan (satu per satu), serta menghapus semua dompet.

**Penjelasan Kode:**
- `class DompetPage` & `_DompetPageState`: Mengelola state dan logika keseluruhan halaman, termasuk memuat data dompet dari `DompetOperasi` dan menangani interaksi pengguna.
- `_loadDompet()`: Fungsi sentral untuk memuat ulang data dompet dari `DompetOperasi` dan memperbarui UI, termasuk `RingkasanKeuangan`.
- `_tambahDompet()`: Menangani navigasi ke `FormDompet` untuk membuat dompet baru. Jika pembuatan berhasil, ia akan memanggil `_loadDompet()` untuk menyegarkan daftar.
- `_tampilkanDialogHapusSemua()`: Menampilkan dialog konfirmasi kepada pengguna sebelum menjalankan operasi penghapusan semua dompet. Ini mencegah penghapusan data yang tidak disengaja.
- `_hapusSemuaDompet()`: Memanggil metode `hapusSemuaDompet()` dari `DompetOperasi` dan memberikan umpan balik kepada pengguna melalui `SnackBar`.
- `_showDialogHapusSatu(DompetModel dompet)`: Menampilkan dialog konfirmasi untuk mengarsipkan satu dompet spesifik. Fungsi ini dipicu oleh gestur *long press* pada `DompetCard`.
- `_hapusSatuDompet(DompetModel dompet)`: **(Perbaikan)** Fungsi ini sekarang dengan benar memanggil `arsipkanSatuDompet(dompet.id)` dari `DompetOperasi`, mengirimkan ID sebagai `String`. Pesan umpan baliknya juga telah diperbaiki menjadi "Dompet berhasil diarsipkan" untuk mencerminkan tindakan yang sebenarnya.
- `build()`: Merender UI lengkap halaman, yang terdiri dari `AppBar` dengan aksi hapus semua, `RingkasanKeuangan` di bagian atas, dan `ListView` yang di-build menggunakan `FutureBuilder` untuk menampilkan daftar `DompetCard`.
- `class RingkasanKeuangan`: Widget terpisah (`StatefulWidget`) yang menampilkan total pemasukan, pengeluaran, dan saldo dari semua dompet. Widget ini memiliki metode `refresh()` yang dapat dipanggil oleh parent-nya untuk memuat ulang data.
- `class DompetCard`: Widget UI (`StatelessWidget`) yang menampilkan informasi satu dompet. Widget ini menangani gestur `onTap` untuk navigasi ke detail dan `onLongPress` untuk memicu dialog pengarsipan.

**Catatan:**
- Logika pengarsipan satu dompet telah diperbaiki dari kesalahan sebelumnya dimana ia memberikan pesan umpan balik yang salah dan memiliki parameter yang tidak tepat.
- Penggunaan `if (!mounted) return;` telah ditambahkan di beberapa lokasi setelah operasi `async` untuk mencegah error saat mencoba menggunakan `BuildContext` pada widget yang sudah tidak ada di pohon widget.


### **File: lib/data/operasi/dompet_operasi.dart**
**Fitur:** Operasi Database untuk Dompet
**Tujuan file ini dibuat:** Untuk menyediakan sekumpulan fungsi yang melakukan operasi Create, Read, Update, Delete (CRUD) pada tabel `dompet` di database SQLite.
**Daftar Fungsi/Class:**
- `class DompetOperasi`: Kelas yang berisi semua metode untuk berinteraksi dengan tabel dompet.
- `createDompet(DompetModel dompet)`: Menambahkan dompet baru ke database.
- `getDompet()`: Mengambil semua data dompet dari database.
- `getDompetById(String id)`: Mengambil dompet berdasarkan ID.
- `updateDompet(DompetModel dompet)`: Memperbarui data dompet yang sudah ada.
- `hapusSemuaDompet()`: Menghapus semua data dari tabel `dompet`.
- `arsipkanSatuDompet(String id)`: **(Diperbarui)** Melakukan *soft delete* dengan mengisi kolom `diarsipkan` dan `isDeleted`.
- `getTotalSaldo()`, `getTotalSaldoPositif()`, `getTotalSaldoNegatif()`: Fungsi agregasi untuk menghitung total saldo.
- `sisipkanAtauPerbaruiBatch(List<DompetModel> items)`: Melakukan operasi insert atau update massal.

### **File: lib/model/dompet_model.dart**
**Fitur:** Model Data untuk Dompet

**Tujuan file ini dibuat:** Untuk mendefinisikan struktur data dari sebuah "dompet". File ini berisi kelas `DompetModel` yang merepresentasikan semua atribut yang terkait dengan entitas dompet, seperti nama, saldo, dan statusnya.

**Daftar Fungsi/Class:**
- `class DompetModel`: Kelas utama yang menampung properti-properti dari sebuah dompet.
    - `id`: ID unik untuk setiap dompet, dihasilkan otomatis menggunakan `UUID` jika tidak disediakan.
    - `namaDompet`: Nama dari dompet (misalnya: "Dompet Utama", "Kas").
    - `saldo`: Jumlah uang yang ada di dalam dompet.
    - `diperbarui`: Tanggal dan waktu kapan data dompet terakhir kali diperbarui.
    - `isDeleted`: Status boolean untuk menandai apakah dompet telah dihapus (soft delete).
    - `diarsipkan`: Tanggal dan waktu kapan dompet diarsipkan.
- `DompetModel.copyWith()`: Sebuah metode untuk membuat salinan (copy) dari objek `DompetModel` dengan beberapa perubahan pada propertinya. Ini sangat berguna untuk memperbarui state secara immutable.
- `static _parseDateTime()`: Fungsi helper internal untuk mengonversi nilai `Timestamp` dari Firestore atau `String` ke dalam objek `DateTime`.
- `factory DompetModel.fromMap(Map<String, dynamic> map)`: Factory constructor untuk membuat instance `DompetModel` dari sebuah `Map` (biasanya dari data JSON atau Firestore). Ini menangani konversi tipe data dan nilai default jika ada data yang hilang.
- `toMap()`: Mengonversi instance `DompetModel` kembali menjadi sebuah `Map`. Ini digunakan saat menyimpan data ke database atau mengirimnya ke server.

**Catatan:**
- Model ini menggunakan pendekatan *non-nullable* untuk properti-properti penting dan memberikan nilai default untuk memastikan integritas data.
- Penggunaan `UUID` untuk `id` memastikan bahwa setiap dompet yang dibuat memiliki identitas yang unik dan tidak akan pernah `null`.
- Konversi `isDeleted` menjadi integer (`1` atau `0`) di `toMap()` adalah untuk kompatibilitas dengan SQLite yang tidak memiliki tipe data boolean secara native.

**Rules:**
- Setiap kali membuat objek `DompetModel` baru tanpa `id`, sebuah ID unik akan otomatis dibuat.
- Saat membaca data dari database/map, jika ada field yang `null`, nilai default (seperti string kosong atau 0.0) akan digunakan untuk mencegah error.

### **File: lib/model/kategori_model.dart**
**Fitur:** Model Data untuk Kategori dan Sub-Kategori

**Tujuan file ini dibuat:** Untuk mendefinisikan struktur data dari "kategori" transaksi dan "sub-kategori" di dalamnya. File ini penting untuk mengelompokkan jenis-jenis pemasukan dan pengeluaran.

**Daftar Fungsi/Class:**
- `enum TipeKategori`: Mendefinisikan tiga tipe kategori yang mungkin: `pemasukan`, `pengeluaran`, dan `transfer`.
- `class KategoriModel`: Kelas utama yang merepresentasikan sebuah kategori.
    - `id`: ID unik yang dihasilkan oleh `UUID`.
    - `nama`: Nama dari kategori (contoh: "Gaji", "Belanja Bulanan").
    - `tipe`: Tipe dari kategori, menggunakan `enum TipeKategori`.
    - `subKategori`: Sebuah list yang berisi objek `SubKategoriModel`, memungkinkan adanya tingkatan dalam kategori.
    - `diperbarui`, `isDeleted`, `diarsipkan`: Properti untuk melacak status dan perubahan data.
- `class SubKategoriModel`: Kelas yang merepresentasikan sebuah sub-kategori.
    - `id`: ID unik yang dihasilkan oleh `UUID`.
    - `nama`: Nama dari sub-kategori (contoh: "Gaji Pokok", "Bonus").
    - `diperbarui`, `isDeleted`, `diarsipkan`: Properti untuk melacak status dan perubahan data.
- **Metode pada kedua kelas (`KategoriModel` dan `SubKategoriModel`):**
    - `copyWith()`: Untuk membuat salinan objek dengan modifikasi, mendukung *immutable state*.
    - `_parseDateTime()`: Fungsi utilitas internal untuk mengonversi data tanggal dari berbagai format.
    - `fromMap()`: Factory constructor untuk membuat objek dari `Map` (data dari database). Menangani nilai-nilai yang mungkin hilang dengan memberikan nilai default.
    - `toMap()`: Mengonversi objek menjadi `Map` untuk disimpan ke database.

**Catatan:**
- Model ini memiliki struktur bersarang, di mana sebuah `KategoriModel` bisa memiliki banyak `SubKategoriModel`.
- Penggunaan `enum` untuk `tipe` membuat kode lebih aman dan mudah dibaca dibandingkan menggunakan `String` biasa.
- Sama seperti model lainnya, file ini menerapkan prinsip *non-nullable* dan pembuatan `UUID` otomatis untuk ID.

**Rules:**
- Setiap kategori harus memiliki salah satu dari tiga `TipeKategori`.
- Saat data dibaca dari database, jika tipe kategori tidak dikenali, maka akan secara default diatur sebagai `TipeKategori.pemasukan` untuk menghindari error.

### **File: lib/model/kritik_saran_model.dart**
**Fitur:** Model Data untuk Kritik dan Saran

**Tujuan file ini dibuat:** Untuk mendefinisikan struktur data dari "kritik dan saran" yang dikirim oleh pengguna. File ini memungkinkan aplikasi untuk menyimpan dan mengelola masukan dari pengguna secara terstruktur.

**Daftar Fungsi/Class:**
- `class KritikSaranModel`: Kelas yang membungkus semua informasi terkait satu masukan.
    - `id`: ID unik dari masukan, bisa jadi null jika belum disimpan di database.
    - `isi`: Teks atau konten dari kritik atau saran yang diberikan.
    - `tanggal`: Waktu kapan masukan tersebut dikirim.
    - `userId`: ID dari pengguna yang mengirimkan masukan.
    - `diperbarui`: Waktu kapan data ini terakhir diubah di server.
- `toMap()`: Mengonversi objek `KritikSaranModel` menjadi `Map`. Metode ini sangat penting untuk menyimpan data ke database seperti Firestore atau SQLite, dengan mengubah `DateTime` menjadi format string ISO 8601 yang universal.
- `factory KritikSaranModel.fromMap(Map<String, dynamic> map)`: Factory constructor yang berfungsi sebaliknya dari `toMap()`. Ini membuat objek `KritikSaranModel` dari sebuah `Map`. Terdapat logika cerdas di dalamnya untuk menangani dua format tanggal yang berbeda:
    - `Timestamp` dari Firestore.
    - `String` dari SQLite.
    Hal ini membuat model ini fleksibel dan dapat digunakan dengan kedua sumber data tersebut.

**Catatan:**
- Model ini dirancang untuk menjadi jembatan antara data di UI dan data yang disimpan di database.
- Penanganan format tanggal yang berbeda di `fromMap()` adalah contoh praktik terbaik untuk memastikan data dapat dibaca dengan andal dari berbagai sumber.

**Rules:**
- `isi`, `tanggal`, dan `userId` adalah field yang wajib diisi, memastikan bahwa setiap masukan memiliki informasi konteks yang esensial.

### **File: lib/model/paket_model.dart**
**Fitur:** Model Data untuk Paket Langganan

**Tujuan file ini dibuat:** Untuk mendefinisikan struktur data dari sebuah "paket" internet yang dapat dibeli oleh pelanggan. File ini sangat penting untuk manajemen produk yang ditawarkan.

**Daftar Fungsi/Class:**
- `enum TipeDurasi`: Mendefinisikan unit waktu untuk durasi paket, yaitu `menit`, `jam`, `hari`, dan `bulan`. Enum ini juga memiliki `displayName` untuk menampilkan nama yang lebih ramah pengguna di UI.
- `class PaketModel`: Kelas utama yang menyimpan semua detail tentang sebuah paket.
    - `id`: ID unik untuk setiap paket, yang secara otomatis dibuat menggunakan `UUID` jika tidak disediakan.
    - `nama`: Nama dari paket (contoh: "Paket Harian", "Paket Bulanan Super Cepat").
    - `harga`: Harga dari paket dalam bentuk integer.
    - `durasi`: Lamanya paket aktif, dalam satuan angka.
    - `tipe`: Satuan dari durasi, menggunakan `enum TipeDurasi`.
    - `diperbarui`, `isDeleted`, `diarsipkan`: Properti untuk melacak status dan perubahan data, mendukung *soft delete* dan pengarsipan.
- `PaketModel.copyWith()`: Metode yang memungkinkan pembuatan salinan objek `PaketModel` dengan nilai properti yang telah diubah, berguna untuk manajemen state yang *immutable*.
- `_parseDateTime()`: Fungsi helper statis yang aman untuk mengonversi nilai tanggal dari berbagai format (Firestore `Timestamp`, `DateTime`, atau `String`) menjadi objek `DateTime`, serta menangani nilai `null`.
- `factory PaketModel.fromMap(Map<String, dynamic> map)`: Factory constructor untuk membuat objek `PaketModel` dari `Map`. Jika `tipe` durasi tidak ditemukan, `TipeDurasi.hari` akan digunakan sebagai nilai default.
- `toMap()`: Mengonversi objek `PaketModel` menjadi `Map` yang siap untuk disimpan ke dalam database.

**Catatan:**
- Penggunaan `enum` untuk `TipeDurasi` membuat kode lebih terstruktur dan mengurangi kemungkinan kesalahan input dibandingkan menggunakan string biasa.
- Seperti model data lainnya dalam proyek ini, `PaketModel` juga mengadopsi pembuatan `id` yang non-nullable dan otomatis, serta menyertakan properti untuk *soft delete* dan pengarsipan.

**Rules:**
- `nama`, `harga`, `durasi`, dan `tipe` adalah properti yang wajib diisi saat membuat sebuah paket baru.
- Jika saat membaca data dari database `tipe` durasi tidak valid atau tidak ada, maka akan secara otomatis diatur ke `TipeDurasi.hari`.

### **File: lib/model/pelanggan_aktif_model.dart**
**Fitur:** Model Data untuk Pelanggan Aktif

**Tujuan file ini dibuat:** Untuk merepresentasikan data langganan yang sedang aktif dari seorang pelanggan. File ini menghubungkan antara pelanggan dan paket yang mereka pilih, serta melacak status langganan tersebut.

**Daftar Fungsi/Class:**
- `class PelangganAktifModel`: Kelas utama yang menyimpan informasi tentang langganan aktif.
    - `id`: ID unik untuk setiap record langganan aktif, dihasilkan oleh `UUID`.
    - `idPelanggan`: ID pelanggan yang memiliki langganan ini.
    - `idPaket`: ID paket yang dilanggan oleh pelanggan.
    - `tanggalMulai`: Tanggal dimulainya periode langganan.
    - `tanggalBerakhir`: Tanggal berakhirnya periode langganan.
    - `status`: Status pembayaran dari langganan, menggunakan `enum StatusPembayaran`.
    - `diperbarui`, `isDeleted`, `diarsipkan`: Properti standar untuk melacak perubahan, penghapusan sementara, dan pengarsipan data.
- `_parseDateTime()`: Fungsi utilitas internal untuk mengurai tanggal dari berbagai format.
- `copyWith()`: Metode untuk membuat salinan objek dengan beberapa perubahan, mendukung *immutable state*.
- `factory PelangganAktifModel.fromMap(Map<String, dynamic> map)`: Factory constructor untuk membuat objek dari `Map`. Terdapat validasi ketat di dalamnya: jika `id`, `idPelanggan`, atau `idPaket` null atau kosong, maka akan melempar `ArgumentError`. Ini memastikan integritas data relasional.
- `toMap()`: Mengonversi objek `PelangganAktifModel` menjadi `Map` untuk disimpan ke database.

**Catatan:**
- Validasi `ArgumentError` di dalam `fromMap()` adalah mekanisme pertahanan yang sangat baik untuk mencegah data yang tidak valid atau korup masuk ke dalam sistem.
- Model ini adalah inti dari logika bisnis langganan, menghubungkan pelanggan dengan layanan yang mereka gunakan.

**Rules:**
- `idPelanggan`, `idPaket`, `tanggalMulai`, `tanggalBerakhir`, dan `status` adalah field yang wajib ada.
- Saat membuat objek dari `Map`, jika ada ID relasional yang kosong, proses akan gagal untuk menjaga integritas data.
- Jika `status` pembayaran tidak dikenali, maka akan diatur ke `StatusPembayaran.lunas` sebagai default.

### **File: lib/model/pelanggan_model.dart**
**Fitur:** Model Data untuk Pelanggan

**Tujuan file ini dibuat:** Untuk mendefinisikan struktur data dari entitas "pelanggan". File ini adalah salah satu model inti yang menyimpan semua informasi detail mengenai pelanggan, seperti data pribadi dan kredensial.

**Daftar Fungsi/Class:**
- `enum StatusPelanggan`: Mendefinisikan status pelanggan, yang bisa `aktif` atau `diarsip`. Ini mendukung mekanisme *soft delete*.
- `class PelangganModel`: Kelas utama yang merepresentasikan seorang pelanggan.
    - `id`: ID unik pelanggan yang dibuat oleh `UUID`.
    - `nama`: Nama lengkap pelanggan.
    - `telepon`: Nomor telepon pelanggan.
    - `alamat`: Alamat fisik pelanggan.
    - `password`: Password yang digunakan pelanggan untuk login (atau keperluan autentikasi lainnya).
    - `macAddress`: Alamat MAC perangkat pelanggan, penting untuk identifikasi di jaringan.
    - `status`: Status pelanggan saat ini (`aktif` atau `diarsip`), menggunakan `enum StatusPelanggan`.
    - `diperbarui`, `diarsipkan`: Properti `DateTime` untuk melacak kapan data diubah atau diarsipkan.
- `copyWith()`: Metode untuk membuat salinan objek dengan modifikasi, mendukung pembaruan state yang *immutable*.
- `_parseDateTime()`: Fungsi utilitas internal untuk mengonversi data tanggal dari berbagai format secara aman.
- `factory PelangganModel.fromMap(Map<String, dynamic> map)`: Factory constructor untuk membuat objek `PelangganModel` dari sebuah `Map`. Menangani nilai `null` dengan memberikan nilai default dan mengatur status ke `aktif` jika tidak ada data status yang valid.
- `toMap()`: Mengonversi objek `PelangganModel` menjadi `Map` untuk disimpan ke database.

**Catatan:**
- Model ini sangat fundamental karena menjadi dasar dari data pelanggan yang akan digunakan di seluruh fitur aplikasi, mulai dari autentikasi hingga manajemen langganan.
- Penggunaan `enum` untuk status membantu menjaga konsistensi data dan menghindari kesalahan pengetikan string.

**Rules:**
- `nama`, `telepon`, `alamat`, dan `password` adalah informasi yang wajib ada untuk setiap pelanggan.
- Jika status pelanggan tidak terdefinisi saat data dibaca, maka akan secara otomatis dianggap `aktif`.

### **File: lib/model/pesanan_model.dart**
**Fitur:** Model Data untuk Pesanan

**Tujuan file ini dibuat:** Untuk merepresentasikan data "pesanan" yang dibuat oleh pelanggan saat mereka membeli sebuah paket. File ini berfungsi sebagai catatan transaksi awal sebelum pembayaran dikonfirmasi.

**Daftar Fungsi/Class:**
- `class PesananModel`: Kelas utama yang mendefinisikan struktur sebuah pesanan.
    - `id`: ID unik untuk setiap pesanan, yang secara otomatis dibuat menggunakan `UUID`.
    - `idPelanggan`: ID dari pelanggan yang membuat pesanan.
    - `idPaket`: ID dari paket yang dipesan.
    - `tanggal`: Tanggal dan waktu pesanan dibuat.
    - `status`: Status dari pesanan (misalnya: "baru", "diproses", "selesai").
    - `diperbarui`, `isDeleted`, `diarsipkan`: Properti standar untuk melacak perubahan, penghapusan sementara, dan pengarsipan data.
- `copyWith()`: Metode untuk membuat salinan objek dengan beberapa properti yang diubah, mendukung *immutable state*.
- `_parseDateTime()`: Fungsi helper internal untuk mengonversi data tanggal dari berbagai format dengan aman.
- `factory PesananModel.fromMap(Map<String, dynamic> map)`: Factory constructor untuk membuat objek `PesananModel` dari `Map`. Jika ada data yang hilang, nilai default akan digunakan (misalnya, `status` akan menjadi "baru").
- `toMap()`: Mengonversi objek `PesananModel` menjadi `Map` yang siap disimpan di database.

**Catatan:**
- Model ini penting untuk melacak alur pemesanan dari awal hingga selesai.
- Penggunaan nilai default di `fromMap()` (seperti status "baru" dan `DateTime.now()` untuk tanggal) membuat proses pembuatan objek menjadi lebih tangguh terhadap data yang tidak lengkap.

**Rules:**
- `idPelanggan`, `idPaket`, `tanggal`, dan `status` adalah field yang wajib diisi.
- Jika `status` tidak ada saat data dibaca, maka akan secara default diatur ke "baru".
- Jika `tanggal` tidak ada, maka akan diatur ke waktu saat ini.

### **File: lib/model/riwayat_langganan_model.dart**
**Fitur:** Model Data untuk Riwayat Langganan

**Tujuan file ini dibuat:** Untuk menyimpan catatan historis dari setiap langganan yang pernah dimiliki oleh pelanggan. Model ini memiliki keunikan karena ia menyimpan "snapshot" atau salinan data dari paket pada saat transaksi terjadi. Ini memastikan bahwa riwayat tetap akurat meskipun detail paket (seperti harga atau nama) berubah di masa depan.

**Daftar Fungsi/Class:**
- `class RiwayatLanggananModel`: Kelas yang mendefinisikan struktur data riwayat.
    - `id`, `idPelanggan`, `idPaket`: ID relasional untuk menghubungkan riwayat dengan pelanggan dan paket aslinya.
    - **Snapshot Data Paket**:
        - `namaPaket`, `hargaPaket`, `durasiPaket`, `tipeDurasiPaket`: Ini adalah data yang disalin dari `PaketModel` pada saat langganan dibuat.
    - `tanggalMulai`, `tanggalBerakhir`: Periode aktif dari langganan historis ini.
    - `status`: Status pembayaran pada saat itu.
    - `diperbarui`, `isDeleted`, `diarsipkan`: Properti standar untuk manajemen data.
- `_parseDateTime()`: Fungsi utilitas internal untuk mengurai tanggal.
- `factory RiwayatLanggananModel.fromMap(Map<String, dynamic> map)`: Factory constructor untuk membuat objek dari `Map`. Menggunakan nilai default jika ada data yang hilang untuk memastikan objek selalu dapat dibuat.
- `toMapForFirebase()`: Mengonversi objek menjadi `Map` dengan format yang dioptimalkan untuk Firestore, yaitu menggunakan `Timestamp` untuk data tanggal.
- `toMapForSqflite()`: Mengonversi objek menjadi `Map` dengan format untuk SQLite, menggunakan string ISO 8601 untuk tanggal.
- `toMap()`: Metode default yang akan digunakan oleh layanan sinkronisasi. Saat ini, metode ini memanggil `toMapForFirebase()`.

**Catatan:**
- Penyimpanan *snapshot* data paket adalah praktik desain yang sangat baik untuk data historis, karena ini menjaga integritas data dari waktu ke waktu dan mencegah data riwayat berubah ketika data master (paket) diperbarui.
- Adanya dua metode `toMap` yang berbeda (`toMapForFirebase` dan `toMapForSqflite`) menunjukkan bahwa model ini dirancang untuk bekerja dengan mulus di dua lingkungan database yang berbeda.

**Rules:**
- Semua properti snapshot (seperti `namaPaket`, `hargaPaket`) wajib diisi untuk memastikan setiap riwayat memiliki konteks yang lengkap.
- Saat membaca data dari `Map`, jika ada data yang hilang, nilai default yang "aman" akan digunakan (misalnya, "Tidak Diketahui" untuk nama paket).


### **File: lib/services/cek_koneksi_internet.dart**
**Fitur:** Pengecekan Koneksi Internet

**Tujuan file ini dibuat:** Untuk menyediakan sebuah layanan terpusat yang dapat digunakan di seluruh bagian aplikasi untuk memeriksa status koneksi internet perangkat. Ini menghindarkan duplikasi kode dan memastikan logika pengecekan koneksi konsisten.

**Daftar Fungsi/Class:**
- `class KoneksiInternetService`: Kelas yang berisi logika untuk pengecekan koneksi.
    - `static Future<bool> cekKoneksi()`: Sebuah fungsi statis yang dapat dipanggil dari mana saja tanpa perlu membuat instance dari kelas. Fungsi ini:
        1. Menggunakan paket `connectivity_plus` untuk mendapatkan status konektivitas jaringan saat ini.
        2. Memeriksa apakah perangkat terhubung ke jaringan seluler (`mobile`) atau WiFi.
        3. Mengembalikan `Future<bool>` yang akan bernilai `true` jika terhubung ke salah satunya, dan `false` jika tidak.

**Catatan:**
- Penggunaan metode `static` sangat efisien untuk fungsi utilitas seperti ini, karena tidak perlu mengelola state dan dapat diakses secara langsung.
- Layanan ini adalah komponen krusial, terutama untuk fitur-fitur yang memerlukan sinkronisasi data dengan server, seperti yang terlihat pada `SplashScreen`.

**Rules:**
- Fungsi `cekKoneksi()` harus selalu di-`await` karena ia mengembalikan sebuah `Future`.

### **File: lib/services/cek_langganan_kadaluarsa_service.dart**
**Fitur:** Layanan Pengecekan Langganan Kedaluwarsa

**Tujuan file ini dibuat:** Untuk menyediakan layanan yang berjalan di latar belakang untuk secara otomatis memeriksa dan mengarsipkan langganan pelanggan yang telah melewati tanggal akhirnya. Ini adalah tugas pemeliharaan penting untuk memastikan data pelanggan aktif selalu relevan.

**Daftar Fungsi/Class:**
- `class CekLanggananKadaluarsaService`: Kelas layanan yang mengorkestrasi proses pengecekan.
- `Future<void> prosesLanggananKadaluarsa()`: Metode utama yang memulai proses. Logikanya adalah sebagai berikut:
    1.  Membuat instance dari `PelangganAktifOperasi` untuk mendapatkan akses ke operasi database.
    2.  Memanggil metode `_pelangganAktifOperasi.arsipkanPelangganKadaluarsa()`. Seluruh logika kompleks untuk mencari data kedaluwarsa dan memperbaruinya di database ditangani oleh layer operasi ini.
    3.  Mencatat (log) hasil proses, baik jumlah langganan yang berhasil diarsipkan, atau jika tidak ada yang perlu diarsipkan.
    4.  Menangkap dan mencatat error secara detail jika terjadi kegagalan.

**Catatan:**
- Layanan ini adalah contoh yang bagus dari pemisahan tanggung jawab (*separation of concerns*). Layanan ini bertindak sebagai koordinator (`what to do`), sementara `PelangganAktifOperasi` bertindak sebagai eksekutor (`how to do it`).
- Layanan ini dipanggil dari `HalamanUtama`, yang berarti proses pengecekan ini dijalankan secara berkala saat pengguna membuka aplikasi.

**Rules:**
- Layanan ini tidak boleh memiliki interaksi langsung dengan UI.
- Semua output, baik keberhasilan maupun kegagalan, harus dicatat menggunakan `developer.log` untuk kemudahan debugging.

### **File: lib/services/notifikasi_servis.dart**
**Fitur:** Manajemen Notifikasi Lokal

**Tujuan file ini dibuat:** Untuk menyediakan layanan terpusat yang mengelola semua aspek notifikasi lokal di aplikasi. Ini mencakup inisialisasi, permintaan izin, penjadwalan, penampilan, dan pembatalan notifikasi, sehingga mengisolasi logika notifikasi dari bagian lain aplikasi.

**Daftar Fungsi/Class:**
- `class NotifikasiServis`: Kelas utama yang membungkus fungsionalitas dari plugin `flutter_local_notifications`.
- `Future<void> inisialisasi()`: Metode krusial yang harus dipanggil sekali saat aplikasi dimulai (di `SplashScreen`). Ini melakukan:
    1.  Konfigurasi pengaturan awal untuk Android dan iOS.
    2.  Membuat "Channel Notifikasi" khusus untuk Android, yang wajib ada untuk Android 8.0+.
    3.  Menginisialisasi pustaka zona waktu (`timezone`) dan mengaturnya ke 'Asia/Jakarta' untuk memastikan penjadwalan notifikasi akurat.
- `Future<void> requestPermissions()`: Meminta izin kepada pengguna untuk menampilkan notifikasi. Ini adalah langkah penting, terutama pada iOS dan versi Android yang lebih baru.
- `Future<void> tampilkanNotifikasiLangsung(...)`: Menampilkan notifikasi secara instan di perangkat pengguna.
- `Future<void> jadwalNotifikasi(...)`: Menjadwalkan notifikasi untuk ditampilkan pada waktu tertentu di masa depan. Menggunakan `zonedSchedule` untuk menangani zona waktu dengan benar.
- `Future<void> batalNotifikasi(int id)`: Membatalkan notifikasi yang telah dijadwalkan berdasarkan `id` uniknya.
- `Future<void> perbaruiJadwalNotifikasi(...)`: Sebuah metode praktis untuk memperbarui notifikasi yang ada dengan cara membatalkan yang lama dan menjadwalkan yang baru dengan detail yang diperbarui.
- `onDidReceiveNotificationResponse(...)`: Sebuah fungsi global yang berjalan di background. Fungsi ini dipicu ketika pengguna mengetuk notifikasi, memungkinkan aplikasi untuk bereaksi terhadap interaksi tersebut.

**Catatan:**
- Layanan ini sangat penting untuk mengingatkan pengguna tentang hal-hal penting, seperti langganan yang akan segera berakhir.
- Penggunaan `developer.log` (melalui `debugPrint`) untuk mencatat setiap aksi (inisialisasi, pengiriman, penjadwalan) sangat membantu dalam proses debugging.

**Rules:**
- Metode `inisialisasi()` wajib dipanggil sebelum metode notifikasi lainnya dapat berfungsi.
- Setiap notifikasi yang dijadwalkan harus memiliki `id` integer yang unik agar dapat dikelola (dibatalkan atau diperbarui) secara individual.

### **File: lib/utils/colors.dart**
**Fitur:** Palet Warna Aplikasi

**Tujuan file ini dibuat:** Untuk mendefinisikan dan mengelola semua warna yang digunakan di dalam aplikasi secara terpusat. Dengan mengumpulkan semua konstanta warna dalam satu kelas, ini memastikan konsistensi visual di seluruh UI dan memudahkan jika ada perubahan tema atau branding di masa depan.

**Daftar Fungsi/Class:**
- `class AppColors`: Sebuah kelas yang berisi kumpulan konstanta `Color`.
    - `primaryColor`: Warna utama yang digunakan untuk elemen-elemen penting seperti AppBar, tombol utama, dll.
    - `secondaryColor`: Warna sekunder, sering digunakan untuk latar belakang atau elemen pendukung.
    - `accentColor`: Warna aksen untuk menyorot elemen interaktif atau penting.
    - `textColor`: Warna teks default.
    - `backgroundColor`: Warna latar belakang utama aplikasi.

**Catatan:**
- Mendefinisikan warna secara terpusat seperti ini adalah praktik terbaik yang sangat disarankan. Jika suatu saat desainer meminta untuk mengubah warna utama dari biru menjadi hijau, kita hanya perlu mengubahnya di satu tempat, yaitu di file ini.
- Semua properti di kelas ini dideklarasikan sebagai `static const`, yang berarti nilai-nilai ini adalah konstanta waktu kompilasi dan dapat diakses dari mana saja tanpa perlu membuat instance dari `AppColors` (misalnya: `AppColors.primaryColor`).

**Rules:**
- Setiap kali mendefinisikan warna baru yang akan digunakan di lebih dari satu tempat, warna tersebut harus ditambahkan ke dalam kelas `AppColors` ini.
- Jangan melakukan *hard-coding* nilai warna (misalnya, `Color(0xFFFFFFFF)`) langsung di dalam widget. Selalu gunakan konstanta dari `AppColors`.

### **File: lib/utils/format_util.dart**
**Fitur:** Utilitas Pemformatan Data (Tanggal, Jam, Uang)

**Tujuan file ini dibuat:** Untuk menyediakan sekumpulan fungsi statis yang terorganisir untuk memformat berbagai jenis data seperti tanggal, jam, dan mata uang. Menggunakan kelas utilitas terpisah ini memastikan konsistensi format di seluruh aplikasi dan memisahkan logika pemformatan dari logika UI atau bisnis.

**Daftar Fungsi/Class:**
- `class FormatTanggal`: Berisi metode statis untuk memformat objek `DateTime` menjadi string tanggal.
    - `formatTanggalBasic(DateTime)`: Mengubah `DateTime` menjadi format tanggal standar (contoh: "17 Agu 2024").
    - `formatTanggalDanJam(DateTime)`: Mengubah `DateTime` menjadi format tanggal lengkap dengan jam dan menit.
    - `formatTanggalRingkas(DateTime)`: Mengubah `DateTime` menjadi format ringkas yang menyertakan nama hari.
- `class FormatJam`: Berisi metode statis untuk memformat objek `DateTime` menjadi string waktu.
    - `formatJamMenit(DateTime)`: Hanya mengambil bagian jam dan menit dari `DateTime`.
    - `formatJamLengkap(DateTime)`: Mengambil jam, menit, dan detik.
    - `formatTeksKeJam(String)`: Mengonversi string waktu (format ISO) menjadi format jam, dengan penanganan error jika string tidak valid.
- `class FormatUang`: Berisi metode statis untuk memformat angka menjadi string mata uang.
    - `formatMataUang(double)`: Mengubah angka menjadi format mata uang Rupiah yang mudah dibaca, lengkap dengan simbol "Rp" dan pemisah ribuan (contoh: "Rp 50.000").

**Catatan:**
- Penggunaan konstruktor privat (`._()`) adalah praktik yang baik untuk kelas utilitas murni, karena mencegah developer lain membuat instance dari kelas ini secara tidak sengaja.
- Semua metode adalah `static`, sehingga dapat dipanggil langsung dari kelasnya (misal: `FormatUang.formatMataUang(50000)`) tanpa perlu membuat objek.
- Penggunaan paket `intl` dengan lokal `id_ID` menjamin bahwa semua format sesuai dengan standar Indonesia.

**Rules:**
- Setiap logika pemformatan baru yang berkaitan dengan tanggal, jam, atau uang harus ditambahkan ke dalam kelas yang sesuai di file ini.
- Jangan melakukan pemformatan manual di dalam kode widget. Selalu panggil metode dari kelas-kelas utilitas ini untuk menjaga konsistensi.

### **File: lib/utils/sync_manager.dart**
**Fitur:** Manajemen Timestamp Sinkronisasi
**Tujuan file ini dibuat:** Untuk mengelola waktu sinkronisasi terakhir antara aplikasi dan server. File ini menggunakan `SharedPreferences` untuk menyimpan dan mengambil *timestamp* terakhir, yang krusial untuk proses sinkronisasi data delta (hanya data yang berubah).

**Penjelasan Kode:**
- `class SyncManager`: Kelas utilitas yang menyediakan metode untuk berinteraksi dengan `SharedPreferences`.
- `getLastSyncTimestamp()`: Fungsi `async` yang mengambil `timestamp` terakhir kali sinkronisasi berhasil. 
    - Jika tidak ada `timestamp` yang tersimpan (misalnya saat aplikasi dijalankan pertama kali), fungsi ini akan mengembalikan `DateTime` dari epoch (tahun 1970). Hal ini memastikan bahwa pada sinkronisasi pertama, semua data dari server akan diunduh.
    - **(Perbaikan)** Blok `catch` sekarang menggunakan `developer.log` untuk mencatat error secara detail, lengkap dengan nama logger dan *stack trace*, yang jauh lebih baik untuk debugging daripada `print()`.
- `setLastSyncTimestamp(DateTime time)`: Fungsi `async` yang menyimpan `timestamp` waktu saat ini ke `SharedPreferences` setelah proses sinkronisasi berhasil diselesaikan.

**Rules:**
- `getLastSyncTimestamp()` harus selalu dipanggil sebelum memulai proses sinkronisasi untuk mengetahui data mana yang perlu diambil.
- `setLastSyncTimestamp()` harus dipanggil setelah proses sinkronisasi selesai dan berhasil.

### **File: lib/widget/nama_dari_id.dart**
**Fitur:** Widget untuk Menampilkan Nama Pelanggan dari ID

**Tujuan file ini dibuat:** Untuk menyediakan sebuah widget yang dapat digunakan kembali (`reusable`) di berbagai bagian UI untuk menampilkan nama seorang pelanggan hanya dengan memberikan `userId`. Widget ini secara otomatis menangani proses pengambilan data dari database, menampilkan indikator loading, dan menangani kasus jika pelanggan tidak ditemukan.

**Daftar Fungsi/Class:**
- `class NamaDariIdWidget`: Sebuah `StatefulWidget` yang menerima `userId` sebagai parameter wajib.
- `build(BuildContext context)`: Metode ini adalah inti dari widget, yang menggunakan `FutureBuilder` untuk mengelola siklus hidup dari operasi asynchronous (mengambil data dari database).
    - `future`: Memanggil metode `getPelangganById(userId)` dari `PelangganOperasi` untuk memulai proses pencarian data pelanggan di database.
    - `builder`: Sebuah fungsi yang mendefinisikan apa yang harus ditampilkan di UI berdasarkan status dari `Future`:
        1.  **Saat Menunggu (`ConnectionState.waiting`)**: Menampilkan sebuah `CircularProgressIndicator` kecil untuk memberi tahu pengguna bahwa data sedang dimuat.
        2.  **Jika Ada Error atau Data Tidak Ditemukan**: Menampilkan teks "User Tidak Dikenal". Ini adalah penanganan fallback yang baik.
        3.  **Jika Berhasil**: Menampilkan nama pelanggan (`pelanggan.nama`) yang berhasil ditemukan.

**Catatan:**
- Widget ini adalah contoh yang sangat baik dari prinsip *Don't Repeat Yourself* (DRY). Daripada menulis logika `FutureBuilder` untuk mengambil nama pelanggan berulang kali di banyak tempat, kita cukup membungkusnya dalam satu widget ini.
- Widget ini juga memisahkan antara pengambilan data dan presentasi UI dengan rapi.

**Rules:**
- Widget ini harus selalu diberikan `userId` yang valid.
- Tampilan teks (seperti ukuran dan warna font) dapat disesuaikan melalui parameter `style` opsional.

### **File: lib/widget/nama_paket.dart**
**Fitur:** Widget untuk Menampilkan Nama Paket dari ID

**Tujuan file ini dibuat:** Serupa dengan `NamaDariIdWidget`, widget ini bertujuan untuk menyediakan komponen UI yang dapat digunakan kembali (`reusable`) untuk menampilkan nama sebuah paket langganan hanya dengan memberikan `idPaket`. Ini mengisolasi logika pengambilan data paket dari database dan menyederhanakan kode di banyak bagian aplikasi.

**Daftar Fungsi/Class:**
- `class NamaPaketWidget`: Sebuah `StatelessWidget` yang membutuhkan `idPaket` sebagai parameter.
- `build(BuildContext context)`: Menggunakan `FutureBuilder` untuk secara asynchronous mengambil data paket dan merender UI yang sesuai dengan state-nya.
    - `future`: Memanggil metode `getPaketById(idPaket)` dari `PaketOperasi` untuk mengambil detail paket dari database.
    - `builder`: Fungsi yang menentukan tampilan widget berdasarkan status `Future`:
        1.  **Saat Menunggu (`ConnectionState.waiting`)**: Menampilkan `CircularProgressIndicator` kecil untuk menandakan proses loading.
        2.  **Jika Ada Error atau Data Tidak Ditemukan**: Menampilkan teks "Paket tidak tersedia" dengan warna merah untuk memberikan indikasi yang jelas bahwa ada sesuatu yang salah.
        3.  **Jika Berhasil**: Menampilkan nama paket (`snapshot.data!.nama`) yang berhasil ditemukan.

**Catatan:**
- Widget ini sangat berguna pada halaman detail atau daftar di mana kita memiliki ID dari sebuah entitas (dalam hal ini paket) dan perlu menampilkan nama yang lebih deskriptif kepada pengguna.
- Dengan membungkus logika ini dalam satu widget, kita memastikan bahwa semua tempat yang menampilkan nama paket dari ID akan memiliki perilaku yang konsisten, termasuk tampilan loading dan pesan error.

**Rules:**
- Widget ini harus selalu diberikan `idPaket` yang valid.
- Tampilan teks dapat dikustomisasi melalui parameter `style` opsional.

### **File: lib/widget/nama_pelanggan.dart**
**Fitur:** Widget untuk Menampilkan Nama Pelanggan dari ID (Varian)

**Tujuan file ini dibuat:** Widget ini memiliki fungsi yang hampir identik dengan `NamaDariIdWidget`, yaitu untuk menampilkan nama pelanggan berdasarkan ID-nya. Perbedaan utamanya terletak pada bagaimana ia menampilkan status loading dan error, memberikan variasi tampilan yang bisa dipilih sesuai kebutuhan desain di halaman tertentu.

**Daftar Fungsi/Class:**
- `class NamaPelangganWidget`: Sebuah `StatelessWidget` yang menerima `idPelanggan` sebagai parameter wajib.
- `build(BuildContext context)`: Seperti widget `FutureBuilder` lainnya, metode ini menangani pengambilan data secara asynchronous.
    - `future`: Memanggil `getPelangganById(idPelanggan)` dari `PelangganOperasi`.
    - `builder`: Merender UI berdasarkan state dari `Future`:
        1.  **Saat Menunggu (`ConnectionState.waiting`)**: Menampilkan teks "..." dengan warna abu-abu. Ini adalah alternatif yang lebih minimalis dibandingkan `CircularProgressIndicator`.
        2.  **Jika Ada Error**: Menampilkan teks "Error" dengan gaya miring dan warna merah.
        3.  **Jika Berhasil**: Menampilkan nama pelanggan yang ditemukan dengan teks tebal.
        4.  **Jika Data Tidak Ditemukan**: Menampilkan teks "Pelanggan tidak ditemukan" dengan gaya miring dan warna abu-abu.

**Catatan:**
- Widget ini menunjukkan bagaimana kita bisa membuat beberapa komponen serupa dengan sedikit variasi untuk memberikan fleksibilitas pada tim UI/UX tanpa harus mengulang logika `FutureBuilder` yang sama.
- Perbedaan utama dari `NamaDariIdWidget` adalah penggunaan teks "..." sebagai indikator loading, yang mungkin lebih cocok untuk beberapa layout antarmuka.

**Rules:**
- Widget ini wajib diberi `idPelanggan` yang valid.
- Tampilan teks juga dapat dikustomisasi melalui parameter `style` opsional, namun ia memiliki gaya default yang berbeda untuk setiap state (loading, error, success, not found).

### **File: lib/widget/thousands_input_formatter.dart**
**Fitur:** Formatter Input Angka (Ribuan & Negatif)

**Tujuan file ini dibuat:** Untuk menyediakan sebuah `TextInputFormatter` kustom yang dapat dipasang pada `TextField`. Formatter ini secara otomatis mengubah input angka dari pengguna menjadi format dengan pemisah ribuan (misalnya, "10000" menjadi "10.000") dan juga mendukung input angka negatif.

**Daftar Fungsi/Class:**
- `class ThousandsAndNegativeInputFormatter`: Sebuah kelas yang mewarisi `TextInputFormatter`.
- `formatEditUpdate(oldValue, newValue)`: Ini adalah metode inti yang di-override. Logikanya adalah sebagai berikut:
    1.  Menerima input baru (`newValue`) dari pengguna.
    2.  Menangani kasus-kasus khusus seperti input kosong atau saat pengguna baru saja mengetik tanda minus (`-`).
    3.  Menghapus semua karakter yang bukan angka, kecuali tanda minus di awal.
    4.  Menggunakan paket `intl` dengan lokal `id_ID` untuk memformat angka dengan benar (menggunakan titik sebagai pemisah ribuan).
    5.  Menggabungkan kembali tanda minus jika ada.
    6.  Mengembalikan `TextEditingValue` yang baru, yang sudah diformat, sambil memastikan posisi kursor berada di akhir teks.

**Catatan:**
- Ini adalah komponen yang sangat dapat digunakan kembali (`reusable`) untuk `TextField` mana pun yang ditujukan untuk input mata uang atau angka besar, sehingga meningkatkan pengalaman pengguna secara signifikan.
- Logika di dalamnya cukup cerdas untuk menangani input parsial, seperti saat pengguna baru saja mengetik tanda `-` dan belum memasukkan angkanya.

**Rules:**
- Untuk menggunakannya, tambahkan instance dari `ThousandsAndNegativeInputFormatter()` ke dalam properti `inputFormatters` pada sebuah `TextField` atau `TextFormField`.
- Sebaiknya atur juga `keyboardType` pada `TextField` menjadi `TextInputType.numberWithOptions(signed: true)` untuk memunculkan keyboard numerik yang menyertakan tombol minus.

---
## Struktur Folder `lib/`

```
lib/:
data
firebase_options.dart
halaman
halaman_utama.dart
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
data_dummy.dart
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
pesanan_operasi.dart
riwayat_langganan_operasi.dart
sub_kategori_operasi.dart
transaksi_operasi.dart
versi_apk_user_operasi.dart

lib/data/services:
navigasi_servis.dart
sinkronisasi_database.dart

lib/data/sync:
unduh_data.dart
unggah_data.dart

lib/halaman:
detail
form
lainnya
tab

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
form_transaksi.dart
form_versi_apk_user.dart

lib/halaman/lainnya:
kategori.dart
kritik_saran.dart
paket.dart
pelanggan.dart
riwayat_aktivasi_paket.dart
tentang_aplikasi.dart
versi_apk_user.dart

lib/halaman/tab:
dompet.dart
fungsi_menampilkan_notifikasi.dart
home.dart
lainnya.dart
pelanggan_aktif.dart
pesanan.dart
transaksi.dart

lib/model:
dompet_model.dart
enum
kategori_model.dart
kritik_saran_model.dart
paket_model.dart
pelanggan_aktif_model.dart
pelanggan_model.dart
pesanan_model.dart
riwayat_langganan_model.dart
sub_kategori_model.dart
transaksi_model.dart
versi_apk_user_model.dart

lib/model/enum:
status_pembayaran.dart

lib/server:
server_lokal.dart

lib/services:
cek_koneksi_internet.dart
cek_langganan_kadaluarsa_service.dart
kontrol_aplikasi_service.dart
notifikasi_servis.dart
pembersihan_data_service.dart

lib/utils:
colors.dart
format_util.dart
perhitungan_util.dart
sync_manager.dart

lib/whatsapp:
info_paket.dart

lib/widget:
nama_dari_id.dart
nama_paket.dart
nama_pelanggan.dart
thousands_input_formatter.dart
```
