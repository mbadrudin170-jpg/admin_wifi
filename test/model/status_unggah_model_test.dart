// path: test/model/status_unggah_model_test.dart
import 'package:admin_wifi/fitur/status_unggah/model/status_unggah_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StatusUnggahModel', () {
    // Pengujian untuk konstruktor dan properti dasar
    test('Konstruktor harus menginisialisasi properti dengan benar', () {
      final diperbarui = DateTime.utc(2026, 11, 19, 10);
      final model = StatusUnggahModel(
        namaTabel: 'transaksi',
        status: 1,
        ids: 'dd000001-0000-4000-8000-000000000001',
        diperbarui: diperbarui,
      );

      expect(model.namaTabel, 'transaksi');
      expect(model.status, 1);
      expect(model.ids, 'dd000001-0000-4000-8000-000000000001');
      expect(model.diperbarui, diperbarui);
    });

    group('Konversi SQLite', () {
      // Pengujian untuk metode fromSqlite
      test('fromSqlite harus membuat model dari Map SQLite', () {
        final diperbarui = DateTime.utc(2026, 11, 19, 10);
        final map = {
          StatusUnggahSkema.namaTabel: 'pelanggan',
          StatusUnggahSkema.status: 0,
          StatusUnggahSkema.ids: '',
          StatusUnggahSkema.diperbarui: diperbarui.toIso8601String(),
        };

        final model = StatusUnggahModel.fromSqlite(map);
        expect(model.namaTabel, 'pelanggan');
        expect(model.status, 0);
        expect(model.ids, '');
        expect(model.diperbarui, diperbarui.toLocal());
      });

      // Pengujian untuk metode toSqlite
      test('toSqlite harus mengonversi model ke format Map SQLite', () {
        final diperbarui = DateTime.utc(2026, 11, 19, 10);
        final model = StatusUnggahModel(
          namaTabel: 'pelanggan',
          status: 0,
          ids: '',
          diperbarui: diperbarui,
        );

        final map = model.toSqlite();
        expect(map, {
          StatusUnggahSkema.namaTabel: 'pelanggan',
          StatusUnggahSkema.status: 0,
          StatusUnggahSkema.ids: '',
          StatusUnggahSkema.diperbarui: '2026-11-19T10:00:00.000Z',
        });

        // diperbarui null ditulis sebagai null (kolom nullable).
        final modelTanpaTanggal = StatusUnggahModel(
          namaTabel: 'pelanggan',
          status: 0,
          ids: '',
        );
        expect(
          modelTanpaTanggal.toSqlite()[StatusUnggahSkema.diperbarui],
          isNull,
        );
      });
    });
  });
}
