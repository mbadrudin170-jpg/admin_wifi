# Versi: v1.1.2 (Internal Refactor)
Sumber: Perubahan internal, versi pubspec tidak berubah
Tanggal: 2024-07-27

## Tujuan:
Menyempurnakan dan merapikan alur inisialisasi aplikasi saat pertama kali dijalankan. Tujuannya adalah untuk memastikan bahwa jika database lokal masih kosong, aplikasi akan secara proaktif mengunduh data awal dari server (Firestore), bukan lagi menggunakan data dummy. Ini meningkatkan pengalaman pengguna baru secara signifikan.

## Perubahan:
- **`lib/data/sync/pengecekan_tabel_kosong.dart` (File Baru):**
    - Membuat file baru yang berisi `PengecekanTabelKosongService`.
    - **Logika Cerdas**: Layanan ini memeriksa tabel-tabel penting (`paket`, `kategori`, dll.) satu per satu.
    - **Pemicu Unduhan**: Jika sebuah tabel ditemukan kosong (`COUNT(*) == 0`), layanan ini akan memanggil metode unduh yang sesuai dari `LayananUnduhData` untuk mengisi tabel tersebut dengan data *live* dari server.
    - **Perubahan Nama**: Nama file diubah dari `unduhan_awal.dart` dan kelas diubah dari `UnduhanAwalService` untuk lebih akurat mendeskripsikan fungsinya.
- **`lib/splash_screen.dart` (Integrasi):**
    - **Integrasi Pengecekan**: Memanggil `PengecekanTabelKosongService().cekDanIsiDataAwal()` di dalam alur inisialisasi `_initializeAndNavigate()`.
    - **Urutan Eksekusi**: Panggilan ini ditempatkan secara strategis *setelah* database berhasil diinisialisasi (`await DatabaseHelper.instance.database;`) dan *sebelum* proses sinkronisasi data umum, memastikan database siap dan sudah berisi data dasar jika diperlukan.
    - **Umpan Balik Pengguna**: Menambahkan pesan status `_updateLoading("Memeriksa data awal...")` untuk memberi tahu pengguna apa yang sedang terjadi.
- **`lib/services/servis_sinkronisasi.dart` (File Baru):**
    - Membuat layanan terpusat untuk mengelola sinkronisasi data.
    - **Sinkronisasi Manual**: Menyediakan metode `sinkronisasiManual()` yang mengorkestrasi proses unggah data lokal ke server diikuti dengan unduh data dari server.
    - **Sinkronisasi Otomatis**: Menyediakan metode `mulaiSinkronisasiOtomatis()` yang menggunakan `Timer.periodic` untuk menjalankan sinkronisasi secara berkala pada interval yang dapat dikonfigurasi.
    - **Manajemen State**: Menggunakan `ChangeNotifier` untuk memberi tahu bagian lain dari aplikasi (misalnya, UI) tentang status proses sinkronisasi (`_isSinkronisasi`).

## Dampak:
- **Pengalaman Pengguna Baru yang Lebih Baik**: Saat aplikasi diinstal untuk pertama kalinya, aplikasi akan langsung terisi dengan data terbaru dari server, bukan data dummy statis.
- **Kode Lebih Rapi & Terpusat**: Logika pengecekan data awal dan logika sinkronisasi kini berada di dalam kelas layanan mereka sendiri, membuat `SplashScreen` lebih bersih dan lebih fokus pada orkestrasi.
- **Otomatisasi**: Proses sinkronisasi data sekarang dapat berjalan secara otomatis di latar belakang, menjaga data tetap segar tanpa intervensi pengguna.

## Analisa:
- Memisahkan logika bisnis (seperti inisialisasi data dan sinkronisasi) ke dalam kelas-kelas layanan khusus adalah praktik yang baik. Ini mengikuti prinsip *Single Responsibility Principle* dan membuat kode lebih mudah diuji, dipelihara, dan dipahami.
- Menempatkan pemicu layanan ini di `SplashScreen` adalah pilihan yang tepat karena ini adalah titik masuk utama aplikasi di mana semua tugas persiapan harus diselesaikan sebelum pengguna dapat berinteraksi dengan aplikasi.

---

# Versi: Perbaikan Internal (Testing)
Tanggal: 2024-07-27

## Tujuan:
Memperbaiki serangkaian error kompilasi dan peringatan yang muncul di beberapa file pengujian (`test file`) setelah adanya refaktor pada kelas `DatabaseHelper`.

## Perubahan:
- **`lib/data/sqlite.dart`**:
    - Metode `stubDb(Database db)` diperkenalkan untuk menggantikan *setter* pada properti `database`, menyediakan cara yang lebih eksplisit untuk menyuntikkan database tiruan (mock) selama pengujian.
    - Metode `createTables(Database db)` diekspos menjadi publik agar bisa dipanggil langsung dari setup tes untuk menginisialisasi skema.
    - Menghapus impor `package:sqflite/sqflite.dart` yang tidak perlu.
