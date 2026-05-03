# **Dokumentasi Proyek Aplikasi Admin WiFi**

Selamat datang di dokumentasi resmi untuk proyek Aplikasi Admin WiFi. Dokumen ini berfungsi sebagai panduan utama untuk memahami arsitektur, fungsionalitas, dan alur kerja pengembangan aplikasi.

---

## **Folder: lib/data**

**File:** `lib/data/sqlite.dart`
**Fitur:** Pengelola Database SQLite
**Daftar Fungsi:**
*   `database`: Properti getter untuk mendapatkan atau menginisialisasi instance database.
*   `_initDB()`: Menginisialisasi koneksi ke file database SQLite.
*   `_onCreate(Database db, int version)`: Membuat semua tabel saat database pertama kali dibuat.
*   `_onUpgrade(Database db, int oldVersion, int newVersion)`: Menangani migrasi skema database ketika versi dinaikkan.
*   `_createTables(Database db)`: Berisi definisi skema untuk semua tabel dalam aplikasi.
*   `_createTransaksiTable(Database db)`: **(Diperbarui)** Membuat tabel `transaksi`. Skema telah diperbarui untuk menyertakan kolom `sync_status` dengan tipe `TEXT`.
**Catatan:** File ini adalah satu-satunya titik akses untuk semua operasi database. Versi database saat ini adalah **17**. Perubahan terakhir adalah penambahan kolom `sync_status TEXT NOT NULL DEFAULT 'write'` pada tabel `transaksi` untuk mendukung logika sinkronisasi. Proses migrasi di `_onUpgrade` telah diperbarui untuk membuat ulang tabel `transaksi` dengan skema baru.
**Rules:** Setiap perubahan skema tabel harus disertai dengan kenaikan versi database di `_initDB()` dan logika migrasi yang sesuai di `_onUpgrade()`.

---

## **Folder: lib/data/operasi**

**File:** `lib/data/operasi/pelanggan_aktif_operasi.dart`
**Fitur:** Operasi CRUD dan Sinkronisasi untuk Pelanggan Aktif
**(Dokumentasi sebelumnya tidak diubah)**

---

**File:** `lib/data/operasi/transaksi_operasi.dart`
**Fitur:** Operasi CRUD, Agregasi, dan Sinkronisasi untuk Entitas Transaksi
**Daftar Fungsi:**
- `tambahTransaksi(TransaksiModel transaksi)`: **(Diperbarui)** Menyimpan transaksi baru dan secara otomatis menyetel `syncStatus` ke `write`.
- `ambilSemuaTransaksi()`: Mengambil seluruh daftar transaksi.
- `updateTransaksi(TransaksiModel transaksi)`: **(Diperbarui)** Memperbarui transaksi yang ada dan menyetel `syncStatus` ke `update`.
- `deleteTransaksi(String id)`: **(Diperbarui)** Melakukan *soft delete* dengan menyetel `syncStatus` ke `deleted` daripada menghapus record secara fisik.
- `getTotalPemasukan()` & `getTotalPengeluaran()`: **(Diperbarui)** Menghitung total, mengabaikan transaksi yang telah ditandai `deleted`.
- `getNetTotal()`: Menghitung selisih bersih antara pemasukan dan pengeluaran.
- `getPerubahan()`: **(Baru)** Mengambil semua record yang statusnya bukan `synced` (yaitu `write`, `update`, `deleted`) untuk diproses saat sinkronisasi.
- `sisipkanAtauPerbaruiBatch(List<TransaksiModel> items)`: **(Baru)** Menyisipkan atau memperbarui banyak data dari server dan menandainya sebagai `synced`.
**Catatan:** File ini telah dirombak untuk mendukung logika sinkronisasi penuh. Semua operasi CRUD sekarang terintegrasi dengan `SyncStatus`. Interaksi dengan database menggunakan `.name` dari `SyncStatus` (misal: 'write', 'update') untuk kejelasan.
**Rules:** Gunakan kelas ini untuk semua operasi data transaksi untuk memastikan status sinkronisasi dikelola dengan benar.

