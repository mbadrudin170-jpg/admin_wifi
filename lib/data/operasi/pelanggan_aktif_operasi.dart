// path: lib/data/operasi/pelanggan_aktif_operasi.dart
// diubah: Direfactor untuk dependency injection NotifikasiServis agar mudah di-test.

import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/data/operasi/riwayat_langganan_operasi.dart';
import 'package:admin_wifi/model/riwayat_langganan_model.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:developer' as developer;
import 'package:uuid/uuid.dart';

import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/services/notifikasi_servis.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/whatsapp/info_paket.dart';

const uuid = Uuid();

class PelangganAktifOperasi {
  final dbHelper = DatabaseHelper.instance;
  late final NotifikasiServis notifikasiServis;
  final PelangganOperasi _pelangganOperasi = PelangganOperasi();

  // ditambah: Konstruktor untuk dependency injection.
  PelangganAktifOperasi({NotifikasiServis? notifikasiServis}) {
    this.notifikasiServis = notifikasiServis ?? NotifikasiServis();
  }

  Future<PelangganAktifModel> createPelangganAktif(
    PelangganAktifModel pelangganAktif,
  ) async {
    final db = await dbHelper.database;
    final pelangganUntukDisimpan = pelangganAktif.copyWith(
      id: pelangganAktif.id.isEmpty ? uuid.v4() : pelangganAktif.id,
      diperbarui: DateTime.now(),
    );
    final data = pelangganUntukDisimpan.toMap();
    await db.insert(
      'pelanggan_aktif',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _jadwalkanNotifikasi(pelangganUntukDisimpan);
    await PesanInfoPaket.kirimRincianPaket(pelangganUntukDisimpan);
    developer.log(
      '✅ [LOKAL] Pelanggan aktif (ID: ${pelangganUntukDisimpan.id}) berhasil dibuat.',
    );
    return pelangganUntukDisimpan;
  }

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

  Future<void> _jadwalkanNotifikasi(PelangganAktifModel pelangganAktif) async {
    final pelanggan = await _pelangganOperasi.getPelangganById(
      pelangganAktif.idPelanggan,
    );
    final namaPelanggan = pelanggan?.nama ?? 'Tanpa Nama';

    await notifikasiServis.batalNotifikasi(pelangganAktif.id.hashCode);
    await notifikasiServis.batalNotifikasi((pelangganAktif.id.hashCode + 1));

    final jadwalNotifikasiH1 = pelangganAktif.tanggalBerakhir.subtract(
      const Duration(days: 1),
    );
    if (jadwalNotifikasiH1.isAfter(DateTime.now())) {
      await notifikasiServis.jadwalNotifikasi(
        id: pelangganAktif.id.hashCode,
        title: 'Paket Akan Segera Berakhir',
        body: 'Paket untuk pelanggan $namaPelanggan akan berakhir besok.',
        jadwal: jadwalNotifikasiH1,
      );
    }

    final jadwalNotifikasiH3 = pelangganAktif.tanggalBerakhir.subtract(
      const Duration(days: 3),
    );
    if (jadwalNotifikasiH3.isAfter(DateTime.now())) {
      await notifikasiServis.jadwalNotifikasi(
        id: (pelangganAktif.id.hashCode + 1),
        title: 'Pengingat Paket',
        body:
            'Paket untuk pelanggan $namaPelanggan akan berakhir dalam 3 hari.',
        jadwal: jadwalNotifikasiH3,
      );
    }
  }

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
    final pelangganDiarsipkan = pelangganAktif.copyWith(
      isDeleted: true,
      diarsipkan: DateTime.now(),
    );
    await db.update(
      'pelanggan_aktif',
      pelangganDiarsipkan.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
    await notifikasiServis.batalNotifikasi(id.hashCode);
    await notifikasiServis.batalNotifikasi((id.hashCode + 1));
    developer.log(
      '✅ [LOKAL] Pelanggan aktif (ID: $id) berhasil diarsipkan.',
      name: 'PelangganAktifOperasi',
    );
  }

  Future<void> hapusPelangganYangDiArsipkan() async {
    final db = await dbHelper.database;
    final batasWaktu = DateTime.now().subtract(const Duration(days: 30));
    final List<Map<String, dynamic>> pelangganKadaluarsa = await db.query(
      'pelanggan_aktif',
      where: 'diarsipkan IS NOT NULL AND diarsipkan < ?',
      whereArgs: [batasWaktu.toIso8601String()],
    );
    if (pelangganKadaluarsa.isEmpty) {
      developer.log(
        'ℹ️ [LOKAL] Tidak ada pelanggan aktif yang diarsipkan lebih dari 30 hari untuk dihapus.',
        name: 'PelangganAktifOperasi',
      );
      return;
    }
    final idsUntukDihapus = pelangganKadaluarsa
        .map((map) => map['id'] as String)
        .toList();
    final count = await db.delete(
      'pelanggan_aktif',
      where: 'id IN (${List.filled(idsUntukDihapus.length, '?').join(',')})',
      whereArgs: idsUntukDihapus,
    );
    developer.log(
      '🧹 [LOKAL] $count pelanggan aktif yang diarsipkan lebih dari 30 hari telah dihapus permanen.',
      name: 'PelangganAktifOperasi',
    );
  }

  Future<void> hapusSemuaPelangganAktif() async {
    final db = await dbHelper.database;
    await db.delete('pelanggan_aktif');
    developer.log(
      '🗑️ [LOKAL] Semua pelanggan aktif telah dihapus permanen.',
      name: 'PelangganAktifOperasi',
    );
  }

  // diubah: Menambahkan snapshot jumlahPoin saat membuat riwayat.
  Future<int> arsipkanPelangganKadaluarsa() async {
    final riwayatOperasi = RiwayatLanggananOperasi();
    final paketOperasi = PaketOperasi();
    final semuaPelanggan = await ambilSemuaPelangganAktif();
    final sekarang = DateTime.now();
    final pelangganKadaluarsa = semuaPelanggan
        .where((p) => p.tanggalBerakhir.isBefore(sekarang) && !p.isDeleted)
        .toList();
    if (pelangganKadaluarsa.isEmpty) {
      return 0;
    }
    for (final pelanggan in pelangganKadaluarsa) {
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
          jumlahPoinDiperoleh: paket.jumlahPoin, // ditambahkan: snapshot poin dari paket
          tanggalMulai: pelanggan.tanggalMulai,
          tanggalBerakhir: pelanggan.tanggalBerakhir,
          status: pelanggan.status,
          diarsipkan: DateTime.now(),
          diperbarui: DateTime.now(),
        );
        await riwayatOperasi.tambahRiwayatLangganan(riwayat);
      }
      await arsipkanPelangganAktif(pelanggan.id);
    }
    developer.log(
      '🗂️ [LOKAL] ${pelangganKadaluarsa.length} pelanggan kadaluarsa telah diarsipkan.',
      name: 'PelangganAktifOperasi',
    );
    return pelangganKadaluarsa.length;
  }

  Future<int> arsipkanSemuaPelangganAktif() async {
    final semuaPelanggan = await ambilSemuaPelangganAktif();
    if (semuaPelanggan.isEmpty) {
      developer.log(
        'ℹ️ [LOKAL] Tidak ada pelanggan aktif untuk diarsipkan.',
        name: 'PelangganAktifOperasi',
      );
      return 0;
    }
    for (final pelanggan in semuaPelanggan) {
      await arsipkanPelangganAktif(pelanggan.id);
    }
    developer.log(
      '🗂️ [LOKAL] ${semuaPelanggan.length} pelanggan aktif telah diarsipkan.',
      name: 'PelangganAktifOperasi',
    );
    return semuaPelanggan.length;
  }
}