- **`test/data/operasi/transaksi_operasi_test.dart`**:
    - Memperbaiki error `assignment_to_final_no_setter` dengan mengganti pemanggilan `DatabaseHelper.instance.database = ...` menjadi `DatabaseHelper.instance.stubDb(...)`.
    - Merombak struktur `setUp` dan `tearDown` untuk menggunakan database *in-memory* yang baru dan terisolasi untuk setiap tes, meningkatkan keandalan.
- **`test/data/operasi/versi_apk_user_operasi_test.dart`**:
    - Melakukan perbaikan serupa, mengganti penggunaan *setter* yang salah dan merapikan struktur tes untuk isolasi yang lebih baik.
- **File Mock (`*.mocks.dart`)**:
    - Menjalankan `dart run build_runner build --delete-conflicting-outputs` untuk meregenerasi file-file *mock*. Ini secara otomatis menyelesaikan peringatan `override_on_non_overriding_member` yang muncul karena ketidaksesuaian dengan `DatabaseHelper` yang baru.

## Bug yang Diperbaiki:
- `assignment_to_final_no_setter`: Terjadi di beberapa file tes karena mencoba mengisi properti `database` yang tidak lagi memiliki *setter*.
- `override_on_non_overriding_member`: Terjadi di file *mock* yang dihasilkan karena `mockito` mencoba meng-override *setter* `database` yang sudah dihapus dari kelas `DatabaseHelper`.

## Solusi:
- Mengadopsi metode `stubDb()` sebagai cara standar untuk injeksi database dalam pengujian.
- Menerapkan pola inisialisasi per-tes (`setUp` dan `tearDown`) untuk memastikan tidak ada efek samping antar tes.
- Menjalankan kembali `build_runner` untuk menyinkronkan file *mock* dengan perubahan pada kelas aslinya.

## Dampak:
- Semua error kompilasi dan peringatan yang terkait dengan pengujian berhasil dihilangkan.
- Stabilitas dan keandalan *test suite* meningkat secara signifikan.
- Basis kode kembali ke keadaan bersih dan semua 165 tes berhasil dijalankan (`All tests passed!`), mengonfirmasi bahwa tidak ada regresi fungsional.

## Analisa:
Perubahan pada kelas inti seperti `DatabaseHelper` memiliki dampak luas pada file-file pengujian. Proses ini menyoroti pentingnya:
1.  Segera memperbaiki file-file tes yang bergantung pada kelas yang diubah.
2.  Menjalankan kembali `build_runner` setelah mengubah antarmuka publik dari sebuah kelas untuk menjaga konsistensi file yang dihasilkan.
3.  Menggunakan pola isolasi tes (misalnya, membuat database baru untuk setiap tes) untuk mencegah hasil yang tidak terduga dan sulit dilacak.

---
# Versi: v1.0.9
Sumber: pubspec.yaml (version: 1.0.9+4)
Tanggal: 2024-07-27

## Tujuan:
Mengimplementasikan fitur "Pengaturan Aplikasi" secara penuh, memungkinkan admin untuk mengonfigurasi interval sinkronisasi, kebijakan penghapusan data arsip, dan mengaktifkan/menonaktifkan mode pemeliharaan langsung dari antarmuka aplikasi.

## Perubahan:
- **`lib/model/pengaturan_model.dart`**: Membuat model data baru (`PengaturanModel`) untuk mendefinisikan struktur data pengaturan.
- **`lib/data/sqlite.dart`**: Melakukan migrasi database ke versi 28 dengan menambahkan tabel `pengaturan` baru untuk menyimpan konfigurasi aplikasi secara lokal.
- **`lib/data/operasi/pengaturan_operasi.dart`**: Membuat file operasi baru yang menyediakan metode CRUD (Create, Read, Update) untuk data pengaturan di database SQLite.
- **`lib/halaman/lainnya/pengaturan.dart`**: Membuat halaman UI baru yang berfungsi sebagai dasbor untuk menampilkan pengaturan yang sedang aktif dan menyediakan tombol untuk masuk ke mode edit.
- **`lib/halaman/form/form_pengaturan.dart`**: Membuat halaman formulir khusus untuk mengubah dan menyimpan nilai-nilai pengaturan. Formulir ini dilengkapi dengan validasi input.
- **`lib/data/sync/unduh_data.dart`**: Memperluas fungsionalitas sinkronisasi dengan menambahkan fungsi `unduhDataPengaturan` untuk mengambil data konfigurasi dari Firestore dan menyimpannya ke database SQLite lokal.
- **Perbaikan Kode**: Memperbaiki berbagai error dan peringatan yang dilaporkan oleh `flutter analyze` di beberapa file.

## Bug:
- Ditemukan error `Missing required argument` saat membuat instance `PengaturanModel` tanpa argumen, karena konstruktor telah diubah untuk menuntut nilai.
- Analyzer melaporkan penggunaan `withOpacity` yang sudah usang (`deprecated_member_use`) dan urutan properti `child` yang salah (`sort_child_properties_last`) di file `form_pengaturan.dart`.
- Sebuah baris komentar "tugas" di `unduh_data.dart` menyebabkan parser analyzer gagal dan melaporkan banyak error sintaks yang keliru.

