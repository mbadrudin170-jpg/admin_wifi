// path: lib/data/sync/unduh_data.dart

import 'package:admin_wifi/fitur/pengaturan/notifier/pengaturan_notifier.dart';
import 'package:admin_wifi/fitur/pesanan/notifier/pesanan_notifier.dart';
import 'package:admin_wifi/fitur/kategori/notifier/sub_kategori_notifier.dart';

import 'package:admin_wifi/fitur/versi_apk_user/notifier/versi_apk_user_notifier.dart';
import 'package:admin_wifi/db/supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:admin_wifi/fitur/dompet/model/dompet_model.dart';
import 'package:admin_wifi/fitur/dompet/notifier/dompet_notifier.dart';
import 'package:admin_wifi/fitur/kategori/model/kategori_model.dart';
import 'package:admin_wifi/fitur/kategori/notifier/kategori_notifier.dart';
import 'package:admin_wifi/fitur/kritik_saran/model/kritik_saran_model.dart';
import 'package:admin_wifi/fitur/kritik_saran/notifier/kritik_saran_notifier.dart';
import 'package:admin_wifi/fitur/paket/notifier/paket_notifier.dart';
import 'package:admin_wifi/fitur/pelanggan/notifier/pelanggan_notifier.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/notifer/pengguna_aktif_notifier.dart';
import 'package:admin_wifi/fitur/paket/model/paket_model.dart';
import 'package:admin_wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/fitur/pengaturan/model/pengaturan_model.dart';
import 'package:admin_wifi/fitur/pesanan/model/pesanan_model.dart';
import 'package:admin_wifi/fitur/kategori/model/sub_kategori_model.dart';
import 'package:admin_wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:admin_wifi/fitur/transaksi/notifier/transaksi_notifier.dart';
import 'package:admin_wifi/fitur/versi_apk_user/model/versi_apk_user_model.dart';
import 'package:admin_wifi/utils/sync_manager.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:share_global_saya/src/utils/parser_util.dart';

class LayananUnduhData {
  final SupabaseClient _supabase;
  final SyncManager _syncManager;

  // Global notifier (diakses lewat ProviderContainer terpisah, tanpa instance operasi)

  LayananUnduhData({SupabaseClient? supabase, SyncManager? syncManager})
    : _supabase = supabase ?? SupabaseKlien.instance.client,
      _syncManager = syncManager ?? SyncManager() {
    L.i(
      'LayananUnduhData berhasil diinisialisasi. Seluruh operasi database lokal dan referensi Supabase telah siap digunakan untuk sinkronisasi masuk.',
    );
  }

  Future<void> unduhSemuaData() async {
    L.i(
      'Memulai prosedur orkestrasi unduh data massal. Sistem akan menjalankan permintaan paralel untuk 11 kategori data berbeda guna mempercepat proses sinkronisasi.',
    );
    final stopwatch = Stopwatch()..start();

    try {
      await Future.wait([
        unduhDataPengaturan(),
        unduhDataDompet(),
        unduhDataKategori(),
        unduhDataPaket(),
        unduhDataPelanggan(),
        unduhDataPelangganAktif(),
        unduhDataTransaksi(),
        unduhDataKritikSaran(),
        unduhDataPesanan(),
        unduhDataSubKategori(),
        unduhDataVersiApkUser(),
      ]);

      stopwatch.stop();
      L.i(
        'Prosedur unduh data massal selesai sepenuhnya. Total durasi eksekusi: ${stopwatch.elapsed.inMilliseconds} ms. Seluruh data lokal kini sinkron dengan server.',
      );
    } catch (e, s) {
      L.e(
        'Kegagalan kritis terdeteksi selama prosedur unduh massal. Salah satu atau lebih permintaan paralel gagal diselesaikan. Error: $e $s',
      );
      rethrow;
    }
  }

