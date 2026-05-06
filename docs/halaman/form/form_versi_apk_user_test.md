 // path: docs/halaman/form/form_versi_apk_user_test.md

 # Buat atau Ubah isi file test agar sesuai dengan yang ada disini

 # Data yang harus disimpan 
  final String id;
  final String catatanRilis;
  final Map<String, int> nomorBuildTerbaru;
  final Map<String, String> tautanUnduhan;
  final String versiTerbaru;
  final bool wajibUpdate;
  final String youtubeTutorial;
  final DateTime? diperbarui;

 1. untuk nomorBuildTerbaru kita gunakan 3 map 
 - bit_32 
 - bit_64
 - universal
 2. untuk tautanUnduhan
 - bit_32
 - bit_64
 - universal

 1. file ini akan menagani edit dan tambah

  - jika edit maka mengisi form yang di ambil dari id yang dikirim
- jika mode tambah akan mengisi form yang diambil dari fungsi ambilVersiApkTerbaru di file test/data/operasi/versi_apk_user_operasi_test.dart.
- dalam mode tambah untuk form nomorBuildTerbaru akan otomatis menambahkan dari data yang diambil dari ambilVersiApkTerbaru itu contoh versi terbaru dari database 1 maka di form akan menjadi 2.
- untuk form tautanUnduhan jangan otomatis terisi untuk mode tambah.
- 


# tombol simpan
- tombol simpan letakan di paling bawah TextFormField dan setelah menjalankan fungsinya akan diarahakan ke file lib/halaman/lainnya/versi_apk_user.dart.
- sebelum melanjutkan ke fungsi simpan tambahkan peringatan semua form wajib diisi

#