## Solusi:
- Memperbaiki `pengaturan_operasi.dart` dengan menyediakan nilai default yang eksplisit saat `PengaturanModel` dibuat dalam kondisi fallback (data tidak ada atau terjadi error).
- Memperbaiki `form_pengaturan.dart` sesuai dengan rekomendasi analyzer, yaitu mengganti `withOpacity` dengan `Color.fromRGBO` dan memindahkan properti `child` ke akhir.
- Menghapus baris komentar yang bermasalah di `unduh_data.dart` dan mengimplementasikan fungsionalitas yang diminta (unduh data pengaturan).

## Dampak:
- Aplikasi kini memiliki halaman pengaturan yang fungsional dan terpusat, memberikan kontrol lebih besar kepada admin.
- Kualitas kode meningkat secara signifikan setelah semua error dan peringatan dari `flutter analyze` berhasil diatasi, membuat aplikasi lebih stabil dan mudah dipelihara.

## Analisa:
- Proses analisis kode (`analyze_files`) kembali terbukti sangat vital dalam menemukan masalah tersembunyi, mulai dari bug logika hingga isu kualitas kode, dan memandu proses perbaikan.

---
# Versi: v1.1.1
Sumber: pubspec.yaml (version: 1.1.0+7)
Tanggal: 2024-07-26

## Tujuan:
Menambahkan fungsionalitas untuk membuat sub-kategori secara dinamis langsung dari halaman "Tambah Kategori Baru". Ini menyederhanakan alur kerja admin, karena mereka tidak perlu lagi membuat kategori induk terlebih dahulu dan kemudian mengeditnya untuk menambahkan sub-kategori.

## Perubahan:
- **`lib/halaman/form/form_kategori.dart`**:
    - **UI Dinamis**: Menambahkan `ListView.builder` dan `TextButton` "Tambah Input" yang hanya muncul dalam mode "Tambah Kategori". Ini memungkinkan pengguna menambah atau menghapus field input untuk sub-kategori sesuai kebutuhan.
    - **Manajemen State**: Menggunakan `List<TextEditingController>` untuk mengelola input teks dari setiap sub-kategori yang dinamis.
    - **Logika Penyimpanan (`_simpanForm`)**: Saat menyimpan kategori baru, logika diperbarui untuk:
        1.  Membuat ID unik untuk kategori induk terlebih dahulu.
        2.  Membuat `List<SubKategoriModel>` dari setiap `TextEditingController` yang terisi.
        3.  Setiap `SubKategoriModel` baru secara otomatis ditautkan ke ID kategori induk.
        4.  Menyimpan `KategoriModel` yang lengkap (termasuk daftar sub-kategorinya) ke database.
    - **Layout**: Seluruh form dibungkus dengan `SingleChildScrollView` untuk memastikan halaman dapat di-scroll jika daftar sub-kategori menjadi panjang.
    - **Perbaikan Analyzer**: Mengganti properti `value` yang usang pada `DropdownButtonFormField` dengan `initialValue` untuk mengatasi peringatan dari `flutter analyze`.\
- **`lib/data/sqlite.dart`**:
    - **Migrasi Database**: Menaikkan versi database dari 26 ke 27.
    - **Skema & Migrasi**: Menambahkan kolom `id_sub_kategori` bertipe `TEXT` ke tabel `kategori`. Ini penting untuk menyimpan daftar sub-kategori yang sudah di-serialize sebagai JSON string.

## Bug:
- Ditemukan ketidaksesuaian antara `KategoriModel` (yang memiliki field `id_sub_kategori`) dan skema tabel `kategori` di SQLite (yang tidak memiliki kolom tersebut). Ini akan menyebabkan error saat menyimpan data.
- Analyzer mendeteksi penggunaan properti `value` yang sudah usang di `DropdownButtonFormField`.

## Solusi:
- Melakukan migrasi database dengan menambahkan kolom `id_sub_kategori` ke tabel `kategori` melalui `ALTER TABLE` di dalam `_onUpgrade`.
- Mengganti `value` dengan `initialValue` pada `DropdownButtonFormField`.

## Dampak:
- Proses pembuatan kategori dan sub-kategori menjadi jauh lebih efisien dan intuitif bagi admin.
- Stabilitas aplikasi meningkat karena bug database kritis telah diperbaiki sebelum menjadi masalah di produksi.
- Kualitas kode terjaga dengan mengatasi semua peringatan dari analyzer.

## Analisa:
- Proses analisa (`analyze_files`) kembali terbukti efektif dalam menemukan masalah, kali ini terkait dengan properti yang usang.
- Sinkronisasi antara model data dan skema database adalah hal yang krusial dan harus selalu diperiksa setelah ada perubahan model.

---
# Versi: v1.1.0
Sumber: pubspec.yaml (version: 1.1.0+7)
Tanggal: 2024-07-26

