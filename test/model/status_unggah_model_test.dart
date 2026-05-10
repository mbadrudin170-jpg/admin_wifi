// path: test/model/status_unggah_model_test.dart
import 'package:admin_wifi/model/status_unggah_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StatusUnggahModel', () {
    // Pengujian untuk konstruktor dan properti dasar
    test('Konstruktor harus menginisialisasi properti dengan benar', () {
      final model = StatusUnggahModel(id: 1, perluUnggah: true);

      expect(model.id, 1);
      expect(model.perluUnggah, isTrue);
    });

    group('Konversi SQLite', () {
      // Pengujian untuk metode fromSqlite
      test('fromSqlite harus membuat model dari Map SQLite', () {
        // Kasus 1: perlu_unggah adalah 1 (true)
        final map1 = {'id': 1, 'perlu_unggah': 1};
        final model1 = StatusUnggahModel.fromSqlite(map1);
        expect(model1.id, 1);
        expect(model1.perluUnggah, isTrue);

        // Kasus 2: perlu_unggah adalah 0 (false)
        final map2 = {'id': 1, 'perlu_unggah': 0};
        final model2 = StatusUnggahModel.fromSqlite(map2);
        expect(model2.id, 1);
        expect(model2.perluUnggah, isFalse);
      });

      // Pengujian untuk metode toSqlite
      test('toSqlite harus mengonversi model ke format Map SQLite', () {
        // Kasus 1: perluUnggah adalah true
        final model1 = StatusUnggahModel(id: 1, perluUnggah: true);
        final map1 = model1.toSqlite();
        expect(map1, {'id': 1, 'perlu_unggah': 1});

        // Kasus 2: perluUnggah adalah false
        final model2 = StatusUnggahModel(id: 1, perluUnggah: false);
        final map2 = model2.toSqlite();
        expect(map2, {'id': 1, 'perlu_unggah': 0});
      });
    });
  });
}
