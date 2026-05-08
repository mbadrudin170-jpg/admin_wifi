// path: test/model/dompet_model_test.dart
// diperbaiki: Menggunakan nama metode fromSqlite dan toSqlite yang benar.

import 'package:admin_wifi/model/dompet_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

void main() {
  group('DompetModel Unit Test', () {
    
    test('Inisialisasi: Harus membuat UUID otomatis jika id tidak disediakan', () {
      developer.log('Menjalankan test: Inisialisasi UUID otomatis');
      
      final dompet = DompetModel(
        namaDompet: 'Dompet Utama',
        saldo: 500000,
      );

      expect(dompet.id, isNotNull);
      expect(dompet.id, isA<String>());
      expect(dompet.id.length, greaterThan(10));
      
      developer.log('Berhasil: ID dihasilkan -> ${dompet.id}');
    });

    group('SQLite Mapping', () {
      test('fromSqlite: Harus membuat model dari map dengan benar', () {
        developer.log('Menjalankan test: fromSqlite dari data SQLite');
        
        final nowString = DateTime.now().toIso8601String();
        final Map<String, dynamic> dataSqlite = {
          'id': 'uuid-sqlite-123',
          'namaDompet': 'Tabungan SQLite',
          'saldo': 100.50,
          'diperbarui': nowString,
          'isDeleted': 1, // SQLite boolean
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
        expect(map['namaDompet'], 'Saku');
        expect(map['saldo'], 10);
        expect(map['isDeleted'], 1); // bool to int
        expect(map['diperbarui'], isA<String>());
        
        developer.log('Berhasil: isDeleted terkonversi ke 1 untuk SQLite');
      });
    });
    
    group('Firestore Mapping', () {
        test('fromFirebase: Harus membuat model dari map Firestore', () {
            developer.log('Menjalankan test: fromFirebase');
            
            final timestamp = Timestamp.now();
            final Map<String, dynamic> dataFirestore = {
                'namaDompet': 'Investasi',
                'saldo': 2500.75,
                'diperbarui': timestamp,
                'isDeleted': false,
            };

            final model = DompetModel.fromFirebase('firestore-id-123', dataFirestore);
            
            expect(model.id, 'firestore-id-123');
            expect(model.namaDompet, 'Investasi');
            expect(model.saldo, 2500.75);
            expect(model.isDeleted, false);
            expect(model.diperbarui, timestamp.toDate());
            
            developer.log('Berhasil: Data Firestore terkonversi sempurna ke model.');
        });

        test('toFirebase: Harus mengonversi model ke map untuk Firestore', () {
            developer.log('Menjalankan test: toFirebase');

            final model = DompetModel(
                namaDompet: 'Dana Darurat',
                saldo: 10000,
                isDeleted: false,
            );

            final map = model.toFirebase();
            
            expect(map['namaDompet'], 'Dana Darurat');
            expect(map['saldo'], 10000);
            expect(map['isDeleted'], false);
            expect(map['diperbarui'], isA<FieldValue>());
            
            developer.log('Berhasil: Model terkonversi ke map untuk Firestore.');
        });
    });

    group('Fitur Model', () {
      test('copyWith: Harus menyalin objek dan memperbarui nilai yang diberikan', () {
        developer.log('Menjalankan test: copyWith');
        
        final original = DompetModel(id: 'original-id', namaDompet: 'Lama', saldo: 100, isDeleted: false);
        
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
      });
    });
  });
}