## Tujuan:
Mengimplementasikan fitur "Arsip" untuk Kategori dan Sub-Kategori, menggantikan fungsi "Hapus" yang bersifat destruktif. Ini memungkinkan data disembunyikan dari tampilan utama tanpa menghapusnya secara permanen dari database.

## Perubahan:
- **`lib/halaman/lainnya/kategori.dart`**:
    - Mode "Hapus" diubah menjadi mode "Arsip".
    - Ikon `delete` diganti dengan ikon `archive`.
    - Mengimplementasikan dialog konfirmasi sebelum melakukan pengarsipan.
    - Logika untuk mengarsipkan kategori dan sub-kategori dengan mengatur tanggal `diarsipkan`.
    - Menambahkan pemeriksaan `if (!mounted) return;` setelah operasi `async` untuk mencegah *crash*.
- **`lib/data/operasi/kategori_operasi.dart`**:
    - Fungsi `getKategori()` dan `getKategoriByTipe()` dimodifikasi untuk hanya mengambil data yang kolom `diarsipkan`-nya `NULL`.
- **`lib/model/kategori_model.dart`**:
    - Memperbaiki `toMap()` dan `fromMap()` untuk menangani serialisasi daftar `subKategori` dengan benar (menggunakan `jsonEncode` dan `jsonDecode`).
    - Mengganti *key* dari `subKategori` menjadi `id_sub_kategori` di dalam `Map` untuk konsistensi database.
    - Memperbaiki bug di metode `copyWith` dimana nilai `diarsipkan` tidak disalin dengan benar.
    - Menghapus *cast* yang tidak perlu untuk meningkatkan kebersihan kode.

## Bug:
- Saat mengedit/memperbarui Kategori, daftar Sub-Kategorinya akan hilang karena tidak ikut disimpan ke database.
- Peringatan `use_build_context_synchronously` dari analyzer karena penggunaan `BuildContext` setelah operasi `await`.

## Solusi:
- Menggunakan `jsonEncode` untuk mengubah `List<SubKategoriModel>` menjadi `String` sebelum disimpan ke SQLite, dan `jsonDecode` saat mengambilnya.
- Menambahkan guard `if (!mounted) return;` sebelum memanggil `ScaffoldMessenger` setelah operasi `async`.

## Dampak:
- Pengguna sekarang dapat mengarsipkan kategori/sub-kategori, bukan menghapusnya, sehingga data tetap aman.
- UI menjadi lebih stabil dan terhindar dari potensi *crash*.
- Integritas data sub-kategori terjaga saat kategori induknya diperbarui.

## Analisa:
- Proses analisa kode (`analyze_files`) berhasil menemukan potensi *bug runtime* dan isu kualitas kode, yang kemudian berhasil diperbaiki.

---

## Dokumen Lengkap Proyek Saya per File

### File: lib/data/operasi/pengaturan_operasi.dart
**Fitur:** Operasi Database untuk Pengaturan
**Tujuan file ini dibuat:** Menyediakan lapisan abstraksi untuk semua operasi database (CRUD) yang terkait dengan tabel `pengaturan`.

**Penjelasan Kode:**
- **`getPengaturan()`**: Fungsi untuk mengambil satu-satunya baris data pengaturan. Fungsi ini dirancang untuk tangguh:
    - Jika data ditemukan, ia akan mengembalikannya.
    - Jika tidak ada data (misalnya, saat aplikasi pertama kali dijalankan), ia akan mengembalikan `PengaturanModel` dengan nilai default yang sudah ditentukan.
    - Jika terjadi error saat membaca database, ia akan mencatat error dan mengembalikan model default untuk mencegah aplikasi crash.
- **`simpanAtauPerbaruiPengaturan(PengaturanModel pengaturan)`**: Metode cerdas yang memeriksa apakah data pengaturan sudah ada di database. Jika sudah ada, ia akan melakukan `UPDATE`. Jika belum, ia akan melakukan `INSERT`. Ini memastikan hanya ada satu baris konfigurasi di tabel.

---

### File: lib/data/sqlite.dart
**Fitur:** Manajemen Database SQLite (Helper & Migrasi)
**Tujuan file ini dibuat:** Sebagai pusat kontrol untuk semua hal yang berkaitan dengan database SQLite. File ini bertanggung jawab untuk membuka koneksi database, membuat skema tabel saat pertama kali, dan menangani migrasi (perubahan skema) saat versi aplikasi diperbarui.

**Penjelasan Kode:**
- **Singleton Pattern**: Menggunakan `DatabaseHelper._privateConstructor()` dan `static final DatabaseHelper instance` untuk memastikan hanya ada satu instance dari `DatabaseHelper` di seluruh aplikasi, mencegah konflik koneksi database.
- **`_initDatabase()`**: Fungsi ini dipanggil saat database pertama kali dibuat. Ini mengeksekusi serangkaian perintah SQL `CREATE TABLE` untuk semua tabel yang dibutuhkan oleh aplikasi.
- **`_onUpgrade(db, oldVersion, newVersion)`**: Fungsi ini adalah kunci dari proses migrasi. Setiap kali `_dbVersion` dinaikkan, fungsi ini akan dieksekusi. Di dalamnya terdapat serangkaian `if (oldVersion < ...)` untuk menerapkan perubahan skema secara berurutan.
- **Perubahan Terbaru (v28)**:
    - **`_dbVersion` dinaikkan menjadi 28.**
    - **Migrasi v28**: Menambahkan logika `if (oldVersion < 28)` yang mengeksekusi perintah `CREATE TABLE pengaturan`. Tabel ini digunakan untuk menyimpan konfigurasi aplikasi.

