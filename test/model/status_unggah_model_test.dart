// path: test/model/status_unggah_model_test.dart
// diubah: Memperbaiki logika pengujian fromFirebase untuk mencerminkan penggunaan ID dokumen.

import 'package:admin_wifi/enum/nama_tabel_enum.dart';
import 'package:admin_wifi/model/status_unggah_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StatusUnggahModel', () {
    final now = DateTime.now();
    final model = StatusUnggahModel(
      tabel: NamaTabel.pelanggan,
      status: true,
      ids: ['id1', 'id2'],
      diperbarui: now,
    );

    test('copyWith harus membuat salinan dengan nilai yang diperbarui', () {
      final salinan = model.copyWith(status: false);
      expect(salinan.status, isFalse);
      expect(salinan.tabel, model.tabel);
    });

    group('Konversi SQLite', () {
      test('toSqlite harus mengubah model menjadi format Map yang benar', () {
        final peta = model.toSqlite();
        expect(peta['tabel'], 'pelanggan');
        expect(peta['status'], 1);
        expect(peta['ids'], '["id1","id2"]');
        expect(peta['diperbarui'], now.toIso8601String());
      });

      test('fromSqlite harus mem-parsing Map dari SQLite dengan benar', () {
        final peta = {
          'tabel': 'pelanggan',
          'status': 1,
          'ids': '["id1","id2"]',
          'diperbarui': now.toIso8601String(),
        };
        final hasil = StatusUnggahModel.fromSqlite(peta);
        expect(hasil.tabel, NamaTabel.pelanggan);
        expect(hasil.status, isTrue);
        expect(hasil.ids, ['id1', 'id2']);
        // Membandingkan milidetik untuk menghindari masalah presisi
        expect(hasil.diperbarui?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      });
    });

    group('Konversi Firebase', () {
      // diubah: Pengujian disesuaikan untuk mensimulasikan alur kerja Firebase yang sebenarnya.
      test(
          'Siklus toFirebase -> fromFirebase harus menghasilkan model yang identik', () {
        // 1. Ubah model ke format Firebase
        final dataFirebase = model.toFirebase();

        // 2. Simulasikan data yang diterima dari Firebase (dengan server timestamp)
        final dataDariServer = Map<String, dynamic>.from(dataFirebase);
        dataDariServer['diperbarui'] = Timestamp.now(); // Ganti FieldValue dengan Timestamp

        // 3. Ambil ID dokumen dari nama tabel model asli
        final idDokumen = model.tabel.name;

        // 4. Buat kembali model dari data yang disimulasikan
        final modelHasil = StatusUnggahModel.fromFirebase(idDokumen, dataDariServer);

        // 5. Validasi
        expect(modelHasil.tabel, model.tabel);
        expect(modelHasil.status, model.status);
        expect(modelHasil.ids, model.ids);
        expect(modelHasil.diperbarui, isA<DateTime>());
      });

      test('toFirebase harus menghasilkan peta dengan server timestamp', () {
        final peta = model.toFirebase();
        expect(peta['status'], true);
        expect(peta['ids'], ['id1', 'id2']);
        expect(peta['diperbarui'], isA<FieldValue>());
      });

      test('fromFirebase harus menangani nilai null dan kosong dengan aman', () {
        final data = {
          'status': null,
          'ids': null,
          'diperbarui': null,
        };
        final hasil = StatusUnggahModel.fromFirebase('dompet', data);
        expect(hasil.tabel, NamaTabel.dompet);
        expect(hasil.status, isFalse);
        expect(hasil.ids, isEmpty);
        expect(hasil.diperbarui, isNull);
      });
    });
  });
}
