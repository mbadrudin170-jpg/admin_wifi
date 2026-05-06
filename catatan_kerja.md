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