---

### File: lib/data/sync/unduh_data.dart
**Fitur:** Layanan Sinkronisasi Data (Unduh dari Firestore)
**Tujuan file ini dibuat:** Untuk mengelola proses pengunduhan (sinkronisasi) data dari Firestore ke database SQLite lokal. Ini memungkinkan aplikasi berfungsi dalam mode offline dengan data yang relatif baru.

**Penjelasan Kode:**
- **`unduhSemuaData()`**: Fungsi utama yang mengorkestrasi pengunduhan semua koleksi data secara paralel menggunakan `Future.wait()`, membuatnya sangat efisien.
- **Fungsi Unduh Spesifik**: Untuk setiap koleksi (seperti `dompet`, `kategori`, `paket`, dll.), terdapat fungsi `unduhData...()` tersendiri.
- **`sinkronisasiKoleksi<T>()`**: Fungsi generik yang dapat digunakan kembali untuk menangani logika unduh umum: mengambil semua dokumen dari sebuah koleksi, mengonversinya menjadi daftar model, dan kemudian menyimpannya ke SQLite secara massal (batch).
- **Perubahan Terbaru**:
    - **`unduhDataPengaturan()`**: Menambahkan fungsi baru yang spesifik untuk mengunduh dokumen pengaturan tunggal dari Firestore (`pengaturan/default`) dan menyimpannya menggunakan `_pengaturanOperasi`. Logikanya berbeda karena tidak menangani daftar, melainkan satu objek.
    - Panggilan ke `unduhDataPengaturan()` ditambahkan ke dalam `Future.wait()` di `unduhSemuaData()`.
    - Memperbaiki error analisis dengan menghapus komentar yang salah format dan menambahkan semua impor yang diperlukan.

---

### File: lib/halaman/form/form_pengaturan.dart
**Fitur:** Formulir Edit Pengaturan Aplikasi
**Tujuan file ini dibuat:** Untuk menyediakan antarmuka bagi admin untuk mengubah dan menyimpan konfigurasi aplikasi.

**Penjelasan Kode:**
- **Manajemen Form**: Menggunakan `GlobalKey<FormState>` untuk validasi dan `TextEditingController` untuk setiap field input.
- **Validasi Input**: Setiap `TextFormField` untuk input angka memiliki validator yang memastikan field tidak kosong, merupakan angka yang valid, dan lebih besar dari 0.
- **`_simpanForm()`**: Logika utama yang dipicu saat tombol "Simpan" ditekan. Fungsi ini akan:
    1.  Memvalidasi form.
    2.  Membuat objek `PengaturanModel` baru dari nilai-nilai di controller.
    3.  Memanggil `_pengaturanOperasi.simpanAtauPerbaruiPengaturan()` untuk menyimpan data ke database.
    4.  Menampilkan `SnackBar` sebagai umpan balik (sukses atau gagal).
    5.  Menampilkan overlay loading (`CircularProgressIndicator`) selama proses penyimpanan.
- **UI Dinamis**: `SwitchListTile` digunakan untuk mengontrol `modePemeliharaan`. `TextFormField` untuk info pemeliharaan hanya akan muncul jika switch tersebut aktif.
- **Perbaikan Kualitas Kode**:
    - Mengganti `Colors.black.withOpacity(0.5)` dengan `const Color.fromRGBO(0, 0, 0, 0.5)` untuk mengatasi peringatan `deprecated_member_use`.
    - Memindahkan argumen `child` pada `ElevatedButton` ke posisi terakhir untuk mematuhi aturan `sort_child_properties_last`.

---

### File: lib/halaman/lainnya/kategori.dart
**Fitur:** Halaman Manajemen Kategori (dengan Fitur Arsip)
**Tujuan file ini dibuat:** Untuk menampilkan daftar kategori dan sub-kategori pemasukan/pengeluaran. Pengguna dapat menambah, mengedit, dan sekarang mengarsipkan item.

**Penjelasan Kode:**
- **Mode Arsip**: Mengganti mode "Hapus" dengan "Arsip" (`_isArsipMode`). Tombol di `AppBar` diubah dari ikon `delete` menjadi `archive`.
- **Logika Arsip (`_arsipkanKategoriUtama` & `_arsipkanSubKategori`)**:
    1.  Menampilkan `AlertDialog` untuk konfirmasi pengguna.
    2.  Jika dikonfirmasi, memanggil metode `copyWith()` pada model untuk mengatur properti `diarsipkan` dengan tanggal saat ini.
    3.  Memanggil `_kategoriOperasi.update()` untuk menyimpan perubahan ke database.
    4.  Menampilkan `SnackBar` sebagai umpan balik dan memuat ulang data.
