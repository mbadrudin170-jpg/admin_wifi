// path: lib/model/status_unggah_model.dart
// diubah: Penamaan metode diseragamkan menjadi fromSqlite, toSqlite, fromFirebase, toFirebase.
import 'dart:convert';
import 'package:admin_wifi/model/enum/nama_tabel_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatusUnggahModel {
  final NamaTabel tabel;
  final bool status;
  final List<String> ids;
  final DateTime? diperbarui;

  StatusUnggahModel({
    required this.tabel,
    required this.status,
    required this.ids,
    this.diperbarui,
  });

  StatusUnggahModel copyWith({
    NamaTabel? tabel,
    bool? status,
    List<String>? ids,
    DateTime? diperbarui,
  }) {
    return StatusUnggahModel(
      tabel: tabel ?? this.tabel,
      status: status ?? this.status,
      ids: ids ?? this.ids,
      diperbarui: diperbarui ?? this.diperbarui,
    );
  }

  factory StatusUnggahModel.fromSqlite(Map<String, dynamic> map) {
    return StatusUnggahModel(
      tabel: NamaTabel.values.firstWhere((e) => e.name == map['tabel']),
      status: map['status'] == 1,
      ids: (jsonDecode(map['ids']) as List).cast<String>().toList(),
      diperbarui:
          map['diperbarui'] != null ? DateTime.tryParse(map['diperbarui']) : null,
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      'tabel': tabel.name,
      'status': status ? 1 : 0,
      'ids': jsonEncode(ids),
      'diperbarui': diperbarui?.toIso8601String(),
    };
  }

  factory StatusUnggahModel.fromFirebase(String id, Map<String, dynamic> data) {
    return StatusUnggahModel(
      tabel: NamaTabel.values.firstWhere((e) => e.name == id),
      status: data['status'] as bool? ?? false,
      ids: (data['ids'] as List<dynamic>?)?.cast<String>().toList() ?? [],
      diperbarui: (data['diperbarui'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      'status': status,
      'ids': ids,
      'diperbarui': FieldValue.serverTimestamp(),
    };
  }
}
