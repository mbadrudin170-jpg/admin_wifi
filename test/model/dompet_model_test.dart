// path: test/model/dompet_model_test.dart
// diperbaiki: Menggunakan nama metode fromSqlite dan toSqlite yang benar.

import 'package:admin_wifi/fitur/dompet/model/dompet_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:developer' as developer;

void main() {
  group('DompetModel Unit Test', () {
    test('Inisialisasi: id wajib disediakan secara eksplisit', () {
      developer.log('Menjalankan test: Inisialisasi dengan id eksplisit');

      final dompet = DompetModel(
        id: 'dompet-utama-123',
        namaDompet: 'Dompet Utama',
        saldo: 500000,
      );

      expect(dompet.id, 'dompet-utama-123');

      developer.log('Berhasil: ID eksplisit -> ${dompet.id}');
    });

    group('SQLite Mapping', () {
      test('fromSqlite: Harus membuat model dari map dengan benar', () {
        developer.log('Menjalankan test: fromSqlite dari data SQLite');

        final nowString = DateTime.now().toIso8601String();
        final Map<String, dynamic> dataSqlite = {
          'id': 'uuid-sqlite-123',
          'nama_dompet': 'Tabungan SQLite',
          'saldo': 100.50,
          'diperbarui': nowString,
          'is_deleted': 1, // SQLite boolean
        };

        final model = DompetModel.fromSqlite(dataSqlite);

        expect(model.id, 'uuid-sqlite-123');
        expect(model.namaDompet, 'Tabungan SQLite');
        expect(model.saldo, 100.50);
        expect(model.diperbarui, isA<DateTime>());
        expect(model.isDeleted, true);

        developer.log('Berhasil: Data SQLite terkonversi sempurna ke model');
      });

      test('toSqlite: Harus mengonversi model ke map dengan benar', () {
        developer.log('Menjalankan test: toSqlite');

        final model = DompetModel(
          id: 'uuid-sqlite-456',
          namaDompet: 'Saku',
          saldo: 10,
          isDeleted: true,
          diperbarui: DateTime.now(),
        );

        final map = model.toSqlite();

        expect(map['id'], 'uuid-sqlite-456');
        expect(map['nama_dompet'], 'Saku');
        expect(map['saldo'], 10);
        expect(map['is_deleted'], 1); // bool to int
        expect(map['diperbarui'], isA<String>());

        developer.log('Berhasil: isDeleted terkonversi ke 1 untuk SQLite');
      });
    });

    group('Supabase Mapping', () {
      test('fromSupabase: Harus membuat model dari map Supabase', () {
        developer.log('Menjalankan test: fromSupabase');

        final Map<String, dynamic> dataSupabase = {
          'id': 'supabase-id-123',
          'nama_dompet': 'Investasi',
          'saldo': 2500.75,
          'diperbarui': DateTime.now().toUtc().toIso8601String(),
          'is_deleted': false,
        };

        final model = DompetModel.fromSupabase(dataSupabase);

        expect(model.id, 'supabase-id-123');
        expect(model.namaDompet, 'Investasi');
        expect(model.saldo, 2500.75);
        expect(model.isDeleted, false);

        developer.log('Berhasil: Data Supabase terkonversi sempurna ke model.');
      });

      test('toSupabase: Harus mengonversi model ke map untuk Supabase', () {
        developer.log('Menjalankan test: toSupabase');

        final model = DompetModel(
          id: 'test-id-untuk-supabase',
          namaDompet: 'Dana Darurat',
          saldo: 10000,
          isDeleted: false,
        );

        final map = model.toSupabase();

        expect(map['nama_dompet'], 'Dana Darurat');
        expect(map['saldo'], 10000);
        expect(map['is_deleted'], false);
        expect(map['diperbarui'], isA<String>());

        developer.log('Berhasil: Model terkonversi ke map untuk Supabase.');
      });
    });

    group('Fitur Model', () {
      test(
        'copyWith: Harus menyalin objek dan memperbarui nilai yang diberikan',
        () {
          developer.log('Menjalankan test: copyWith');

          final original = DompetModel(
            id: 'original-id',
            namaDompet: 'Lama',
            saldo: 100,
            isDeleted: false,
          );

          final updatedName = original.copyWith(namaDompet: 'Baru');
          expect(updatedName.namaDompet, 'Baru');
          expect(updatedName.saldo, 100);
          expect(updatedName.id, 'original-id');

          final updatedSaldo = original.copyWith(saldo: 200);
          expect(updatedSaldo.namaDompet, 'Lama');
          expect(updatedSaldo.saldo, 200);

          final updatedDeleted = original.copyWith(isDeleted: true);
          expect(updatedDeleted.isDeleted, true);

          developer.log('Berhasil: copyWith menjaga integritas field lain');
        },
      );
    });
  });
}
