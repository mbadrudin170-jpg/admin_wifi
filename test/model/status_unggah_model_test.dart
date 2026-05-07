// path: test/model/status_unggah_model_test.dart
import 'dart:convert';

import 'package:admin_wifi/model/enum/nama_tabel.dart';
import 'package:admin_wifi/model/status_unggah_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StatusUnggahModel', () {
    final List<String> tIds = ['id-001', 'id-002'];
    
    // Data mentah seperti yang akan datang dari SQLite
    final Map<String, dynamic> sqliteMap = {
      'tabel': 'pelanggan',
      'status': 1, // boolean sebagai integer
      'ids': jsonEncode(tIds), // list sebagai string JSON
    };

    // Data mentah seperti yang akan datang dari Firebase
    final Map<String, dynamic> firebaseMap = {
      'tabel': 'pelanggan',
      'status': true, // boolean asli
      'ids': tIds, // list sebagai array
    };

    // Instance model untuk pengujian konversi ke Map
    final modelInstance = StatusUnggahModel(
      tabel: NamaTabel.pelanggan,
      status: true,
      ids: tIds,
    );

    test('fromMap harus mem-parsing data dari format SQLite dengan benar', () {
      // 1. Aksi: Membuat model dari map format SQLite
      final model = StatusUnggahModel.fromMap(sqliteMap);

      // 2. Hasil: Memverifikasi bahwa setiap properti di-parsing dengan benar
      expect(model.tabel, NamaTabel.pelanggan);
      expect(model.status, isTrue);
      expect(model.ids, tIds);
    });

    test('fromMap harus mem-parsing data dari format Firebase dengan benar', () {
      // 1. Aksi: Membuat model dari map format Firebase
      final model = StatusUnggahModel.fromMap(firebaseMap);

      // 2. Hasil: Memverifikasi bahwa setiap properti di-parsing dengan benar
      expect(model.tabel, NamaTabel.pelanggan);
      expect(model.status, isTrue);
      expect(model.ids, tIds);
    });

    test('toMapForSqlite harus menghasilkan map dengan format yang benar', () {
      // 1. Aksi: Mengonversi instance model ke map format SQLite
      final map = modelInstance.toMapForSqlite();

      // 2. Hasil: Memverifikasi bahwa hasilnya cocok dengan ekspektasi format SQLite
      expect(map['tabel'], 'pelanggan');
      expect(map['status'], 1);
      expect(map['ids'], jsonEncode(tIds));
    });

    test('toMapForFirebase harus menghasilkan map dengan format yang benar', () {
      // 1. Aksi: Mengonversi instance model ke map format Firebase
      final map = modelInstance.toMapForFirebase();

      // 2. Hasil: Memverifikasi bahwa hasilnya cocok dengan ekspektasi format Firebase
      expect(map['tabel'], 'pelanggan');
      expect(map['status'], isTrue);
      expect(map['ids'], tIds);
    });

    test('fromMap harus menangani status 0 dari SQLite dengan benar', () {
      final map = {...sqliteMap, 'status': 0};
      final model = StatusUnggahModel.fromMap(map);
      expect(model.status, isFalse);
    });
    
    test('fromMap harus menangani status false dari Firebase dengan benar', () {
      final map = {...firebaseMap, 'status': false};
      final model = StatusUnggahModel.fromMap(map);
      expect(model.status, isFalse);
    });

    test('fromMap harus menangani daftar ID kosong dengan benar', () {
      final sqliteMapEmpty = {...sqliteMap, 'ids': jsonEncode([])};
      final firebaseMapEmpty = {...firebaseMap, 'ids': []};
      
      final modelFromSqlite = StatusUnggahModel.fromMap(sqliteMapEmpty);
      final modelFromFirebase = StatusUnggahModel.fromMap(firebaseMapEmpty);

      expect(modelFromSqlite.ids, isEmpty);
      expect(modelFromFirebase.ids, isEmpty);
    });
  });
}
