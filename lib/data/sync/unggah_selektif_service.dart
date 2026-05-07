// path: lib/data/sync/unggah_selektif_service.dart
import 'package:admin_wifi/data/operasi/dompet_operasi.dart';
import 'package:admin_wifi/data/operasi/kategori_operasi.dart';
import 'package:admin_wifi/data/operasi/kritik_saran_operasi.dart';
import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_aktif_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/data/operasi/pengaturan_operasi.dart';
import 'package:admin_wifi/data/operasi/pesanan_operasi.dart';
import 'package:admin_wifi/data/operasi/riwayat_langganan_operasi.dart';
import 'package:admin_wifi/data/operasi/status_unggah_operasi.dart';
import 'package:admin_wifi/data/operasi/sub_kategori_operasi.dart';
import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
import 'package:admin_wifi/data/operasi/versi_apk_user_operasi.dart';
import 'package:admin_wifi/model/enum/nama_tabel_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// [UnggahSelektifService] bertanggung jawab untuk menangani logika unggah
/// data yang perubahannya telah dicatat di tabel `status_unggah`.
class UnggahSelektifService {
  final FirebaseFirestore _firestore;
  final StatusUnggahOperasi _statusOperasi;
  final DompetOperasi _dompetOperasi;
  final KategoriOperasi _kategoriOperasi;
  final KritikSaranOperasi _kritikSaranOperasi;
  final PaketOperasi _paketOperasi;
  final PelangganAktifOperasi _pelangganAktifOperasi;
  final PelangganOperasi _pelangganOperasi;
  final PengaturanOperasi _pengaturanOperasi;
  final PesananOperasi _pesananOperasi;
  final RiwayatLanggananOperasi _riwayatLanggananOperasi;
  final SubKategoriOperasi _subKategoriOperasi;
  final TransaksiOperasi _transaksiOperasi;
  final VersiApkUserOperasi _versiApkUserOperasi;