- **UI Safety**: Menambahkan pemeriksaan `if (!mounted) return;` setelah operasi `await` sebelum berinteraksi dengan `BuildContext` untuk mencegah *crash*.
- **Tampilan**: `ListView` hanya menampilkan kategori yang belum diarsipkan. `ExpansionTile` juga memfilter untuk hanya menampilkan sub-kategori yang belum diarsipkan.

---

### File: lib/halaman/lainnya/pengaturan.dart
**Fitur:** Halaman Dasbor Pengaturan
**Tujuan file ini dibuat:** Untuk menampilkan ringkasan konfigurasi aplikasi yang sedang aktif dalam format read-only, dan menyediakan titik masuk untuk mengedit pengaturan tersebut.

**Penjelasan Kode:**
- **State Management**: Menggunakan `StatefulWidget` untuk mengelola data pengaturan (`_pengaturan`) dan status pemuatan (`_isLoading`).
- **`_loadPengaturan()`**: Fungsi ini dipanggil saat `initState` untuk mengambil data pengaturan terbaru dari `PengaturanOperasi`.
- **`_navigateToForm()`**: Menangani navigasi ke halaman `FormPengaturan`. Setelah kembali dari form (jika ada perubahan yang disimpan), halaman ini akan memuat ulang datanya untuk menampilkan nilai yang diperbarui.
- **UI Tampilan**: Menggunakan `FutureBuilder` untuk menangani pemuatan data awal. Setelah data dimuat, halaman menampilkan `ListView` berisi `ListTile` untuk setiap item pengaturan (interval sinkronisasi, hapus arsip, dll.), membuatnya mudah dibaca.
- **`FloatingActionButton`**: Tombol `edit` yang mengambang digunakan untuk memicu navigasi ke form edit.

---

### File: lib/data/operasi/kategori_operasi.dart
**Fitur:** Operasi Database untuk Kategori
**Tujuan file ini dibuat:** Menyediakan fungsi CRUD (Create, Read, Update, Delete) untuk data kategori di database SQLite.

**Penjelasan Kode:**
- **`getKategori()`**: Fungsi ini dimodifikasi. Sekarang menggunakan klausa `WHERE 'diarsipkan' IS NULL` dalam query-nya untuk memastikan hanya kategori yang tidak diarsipkan yang diambil dari database.
- **`getKategoriByTipe(TipeKategori tipe)`**: Fungsi ini juga diperbarui dengan filter `diarsipkan IS NULL` untuk memastikan hanya kategori aktif dari tipe tertentu yang dikembalikan.
- **`update(KategoriModel kategori)`**: Fungsi ini sekarang tidak hanya untuk mengedit nama, tetapi juga digunakan untuk proses pengarsipan dengan menyimpan objek `KategoriModel` yang sudah diperbarui (termasuk nilai `diarsipkan`).

---

### File: lib/model/pengaturan_model.dart
**Fitur:** Model Data untuk Pengaturan Aplikasi
**Tujuan:** Untuk mendefinisikan struktur data yang menyimpan berbagai konfigurasi atau setelan aplikasi, seperti jadwal sinkronisasi dan kebijakan retensi data.

**Isi:**
- **`class PengaturanModel`**: Kelas utama untuk data pengaturan.
- **`intervalSinkronisasiOtomatis`**: Properti `int` untuk mengatur jeda waktu (dalam jam) sinkronisasi otomatis.
- **`hapusOtomatisDataArsip`**: Properti `int` untuk menentukan umur data (dalam hari) sebelum dihapus otomatis.
- **`modePemeliharaan`**: Properti `bool` untuk mengaktifkan/menonaktifkan mode pemeliharaan.
- **`infoPemeliharaan`**: Properti `String` untuk menyimpan pesan yang ditampilkan saat mode pemeliharaan aktif.
- **`PengaturanModel({ ... })`**: Konstruktor dengan parameter `required` untuk memastikan semua konfigurasi diinisialisasi.
- **`toMap()`**: Metode untuk mengonversi objek menjadi `Map` yang siap disimpan ke database.
- **`fromMap()`**: Metode `factory` untuk membuat objek dari `Map` (data dari database), dengan penanganan nilai `null` yang aman.

**Catatan:**
- Model ini sengaja tidak memiliki `id` karena diasumsikan hanya akan ada satu setelan global untuk seluruh aplikasi.

---

### **File: lib/model/kategori_model.dart**
**Fitur:** Model Data untuk Kategori & Sub-Kategori
**Tujuan file ini dibuat:** Mendefinisikan struktur data untuk `KategoriModel` dan menangani konversi data dari dan ke format database.