---
**(Dokumentasi untuk file-file lain tidak ditampilkan untuk keringkasan)**
---

## **Folder: lib/model**

**File:** `lib/model/transaksi_model.dart`
**Fitur:** Model Data untuk Entitas Transaksi dengan Dukungan Sinkronisasi
**Daftar Fungsi:**
- `TransaksiModel()`: Konstruktor untuk membuat atau memperbarui objek transaksi.
- `fromMap(Map<String, dynamic> map)`: **(Diperbarui)** Membuat instance dari Map, sekarang dapat mengurai `syncStatus` dari `String` (`.name`).
- `toMap()`: **(Diperbarui)** Mengonversi instance menjadi Map, sekarang menyertakan `sync_status` sebagai `String` (`.name`).
- `salinDengan(...)`: **(Baru)** Fungsi *copy with* untuk membuat salinan objek dengan nilai yang diperbarui, sangat berguna untuk mengubah status tanpa memutasi objek asli.
**Catatan:** Model ini sekarang menyertakan properti `syncStatus` dari `enum SyncStatus`. Ini adalah inti dari mekanisme sinkronisasi, yang memungkinkan pelacakan perubahan pada setiap record.
**Rules:** Wajib gunakan `salinDengan` saat memperbarui properti objek `TransaksiModel` untuk menjaga imutabilitas dan alur data yang jelas.

---

## **Folder: lib/model/enum**

**File:** `lib/model/enum/sync_status.dart`
**Fitur:** Enum untuk Status Sinkronisasi Data
**Daftar Nilai:**
- `synced`: Data di perangkat sama dengan data di server.
- `write`: Data baru dibuat di perangkat dan perlu diunggah ke server.
- `update`: Data yang ada telah diubah di perangkat dan perlu diunggah perubahannya.
- `deleted`: Data telah dihapus di perangkat dan perlu dihapus juga di server.
**Catatan:** Enum ini adalah "sumber kebenaran tunggal" untuk melacak status setiap record yang dapat disinkronkan. Menggunakan enum memastikan konsistensi dan menghindari kesalahan ketik.
**Rules:** Selalu gunakan enum ini saat bekerja dengan status sinkronisasi. Representasi string (`.name`) digunakan saat menyimpan ke database untuk keterbacaan.

---

# **Kritik dan Saran untuk Peningkatan Proyek**

Berdasarkan perubahan terbaru pada logika sinkronisasi, berikut adalah saran untuk langkah selanjutnya:

1.  **Lengkapi Logika Sinkronisasi di `SyncManager`**:
    *   **Saran**: Sekarang `transaksi_operasi.dart` sudah bisa membedakan antara `write`, `update`, dan `deleted`, pastikan kelas atau fungsi yang bertanggung jawab untuk sinkronisasi (misalnya, `SyncManager` atau yang serupa) benar-benar menangani ketiga kasus ini.
        *   Untuk `SyncStatus.write`: Panggil `db.collection('transaksi').doc(item.id).set(item.toMap())`.
        *   Untuk `SyncStatus.update`: Panggil `db.collection('transaksi').doc(item.id).update(item.toMap())`.
        *   Untuk `SyncStatus.deleted`: Panggil `db.collection('transaksi').doc(item.id).delete()`.
    *   **Manfaat**: Ini akan menyelesaikan alur kerja sinkronisasi dua arah secara penuh, memastikan perubahan lokal (tambah, edit, hapus) tercermin dengan benar di Firebase.

2.  **Refaktor Konsistensi `sync_status` di Seluruh Model**:
    *   **Saran**: Terapkan pola `SyncStatus` yang sama (properti di model, kolom `TEXT` di DB, fungsi `getPerubahan` di operasi) ke model lain seperti `Pelanggan`, `Paket`, `Dompet`, dll.
    *   **Manfaat**: Menciptakan arsitektur sinkronisasi yang konsisten dan dapat diprediksi di seluruh aplikasi, membuatnya lebih mudah untuk dikelola dan diperluas.
