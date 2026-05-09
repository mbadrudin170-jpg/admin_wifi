# Laporan Perubahan Teknis: Refactoring & Perbaikan Bug

**Tanggal:** 9 Mei 2026

---

### **Ringkasan Eksekutif**

Telah dilakukan dua pekerjaan utama:
1.  **Refactoring Layanan Pembersihan Data Otomatis:** Menghilangkan nilai *hardcoded* dan membuatnya dinamis berdasarkan konfigurasi dari database, meningkatkan fleksibilitas dan keandalan.
2.  **Perbaikan Bug Kritis pada Form Pelanggan Aktif:** Memperbaiki logika yang menyebabkan transaksi duplikat saat mengedit data aktivasi, memastikan konsistensi data antara aktivasi dan transaksi terkait.

---

### **1. File yang Dimodifikasi: `lib/data/operasi/pembersihan_data_operasi.dart`**

File ini bertanggung jawab untuk mengeksekusi query SQL penghapusan data secara langsung.

#### **Masalah Awal:**
Fungsi `hapusSemuaDataArsipKadaluarsa()` menggunakan nilai tetap `-30 days` di dalam query SQL-nya, membuatnya tidak fleksibel.

#### **Detail Perubahan:**
*   **Fungsi Dibuat Dinamis:** Tanda tangan fungsi diubah menjadi `hapusSemuaDataArsipKadaluarsa({required int batasHari})` untuk menerima parameter dinamis.
*   **Query SQL Diperbarui:** Nilai *hardcoded* diganti dengan *placeholder* `?` yang aman untuk diisi oleh parameter `batasHari`.

#### **Hasil Akhir (Kode Baru):**
```dart
// path: lib/data/operasi/pembersihan_data_operasi.dart
Future<int> hapusSemuaDataArsipKadaluarsa({required int batasHari}) async {
  // ...
  final hasil = await db.rawDelete('''
    DELETE FROM $tabel
    WHERE diarsipkan IS NOT NULL
    AND diarsipkan <= datetime('now', '-? days')
  ''', [batasHari]);
  // ...
}
```

---

### **2. File yang Dimodifikasi: `lib/services/pembersihan_data_service.dart`**

File ini adalah orkestrator yang memutuskan kapan proses pembersihan perlu dijalankan.

#### **Masalah Awal:**
Fungsi `jalankanJikaPerlu()` memanggil fungsi operasi tanpa parameter, sehingga masih bergantung pada nilai *hardcoded*.

#### **Detail Perubahan:**
*   **Pengambilan Pengaturan:** Logika ditambahkan untuk mengambil `PengaturanModel` dari database.
*   **Pemanggilan Fungsi Dinamis:** Nilai `hapusOtomatisDataArsip` dari pengaturan kini diteruskan sebagai parameter `batasHari` saat memanggil `hapusSemuaDataArsipKadaluarsa`.

#### **Hasil Akhir (Kode Baru):**
```dart
// path: lib/services/pembersihan_data_service.dart
Future<void> jalankanJikaPerlu() async {
  // ...
  final PengaturanModel pengaturan = await _pengaturanOperasi.getPengaturan();
  final int batasHari = pengaturan.hapusOtomatisDataArsip;
  
  final totalTerhapus = await _operasi.hapusSemuaDataArsipKadaluarsa(
    batasHari: batasHari,
  );
  // ...
}
```

---

### **3. File yang Dimodifikasi: `lib/halaman/form/form_pelanggan_aktif.dart`**

**Fitur:** Formulir Aktivasi Pelanggan

#### **Masalah Awal (Bug):**
Saat data `PelangganAktif` diedit, transaksi yang terkait tidak ikut terbarui. Sebaliknya, sistem malah membuat transaksi baru setiap kali ada penyimpanan, menyebabkan duplikasi data. Ini terjadi karena `idTransaksi` tidak disimpan di `PelangganAktifModel`, sehingga hubungan antara keduanya putus saat diedit.

