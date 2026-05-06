# tolong periksa file testnya wajib sama dengan file ini

## 🧪 1. Kondisi Database Kosong

* **ambilSemuaVersiApkAktif harus mengembalikan list kosong**
  → Memastikan fungsi mengembalikan list kosong saat tidak ada data aktif di database

* **ambilSemuaVersiApk harus mengembalikan list kosong**
  → Memastikan fungsi mengembalikan list kosong saat database benar-benar kosong

* **ambilVersiApkById harus mengembalikan null**
  → Memastikan fungsi mengembalikan `null` jika ID tidak ditemukan

* **ambilVersiApkTerbaru harus mengembalikan null**
  → Memastikan fungsi mengembalikan `null` jika tidak ada data sama sekali

---

## 🧪 2. Operasi CRUD Dasar

* **tambahVersiApkUser harus berhasil menyimpan data baru**
  → Data berhasil disimpan dan dapat diambil kembali berdasarkan ID
  - tambahkan pengecekan koneksi internet panggil fungsi KoneksiInternetService di lib/services/cek_koneksi_internet.dart jika online maka panggil fungsi   Future<void> unggahDataVersiApkUser() async di lib/data/sync/unggah_data.dart. jika tidak online lewati dan tambahkan timeout jika sinyal buruk. jika fungsi  unggahDataVersiApkUser berhasil maka panggil fungsi   Future<void> setLastSyncTimestamp(DateTime time) async {
di file lib/utils/sync_manager.dart.
  


* **perbaruiVersiApkUser harus berhasil mengubah data**
  → Data yang sudah ada berhasil diperbarui dan perubahan tersimpan

* **arsipkanVersiApkUser harus merubah data di id yang diberikan agar isDeleted menjadi 1, diarsipkan dan diperbarui ke DateTime.now()**
  → Memastikan:

  * `isDeleted` berubah menjadi `1`
  * kolom `diarsipkan` terisi
  * kolom `diperbarui` terupdate
  * data tidak bisa diambil lagi melalui fungsi aktif

---

## 🧪 3. Fungsi Pengambilan (Fetch)

### 🔍 ambilVersiApkTerbaru

* **harus mengembalikan null jika hanya ada data yang diarsip**
  → Semua data diarsip → hasil harus `null`

* **harus mengambil data yang hanya kolom build nya lebih tinggi dari data yang ada dan tidak diarsip**
  → Memastikan:

  * versi sama
  * dipilih berdasarkan **build number tertinggi**
  * data arsip diabaikan
  * tidak bergantung pada tanggal `diperbarui`

---

### 📊 Dengan Data Awal

* **ambilSemuaVersiApkAktif hanya mengembalikan data yang isDeleted nya 0**
  → Memastikan hanya data aktif yang dikembalikan

* **ambilSemuaVersiApk harus mengembalikan semua data (aktif dan diarsip)**
  → Memastikan semua data ditampilkan tanpa filter

* **ambilSemuaVersiApkAktif harus mengembalikan data terurut dari yang terbaru (berdasarkan tanggal)**
  → Memastikan urutan data berdasarkan `diperbarui DESC`

---

## 🧪 4. Operasi Batch

* **sisipkanAtauPerbaruiBatch harus memasukkan beberapa data baru**
  → Batch insert berhasil menambahkan banyak data sekaligus

* **sisipkanAtauPerbaruiBatch harus memperbarui data yang ada**
  → Memastikan:

  * data lama diupdate
  * data baru tetap ditambahkan
  * tidak terjadi duplikasi

---

## 🎯 Catatan Teknis

* Filter utama: `isDeleted = 0`
* Data arsip tidak boleh muncul di fungsi aktif
* Penentuan versi terbaru berbasis:

  * versi
  * nomor build
* Database test menggunakan **in-memory (sqflite_ffi)**

---

## 🚀 Insight Singkat

Struktur kamu ini sudah:

* konsisten
* scalable
* siap untuk production testing

Tinggal dijaga:

> nama test = kontrak perilaku sistem

Kalau sampai nama test berubah tapi logic tidak, itu tanda mulai “drift”.

---

Kalau mau lanjut lebih tajam lagi:
kita bisa bikin **mapping test ↔ fungsi ↔ bug risk**
biar kamu tahu bagian mana yang paling rawan rusak di masa depan.
