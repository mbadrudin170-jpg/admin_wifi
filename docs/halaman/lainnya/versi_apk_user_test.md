 // path: docs/halaman/lainnya/versi_apk_user_test.md


# Buat atau Ubah isi file test agar sesuai dengan yang ada disini


# Appbar
### tombol urutkan 
- harus memanggil fungsi ## showdialogurutkan 

# body

## List
### test 1 menampilkan semua list
- menampilkan list data yang sudah diurutkan di ## showdialogurutkan 

### test 2
+ data yang di tampilkan adalah nomorBuildTerbaru,catatanRilis,versiTerbaru
+ ketika salah satu list nya ditekan akan menuju ke file lib/halaman/detail/detail_versi_apk_user.dart dengan membawa idnya.
### test 3
+ saat ditekan lama akan menampilkan fungsi showDialogOpsi 
### test 4 
* showDialogOpsi harus menampilkan dua opsi edit dan arsip
  - tombol edit harus menuju ke file lib/halaman/form/form_versi_apk_user.dart dengan membawa idnya.
  - tombol arsip harus memanggil ialog konfirmasi arsip
### test 5 dialog konfirmasi arsip
- harus menampilkan alert konfirmasi ya dan batal jika ya harus memanggil fungsi arsipkanVersiApkUser di file lib/data/operasi/versi_apk_user_operasi.dart

## tombol tambah 
- berupa FloatingActionButton untuk menuju ke file lib/halaman/form/form_versi_apk_user.dart.

# show dialog
## showdialogurutkan 
- akan menampilkan beberapa opsi untuk mengurutkan data yang akan muncul di list dengan default nya menampilkan semua list di tabel versi_apk_user yang kolom isDeleted nya 0, dan urutkan berdasarkan kolom nomor_build_terbaru paling tinggi.
- opsi urutkan nya antara lain build a-z, build z-a, versi a-z, versi z-a.
- mengatasi jiksa salah satu item di list diarsipkan atau setelah di edit listnya akan masih sama dengan apa yang opsi di showdialogurutkan dipilih, dan list akan tetap berada di terakhir list di scroll tidak otomatis pindah ke paling atas lagi