  // diubah: Menggunakan konstruktor untuk Dependency Injection
  UnggahSelektifService({
    FirebaseFirestore? firestore,
    StatusUnggahOperasi? statusOperasi,
    DompetOperasi? dompetOperasi,
    KategoriOperasi? kategoriOperasi,
    KritikSaranOperasi? kritikSaranOperasi,
    PaketOperasi? paketOperasi,
    PelangganAktifOperasi? pelangganAktifOperasi,
    PelangganOperasi? pelangganOperasi,
    PengaturanOperasi? pengaturanOperasi,
    PesananOperasi? pesananOperasi,
    RiwayatLanggananOperasi? riwayatLanggananOperasi,
    SubKategoriOperasi? subKategoriOperasi,
    TransaksiOperasi? transaksiOperasi,
    VersiApkUserOperasi? versiApkUserOperasi,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _statusOperasi = statusOperasi ?? StatusUnggahOperasi(),
        _dompetOperasi = dompetOperasi ?? DompetOperasi(),
        _kategoriOperasi = kategoriOperasi ?? KategoriOperasi(),
        _kritikSaranOperasi = kritikSaranOperasi ?? KritikSaranOperasi(),
        _paketOperasi = paketOperasi ?? PaketOperasi(),
        _pelangganAktifOperasi =
            pelangganAktifOperasi ?? PelangganAktifOperasi(),
        _pelangganOperasi = pelangganOperasi ?? PelangganOperasi(),
        _pengaturanOperasi = pengaturanOperasi ?? PengaturanOperasi(),
        _pesananOperasi = pesananOperasi ?? PesananOperasi(),
        _riwayatLanggananOperasi =
            riwayatLanggananOperasi ?? RiwayatLanggananOperasi(),
        _subKategoriOperasi = subKategoriOperasi ?? SubKategoriOperasi(),
        _transaksiOperasi = transaksiOperasi ?? TransaksiOperasi(),
        _versiApkUserOperasi = versiApkUserOperasi ?? VersiApkUserOperasi();


  Future<void> unggahPerubahanTertunda() async {
    developer.log('Memulai pengecekan perubahan tertunda untuk diunggah.',
        name: 'UnggahSelektifService');

    final daftarStatus = await _statusOperasi.ambilSemuaStatusUnggah();
    final perluDiunggah =
        daftarStatus.where((s) => s.status && s.ids.isNotEmpty).toList();

    if (perluDiunggah.isEmpty) {
      developer.log('Tidak ada data yang perlu diunggah secara selektif.',
          name: 'UnggahSelektifService');
      return;
    }

    developer.log(
        'Ditemukan ${perluDiunggah.length} tabel dengan perubahan yang perlu diunggah.',
        name: 'UnggahSelektifService');

    for (final status in perluDiunggah) {
      try {
        bool berhasil = false;
        switch (status.tabel) {
          case NamaTabel.dompet:
            berhasil = await _unggahDompet(status.ids);
            break;
          case NamaTabel.transaksi:
            berhasil = await _unggahTransaksi(status.ids);
            break;
          case NamaTabel.versiApkUser:
            berhasil = await _unggahVersiApkUser(status.ids);
            break;
          case NamaTabel.pengaturan:
            berhasil = await _unggahPengaturan(status.ids);
            break;
          case NamaTabel.kategori:
            berhasil = await _unggahKategori(status.ids);
            break;
          case NamaTabel.subKategori:
            berhasil = await _unggahSubKategori(status.ids);
            break;
          case NamaTabel.paket:
            berhasil = await _unggahPaket(status.ids);
            break;
          case NamaTabel.pelanggan:
            berhasil = await _unggahPelanggan(status.ids);
            break;
          case NamaTabel.pelangganAktif:
            berhasil = await _unggahPelangganAktif(status.ids);
            break;
          case NamaTabel.kritikSaran:
            berhasil = await _unggahKritikSaran(status.ids);
            break;
          case NamaTabel.riwayatLangganan:
            berhasil = await _unggahRiwayatLangganan(status.ids);
            break;
          case NamaTabel.pesanan:
            berhasil = await _unggahPesanan(status.ids);
            break;
          default:
            developer.log(
                'Tipe tabel ${status.tabel} tidak memiliki handler unggah.',
                name: 'UnggahSelektifService');
        }

        if (berhasil) {
          developer.log(
              'Unggah untuk tabel ${status.tabel} berhasil, mereset status.',
              name: 'UnggahSelektifService');
          await _statusOperasi.resetStatus(status.tabel);
        }
      } catch (e, stackTrace) {
        developer.log(
          'Gagal memproses unggahan untuk tabel ${status.tabel}.',
          name: 'UnggahSelektifService',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }

    developer.log('Proses unggah selektif selesai.',
        name: 'UnggahSelektifService');
  }

  Future<bool> _unggahDompet(List<String> ids) async {
    final daftarDompet = await _dompetOperasi.getDompetByIds(ids);

    if (daftarDompet.isEmpty) {
      developer.log(
          'Tidak ada data dompet valid yang ditemukan untuk diunggah.',
          name: 'UnggahSelektifService');
      return true;
    }

    final batch = _firestore.batch();
    for (final dompet in daftarDompet) {
      final docRef = _firestore.collection('dompet').doc(dompet.id);
      batch.set(docRef, dompet.toMapForFirebase(), SetOptions(merge: true));
    }

    await batch.commit();
    developer.log(
        'Berhasil mengunggah ${daftarDompet.length} item dompet secara selektif.',
        name: 'UnggahSelektifService');
    return true;
  }

  // Fungsi ini bertujuan untuk mengambil data transaksi dari database lokal berdasarkan ID yang diberikan dan mengunggahnya ke Firestore.
  Future<bool> _unggahTransaksi(List<String> ids) async {
    final daftarTransaksi = await _transaksiOperasi.getTransaksiByIds(ids);

    if (daftarTransaksi.isEmpty) {
      developer.log('Tidak ada data transaksi valid yang ditemukan untuk diunggah.', name: 'UnggahSelektifService._unggahTransaksi');
      return true; // diubah: Kembalikan true karena tidak ada yang perlu diunggah, proses dianggap selesai.
    }

    final batch = _firestore.batch();
    for (final transaksi in daftarTransaksi) {
      final docRef = _firestore.collection('transaksi').doc(transaksi.id);
      // diubah: Menggunakan toMapForFirebase untuk memastikan kompatibilitas format data saat unggah.
      batch.set(docRef, transaksi.toMapForFirebase(), SetOptions(merge: true));
    }

    await batch.commit();
    developer.log('Berhasil mengunggah ${daftarTransaksi.length} item transaksi secara selektif.', name: 'UnggahSelektifService._unggahTransaksi');
    return true;
  }
  
  Future<bool> _unggahVersiApkUser(List<String> ids) async {
    final daftarData = await _versiApkUserOperasi.getVersiApkUserByIds(ids);

    if (daftarData.isEmpty) {
      developer.log('Tidak ada data versi_apk_user valid yang ditemukan untuk diunggah.', name: 'UnggahSelektifService._unggahVersiApkUser');
      return true;
    }

    final batch = _firestore.batch();
    for (final data in daftarData) {
      final docRef = _firestore.collection('versi_apk_user').doc(data.id);
      batch.set(docRef, data.toMapForFirebase(), SetOptions(merge: true));
    }

    await batch.commit();
    developer.log('Berhasil mengunggah ${daftarData.length} item versi_apk_user secara selektif.', name: 'UnggahSelektifService._unggahVersiApkUser');
    return true;
  }

  Future<bool> _unggahPengaturan(List<String> ids) async {
    final daftarData = await _pengaturanOperasi.getPengaturanByIds(ids);

    if (daftarData.isEmpty) {
      developer.log('Tidak ada data pengaturan valid yang ditemukan untuk diunggah.', name: 'UnggahSelektifService._unggahPengaturan');
      return true;
    }

    final batch = _firestore.batch();
    for (final data in daftarData) {
      final docRef = _firestore.collection('pengaturan').doc(data.id);
      batch.set(docRef, data.toMapForFirebase(), SetOptions(merge: true));
    }

    await batch.commit();
    developer.log('Berhasil mengunggah ${daftarData.length} item pengaturan secara selektif.', name: 'UnggahSelektifService._unggahPengaturan');
    return true;
  }
  Future<bool> _unggahKategori(List<String> ids) async {
    final daftarData = await _kategoriOperasi.getKategoriByIds(ids);

    if (daftarData.isEmpty) {
      developer.log('Tidak ada data kategori valid yang ditemukan untuk diunggah.', name: 'UnggahSelektifService._unggahKategori');
      return true;
    }

    final batch = _firestore.batch();
    for (final data in daftarData) {
      final docRef = _firestore.collection('kategori').doc(data.id);
      batch.set(docRef, data.toMapForFirebase(), SetOptions(merge: true));
    }

    await batch.commit();
    developer.log('Berhasil mengunggah ${daftarData.length} item kategori secara selektif.', name: 'UnggahSelektifService._unggahKategori');
    return true;
  }
  Future<bool> _unggahSubKategori(List<String> ids) async {
    final daftarData = await _subKategoriOperasi.getSubKategoriByIds(ids);

    if (daftarData.isEmpty) {
      developer.log('Tidak ada data sub_kategori valid yang ditemukan untuk diunggah.', name: 'UnggahSelektifService._unggahSubKategori');
      return true;
    }

    final batch = _firestore.batch();
    for (final data in daftarData) {
      final docRef = _firestore.collection('sub_kategori').doc(data.id);
      batch.set(docRef, data.toMapForFirebase(), SetOptions(merge: true));
    }

    await batch.commit();
    developer.log('Berhasil mengunggah ${daftarData.length} item sub_kategori secara selektif.', name: 'UnggahSelektifService._unggahSubKategori');
    return true;
  }
  Future<bool> _unggahPaket(List<String> ids) async {
    final daftarData = await _paketOperasi.getPaketByIds(ids);

    if (daftarData.isEmpty) {
      developer.log('Tidak ada data paket valid yang ditemukan untuk diunggah.', name: 'UnggahSelektifService._unggahPaket');
      return true;
    }

    final batch = _firestore.batch();
    for (final data in daftarData) {
      final docRef = _firestore.collection('paket').doc(data.id);
      batch.set(docRef, data.toMapForFirebase(), SetOptions(merge: true));
    }

    await batch.commit();
    developer.log('Berhasil mengunggah ${daftarData.length} item paket secara selektif.', name: 'UnggahSelektifService._unggahPaket');
    return true;
  }
  Future<bool> _unggahPelanggan(List<String> ids) async {
    final daftarData = await _pelangganOperasi.getPelangganByIds(ids);

    if (daftarData.isEmpty) {
      developer.log('Tidak ada data pelanggan valid yang ditemukan untuk diunggah.', name: 'UnggahSelektifService._unggahPelanggan');
      return true;
    }

    final batch = _firestore.batch();
    for (final data in daftarData) {
      final docRef = _firestore.collection('pelanggan').doc(data.id);
      batch.set(docRef, data.toMapForFirebase(), SetOptions(merge: true));
    }

    await batch.commit();
    developer.log('Berhasil mengunggah ${daftarData.length} item pelanggan secara selektif.', name: 'UnggahSelektifService._unggahPelanggan');
    return true;
  }
  Future<bool> _unggahPelangganAktif(List<String> ids) async {
    final daftarData = await _pelangganAktifOperasi.getPelangganAktifByIds(ids);

    if (daftarData.isEmpty) {
      developer.log('Tidak ada data pelanggan_aktif valid yang ditemukan untuk diunggah.', name: 'UnggahSelektifService._unggahPelangganAktif');
      return true;
    }

    final batch = _firestore.batch();
    for (final data in daftarData) {
      final docRef = _firestore.collection('pelanggan_aktif').doc(data.id);
      batch.set(docRef, data.toMapForFirebase(), SetOptions(merge: true));
    }

    await batch.commit();
    developer.log('Berhasil mengunggah ${daftarData.length} item pelanggan_aktif secara selektif.', name: 'UnggahSelektifService._unggahPelangganAktif');
    return true;
  }
  Future<bool> _unggahKritikSaran(List<String> ids) async {
    final daftarData = await _kritikSaranOperasi.getKritikSaranByIds(ids);

    if (daftarData.isEmpty) {
      developer.log('Tidak ada data kritik_saran valid yang ditemukan untuk diunggah.', name: 'UnggahSelektifService._unggahKritikSaran');
      return true;
    }

    final batch = _firestore.batch();
    for (final data in daftarData) {
      final docRef = _firestore.collection('kritik_saran').doc(data.id);
      batch.set(docRef, data.toMapForFirebase(), SetOptions(merge: true));
    }

    await batch.commit();
    developer.log('Berhasil mengunggah ${daftarData.length} item kritik_saran secara selektif.', name: 'UnggahSelektifService._unggahKritikSaran');
    return true;
  }
  Future<bool> _unggahRiwayatLangganan(List<String> ids) async {
    final daftarData = await _riwayatLanggananOperasi.getRiwayatLanggananByIds(ids);

    if (daftarData.isEmpty) {
      developer.log('Tidak ada data riwayat_langganan valid yang ditemukan untuk diunggah.', name: 'UnggahSelektifService._unggahRiwayatLangganan');
      return true;
    }

    final batch = _firestore.batch();
    for (final data in daftarData) {
      final docRef = _firestore.collection('riwayat_langganan').doc(data.id);
      batch.set(docRef, data.toMapForFirebase(), SetOptions(merge: true));
    }

    await batch.commit();
    developer.log('Berhasil mengunggah ${daftarData.length} item riwayat_langganan secara selektif.', name: 'UnggahSelektifService._unggahRiwayatLangganan');
    return true;
  }
  Future<bool> _unggahPesanan(List<String> ids) async {
    final daftarData = await _pesananOperasi.getPesananByIds(ids);

    if (daftarData.isEmpty) {
      developer.log('Tidak ada data pesanan valid yang ditemukan untuk diunggah.', name: 'UnggahSelektifService._unggahPesanan');
      return true;
    }

    final batch = _firestore.batch();
    for (final data in daftarData) {
      final docRef = _firestore.collection('pesanan').doc(data.id);
      batch.set(docRef, data.toMapForFirebase(), SetOptions(merge: true));
    }

    await batch.commit();
    developer.log('Berhasil mengunggah ${daftarData.length} item pesanan secara selektif.', name: 'UnggahSelektifService._unggahPesanan');
    return true;
  }
}
