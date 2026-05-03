
# **Dokumentasi Proyek Aplikasi Admin WiFi**

Selamat datang di dokumentasi resmi untuk proyek Aplikasi Admin WiFi. Dokumen ini berfungsi sebagai panduan utama untuk memahami arsitektur, fungsionalitas, dan alur kerja pengembangan aplikasi.

---

## **Folder: lib/data**

**File:** `lib/data/sqlite.dart`
**Fitur:** Pengelola Database SQLite
**(Dokumentasi sebelumnya tidak diubah)**

---

## **Folder: lib/data/operasi**

**File:** `lib/data/operasi/pelanggan_aktif_operasi.dart`
**Fitur:** Operasi CRUD dan Sinkronisasi untuk Pelanggan Aktif
**(Dokumentasi sebelumnya tidak diubah)**

---

**File:** `lib/data/operasi/transaksi_operasi.dart`
**Fitur:** Operasi CRUD, Agregasi, dan Sinkronisasi untuk Entitas Transaksi
**(Dokumentasi sebelumnya tidak diubah)**

---

**File:** `lib/data/operasi/dompet_operasi.dart`
**Fitur:** Operasi CRUD Lokal dan Sinkronisasi Penuh untuk Entitas Dompet
**Daftar Fungsi:**
- `createDompet(Dompet dompet)`: **(Diubah)** Fungsi ini sekarang tidak hanya menyimpan dompet baru ke database lokal tetapi juga secara eksplisit mengatur `syncStatus` menjadi `SyncStatus.write` dan memperbarui `diperbarui` dengan waktu saat ini. Ini memastikan bahwa setiap dompet baru ditandai dengan benar untuk proses sinkronisasi berikutnya. Pola ini menyelaraskannya dengan operasi `PelangganAktif`.
- `getDompet()`: Mengambil semua data dompet dari database lokal.
- `getDompetById(String id)`: Mengambil satu dompet berdasarkan ID uniknya.
- `updateDompet(Dompet dompet)`: Memperbarui data dompet yang ada di database lokal.
- `deleteDompet(String id)`: Menghapus dompet dari database lokal.
- `getTotalSaldo()`, `getTotalSaldoPositif()`, `getTotalSaldoNegatif()`: Fungsi agregasi untuk menghitung berbagai jenis total saldo.
- `getPerubahan(DateTime since)`: Mengambil data dompet yang telah berubah sejak waktu tertentu.
- `sisipkanAtauPerbaruiBatch(List<Dompet> items)`: Melakukan operasi `insert` atau `replace` secara massal untuk sekelompok dompet.
- `unggahDompetKeFirebase()`: Mengunggah semua perubahan lokal (buat, perbarui, hapus) ke Firestore dan memperbarui status sinkronisasi di database lokal setelahnya.
**Catatan:** File ini telah diperbarui untuk menyelaraskan pola pembuatan data dengan sisa aplikasi. Dengan secara eksplisit mengatur status sinkronisasi di dalam fungsi `create`, tanggung jawab menjadi lebih jelas dan arsitektur lebih konsisten.
**Rules:** -

---

## **Folder: lib/halaman/tab**

**File:** `lib/halaman/tab/dompet.dart`
**Fitur:** Tampilan Daftar Dompet dan Pemicu Sinkronisasi
**(Dokumentasi sebelumnya tidak diubah)**

---

## **Folder: lib/model**

