# Dokumentasi File: lib/halaman/lainnya/versi_apk_user.dart

## Tujuan File

File ini bertujuan untuk membuat sebuah halaman pada aplikasi admin yang memiliki dua fungsi utama:
1.  **Menampilkan Informasi Versi APK Pengguna**: Menampilkan detail versi aplikasi pengguna yang sedang berlaku, seperti versi terbaru, catatan rilis, dan tautan unduhan.
2.  **Mengontrol Status Aplikasi Pengguna**: Memberikan tombol untuk mengaktifkan atau menonaktifkan "Mode Maintenance" pada aplikasi pengguna dari jarak jauh.

Halaman ini memungkinkan admin untuk mengelola siklus hidup versi aplikasi pengguna dan menangani situasi darurat (misalnya, jika ada bug kritis) dengan mengaktifkan mode maintenance.

---

## Struktur Kode

### Kelas `VersiApkUserPage` (StatefulWidget)

Ini adalah widget utama yang membentuk kerangka halaman.

### Kelas `_VersiApkUserPageState` (State)

Ini adalah kelas State yang menampung semua logika, state, dan UI untuk halaman ini.

#### Variabel State Utama

-   `_versiApkUserOperasi`: Instance dari `VersiApkUserOperasi` untuk berinteraksi dengan database (mengambil dan menyimpan data versi APK).
-   `_kontrolAplikasiService`: Instance dari `KontrolAplikasiService` untuk berinteraksi dengan Firebase Firestore (mengatur status maintenance).
-   `_versiApkUser`: Sebuah `VersiApkUserModel?` yang menyimpan data detail versi APK setelah berhasil diambil dari database.
-   `_isLoading`: `bool` untuk menandakan status loading saat data versi APK sedang diambil.
-   `_error`: `String?` untuk menyimpan pesan error jika terjadi kegagalan saat memuat data.
-   `_isMaintenanceMode`: `bool` yang menyimpan status mode maintenance saat ini (diambil dari Firestore).
-   `_isLoadingMaintenance`: `bool` untuk menandakan status loading saat data maintenance sedang diambil.

#### Metode-Metode Penting

-   `initState()`:
    -   Dipanggil saat widget pertama kali dibuat.
    -   Langsung memanggil `_loadAllData()` untuk memulai proses pengambilan data.

-   `_loadAllData()`:
    -   Fungsi *asynchronous* yang menjadi pusat pengambilan data.
    -   Menggunakan `Future.wait` untuk menjalankan dua operasi secara bersamaan demi efisiensi:
        1.  `_versiApkUserOperasi.ambilVersiApkUser()`: Mengambil data versi APK dari database lokal (SQLite).
        2.  `_kontrolAplikasiService.dapatkanStatusMaintenance()`: Mengambil status boolean mode maintenance dari Firebase Firestore.
    -   Mengatur state `_isLoading` menjadi `true` di awal dan `false` di akhir.
    -   Menyimpan hasil dari kedua operasi ke dalam state `_versiApkUser` dan `_isMaintenanceMode`.
    -   Dilengkapi dengan `try-catch` untuk menangani error dan menyimpannya di state `_error`.
    -   Memanggil `developer.log` untuk mencatat error jika terjadi.

-   `_toggleMaintenanceMode(bool value)`:
    -   Fungsi *asynchronous* yang dipanggil saat `SwitchListTile` untuk mode maintenance diubah nilainya.
    -   **Optimistic UI Update**: Langsung mengubah state `_isMaintenanceMode` untuk memberikan respons visual instan kepada admin.
    -   Memanggil `_kontrolAplikasiService.aturStatusMaintenance(value)` untuk mengirim status baru ke Firebase Firestore.
    -   Jika berhasil, menampilkan `SnackBar` hijau.
    -   Jika gagal, mengembalikan state `_isMaintenanceMode` ke nilai sebelumnya dan menampilkan `SnackBar` merah.

-   `_buildInfoRow(String label, String value)`:
    -   Widget *helper* untuk membangun baris informasi yang konsisten (misalnya, "Versi Terbaru: 1.0.0").
    -   Menggunakan `Row` dan `Flexible` untuk memastikan teks yang panjang tidak menyebabkan *layout overflow*.

-   `_buildMaintenanceControl()`:
    -   Membangun bagian UI untuk kontrol mode maintenance.
    -   Menampilkan `CircularProgressIndicator` jika `_isLoadingMaintenance` masih `true`.
    -   Menampilkan `SwitchListTile` yang terikat dengan state `_isMaintenanceMode` dan memanggil `_toggleMaintenanceMode` saat diubah.

-   `_buildContent()`:
    -   Ini adalah "otak" dari logika tampilan UI.
    -   Berdasarkan kondisi state saat ini, ia akan menampilkan salah satu dari beberapa kemungkinan widget:
        1.  `Center(child: CircularProgressIndicator())`: Jika `_isLoading` adalah `true`.
        2.  `Center(child: Text(_error!))`: Jika `_error` tidak null.
        3.  `Center(child: Text('Tidak ada data...'))`: Jika `_versiApkUser` adalah null setelah loading selesai.
        4.  `RefreshIndicator(child: ListView(...))`: Jika data berhasil dimuat.
    -   `ListView` ini berisi semua informasi detail dari `_versiApkUser` dan juga memanggil `_buildMaintenanceControl()`.
    -   Dibungkus dengan `RefreshIndicator` yang memanggil `_loadAllData` ketika pengguna melakukan *pull-to-refresh*.

-   `build(BuildContext context)`:
    -   Metode utama yang membangun seluruh scaffold halaman.
    -   `appBar`: Menampilkan judul halaman.
    -   `body`: Memanggil `_buildContent()` untuk merender konten utama.
    -   `floatingActionButton`: Sebuah tombol edit yang akan:
        -   Mengecek apakah data `_versiApkUser` sudah siap.
        -   Jika ya, menavigasikan ke halaman `FormVersiApkUser` sambil membawa data `_versiApkUser` yang ada untuk diedit.
        -   Menunggu hasil dari `Navigator.push`. Jika hasilnya `true` (yang menandakan ada perubahan yang disimpan di form), maka akan memanggil `_loadAllData()` lagi untuk me-refresh data di halaman ini.

---

## Alur Kerja Pengguna (Admin)

1.  Admin membuka halaman "Informasi & Kontrol APK".
2.  Aplikasi secara otomatis memuat status mode maintenance dari Firebase dan data detail versi APK dari database lokal secara bersamaan. Sebuah indikator loading ditampilkan.
3.  Setelah selesai, halaman menampilkan `Switch` untuk mode maintenance dan semua informasi detail tentang versi APK.
4.  Admin bisa mengaktifkan/menonaktifkan mode maintenance. Perubahan langsung terlihat di UI dan dikirim ke Firebase.
5.  Admin bisa menarik layar ke bawah (*pull-to-refresh*) untuk memuat ulang kedua data tersebut.
6.  Admin menekan tombol `FloatingActionButton` (ikon pensil) untuk masuk ke mode edit.
7.  Halaman `FormVersiApkUser` terbuka, sudah terisi dengan data yang ada.
8.  Admin mengubah data dan menyimpannya.
9.  Setelah kembali ke halaman `VersiApkUserPage`, data yang baru diubah akan otomatis dimuat ulang dan ditampilkan.
