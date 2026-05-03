// path: lib/data/operasi/pelanggan_aktif_operasi.dart
// diubah: Menambahkan fungsi untuk mengarsipkan semua pelanggan aktif.

import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/data/operasi/riwayat_langganan_operasi.dart';
import 'package:admin_wifi/model/riwayat_langganan_model.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:developer' as developer;

import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/services/notifikasi_servis.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/whatsapp/info_paket.dart';

class PelangganAktifOperasi {
  final dbHelper = DatabaseHelper.instance;
  final NotifikasiServis _notifikasiServis = NotifikasiServis();
  final PelangganOperasi _pelangganOperasi = PelangganOperasi();

  // untuk membuat pelanggan aktif baru
  Future<int> createPelangganAktif(PelangganAktifModel pelangganAktif) async {
    final db = await dbHelper.database;

    final data = pelangganAktif.toMap();

    final result = await db.insert(
      'pelanggan_aktif',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await _jadwalkanNotifikasi(pelangganAktif);
    await PesanInfoPaket.kirimRincianPaket(pelangganAktif);

    developer.log(
      '✅ [LOKAL] Pelanggan aktif (ID: ${pelangganAktif.id}) berhasil dibuat.',
    );
    return result;
  }

  // untuk mengambil semua data pelanggan aktif yang belum diarsipkan
  Future<List<PelangganAktifModel>> ambilSemuaPelangganAktif() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pelanggan_aktif',
      where: 'isDeleted = ?',
      whereArgs: [0],
    );
    return List.generate(
      maps.length,
      (i) => PelangganAktifModel.fromMap(maps[i]),
    );
  }

  // untuk mengambil satu data pelanggan aktif
  Future<PelangganAktifModel?> ambilSatuPelangganAktif(String id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pelanggan_aktif',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return PelangganAktifModel.fromMap(maps.first);
    }
    return null;
  }

  // untuk memperbarui data pelanggan aktif
  Future<void> updatePelangganAktif(PelangganAktifModel pelangganAktif) async {
    final db = await dbHelper.database;

    final data = pelangganAktif.toMap();

    await db.update(
      'pelanggan_aktif',
      data,
      where: 'id = ?',
      whereArgs: [pelangganAktif.id],
    );

    developer.log(
      '✅ [LOKAL] Pelanggan aktif (ID: ${pelangganAktif.id}) berhasil diperbarui.',
    );
    await _jadwalkanNotifikasi(pelangganAktif);
    await PesanInfoPaket.kirimRincianPaket(pelangganAktif);
  }

  // untuk menjadwalkan notifikasi
  Future<void> _jadwalkanNotifikasi(PelangganAktifModel pelangganAktif) async {
    final pelanggan = await _pelangganOperasi.getPelangganById(
      pelangganAktif.idPelanggan,
    );
    final namaPelanggan = pelanggan?.nama ?? 'Tanpa Nama';

    // Batalkan notifikasi lama sebelum menjadwalkan yang baru
    await _notifikasiServis.batalNotifikasi(pelangganAktif.id.hashCode);
    await _notifikasiServis.batalNotifikasi((pelangganAktif.id.hashCode + 1));

    // Jadwalkan notifikasi H-1
    final jadwalNotifikasiH1 = pelangganAktif.tanggalBerakhir.subtract(
      const Duration(days: 1),
    );
    if (jadwalNotifikasiH1.isAfter(DateTime.now())) {
      await _notifikasiServis.jadwalNotifikasi(
        id: pelangganAktif.id.hashCode,
        title: 'Paket Akan Segera Berakhir',
        body: 'Paket untuk pelanggan $namaPelanggan akan berakhir besok.',
        jadwal: jadwalNotifikasiH1,
      );
    }

    // Jadwalkan notifikasi H-3
    final jadwalNotifikasiH3 = pelangganAktif.tanggalBerakhir.subtract(
      const Duration(days: 3),
    );
    if (jadwalNotifikasiH3.isAfter(DateTime.now())) {
      await _notifikasiServis.jadwalNotifikasi(
        id: (pelangganAktif.id.hashCode + 1), // ID unik untuk notifikasi kedua
        title: 'Pengingat Paket',
        body:
            'Paket untuk pelanggan $namaPelanggan akan berakhir dalam 3 hari.',
        jadwal: jadwalNotifikasiH3,
      );
    }
  }

  // untuk menyisipkan atau memperbarui data secara batch
  Future<void> sisipkanAtauPerbaruiBatch(
    List<PelangganAktifModel> items,
  ) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    for (var item in items) {
      batch.insert(
        'pelanggan_aktif',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // ditambah: untuk mengarsipkan pelanggan aktif (soft delete)
  Future<void> arsipkanPelangganAktif(String id) async {
    final db = await dbHelper.database;

    final pelangganAktif = await ambilSatuPelangganAktif(id);
    if (pelangganAktif == null) {
      developer.log(
        '⚠️ [LOKAL] Pelanggan aktif dengan ID: $id tidak ditemukan untuk diarsipkan.',
        name: 'PelangganAktifOperasi',
      );
      return;
    }

    // ubah status menjadi diarsipkan
    final pelangganDearsipkan = pelangganAktif.copyWith(
      isDeleted: true,
      diarsipkan: DateTime.now(),
    );

    // perbarui di database lokal
    await db.update(
      'pelanggan_aktif',
      pelangganDearsipkan.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );

    // batalkan notifikasi
    await _notifikasiServis.batalNotifikasi(id.hashCode);
    await _notifikasiServis.batalNotifikasi((id.hashCode + 1));

    developer.log(
      '✅ [LOKAL] Pelanggan aktif (ID: $id) berhasil diarsipkan.',
      name: 'PelangganAktifOperasi',
    );
  }

  // ditambah: untuk menghapus semua pelanggan aktif secara permanen
  Future<void> hapusSemuaPelangganAktif() async {
    final db = await dbHelper.database;
    await db.delete('pelanggan_aktif');
    developer.log(
      '🗑️ [LOKAL] Semua pelanggan aktif telah dihapus permanen.',
      name: 'PelangganAktifOperasi',
    );
  }

  // ditambah: untuk mengarsipkan pelanggan yang sudah kadaluarsa
  Future<int> arsipkanPelangganKadaluarsa() async {
    final riwayatOperasi = RiwayatLanggananOperasi();
    final paketOperasi = PaketOperasi();

    // 1. Ambil semua pelanggan aktif yang belum diarsipkan
    final semuaPelanggan = await ambilSemuaPelangganAktif();
    final sekarang = DateTime.now();
    final pelangganKadaluarsa = semuaPelanggan
        .where((p) => p.tanggalBerakhir.isBefore(sekarang) && !p.isDeleted)
        .toList();

    if (pelangganKadaluarsa.isEmpty) {
      return 0; // Tidak ada yang diarsipkan
    }

    // 2. Proses setiap pelanggan kadaluarsa
    for (final pelanggan in pelangganKadaluarsa) {
      // Buat entri untuk riwayat
      final paket = await paketOperasi.getPaketById(pelanggan.idPaket);
      if (paket != null) {
        final riwayat = RiwayatLanggananModel(
          id: pelanggan.id,
          idPelanggan: pelanggan.idPelanggan,
          idPaket: pelanggan.idPaket,
          namaPaket: paket.nama,
          hargaPaket: paket.harga,
          durasiPaket: paket.durasi,
          tipeDurasiPaket: paket.tipe.name,
          tanggalMulai: pelanggan.tanggalMulai,
          tanggalBerakhir: pelanggan.tanggalBerakhir,
          status: pelanggan.status,
          diarsipkan: DateTime.now(),
          diperbarui: DateTime.now(),
        );
        await riwayatOperasi.tambahRiwayatLangganan(riwayat);
      }

      // Lakukan soft delete dengan memanggil fungsi arsipkan
      await arsipkanPelangganAktif(pelanggan.id);
    }

    developer.log(
      '🗂️ [LOKAL] ${pelangganKadaluarsa.length} pelanggan kadaluarsa telah diarsipkan.',
      name: 'PelangganAktifOperasi',
    );

    return pelangganKadaluarsa.length;
  }

  // ditambah: untuk mengarsipkan semua pelanggan aktif
  Future<int> arsipkanSemuaPelangganAktif() async {
    final semuaPelanggan = await ambilSemuaPelangganAktif();

    if (semuaPelanggan.isEmpty) {
      developer.log(
        'ℹ️ [LOKAL] Tidak ada pelanggan aktif untuk diarsipkan.',
        name: 'PelangganAktifOperasi',
      );
      return 0; // Tidak ada yang diarsipkan
    }

    for (final pelanggan in semuaPelanggan) {
      // Lakukan soft delete dengan memanggil fungsi arsipkan yang sudah ada
      await arsipkanPelangganAktif(pelanggan.id);
    }

    developer.log(
      '🗂️ [LOKAL] ${semuaPelanggan.length} pelanggan aktif telah diarsipkan.',
      name: 'PelangganAktifOperasi',
    );

    return semuaPelanggan.length;
  }
}
