import 'package:admin_wifi/data/operasi/dompet_operasi.dart';
import 'package:admin_wifi/data/operasi/status_unggah_operasi.dart';
import 'package:admin_wifi/model/enum/nama_tabel_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// [UnggahSelektifService] bertanggung jawab untuk menangani logika unggah
/// data yang perubahannya telah dicatat di tabel `status_unggah`.
class UnggahSelektifService {
  final FirebaseFirestore _firestore;
  final StatusUnggahOperasi _statusOperasi;
  final DompetOperasi _dompetOperasi;

  // diubah: Menggunakan konstruktor untuk Dependency Injection
  UnggahSelektifService({
    FirebaseFirestore? firestore,
    StatusUnggahOperasi? statusOperasi,
    DompetOperasi? dompetOperasi,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _statusOperasi = statusOperasi ?? StatusUnggahOperasi(),
        _dompetOperasi = dompetOperasi ?? DompetOperasi();

  Future<void> unggahPerubahanTertunda() async {
    developer.log('Memulai pengecekan perubahan tertunda untuk diunggah.', name: 'UnggahSelektifService');

    final daftarStatus = await _statusOperasi.ambilSemuaStatusUnggah();
    final perluDiunggah = daftarStatus.where((s) => s.status && s.ids.isNotEmpty).toList();

    if (perluDiunggah.isEmpty) {
      developer.log('Tidak ada data yang perlu diunggah secara selektif.', name: 'UnggahSelektifService');
      return;
    }

    developer.log('Ditemukan ${perluDiunggah.length} tabel dengan perubahan yang perlu diunggah.', name: 'UnggahSelektifService');

    for (final status in perluDiunggah) {
      try {
        bool berhasil = false;
        switch (status.tabel) {
          case NamaTabel.dompet:
            berhasil = await _unggahDompet(status.ids);
            break;
          case NamaTabel.transaksi:
            developer.log('Handler untuk unggah transaksi belum diimplementasikan.', name: 'UnggahSelektifService');
            break;
          default:
            developer.log('Tipe tabel ${status.tabel} tidak memiliki handler unggah.', name: 'UnggahSelektifService');
        }

        if (berhasil) {
          developer.log('Unggah untuk tabel ${status.tabel} berhasil, mereset status.', name: 'UnggahSelektifService');
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

    developer.log('Proses unggah selektif selesai.', name: 'UnggahSelektifService');
  }

  Future<bool> _unggahDompet(List<String> ids) async {
    final daftarDompet = await _dompetOperasi.getDompetByIds(ids);

    if (daftarDompet.isEmpty) {
      developer.log('Tidak ada data dompet valid yang ditemukan untuk diunggah.', name: 'UnggahSelektifService');
      return true;
    }

    final batch = _firestore.batch();
    for (final dompet in daftarDompet) {
      final docRef = _firestore.collection('dompet').doc(dompet.id);
      batch.set(docRef, dompet.toMapForFirebase(), SetOptions(merge: true));
    }

    await batch.commit();
    developer.log('Berhasil mengunggah ${daftarDompet.length} item dompet secara selektif.', name: 'UnggahSelektifService');
    return true;
  }
}
