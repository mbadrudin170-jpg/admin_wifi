// path: lib/data/services/sinkronisasi_database.dart
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:admin_wifi/model/kategori_model.dart';
import 'package:admin_wifi/model/kritik_saran_model.dart';
import 'package:admin_wifi/model/paket_model.dart';
import 'package:admin_wifi/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';
import 'package:admin_wifi/model/pesan_model.dart';
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

// diubah: nama kelas menjadi lebih deskriptif dan konsisten dengan penamaan layanan lain.
class LayananSinkronisasi {
  final SyncManager _syncManager = SyncManager();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ditambahkan: Instance dari semua kelas operasi untuk mengakses metode database.
  final DompetOperasi _dompetOperasi = DompetOperasi();
  final KategoriOperasi _kategoriOperasi = KategoriOperasi();
  final PaketOperasi _paketOperasi = PaketOperasi();
  final PelangganOperasi _pelangganOperasi = PelangganOperasi();
  final PelangganAktifOperasi _pelangganAktifOperasi = PelangganAktifOperasi();
  final TransaksiOperasi _transaksiOperasi = TransaksiOperasi();
  final RiwayatLanggananOperasi _riwayatLanggananOperasi =
      RiwayatLanggananOperasi();
  final KritikSaranOperasi _kritikSaranOperasi = KritikSaranOperasi();
  final PesanOperasi _pesanOperasi = PesanOperasi();

  // Fungsi utama untuk mengorkestrasi proses sinkronisasi.
  Future<void> sinkronisasiData() async {
    final waktuSinkronisasiTerakhir = await dapatkanWaktuSinkronisasiTerakhir();

    // ditambahkan: Logika untuk memeriksa apakah ini sinkronisasi pertama kali.
    // Jika timestamp adalah epoch (0), berarti ini sinkronisasi awal.
    if (waktuSinkronisasiTerakhir.millisecondsSinceEpoch == 0) {
      await _sinkronisasiAwal();
    } else {
      // TODO: Implementasikan logika sinkronisasi inkremental di sini
      // untuk data yang berubah setelah `waktuSinkronisasiTerakhir`.
    }
  }

  // ditambahkan: Fungsi privat untuk menangani sinkronisasi penuh pertama kali.
  Future<void> _sinkronisasiAwal() async {
    try {
      // Menjalankan semua sinkronisasi koleksi secara paralel.
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
        _sinkronisasiKoleksi<PesanModel>(
          namaKoleksi: 'pesan',
          fromMap: (map) => PesanModel.fromMap(map),
          operasiBatch: (data) => _pesanOperasi.sisipkanAtauPerbaruiBatch(data),
        ),
      ]);

      // Jika semua berhasil, perbarui timestamp.
      await tetapkanWaktuSinkronisasiTerakhir(DateTime.now());
    } catch (e) {
      // Error handling jika terjadi kegagalan saat sinkronisasi.
      // Timestamp tidak akan diperbarui agar proses bisa diulang.
      print('Gagal melakukan sinkronisasi awal: $e');
      // Opsional: Lemparkan kembali error untuk ditangani oleh pemanggil.
      rethrow;
    }
  }

  // ditambahkan: Fungsi generik untuk menghindari duplikasi kode sinkronisasi.
  // Ini adalah implementasi dari saran refaktorisasi di README.
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

  // Fungsi untuk mendapatkan waktu sinkronisasi terakhir dari local storage.
  Future<DateTime> dapatkanWaktuSinkronisasiTerakhir() async {
    return await _syncManager.getLastSyncTimestamp();
  }

  // Fungsi untuk memperbarui waktu sinkronisasi terakhir di local storage.
  Future<void> tetapkanWaktuSinkronisasiTerakhir(DateTime waktu) async {
    await _syncManager.setLastSyncTimestamp(waktu);
  }
}