  Future<void> unduhDataPengaturan() async {
    L.i('Memulai pengecekan sinkronisasi untuk koleksi: [PENGATURAN]');
    try {
      final waktuUnduhTerakhir = await _syncManager.getTerakhirUnduh();
      L.i('Timestamp sinkronisasi lokal terakhir: $waktuUnduhTerakhir');

      final rows = await _supabase.from('pengaturan').select().limit(1);

      if (rows.isNotEmpty) {
        final data = Map<String, dynamic>.from(rows.first as Map);
        if (data.containsKey('diperbarui')) {
          final fieldValue = data['diperbarui'];
          L.i(
            'Mendapatkan metadata "diperbarui" dari server. Tipe data terdeteksi: ${fieldValue.runtimeType}',
          );

          final waktuPembaruanServer = ParserUtil.parseDateTime(
            fieldValue,
          )?.toLocal();
          if (waktuPembaruanServer == null) {
            L.e(
              'Inkompatibilitas Tipe Data: Field "diperbarui" di Supabase adalah ${fieldValue.runtimeType}, namun sistem mengharapkan ISO-8601 string. Sinkronisasi dibatalkan untuk mencegah crash.',
            );
            return;
          }

          L.i('Waktu modifikasi server: $waktuPembaruanServer');

          if (waktuPembaruanServer.isAfter(waktuUnduhTerakhir)) {
            L.i(
              'Data server lebih baru. Memulai pembaruan database SQLite untuk model PengaturanModel.',
            );
            final pengaturan = PengaturanModel.fromSupabase(data);
            await pengaturanNotifierGlobal.simpanAtauPerbaruiPengaturan(pengaturan);
            L.i('Update Pengaturan lokal berhasil disimpan.');
          } else {
            L.i(
              'Data pengaturan lokal sudah sesuai dengan versi server terbaru.',
            );
          }
        } else {
          L.w(
            'Dokumen pengaturan ditemukan, namun tidak memiliki field "diperbarui". Melewati pengecekan waktu.',
          );
        }
      } else {
        L.w('Dokumen "pengaturan" tidak ditemukan di server Supabase.');
      }
    } catch (e, s) {
      L.e('Terjadi kesalahan saat sinkronisasi data Pengaturan. Error: $e $s');
    }
  }

