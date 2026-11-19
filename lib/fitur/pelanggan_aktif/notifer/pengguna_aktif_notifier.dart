// path: lib/fitur/pelanggan_aktif/notifer/pengguna_aktif_notifier.dart

import 'package:admin_wifi/db/operasi_sqlite.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/state/pelanggan_aktif_state.dart';
import 'package:admin_wifi/services/notifikasi/notifikasi_servis.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:uuid/uuid.dart';

part 'pengguna_aktif_notifier.g.dart';

@Riverpod(keepAlive: true)
class PenggunaAktifNotifier extends _$PenggunaAktifNotifier {
  final NotifikasiServis _notifikasiServis = NotifikasiServis();
  final Uuid _uuid = const Uuid();

  @override
  Future<PelangganAktifState> build() async {
    L.i('Memuat daftar pelanggan aktif dari database');
    return _ambilSemua();
  }

  Future<void> muatUlang() async {
    try {
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal memuat ulang pelanggan aktif: $e\n$s');
      rethrow;
    }
  }

  Future<PelangganAktifState> _ambilSemua() async {
    final operasiSqlite = ref.read(operasiSqliteProvider);
    final maps = await operasiSqlite.ambil(
      PelangganAktifSkema.tabel,
      where: '${PelangganAktifSkema.isDeleted} = ?',
      whereArgs: const [0],
    );
    final daftar = maps.map(PelangganAktifModel.fromSqlite).toList();
    return PelangganAktifState(
      listPelangganAktif: daftar,
      jumlahPelangganAktif: daftar.length,
    );
  }

  Future<PelangganAktifModel> tambah(PelangganAktifModel model) async {
    try {
      final idBaru = model.id.isEmpty ? _uuid.v4() : model.id;
      final pelangganUntukDisimpan = model.copyWith(
        id: idBaru,
        diperbarui: DateTime.now().toUtc(),
      );

      final operasiSqlite = ref.read(operasiSqliteProvider);
      await operasiSqlite.tambah(
        PelangganAktifSkema.tabel,
        pelangganUntukDisimpan.toSqlite(),
      );

      await _jadwalkanNotifikasi(pelangganUntukDisimpan);

      state = AsyncValue.data(await _ambilSemua());
      return pelangganUntukDisimpan;
    } catch (e, s) {
      L.e('Gagal menambahkan pelanggan aktif: $e\n$s');
      rethrow;
    }
  }

  Future<void> tambahBatch(List<PelangganAktifModel> models) async {
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final data = models.map((item) => item.toSqlite()).toList();
      await operasiSqlite.tambahBatch(PelangganAktifSkema.tabel, data);
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal menambahkan batch pelanggan aktif: $e\n$s');
      rethrow;
    }
  }

  Future<PelangganAktifModel> ubah(PelangganAktifModel model) async {
    try {
      final pelangganUntukDisimpan = model.copyWith(
        diperbarui: DateTime.now().toUtc(),
      );

      final operasiSqlite = ref.read(operasiSqliteProvider);
      await operasiSqlite.ubah(
        PelangganAktifSkema.tabel,
        pelangganUntukDisimpan.toSqlite(),
        id: pelangganUntukDisimpan.id,
      );

      await _jadwalkanNotifikasi(pelangganUntukDisimpan);

      state = AsyncValue.data(await _ambilSemua());
      return pelangganUntukDisimpan;
    } catch (e, s) {
      L.e('Gagal mengubah pelanggan aktif: $e\n$s');
      rethrow;
    }
  }

  Future<void> hapus(String id) async {
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final maps = await operasiSqlite.ambil(
        PelangganAktifSkema.tabel,
        where: '${PelangganAktifSkema.id} = ?',
        whereArgs: [id],
      );
      if (maps.isEmpty) {
        L.i('Pelanggan aktif ID: $id tidak ditemukan, tidak dapat menghapus');
        return;
      }
      final pelangganAktif = PelangganAktifModel.fromSqlite(maps.first);

      final now = DateTime.now().toUtc();
      final pelangganDiarsipkan = pelangganAktif.copyWith(
        isDeleted: true,
        diarsipkan: now,
        diperbarui: now,
      );
      await operasiSqlite.ubah(
        PelangganAktifSkema.tabel,
        pelangganDiarsipkan.toSqlite(),
        id: id,
      );

      await _notifikasiServis.batalNotifikasi(id.hashCode);
      await _notifikasiServis.batalNotifikasi((id.hashCode + 1));
      await _notifikasiServis.batalNotifikasi((id.hashCode + 2));

      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal menghapus pelanggan aktif: $e\n$s');
      rethrow;
    }
  }

  Future<void> _jadwalkanNotifikasi(PelangganAktifModel pelangganAktif) async {
    try {
      L.i(
        'Menjadwalkan notifikasi untuk pelanggan aktif ID: ${pelangganAktif.id}',
      );

      final operasiSqlite = ref.read(operasiSqliteProvider);
      final pelangganMaps = await operasiSqlite.ambil(
        'pelanggan',
        where: 'id = ?',
        whereArgs: [pelangganAktif.idPelanggan],
      );
      final namaPelanggan = pelangganMaps.isNotEmpty
          ? (pelangganMaps.first['nama'] as String? ?? 'Tanpa Nama')
          : 'Tanpa Nama';

      await _notifikasiServis.batalNotifikasi(pelangganAktif.id.hashCode);
      await _notifikasiServis.batalNotifikasi((pelangganAktif.id.hashCode + 1));
      await _notifikasiServis.batalNotifikasi((pelangganAktif.id.hashCode + 2));

      final jadwalTepatWaktu = pelangganAktif.tanggalBerakhir;
      if (jadwalTepatWaktu.isAfter(DateTime.now())) {
        await _notifikasiServis.jadwalNotifikasi(
          id: (pelangganAktif.id.hashCode + 2),
          title: 'Masa Aktif Habis!',
          body: 'Paket WiFi untuk $namaPelanggan telah berakhir sekarang.',
          jadwal: jadwalTepatWaktu,
        );
      }

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

      final jadwalNotifikasiH3 = pelangganAktif.tanggalBerakhir.subtract(
        const Duration(days: 3),
      );
      if (jadwalNotifikasiH3.isAfter(DateTime.now())) {
        await _notifikasiServis.jadwalNotifikasi(
          id: (pelangganAktif.id.hashCode + 1),
          title: 'Pengingat Paket',
          body:
              'Paket untuk pelanggan $namaPelanggan akan berakhir dalam 3 hari.',
          jadwal: jadwalNotifikasiH3,
        );
      }
    } catch (e, st) {
      L.e(
        'Gagal menjadwalkan notifikasi untuk pelanggan aktif ID: ${pelangganAktif.id} Error: $e $st',
      );
    }
  }
}
