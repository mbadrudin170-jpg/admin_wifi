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

  // ditambah: Placeholder untuk setiap metode unggah
  Future<bool> _unggahTransaksi(List<String> ids) async {
    developer.log('Handler untuk unggah transaksi belum diimplementasikan.', name: 'UnggahSelektifService');
    return false; // diubah: Kembalikan false agar status tidak di-reset
  }
  Future<bool> _unggahVersiApkUser(List<String> ids) async {
    developer.log('Handler untuk unggah versiApkUser belum diimplementasikan.', name: 'UnggahSelektifService');
    return false;
  }
  Future<bool> _unggahPengaturan(List<String> ids) async {
    developer.log('Handler untuk unggah pengaturan belum diimplementasikan.', name: 'UnggahSelektifService');
    return false;
  }
  Future<bool> _unggahKategori(List<String> ids) async {
    developer.log('Handler untuk unggah kategori belum diimplementasikan.', name: 'UnggahSelektifService');
    return false;
  }
  Future<bool> _unggahSubKategori(List<String> ids) async {
    developer.log('Handler untuk unggah subKategori belum diimplementasikan.', name: 'UnggahSelektifService');
    return false;
  }
  Future<bool> _unggahPaket(List<String> ids) async {
    developer.log('Handler untuk unggah paket belum diimplementasikan.', name: 'UnggahSelektifService');
    return false;
  }
  Future<bool> _unggahPelanggan(List<String> ids) async {
    developer.log('Handler untuk unggah pelanggan belum diimplementasikan.', name: 'UnggahSelektifService');
    return false;
  }
  Future<bool> _unggahPelangganAktif(List<String> ids) async {
    developer.log('Handler untuk unggah pelangganAktif belum diimplementasikan.', name: 'UnggahSelektifService');
    return false;
  }
  Future<bool> _unggahKritikSaran(List<String> ids) async {
    developer.log('Handler untuk unggah kritikSaran belum diimplementasikan.', name: 'UnggahSelektifService');
    return false;
  }
  Future<bool> _unggahRiwayatLangganan(List<String> ids) async {
    developer.log('Handler untuk unggah riwayatLangganan belum diimplementasikan.', name: 'UnggahSelektifService');
    return false;
  }
  Future<bool> _unggahPesanan(List<String> ids) async {
    developer.log('Handler untuk unggah pesanan belum diimplementasikan.', name: 'UnggahSelektifService');
    return false;
  }
}