  // Wrapper untuk Koleksi Lainnya
  Future<void> unduhDataDompet() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<DompetModel>(
      namaKoleksi: 'dompet',
      waktuUnduhTerakhir: waktu,
      fromSupabase: (map) => DompetModel.fromSupabase(map),
      operasiBatch: (data) =>
          dompetNotifierGlobal.sisipkanAtauPerbaruiBatch(data),
    );
  }

  Future<void> unduhDataKategori() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<KategoriModel>(
      namaKoleksi: 'kategori',
      waktuUnduhTerakhir: waktu,
      fromSupabase: (map) => KategoriModel.fromSupabase(map),
      operasiBatch: (data) =>
          kategoriNotifierGlobal.sisipkanAtauPerbaruiBatch(data),
    );
  }

  Future<void> unduhDataPaket() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<PaketModel>(
      namaKoleksi: 'paket',
      waktuUnduhTerakhir: waktu,
      fromSupabase: (map) => PaketModel.fromSupabase(map),
      operasiBatch: (data) => paketNotifierGlobal.tambahBatch(data),
    );
  }

  Future<void> unduhDataPelanggan() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<PelangganModel>(
      namaKoleksi: 'pelanggan',
      waktuUnduhTerakhir: waktu,
      fromSupabase: (map) => PelangganModel.fromSupabase(map),
      operasiBatch: (data) => pelangganNotifierGlobal.tambahBatch(data),
    );
  }

  Future<void> unduhDataPelangganAktif() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<PelangganAktifModel>(
      namaKoleksi: 'pelanggan_aktif',
      waktuUnduhTerakhir: waktu,
      fromSupabase: (map) => PelangganAktifModel.fromSupabase(map),
      operasiBatch: (data) => penggunaAktifNotifierGlobal.tambahBatch(data),
    );
  }

  Future<void> unduhDataTransaksi() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<TransaksiModel>(
      namaKoleksi: 'transaksi',
      waktuUnduhTerakhir: waktu,
      fromSupabase: (map) => TransaksiModel.fromSupabase(map),
      operasiBatch: (data) =>
          transaksiNotifierGlobal.sisipkanAtauPerbaruiBatch(data),
    );
  }

  Future<void> unduhDataKritikSaran() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<KritikSaranModel>(
      namaKoleksi: 'kritik_saran',
      waktuUnduhTerakhir: waktu,
      fromSupabase: (map) => KritikSaranModel.fromSupabase(map),
      operasiBatch: (data) =>
          kritikSaranNotifierGlobal.sisipkanAtauPerbaruiBatch(data),
    );
  }

  Future<void> unduhDataPesanan() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<PesananModel>(
      namaKoleksi: 'pesan',
      waktuUnduhTerakhir: waktu,
      fromSupabase: (map) => PesananModel.fromSupabase(map),
      operasiBatch: (data) => pesananNotifierGlobal.sisipkanAtauPerbaruiBatch(data),
    );
  }

  Future<void> unduhDataSubKategori() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<SubKategoriModel>(
      namaKoleksi: 'sub_kategori',
      waktuUnduhTerakhir: waktu,
      fromSupabase: (map) => SubKategoriModel.fromSupabase(map),
      operasiBatch: (data) =>
          subKategoriNotifierGlobal.sisipkanAtauPerbaruiBatch(data),
    );
  }

  Future<void> unduhDataVersiApkUser() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<VersiApkUserModel>(
      namaKoleksi: 'versi_apk_user',
      waktuUnduhTerakhir: waktu,
      fromSupabase: (map) => VersiApkUserModel.fromSupabase(map),
      operasiBatch: (data) =>
          versiApkUserNotifierGlobal.sisipkanAtauPerbaruiBatch(data),
    );
  }

  Future<void> sinkronisasiKoleksi<T>({
    required String namaKoleksi,
    required DateTime waktuUnduhTerakhir,
    required T Function(Map<String, dynamic> data) fromSupabase,
    required Future<void> Function(List<T>) operasiBatch,
  }) async {
    L.i(
      'Sinkronisasi Koleksi: Memeriksa [$namaKoleksi] untuk data baru sejak $waktuUnduhTerakhir.',
    );
    try {
      final rows = await _supabase
          .from(namaKoleksi)
          .select()
          .gt('diperbarui', waktuUnduhTerakhir.toUtc().toIso8601String());

      if (rows.isNotEmpty) {
        L.i(
          'Ditemukan ${rows.length} dokumen baru/diperbarui di koleksi [$namaKoleksi]. Memulai parsing data.',
        );

        final List<T> dataList = [];
        for (final row in rows) {
          try {
            final data = Map<String, dynamic>.from(row as Map);
            dataList.add(fromSupabase(data));
          } catch (e, s) {
            L.e(
              'Gagal memproses dokumen individual pada koleksi $namaKoleksi. Error: $e $s',
            );
          }
        }

        if (dataList.isNotEmpty) {
          L.i(
            'Mengirim ${dataList.length} item valid ke operasi batch database lokal.',
          );
          await operasiBatch(dataList);
          L.i('Sinkronisasi masuk untuk [$namaKoleksi] berhasil diselesaikan.');
        } else {
          L.w(
            'Pengecekan selesai: Tidak ada data valid yang dapat disimpan ke lokal dari [$namaKoleksi].',
          );
        }
      } else {
        L.i(
          'Hasil Pengecekan: Koleksi [$namaKoleksi] sudah sinkron dengan server.',
        );
      }
    } catch (e, s) {
      L.e(
        'Kegagalan pada prosedur sinkronisasi koleksi: $namaKoleksi Error: $e $s',
      );
    }
  }
}