**Penjelasan Kode:**
- **Serialisasi `subKategori`**:
    - **`toMap()`**: Menggunakan `jsonEncode` untuk mengubah `List<SubKategoriModel>` menjadi sebuah JSON String. String ini disimpan dalam satu kolom (`id_sub_kategori`) di SQLite.
    - **`fromMap()`**: Menggunakan `jsonDecode` untuk mengubah JSON String dari database kembali menjadi `List<SubKategoriModel>`. Logika ini juga menangani data dari Firebase yang mungkin formatnya adalah `List`.
- **Perbaikan `copyWith`**: Memperbaiki bug di mana parameter `diarsipkan` yang diterima tidak digunakan, sehingga proses `copyWith` untuk arsip gagal.
- **Kualitas Kode**: Menghapus `cast` (konversi tipe) `as List<dynamic>` yang tidak perlu saat memproses data sub-kategori, membuat kode lebih bersih dan sedikit lebih efisien.

---

### File: lib/utils/perhitungan_util.dart
**Fitur:** Utilitas Perhitungan (Masa Aktif & Poin Hangus)

**Tujuan:**
- Menyediakan kumpulan fungsi statis untuk melakukan berbagai perhitungan terkait logika bisnis, seperti menghitung sisa masa aktif, menentukan status poin, dan memberikan representasi visual (warna, teks) berdasarkan perhitungan tersebut.

**Isi:**
- **`getPoinHangus({required DateTime tanggalMulai, DateTime? now})`**: Fungsi baru yang ditambahkan melalui TDD. Fungsi ini menentukan apakah poin dari sebuah transaksi sudah "Hangus" berdasarkan aturan bisnis: jika tanggal mulai transaksi sudah lebih dari 30 hari dari tanggal saat ini, maka akan mengembalikan string 'Hangus'. Jika tidak, mengembalikan string kosong.
- **`sisaHari(DateTime tanggalBerakhir, {DateTime? now})`**: Menghitung selisih hari (dalam integer) antara tanggal berakhir dan tanggal sekarang. Mengembalikan nilai negatif jika sudah lewat.
- **`getTeksSisaMasaAktif(DateTime tanggalBerakhir, {DateTime? now})`**: Memberikan representasi teks yang mudah dibaca dari sisa masa aktif. Contoh: "Sisa 5 hari", "Sisa 3 jam", atau "Berakhir".
- **`getWarnaSisaMasaAktif(DateTime tanggalBerakhir, {DateTime? now})`**: Menentukan warna (hijau, oranye, merah) berdasarkan sisa masa aktif, berguna untuk memberikan isyarat visual di UI.

**Catatan:**
- Kelas ini adalah contoh bagus dari kelas utilitas murni yang tidak memiliki state dan semua metodenya bersifat statis.
- Fungsi `getPoinHangus` dikembangkan menggunakan metodologi Test-Driven Development (TDD), memastikan logikanya kuat dan teruji dengan baik.

---

### File: lib/halaman/detail/detail_pelanggan.dart
**Fitur:** Detail Pelanggan
**Tujuan file ini dibuat:** Untuk menyediakan halaman antarmuka yang menampilkan semua informasi rinci tentang seorang pelanggan, lengkap dengan interaksi cepat seperti menghubungi via WhatsApp, menyalin informasi, dan melihat total poin.

**Penjelasan Kode:**
- **`initState()` & `_loadTotalPoin()`**: Saat halaman pertama kali dibuka, `initState` akan memanggil `_loadTotalPoin`. Fungsi ini secara asinkron mengambil data total poin pelanggan dari `PelangganOperasi` dan memperbarui state (`_totalPoin` dan `_isLoadingPoin`) untuk ditampilkan di UI. Ini memastikan UI tetap responsif saat data poin sedang dimuat.
- **`_launchWhatsApp(String phoneNumber)`**: Fungsi ini memformat nomor telepon ke standar internasional (`62...`) dan menggunakan `url_launcher` untuk membuka aplikasi WhatsApp dan langsung memulai chat. Terdapat penanganan error jika WhatsApp tidak terinstal.
- **`_buildPoinCard()`**: Widget khusus yang menampilkan total poin pelanggan dalam sebuah kartu (Card) dengan desain gradien yang menarik. Widget ini juga berfungsi sebagai tombol yang dapat diklik untuk menavigasi pengguna ke `HalamanPoin`. Menampilkan `CircularProgressIndicator` saat data poin masih dimuat (`_isLoadingPoin`).
- **Interaksi Pengguna**:
    - **Password Visibility**: Menggunakan state `_isPasswordVisible` untuk menampilkan atau menyembunyikan password pelanggan.
    - **Salin Informasi**: Menggunakan `Clipboard.setData()` untuk menyediakan fungsionalitas "salin" pada nomor telepon, MAC address, dan semua informasi pelanggan sekaligus, yang sangat memudahkan admin.
- **Navigasi**: Terdapat tombol `edit` di `AppBar` yang menavigasi ke `FormPelanggan` untuk memperbarui data pelanggan.

---

## Catatan Kerja