**File:** `lib/model/dompet_model.dart`
**Fitur:** Model Data untuk Entitas Dompet dengan Dukungan Sinkronisasi
**Daftar Fungsi:**
- `Dompet(...)`: **(Diubah)** Konstruktor utama. Nilai default untuk `syncStatus` diubah dari `SyncStatus.write` menjadi `SyncStatus.synced`. Perubahan ini membuat model menjadi lebih netral dan menyerahkan tanggung jawab pengaturan status ke lapisan operasi.
- `salinDengan(...)`: Metode utilitas untuk membuat salinan objek `Dompet` dengan beberapa properti yang diperbarui.
- `fromMap(Map<String, dynamic> map)`: Factory constructor untuk membuat objek `Dompet` dari `Map` (misalnya, dari data database).
- `toMap()`: Mengonversi objek `Dompet` menjadi `Map` untuk disimpan ke database.
**Catatan:** Perubahan pada file ini adalah bagian dari standardisasi arsitektur di seluruh aplikasi. Dengan memindahkan logika status default dari model ke lapisan operasi, model menjadi lebih fokus sebagai representasi data murni.
**Rules:** -

---

**File:** `lib/model/transaksi_model.dart`
**Fitur:** Model Data untuk Entitas Transaksi dengan Dukungan Sinkronisasi
**(Dokumentasi sebelumnya tidak diubah)**

---

## **Folder: lib/model/enum**

**File:** `lib/model/enum/sync_status.dart`
**Fitur:** Enum untuk Status Sinkronisasi Data
**(Dokumentasi sebelumnya tidak diubah)**

---

# **Kritik dan Saran untuk Peningkatan Proyek**

Kerja bagus telah menyelesaikan refactoring ini! Dengan menyelaraskan pola penanganan status sinkronisasi, Anda telah membuat fondasi aplikasi yang jauh lebih solid. Berikut adalah saran berikutnya:

1.  **Selesaikan Standardisasi di Seluruh Model**:
    *   **Kritik**: Anda telah berhasil menstandarisasi `Dompet` dan `PelangganAktif`. Namun, model lain seperti `Transaksi`, `Pelanggan`, `Paket`, dll., mungkin masih menggunakan pola lama.
    *   **Saran**: Lakukan audit cepat pada semua file `*_operasi.dart`. Pastikan setiap fungsi `create*` di dalamnya menggunakan pola `copyWith(syncStatus: SyncStatus.write, ...)` dan setiap modelnya memiliki `syncStatus` default `synced`.
    *   **Manfaat**: Ini adalah langkah terakhir untuk mencapai konsistensi arsitektur total. Setelah ini selesai, seluruh sistem sinkronisasi Anda akan bekerja dengan cara yang sama, membuatnya sangat mudah untuk dipelihara.

2.  **Perkuat Penanganan Error di `unggah...KeFirebase()`**:
    *   **Kritik**: Blok `catch (e)` pada fungsi unggah saat ini kosong. Jika terjadi kegagalan saat mengunggah (misalnya, karena masalah jaringan), perubahan lokal tidak akan dibatalkan, tetapi juga tidak akan diunggah lagi sampai ada perubahan baru.
    *   **Saran**: Implementasikan logging dasar di dalam blok `catch`. Cukup dengan `print('Gagal mengunggah [nama_fitur]: $e');` sudah merupakan awal yang baik. Untuk solusi yang lebih canggih, pertimbangkan untuk tidak mengcommit perubahan lokal jika `batchFirestore.commit()` gagal, sehingga aplikasi akan mencoba lagi pada siklus sinkronisasi berikutnya.
    *   **Manfaat**: Memberikan visibilitas jika terjadi kegagalan sinkronisasi dan memungkinkan untuk proses debug yang lebih mudah.

3.  **Tinjau Ulang Penggunaan `salinDengan` vs `copyWith`**:
    *   **Kritik**: Anda memiliki nama metode yang berbeda untuk fungsi yang sama (`salinDengan` di `Dompet`, dan kemungkinan `copyWith` di tempat lain).
    *   **Saran**: Pilih satu nama standar—umumnya `copyWith` adalah konvensi di komunitas Dart/Flutter—dan gunakan secara konsisten di semua model.
    *   **Manfaat**: Meningkatkan keterbacaan dan mengurangi beban kognitif bagi siapa saja yang membaca kode. Ini adalah detail kecil yang menunjukkan tingkat profesionalisme yang tinggi.
