// path: lib/data/sync/unduhan_awal.dart

// diubah: Mengganti impor dan menggunakan 'developer' sebagai alias.
import 'dart:developer' as developer;

import 'package:admin_wifi/data/sync/unduh_data.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:sqflite/sqflite.dart';

/// [UnduhanAwalService] bertanggung jawab untuk mengisi database lokal dengan
/// data dari server jika tabel-tabel tertentu masih kosong.
/// Ini untuk inisialisasi data saat aplikasi pertama kali dijalankan.
class UnduhanAwalService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final LayananUnduhData _layananUnduh = LayananUnduhData();

  /// Fungsi ini bertujuan untuk menjalankan semua pengecekan dan pengunduhan data awal.
  Future<void> jalankanUnduhanAwal() async {
    // diubah: Menggunakan developer.log dengan level INFO.
    developer.log(
      'Memulai proses unduhan awal (inisialisasi data dari server jika kosong).',
      name: 'UnduhanAwalService.jalankanUnduhanAwal',
      level: 800, // INFO
    );

    // diubah: Memanggil semua fungsi unduh untuk setiap tabel yang relevan.
    await _unduhDataPaketJikaKosong();
    await _unduhDataKategoriJikaKosong();
    await _unduhDataSubKategoriJikaKosong();
    await _unduhDataDompetJikaKosong();
    await _unduhDataPelangganJikaKosong();
    await _unduhDataVersiApkJikaKosong();
    await _unduhDataPengaturanJikaKosong();
    // ditambah: Pengecekan untuk tabel-tabel yang sebelumnya terlewat.
    await _unduhDataPelangganAktifJikaKosong();
    await _unduhDataTransaksiJikaKosong();
    await _unduhDataKritikSaranJikaKosong();
    // await _unduhDataRiwayatLanggananJikaKosong();
    await _unduhDataPesananJikaKosong();

    developer.log(
      'Proses unduhan awal selesai.',
      name: 'UnduhanAwalService.jalankanUnduhanAwal',
      level: 800, // INFO
    );
  }

  /// Fungsi ini memeriksa apakah sebuah tabel kosong dan memberikan log detail.
  // diubah: Menambahkan logging detail pada proses pengecekan.
  Future<bool> _apakahTabelKosong(String namaTabel) async {
    final db = await _dbHelper.database;
    developer.log(
      "Mengecek jumlah data di tabel '$namaTabel'...",
      name: 'UnduhanAwalService._apakahTabelKosong',
    );
    final hasil = await db.rawQuery('SELECT COUNT(*) as count FROM $namaTabel');
    final jumlah = Sqflite.firstIntValue(hasil) ?? 0;
    developer.log(
      "Tabel '$namaTabel' memiliki $jumlah baris data.",
      name: 'UnduhanAwalService._apakahTabelKosong',
    );
    return jumlah == 0;
  }

  /// Fungsi ini mengunduh data paket awal jika tabel 'paket' kosong.
  // diubah: Menambahkan logging detail, else block, dan try-catch.
  Future<void> _unduhDataPaketJikaKosong() async {
    const String namaTabel = 'paket';
    try {
      if (await _apakahTabelKosong(namaTabel)) {
        developer.log(
          "Tabel '$namaTabel' terdeteksi kosong. Memulai unduhan...",
          name: 'UnduhanAwalService._unduhDataPaketJikaKosong',
        );
        await _layananUnduh.unduhDataPaket();
        developer.log(
          "Data untuk '$namaTabel' berhasil diunduh.",
          name: 'UnduhanAwalService._unduhDataPaketJikaKosong',
        );
      } else {
        developer.log(
          "Tabel '$namaTabel' sudah berisi data. Unduhan dilewati.",
          name: 'UnduhanAwalService._unduhDataPaketJikaKosong',
        );
      }
    } catch (e, s) {
      developer.log(
        "Error saat proses unduh data '$namaTabel'.",
        name: 'UnduhanAwalService._unduhDataPaketJikaKosong',
        error: e,
        stackTrace: s,
        level: 1000, // SEVERE
      );
    }
  }

  /// Fungsi ini mengunduh data kategori awal jika tabel 'kategori' kosong.
  // diubah: Menambahkan logging detail, else block, dan try-catch.
  Future<void> _unduhDataKategoriJikaKosong() async {
    const String namaTabel = 'kategori';
    try {
      if (await _apakahTabelKosong(namaTabel)) {
        developer.log(
          "Tabel '$namaTabel' terdeteksi kosong. Memulai unduhan...",
          name: 'UnduhanAwalService._unduhDataKategoriJikaKosong',
        );
        await _layananUnduh.unduhDataKategori();
        developer.log(
          "Data untuk '$namaTabel' berhasil diunduh.",
          name: 'UnduhanAwalService._unduhDataKategoriJikaKosong',
        );
      } else {
        developer.log(
          "Tabel '$namaTabel' sudah berisi data. Unduhan dilewati.",
          name: 'UnduhanAwalService._unduhDataKategoriJikaKosong',
        );
      }
    } catch (e, s) {
      developer.log(
        "Error saat proses unduh data '$namaTabel'.",
        name: 'UnduhanAwalService._unduhDataKategoriJikaKosong',
        error: e,
        stackTrace: s,
        level: 1000,
      );
    }
  }

  /// Fungsi ini mengunduh data sub-kategori awal jika tabel 'sub_kategori' kosong.
  // diubah: Menambahkan logging detail, else block, dan try-catch.
  Future<void> _unduhDataSubKategoriJikaKosong() async {
    const String namaTabel = 'sub_kategori';
    try {
      if (await _apakahTabelKosong(namaTabel)) {
        developer.log(
          "Tabel '$namaTabel' terdeteksi kosong. Memulai unduhan...",
          name: 'UnduhanAwalService._unduhDataSubKategoriJikaKosong',
        );
        await _layananUnduh.unduhDataSubKategori();
        developer.log(
          "Data untuk '$namaTabel' berhasil diunduh.",
          name: 'UnduhanAwalService._unduhDataSubKategoriJikaKosong',
        );
      } else {
        developer.log(
          "Tabel '$namaTabel' sudah berisi data. Unduhan dilewati.",
          name: 'UnduhanAwalService._unduhDataSubKategoriJikaKosong',
        );
      }
    } catch (e, s) {
      developer.log(
        "Error saat proses unduh data '$namaTabel'.",
        name: 'UnduhanAwalService._unduhDataSubKategoriJikaKosong',
        error: e,
        stackTrace: s,
        level: 1000,
      );
    }
  }

  /// Fungsi ini mengunduh data dompet awal jika tabel 'dompet' kosong.
  // diubah: Menambahkan logging detail, else block, dan try-catch.
  Future<void> _unduhDataDompetJikaKosong() async {
    const String namaTabel = 'dompet';
    try {
      if (await _apakahTabelKosong(namaTabel)) {
        developer.log(
          "Tabel '$namaTabel' terdeteksi kosong. Memulai unduhan...",
          name: 'UnduhanAwalService._unduhDataDompetJikaKosong',
        );
        await _layananUnduh.unduhDataDompet();
        developer.log(
          "Data untuk '$namaTabel' berhasil diunduh.",
          name: 'UnduhanAwalService._unduhDataDompetJikaKosong',
        );
      } else {
        developer.log(
          "Tabel '$namaTabel' sudah berisi data. Unduhan dilewati.",
          name: 'UnduhanAwalService._unduhDataDompetJikaKosong',
        );
      }
    } catch (e, s) {
      developer.log(
        "Error saat proses unduh data '$namaTabel'.",
        name: 'UnduhanAwalService._unduhDataDompetJikaKosong',
        error: e,
        stackTrace: s,
        level: 1000,
      );
    }
  }

  /// Fungsi ini mengunduh data pelanggan awal jika tabel 'pelanggan' kosong.
  // diubah: Menambahkan logging detail, else block, dan try-catch.
  Future<void> _unduhDataPelangganJikaKosong() async {
    const String namaTabel = 'pelanggan';
    try {
      if (await _apakahTabelKosong(namaTabel)) {
        developer.log(
          "Tabel '$namaTabel' terdeteksi kosong. Memulai unduhan...",
          name: 'UnduhanAwalService._unduhDataPelangganJikaKosong',
        );
        await _layananUnduh.unduhDataPelanggan();
        developer.log(
          "Data untuk '$namaTabel' berhasil diunduh.",
          name: 'UnduhanAwalService._unduhDataPelangganJikaKosong',
        );
      } else {
        developer.log(
          "Tabel '$namaTabel' sudah berisi data. Unduhan dilewati.",
          name: 'UnduhanAwalService._unduhDataPelangganJikaKosong',
        );
      }
    } catch (e, s) {
      developer.log(
        "Error saat proses unduh data '$namaTabel'.",
        name: 'UnduhanAwalService._unduhDataPelangganJikaKosong',
        error: e,
        stackTrace: s,
        level: 1000,
      );
    }
  }

  /// Fungsi ini mengunduh data versi APK awal jika tabel 'versi_apk_user' kosong.
  // diubah: Menambahkan logging detail, else block, dan try-catch.
  Future<void> _unduhDataVersiApkJikaKosong() async {
    const String namaTabel = 'versi_apk_user';
    try {
      if (await _apakahTabelKosong(namaTabel)) {
        developer.log(
          "Tabel '$namaTabel' terdeteksi kosong. Memulai unduhan...",
          name: 'UnduhanAwalService._unduhDataVersiApkJikaKosong',
        );
        await _layananUnduh.unduhDataVersiApkUser();
        developer.log(
          "Data untuk '$namaTabel' berhasil diunduh.",
          name: 'UnduhanAwalService._unduhDataVersiApkJikaKosong',
        );
      } else {
        developer.log(
          "Tabel '$namaTabel' sudah berisi data. Unduhan dilewati.",
          name: 'UnduhanAwalService._unduhDataVersiApkJikaKosong',
        );
      }
    } catch (e, s) {
      developer.log(
        "Error saat proses unduh data '$namaTabel'.",
        name: 'UnduhanAwalService._unduhDataVersiApkJikaKosong',
        error: e,
        stackTrace: s,
        level: 1000,
      );
    }
  }

  /// Fungsi ini mengunduh data pengaturan awal jika tabel 'pengaturan' kosong.
  // diubah: Menambahkan logging detail, else block, try-catch, dan menggunakan _apakahTabelKosong.
  Future<void> _unduhDataPengaturanJikaKosong() async {
    const String namaTabel = 'pengaturan';
    try {
      if (await _apakahTabelKosong(namaTabel)) {
        developer.log(
          "Tabel '$namaTabel' terdeteksi kosong. Memulai unduhan...",
          name: 'UnduhanAwalService._unduhDataPengaturanJikaKosong',
        );
        await _layananUnduh.unduhDataPengaturan();
        developer.log(
          "Data untuk '$namaTabel' berhasil diunduh.",
          name: 'UnduhanAwalService._unduhDataPengaturanJikaKosong',
        );
      } else {
        developer.log(
          "Tabel '$namaTabel' sudah berisi data. Unduhan dilewati.",
          name: 'UnduhanAwalService._unduhDataPengaturanJikaKosong',
        );
      }
    } catch (e, s) {
      developer.log(
        "Error saat proses unduh data '$namaTabel'.",
        name: 'UnduhanAwalService._unduhDataPengaturanJikaKosong',
        error: e,
        stackTrace: s,
        level: 1000,
      );
    }
  }

  // ditambah: Fungsi-fungsi baru untuk tabel yang terlewat.

  /// Fungsi ini mengunduh data pelanggan aktif jika tabel 'pelanggan_aktif' kosong.
  // diubah: Menambahkan logging detail, else block, dan try-catch.
  Future<void> _unduhDataPelangganAktifJikaKosong() async {
    const String namaTabel = 'pelanggan_aktif';
    try {
      if (await _apakahTabelKosong(namaTabel)) {
        developer.log(
          "Tabel '$namaTabel' terdeteksi kosong. Memulai unduhan...",
          name: 'UnduhanAwalService._unduhDataPelangganAktifJikaKosong',
        );
        await _layananUnduh.unduhDataPelangganAktif();
        developer.log(
          "Data untuk '$namaTabel' berhasil diunduh.",
          name: 'UnduhanAwalService._unduhDataPelangganAktifJikaKosong',
        );
      } else {
        developer.log(
          "Tabel '$namaTabel' sudah berisi data. Unduhan dilewati.",
          name: 'UnduhanAwalService._unduhDataPelangganAktifJikaKosong',
        );
      }
    } catch (e, s) {
      developer.log(
        "Error saat proses unduh data '$namaTabel'.",
        name: 'UnduhanAwalService._unduhDataPelangganAktifJikaKosong',
        error: e,
        stackTrace: s,
        level: 1000,
      );
    }
  }

  /// Fungsi ini mengunduh data transaksi jika tabel 'transaksi' kosong.
  // diubah: Menambahkan logging detail, else block, dan try-catch.
  Future<void> _unduhDataTransaksiJikaKosong() async {
    const String namaTabel = 'transaksi';
    try {
      if (await _apakahTabelKosong(namaTabel)) {
        developer.log(
          "Tabel '$namaTabel' terdeteksi kosong. Memulai unduhan...",
          name: 'UnduhanAwalService._unduhDataTransaksiJikaKosong',
        );
        await _layananUnduh.unduhDataTransaksi();
        developer.log(
          "Data untuk '$namaTabel' berhasil diunduh.",
          name: 'UnduhanAwalService._unduhDataTransaksiJikaKosong',
        );
      } else {
        developer.log(
          "Tabel '$namaTabel' sudah berisi data. Unduhan dilewati.",
          name: 'UnduhanAwalService._unduhDataTransaksiJikaKosong',
        );
      }
    } catch (e, s) {
      developer.log(
        "Error saat proses unduh data '$namaTabel'.",
        name: 'UnduhanAwalService._unduhDataTransaksiJikaKosong',
        error: e,
        stackTrace: s,
        level: 1000,
      );
    }
  }

  /// Fungsi ini mengunduh data kritik saran jika tabel 'kritik_saran' kosong.
  // diubah: Menambahkan logging detail, else block, dan try-catch.
  Future<void> _unduhDataKritikSaranJikaKosong() async {
    const String namaTabel = 'kritik_saran';
    try {
      if (await _apakahTabelKosong(namaTabel)) {
        developer.log(
          "Tabel '$namaTabel' terdeteksi kosong. Memulai unduhan...",
          name: 'UnduhanAwalService._unduhDataKritikSaranJikaKosong',
        );
        await _layananUnduh.unduhDataKritikSaran();
        developer.log(
          "Data untuk '$namaTabel' berhasil diunduh.",
          name: 'UnduhanAwalService._unduhDataKritikSaranJikaKosong',
        );
      } else {
        developer.log(
          "Tabel '$namaTabel' sudah berisi data. Unduhan dilewati.",
          name: 'UnduhanAwalService._unduhDataKritikSaranJikaKosong',
        );
      }
    } catch (e, s) {
      developer.log(
        "Error saat proses unduh data '$namaTabel'.",
        name: 'UnduhanAwalService._unduhDataKritikSaranJikaKosong',
        error: e,
        stackTrace: s,
        level: 1000,
      );
    }
  }

  // /// Fungsi ini mengunduh data riwayat langganan jika tabel 'riwayat_langganan' kosong.
  // // diubah: Menambahkan logging detail, else block, dan try-catch.
  // Future<void> _unduhDataRiwayatLanggananJikaKosong() async {
  //   const String namaTabel = 'riwayat_langganan';
  //   try {
  //     if (await _apakahTabelKosong(namaTabel)) {
  //       developer.log(
  //         "Tabel '$namaTabel' terdeteksi kosong. Memulai unduhan...",
  //         name: 'UnduhanAwalService._unduhDataRiwayatLanggananJikaKosong',
  //       );
  //       // await _layananUnduh.unduhDataRiwayatLangganan();
  //       // developer.log(
  //       //   "Data untuk '$namaTabel' berhasil diunduh.",
  //       //   name: 'UnduhanAwalService._unduhDataRiwayatLanggananJikaKosong',
  //       // );
  //     } else {
  //       developer.log(
  //         "Tabel '$namaTabel' sudah berisi data. Unduhan dilewati.",
  //         name: 'UnduhanAwalService._unduhDataRiwayatLanggananJikaKosong',
  //       );
  //     }
  //   } catch (e, s) {
  //     developer.log(
  //       "Error saat proses unduh data '$namaTabel'.",
  //       name: 'UnduhanAwalService._unduhDataRiwayatLanggananJikaKosong',
  //       error: e,
  //       stackTrace: s,
  //       level: 1000,
  //     );
  //   }
  // }

  /// Fungsi ini mengunduh data pesanan jika tabel 'pesanan' kosong.
  // diubah: Menambahkan logging detail, else block, dan try-catch.
  Future<void> _unduhDataPesananJikaKosong() async {
    const String namaTabel = 'pesanan';
    try {
      if (await _apakahTabelKosong(namaTabel)) {
        developer.log(
          "Tabel '$namaTabel' terdeteksi kosong. Memulai unduhan...",
          name: 'UnduhanAwalService._unduhDataPesananJikaKosong',
        );
        await _layananUnduh.unduhDataPesanan();
        developer.log(
          "Data untuk '$namaTabel' berhasil diunduh.",
          name: 'UnduhanAwalService._unduhDataPesananJikaKosong',
        );
      } else {
        developer.log(
          "Tabel '$namaTabel' sudah berisi data. Unduhan dilewati.",
          name: 'UnduhanAwalService._unduhDataPesananJikaKosong',
        );
      }
    } catch (e, s) {
      developer.log(
        "Error saat proses unduh data '$namaTabel'.",
        name: 'UnduhanAwalService._unduhDataPesananJikaKosong',
        error: e,
        stackTrace: s,
        level: 1000,
      );
    }
  }
}
