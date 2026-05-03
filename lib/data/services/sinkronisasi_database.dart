// path: lib/data/services/sinkronisasi_database.dart
import 'dart:developer' as developer;
// diubah: Mengganti path import pesan_model.dart menjadi pesanan_model.dart
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:admin_wifi/model/kategori_model.dart';
import 'package:admin_wifi/model/kritik_saran_model.dart';
import 'package:admin_wifi/model/paket_model.dart';
import 'package:admin_wifi/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';
import 'package:admin_wifi/model/pesanan_model.dart';
import 'package:admin_wifi/model/riwayat_langganan_model.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:admin_wifi/utils/sync_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_wifi/data/operasi/dompet_operasi.dart';
import 'package:admin_wifi/data/operasi/kategori_operasi.dart';
import 'package:admin_wifi/data/operasi/kritik_saran_operasi.dart';
import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_aktif_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/data/operasi/pesan_operasi.dart';
import 'package:admin_wifi/data/operasi/riwayat_langganan_operasi.dart';
import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';

class LayananSinkronisasi {
  final SyncManager _syncManager = SyncManager();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final DompetOperasi _dompetOperasi = DompetOperasi();
  final KategoriOperasi _kategoriOperasi = KategoriOperasi();
  final PaketOperasi _paketOperasi = PaketOperasi();
  final PelangganOperasi _pelangganOperasi = PelangganOperasi();
  final PelangganAktifOperasi _pelangganAktifOperasi = PelangganAktifOperasi();
  final TransaksiOperasi _transaksiOperasi = TransaksiOperasi();
  final RiwayatLanggananOperasi _riwayatLanggananOperasi =
      RiwayatLanggananOperasi();
  final KritikSaranOperasi _kritikSaranOperasi = KritikSaranOperasi();
  final PesananOperasi _pesanOperasi = PesananOperasi();

  Future<void> sinkronisasiData() async {
    final waktuSinkronisasiTerakhir = await dapatkanWaktuSinkronisasiTerakhir();

    if (waktuSinkronisasiTerakhir.millisecondsSinceEpoch == 0) {
      await _sinkronisasiAwal();
    } else {
      // Implement incremental sync logic here
    }
  }

  Future<void> _sinkronisasiAwal() async {
    try {
      await Future.wait([
        _sinkronisasiKoleksi<DompetModel>(
          namaKoleksi: 'dompet',
          fromMap: (map) => DompetModel.fromMap(map),
          operasiBatch: (data) =>
              _dompetOperasi.sisipkanAtauPerbaruiBatch(data),
        ),
        _sinkronisasiKoleksi<KategoriModel>(
          namaKoleksi: 'kategori',
          fromMap: (map) => KategoriModel.fromMap(map),
          operasiBatch: (data) =>
              _kategoriOperasi.sisipkanAtauPerbaruiBatch(data),
        ),
        _sinkronisasiKoleksi<PaketModel>(
          namaKoleksi: 'paket',
          fromMap: (map) => PaketModel.fromMap(map),
          operasiBatch: (data) => _paketOperasi.sisipkanAtauPerbaruiBatch(data),
        ),
        _sinkronisasiKoleksi<PelangganModel>(
          namaKoleksi: 'pelanggan',
          fromMap: (map) => PelangganModel.fromMap(map),
          operasiBatch: (data) =>
              _pelangganOperasi.sisipkanAtauPerbaruiBatch(data),
        ),
        _sinkronisasiKoleksi<PelangganAktifModel>(
          namaKoleksi: 'pelanggan_aktif',
          fromMap: (map) => PelangganAktifModel.fromMap(map),
          operasiBatch: (data) =>
              _pelangganAktifOperasi.sisipkanAtauPerbaruiBatch(data),
        ),
        _sinkronisasiKoleksi<TransaksiModel>(
          namaKoleksi: 'transaksi',
          fromMap: (map) => TransaksiModel.fromMap(map),
          operasiBatch: (data) =>
              _transaksiOperasi.sisipkanAtauPerbaruiBatch(data),
        ),
        _sinkronisasiKoleksi<RiwayatLanggananModel>(
          namaKoleksi: 'riwayat_langganan',
          fromMap: (map) => RiwayatLanggananModel.fromMap(map),
          operasiBatch: (data) =>
              _riwayatLanggananOperasi.sisipkanAtauPerbaruiBatch(data),
        ),
        _sinkronisasiKoleksi<KritikSaranModel>(
          namaKoleksi: 'kritik_saran',
          fromMap: (map) => KritikSaranModel.fromMap(map),
          operasiBatch: (data) =>
              _kritikSaranOperasi.sisipkanAtauPerbaruiBatch(data),
        ),
        _sinkronisasiKoleksi<PesananModel>(
          namaKoleksi: 'pesan',
          fromMap: (map) => PesananModel.fromMap(map),
          operasiBatch: (data) => _pesanOperasi.sisipkanAtauPerbaruiBatch(data),
        ),
      ]);

      await tetapkanWaktuSinkronisasiTerakhir(DateTime.now());
    } catch (e, s) {
      // diubah: Mengganti print dengan developer.log untuk logging yang lebih baik
      developer.log(
        'Gagal melakukan sinkronisasi awal',
        name: 'LayananSinkronisasi',
        error: e,
        stackTrace: s,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<void> _sinkronisasiKoleksi<T>({
    required String namaKoleksi,
    required T Function(Map<String, dynamic>) fromMap,
    required Future<void> Function(List<T>) operasiBatch,
  }) async {
    final snapshot = await _firestore.collection(namaKoleksi).get();
    if (snapshot.docs.isNotEmpty) {
      final dataList = snapshot.docs.map((doc) => fromMap(doc.data())).toList();
      await operasiBatch(dataList);
    }
  }

  Future<DateTime> dapatkanWaktuSinkronisasiTerakhir() async {
    return await _syncManager.getLastSyncTimestamp();
  }

  Future<void> tetapkanWaktuSinkronisasiTerakhir(DateTime waktu) async {
    await _syncManager.setLastSyncTimestamp(waktu);
  }
}
