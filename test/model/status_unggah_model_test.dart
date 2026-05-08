// path: test/model/status_unggah_model_test.dart
// diubah: Memperbaiki pemanggilan `fromFirebase` dengan argumen yang benar.

import 'dart:convert';

import 'package:admin_wifi/enum/nama_tabel_enum.dart';
import 'package:admin_wifi/model/status_unggah_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StatusUnggahModel', () {
    final List<String> tIds = ['id-001', 'id-002'];

    final Map<String, dynamic> sqliteMap = {
      'tabel': 'pelanggan',
      'status': 1,
      'ids': jsonEncode(tIds),
    };

    final Map<String, dynamic> firebaseMap = {
      'tabel': 'pelanggan',
      'status': true,
      'ids': tIds,
    };

    final modelInstance = StatusUnggahModel(
      tabel: NamaTabel.pelanggan,
      status: true,
      ids: tIds,
    );

    test('fromSqlite harus mem-parsing data dari format SQLite dengan benar', () {
      final model = StatusUnggahModel.fromSqlite(sqliteMap);
      expect(model.tabel, NamaTabel.pelanggan);
      expect(model.status, isTrue);
      expect(model.ids, tIds);
    });

    test('fromFirebase harus mem-parsing data dari format Firebase dengan benar', () {
      // diubah: Menyediakan argumen yang benar untuk `fromFirebase`.
      final model = StatusUnggahModel.fromFirebase('id-dokumen', firebaseMap);
      expect(model.tabel, NamaTabel.pelanggan);
      expect(model.status, isTrue);
      expect(model.ids, tIds);
    });

    test('toSqlite harus menghasilkan map dengan format yang benar', () {
      final map = modelInstance.toSqlite();
      expect(map['tabel'], 'pelanggan');
      expect(map['status'], 1);
      expect(map['ids'], jsonEncode(tIds));
    });

    test('toFirebase harus menghasilkan map dengan format yang benar', () {
      final map = modelInstance.toFirebase();
      expect(map['tabel'], 'pelanggan');
      expect(map['status'], isTrue);
      expect(map['ids'], tIds);
    });

    test('fromSqlite harus menangani status 0 dari SQLite dengan benar', () {
      final map = {...sqliteMap, 'status': 0};
      final model = StatusUnggahModel.fromSqlite(map);
      expect(model.status, isFalse);
    });

    test('fromFirebase harus menangani status false dari Firebase dengan benar', () {
      final map = {...firebaseMap, 'status': false};
      // diubah: Menyediakan argumen yang benar untuk `fromFirebase`.
      final model = StatusUnggahModel.fromFirebase('id-dokumen', map);
      expect(model.status, isFalse);
    });

    test('fromSqlite dan fromFirebase harus menangani daftar ID kosong dengan benar', () {
      final sqliteMapEmpty = {...sqliteMap, 'ids': jsonEncode([])};
      final firebaseMapEmpty = {...firebaseMap, 'ids': []};

      final modelFromSqlite = StatusUnggahModel.fromSqlite(sqliteMapEmpty);
      // diubah: Menyediakan argumen yang benar untuk `fromFirebase`.
      final modelFromFirebase = StatusUnggahModel.fromFirebase('id-dokumen', firebaseMapEmpty);

      expect(modelFromSqlite.ids, isEmpty);
      expect(modelFromFirebase.ids, isEmpty);
    });
  });
}