- [x] Memperbaiki semua error dan peringatan dari `flutter analyze`.
- [x] Mengimplementasikan fitur Pengaturan Aplikasi.
- [x] Menambahkan tabel `pengaturan` ke database SQLite.
- [x] Membuat halaman UI untuk melihat dan mengedit pengaturan.
- [x] Menambahkan logika untuk sinkronisasi data pengaturan dari Firestore.
- [x] Memperbarui `README.md` dengan dokumentasi terbaru.

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
pengaturan_operasi.dart
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
pengaturan_model.dart
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
info_ringkasan_widget.dart
nama_dari_id.dart
nama_paket.dart
nama_pelanggan.dart
thousands_input_formatter.dart
transaksi_list_widgets.dart
```

---
### File: lib/model/dompet_model.dart
**Fitur:** Model Data untuk Dompet
**Tujuan file ini dibuat:** Sebagai representasi data dompet pada aplikasi administrasi keuangan dan WiFi, menjadi pusat pertukaran data antara SQLite, Firebase, dan UI.

**Penjelasan Arsitektur:**
- **Offline-first & Sinkronisasi Cloud**: Dirancang agar aplikasi berfungsi tanpa internet, dengan sinkronisasi data ke Firebase saat kembali online.
- **UUID-based Identity**: Menggunakan `String` UUID (`id = const Uuid().v4()`) sebagai primary key untuk menghindari konflik saat sinkronisasi dari beberapa perangkat, menggantikan auto-increment integer yang tidak aman.
- **Soft Delete**: Menggunakan flag `isDeleted` dan `diarsipkan` untuk menandai data yang dihapus tanpa menghilangkannya secara permanen. Ini memungkinkan pemulihan data dan menjaga riwayat.
- **Immutable Data Pattern**: Semua properti dideklarasikan sebagai `final`, dan perubahan dilakukan melalui metode `copyWith`, memastikan konsistensi state dan mengurangi bug *side-effect*.
- **Konsistensi Antar Database**: Menyediakan metode `toMapForSqlite()` dan `toMapForFirebase()` untuk menangani perbedaan format antara SQLite (yang menyimpan boolean sebagai 0/1) dan Firebase (yang menggunakan `true`/`false`).
- **Parsing Aman**: Dilengkapi dengan `_parseDateTime` untuk mengubah berbagai format (`Timestamp` dari Firebase, `String` dari SQLite) menjadi `DateTime`, dan `fromMap` yang menangani konversi tipe `num` ke `double` untuk mencegah error `type 'int' is not a subtype of type 'double'`.

**Poin Penting untuk Presentasi:**
1.  Sistem sudah mendukung **offline-first**.
2.  ID menggunakan **UUID** agar aman untuk sinkronisasi multi-device.
3.  **Soft delete** digunakan agar data tidak langsung hilang.
4.  Model kompatibel untuk **SQLite dan Firebase**.
5.  Menggunakan **immutable pattern** untuk menjaga konsistensi state.
6.  Memiliki fondasi untuk **skalabilitas** di masa depan (misalnya, menambahkan `versioning` atau `audit log`).

---

### File: lib/halaman/pembantu/halaman_poin.dart
**Fitur:** Halaman Poin & Reward Pengguna
**Tujuan file ini dibuat:** Untuk menampilkan halaman antarmuka (UI) yang informatif dan menarik terkait status poin pengguna, daftar reward yang bisa ditukarkan, dan riwayat transaksi mereka.

**Penjelasan Kode:**
- **Pemisahan Data & UI**: Kode ini secara tegas memisahkan data dari tampilan. Data untuk transaksi dan reward tidak lagi di-hardcode di dalam widget, melainkan didefinisikan dalam `List` menggunakan class model `_ModelTransaksi` dan `_ModelReward`.
- **Manajemen State Sederhana**: Menggunakan `StatefulWidget` dengan variabel `_tampilkanReward` (boolean) untuk mengontrol tampilan antara daftar transaksi dan grid reward. Pembaruan UI dipicu oleh `setState()`.
- **Model Data Lokal**: Terdapat dua class privat, `_ModelReward` dan `_ModelTransaksi`, yang berfungsi sebagai cetakan (blueprint) untuk data. Ini membuat struktur data menjadi jelas dan mudah dikelola.
- **Logging Detail**: Setiap interaksi pengguna (misalnya, menekan tombol) dan setiap perubahan state (misalnya, `initState`, `build`, `setState`) dicatat secara eksplisit menggunakan `developer.log`. Ini sangat penting untuk debugging dan memahami alur kerja aplikasi.
- **Fungsi Builder yang Terstruktur**: UI dipecah menjadi beberapa fungsi privat yang lebih kecil dan mudah dikelola (contoh: `_bangunHeader`, `_bangunKartuPoin`, `_bangunGridReward`), mengikuti prinsip *Single Responsibility*.
- **Perbaikan Kualitas Kode**:
    - Semua penamaan (variabel, fungsi, class) telah diubah ke Bahasa Indonesia.
    - Semua fungsi telah diberi komentar dokumentasi yang menjelaskan tujuannya.
    - Error analisis terkait `FontWeight.black` dan `withOpacity` telah diperbaiki menjadi `FontWeight.w900` dan `.withAlpha()`.
