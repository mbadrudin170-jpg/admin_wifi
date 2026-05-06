## Catatan Kerja Harian

### **v1.0.9+5**

- **Refaktorisasi Halaman Versi APK**:
    - **File**: `lib/halaman/lainnya/versi_apk_user.dart`
    - **Perubahan**: 
        - Mengubah halaman dari tampilan detail menjadi tampilan daftar (`ListView`) untuk menampilkan semua data versi APK.
        - Mengimplementasikan `ListView.builder` untuk efisiensi.
        - Menambahkan navigasi `onTap` ke halaman detail untuk setiap item dalam daftar.
- **Penambahan Halaman Detail Versi APK**:
    - **File**: `lib/halaman/detail/detail_versi_apk_user.dart`
    - **Perubahan**: 
        - Membuat halaman baru untuk menampilkan rincian lengkap dari data versi APK yang dipilih.
- **Penambahan Fungsi Operasi**:
    - **File**: `lib/data/operasi/versi_apk_user_operasi.dart`
    - **Perubahan**:
        - Menambahkan fungsi baru `ambilSemuaVersiApk()` untuk mengambil semua data versi APK dalam bentuk `List`.

### **v1.0.9+4**

- **Refaktorisasi & Perbaikan Halaman Kontrol APK**:
    - **File**: `lib/halaman/lainnya/versi_apk_user.dart`
    - **Perubahan**: 
        - Menghapus `FutureBuilder` dan menggantinya dengan manajemen state manual untuk meningkatkan performa dan kejelasan kode.
        - Mengimplementasikan `Future.wait` untuk memuat data dari SQLite dan Firebase secara paralel, mempercepat waktu loading halaman.
        - Mengatasi `_CompileTimeError` yang disebabkan oleh cache build yang usang dengan melakukan `flutter clean`.
        - Menambahkan UI yang lebih informatif dengan `SwitchListTile` untuk kontrol maintenance dan `RefreshIndicator` untuk memuat ulang data.