#### **Detail Perubahan (Perbaikan Bug):**
1.  **Penentuan ID Transaksi di Awal:** Logika diubah untuk menentukan `idTransaksi` di awal `_saveForm()`. Jika mode edit, ID lama digunakan kembali; jika mode baru, UUID baru dibuat.
2.  **Menyimpan Referensi ID:** `PelangganAktifModel` kini selalu diisi dengan `idTransaksi` saat disimpan, memastikan catatan aktivasi memiliki penunjuk ke transaksinya.
3.  **Penyimpanan Data Terpadu:** Logika `create` dan `update` untuk `PelangganAktif` dan `Transaksi` disatukan untuk memperjelas alur kerja.

#### **Hasil Akhir (Kode Baru di `_saveForm()`):**
```dart
// diubah: Tentukan ID transaksi di awal untuk menjaga konsistensi.
final String transaksiId =
    _isEditMode && widget.pelangganAktif?.idTransaksi != null
        ? widget.pelangganAktif!.idTransaksi!
        : const Uuid().v4();

final pelangganAktifData = PelangganAktifModel(
  // ... data lain
  idTransaksi: transaksiId, // ditambahkan: Menyimpan referensi ID transaksi
);

final transaksiData = TransaksiModel(
  id: transaksiId, // diubah: Menggunakan ID yang sudah ditentukan
  // ... data lain
);

// diubah: Logika penyimpanan digabung untuk memastikan atomicity
if (_isEditMode) {
  await widget.pelangganAktifOperasi.updatePelangganAktif(pelangganAktifData);
  await widget.transaksiOperasi.updateTransaksi(transaksiId, transaksiData);
} else {
  await widget.pelangganAktifOperasi.createPelangganAktif(pelangganAktifData);
  await widget.transaksiOperasi.tambahTransaksi(transaksiData);
}
```

---

### **4. File: `lib/halaman/pembantu/halaman_poin.dart`**

**Fitur:** Manajemen Poin Pelanggan

**Tujuan file ini dibuat:**
Menyediakan antarmuka (UI) bagi admin untuk mengelola dan memantau poin loyalitas pelanggan, melihat riwayat perolehan/penggunaan poin, dan melihat daftar hadiah yang dapat ditukarkan.

---
### **Analisis Kode Rinci `halaman_poin.dart`**

#### **1. `enum MenuPoin`**
*   **Tujuan:** Mengontrol konten yang ditampilkan antara mode `penukaran` (daftar hadiah) dan `riwayat` (histori poin).

#### **2. `HalamanPoin` (StatefulWidget)**
*   **Tujuan:** Kerangka utama halaman yang state-nya dinamis. Membutuhkan `idPelanggan` untuk mengambil data yang relevan.

#### **3. `_HalamanPoinState` (State Class)**
*   **Tujuan:** Memegang semua data dan logika, termasuk total poin, daftar paket, dan menu yang aktif.
*   **Metode Utama:**
    *   `_loadData()`: Mengambil total poin pelanggan dan daftar paket dari database secara asinkron.
    *   `build()`: Membangun UI, menampilkan indikator loading saat data diambil, dan kemudian menampilkan konten utama yang terdiri dari info total poin, tombol menu, dan daftar riwayat atau daftar paket.

#### **4. Fungsi dan Widget Pendukung**
*   `_hitungProgressPencapaian()`: Fungsi utilitas untuk menghitung progres poin pelanggan terhadap poin yang dibutuhkan untuk menukar hadiah.
*   `_listPaket()`: Menampilkan daftar paket hadiah, lengkap dengan `LinearProgressIndicator` untuk visualisasi progres.
*   `_riwayatTransaksi()`: Menggunakan `FutureBuilder` untuk menampilkan riwayat transaksi poin pelanggan secara efisien.
File: lib/model/transaksi_model.dart
Fitur: Model Data Transaksi Terpadu
Tujuan file ini dibuat: File ini mendefinisikan `TransaksiModel`, yang merupakan struktur data inti untuk semua jenis transaksi dalam aplikasi. Model ini telah direfaktor secara signifikan untuk menggabungkan data dari `RiwayatLanggananModel` yang sebelumnya terpisah. Tujuannya adalah untuk menjadi *single source of truth* (sumber kebenaran tunggal) yang mencatat tidak hanya transaksi finansial (pemasukan, pengeluaran), tetapi juga semua aktivitas langganan paket. File ini menyediakan logika untuk membuat, mengubah, serta mengonversi data transaksi antara format aplikasi, format database SQLite lokal, dan format Firebase (Firestore).

