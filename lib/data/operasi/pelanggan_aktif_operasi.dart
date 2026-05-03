// path: lib/data/operasi/pelanggan_aktif_operasi.dart
// diubah: Menghapus logika SyncStatus dan menyederhanakan operasi CRUD.
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // diubah: Menghapus pemeriksaan status untuk unggah
  Future<void> unggahKeFirebase(PelangganAktifModel pelanggan) async {
    final firestore = FirebaseFirestore.instance;
    final docRef = firestore.collection('pelanggan_aktif').doc(pelanggan.id);

    // diubah: Menggunakan toMap() dari model, yang seharusnya tidak lagi mengandung sync_status
    final dataToUpload = pelanggan.toMap();

    try {
      await docRef.set(dataToUpload);
      developer.log(
        '🚀 [FIREBASE] Berhasil mengunggah pelanggan aktif (ID: ${pelanggan.id}).',
        name: 'PelangganAktifOperasi',
      );
    } catch (e) {
      developer.log(
        '🔥 [FIREBASE] Gagal mengunggah pelanggan aktif (ID: ${pelanggan.id}): $e',
        name: 'PelangganAktifOperasi',
        error: e,
      );
      rethrow;
    }
  }

  // dihapus: Fungsi tandaiSudahSinkron tidak diperlukan lagi.

  // diubah: Menyederhanakan proses unduh tanpa SyncStatus
  Future<int> unduhPelangganAktif(PelangganAktifModel pelangganAktif) async {
    final db = await dbHelper.database;

    final data = pelangganAktif.toMap();

    final result = await db.insert(
      'pelanggan_aktif',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await _jadwalkanNotifikasi(pelangganAktif);
    // Note: Consider if sending WhatsApp message is appropriate for a download action.
    // await PesanInfoPaket.kirimRincianPaket(pelangganAktif);

    developer.log(
      '✅ [LOKAL] Pelanggan aktif (ID: ${pelangganAktif.id}) berhasil diunduh dan disimpan.',
    );
    return result;
  }

  // diubah: Menyederhanakan pembuatan tanpa SyncStatus
  Future<int> createPelangganAktif(PelangganAktifModel pelangganAktif) async {
    final db = await dbHelper.database;

    // diubah: Langsung gunakan data dari model tanpa mengubah status
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

  // diubah: Mengambil semua pelanggan aktif tanpa filter status
  Future<List<PelangganAktifModel>> ambilSemuaPelangganAktif() async {
    final db = await dbHelper.database;
    // dihapus: Where clause untuk sync_status tidak lagi diperlukan
    final List<Map<String, dynamic>> maps = await db.query('pelanggan_aktif');
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

  // diubah: Menyederhanakan pembaruan tanpa SyncStatus
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

  // diubah: Menggunakan hard delete (hapus permanen)
  Future<void> hapusPelangganAktif(String id) async {
    final db = await dbHelper.database;
    // diubah: dari update (soft delete) menjadi delete (hard delete)
    await db.delete('pelanggan_aktif', where: 'id = ?', whereArgs: [id]);

    developer.log(
      '✅ [LOKAL] Pelanggan aktif (ID: $id) berhasil dihapus permanen.',
    );
    // Batalkan notifikasi terkait
    await _notifikasiServis.batalNotifikasi(id.hashCode);
    await _notifikasiServis.batalNotifikasi((id.hashCode + 1));
  }

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

  Future<void> hapusSemuaPelangganAktif() async {
    final db = await dbHelper.database;
    await db.delete('pelanggan_aktif');
  }

  Future<int> hapusPelangganKadaluarsa() async {
    final db = await dbHelper.database;
    return await db.delete(
      'pelanggan_aktif',
      where: 'tanggalBerakhir < ?',
      whereArgs: [DateTime.now().toIso8601String()],
    );
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
}
