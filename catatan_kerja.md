# Catatan Kerja - 2024-05-24

## Fitur: Pengembangan Fungsi `getPoinHangus` dengan TDD

### Deskripsi
Menambahkan dan memvalidasi fungsi `PerhitunganUtil.getPoinHangus` yang menentukan apakah poin dari sebuah transaksi dianggap "Hangus" berdasarkan aturan bisnis baru. Seluruh proses pengembangan dilakukan dengan mengikuti metodologi Test-Driven Development (TDD).

### Alur Kerja & Perubahan Teknis

1.  **Diskusi Awal & Kesalahan Logika**: Awalnya, logika "Hangus" direncanakan berdasarkan `tanggalDiarsipkan`. Namun, setelah diskusi, disepakati bahwa aturan bisnis yang benar adalah **berdasarkan selisih 30 hari dari `tanggalMulai` transaksi**.

2.  **Tahap 1: Red (Menulis Tes yang Gagal)**
    -   **`test/utils/perhitungan_util_test.dart`**: Menulis dua unit test baru untuk `getPoinHangus`:
        -   `2.1 harus menampilkan teks Hangus jika tanggal mulai sudah lebih dari 30 hari`.
        -   `2.2 harus menampilkan string kosong jika tanggal mulai kurang dari atau sama dengan 30 hari`.
    -   Tes ini sengaja dibuat untuk gagal karena implementasi di `PerhitunganUtil` belum sesuai (baik dari segi parameter maupun logika).

3.  **Tahap 2: Green (Menulis Implementasi untuk Lolos Tes)**
    -   **`lib/utils/perhitungan_util.dart`**: Mengubah fungsi `getPoinHangus`:
        -   Tanda tangan fungsi diubah dari `({DateTime? diarsipkan})` menjadi `({required DateTime tanggalMulai, DateTime? now})`.
        -   Logika internal diimplementasikan untuk menghitung selisih hari antara `now` dan `tanggalMulai`.
        -   Fungsi mengembalikan `'Hangus'` jika selisih > 30 hari, dan `''` jika tidak.

4.  **Tahap 3: Refactor & Verifikasi**
    -   Menjalankan kembali semua tes di `perhitungan_util_test.dart`. Hasilnya, **semua 12 tes berhasil (All tests passed!)**.
    -   Menjalankan `flutter analyze` untuk memastikan tidak ada masalah kualitas kode baru yang muncul. Hasilnya: **No issues found**.

### Hasil Akhir
-   Fungsi `getPoinHangus` kini memiliki logika bisnis yang kuat, tervalidasi, dan didukung oleh unit test yang spesifik.
-   Proses TDD berhasil memandu pengembangan dari definisi kebutuhan yang salah menuju implementasi yang benar dan teruji.

---

# Catatan Kerja - 2024-05-23

## Fitur: Logo Splash Screen Dinamis Sesuai Tema

### Deskripsi
Mengimplementasikan kemampuan pada `SplashScreen` untuk menampilkan logo yang berbeda tergantung pada mode tema sistem (terang atau gelap) yang digunakan pengguna.

### Perubahan Teknis
1.  **`lib/splash_screen.dart`**:
    -   **diubah**: Mengganti `Image.asset` statis dengan `Builder` widget.
    -   **ditambahkan**: Logika untuk memeriksa `MediaQuery.of(context).platformBrightness`.
    -   Jika tema `Brightness.dark`, maka akan memuat `assets/logo/splash_screen/logo_splash_screen_gelap.png`.
    -   Jika tema `Brightness.light`, maka akan memuat `assets/logo/splash_screen/logo_splash_screen_terang.png`.

2.  **`pubspec.yaml`**:
    -   **diubah**: Memperbarui bagian `assets` dari `- assets/logo/` menjadi lebih spesifik:
        - `- assets/logo/ikon/`
        - `- assets/logo/splash_screen/`
    -   Tindakan ini dilakukan untuk meningkatkan kejelasan dan pengelolaan aset proyek.

### Tujuan
- Meningkatkan pengalaman pengguna (UX) dengan menyajikan aset visual yang konsisten dengan tema aplikasi.
- Merapikan dan memperjelas deklarasi aset di `pubspec.yaml`.