---

### Analisis Kode Rinci

#### **enum `TipeTransaksi`**
*   **Tujuan:** Mendefinisikan kategori utama dari setiap transaksi. Penambahan tipe `langganan` adalah bagian dari refactoring besar, yang memungkinkan sistem untuk mencatat aktivasi atau perpanjangan paket sebagai sebuah transaksi, bukan lagi sebagai entitas terpisah. Ini menyatukan logika bisnis dan mempermudah pelacakan.

#### **Class `TransaksiModel`**
*   **Tujuan:** Kelas utama yang merepresentasikan satu entitas transaksi dengan semua atribut yang diperlukan.
*   **Properti Inti:** Berisi field fundamental seperti `id`, `tanggal`, `keterangan`, `jumlah`, `tipe`, `idDompet`, dan `idKategori` yang menjadi dasar dari setiap transaksi.
*   **Properti Tergabung (Hasil Denormalisasi):** Penambahan field `durasiPaket`, `tipeDurasiPaket`, `tanggalMulai`, dan `tanggalBerakhir`. Properti ini dipindahkan dari `RiwayatLanggananModel` dan digabungkan ke sini. Tujuannya adalah untuk menghilangkan kebutuhan join data dan membuat setiap record transaksi langganan menjadi mandiri dan lengkap.

#### **Metode `_parseDateTime(dynamic dateValue)`**
*   **Tujuan:** Fungsi helper statis yang dirancang untuk mengonversi nilai tanggal dari berbagai format (seperti `Timestamp` dari Firebase, `String` dari SQLite, atau `DateTime` dari aplikasi) menjadi objek `DateTime` yang konsisten. Ini membuat model lebih tangguh terhadap berbagai sumber data.

#### **Factory `TransaksiModel.fromSqlite(Map<String, dynamic> map)`**
*   **Tujuan:** Konstruktor pabrik yang bertugas membuat instance `TransaksiModel` dari data `Map` yang dibaca dari database SQLite. Metode ini secara spesifik memetakan nama kolom di tabel SQLite (misalnya, `id_dompet`, `tanggal_mulai`) ke properti yang sesuai di dalam model.

#### **Metode `toSqlite()`**
*   **Tujuan:** Mengonversi objek `TransaksiModel` kembali menjadi sebuah `Map` dengan format kunci dan nilai yang sesuai untuk disimpan atau diperbarui ke dalam tabel di database SQLite. Objek `DateTime` diubah menjadi format string ISO 8601.

#### **Factory `TransaksiModel.fromFirebase(String id, Map<String, dynamic> data)`**
*   **Tujuan:** Konstruktor pabrik yang membuat instance `TransaksiModel` dari data `Map` yang diterima dari dokumen Firestore. Metode ini menangani konversi tipe data spesifik Firebase seperti `Timestamp` menjadi `DateTime`.

#### **Metode `toFirebase()`**
*   **Tujuan:** Mengonversi objek `TransaksiModel` menjadi `Map` untuk disimpan di Firestore. Metode ini menggunakan fitur spesifik Firebase seperti `FieldValue.serverTimestamp()` untuk mengisi field `diperbarui` secara otomatis di sisi server dan mengonversi `DateTime` ke `Timestamp` untuk konsistensi data.

#### **Metode `copyWith({...})`**
*   **Tujuan:** Sebuah metode utilitas yang sangat penting untuk mendukung pola *immutability*. Metode ini memungkinkan pembuatan salinan (kloning) dari sebuah objek `TransaksiModel` sambil mengubah nilai dari satu atau beberapa propertinya. Ini sangat berguna di state management untuk memicu pembaruan UI secara efisien.
