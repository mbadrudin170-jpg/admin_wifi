// path: lib/model/dompet_model.dart
// diubah: Menggunakan UUID untuk ID dan memastikan non-nullable.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class DompetModel {
  final String id; // diubah: menjadi non-nullable
  final String namaDompet;
  final double saldo;
  final DateTime? diperbarui;
  final bool isDeleted;
  final DateTime? diarsipkan;

  DompetModel({
    String? id, // diubah: id bisa null saat pembuatan
    required this.namaDompet,
    required this.saldo,
    this.diperbarui,
    this.isDeleted = false,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4(); // ditambah: inisialisasi UUID jika id null

  DompetModel copyWith({
    String? id,
    String? namaDompet,
    double? saldo,
    DateTime? diperbarui,
    bool? isDeleted,
    DateTime? diarsipkan,
  }) {
    return DompetModel(
      id: id ?? this.id,
      namaDompet: namaDompet ?? this.namaDompet,
      saldo: saldo ?? this.saldo,
      diperbarui: diperbarui ?? this.diperbarui,
      isDeleted: isDeleted ?? this.isDeleted,
      diarsipkan: diarsipkan ?? this.diarsipkan,
    );
  }

  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  factory DompetModel.fromMap(Map<String, dynamic> map) {
    return DompetModel(
      id: map['id'],
      namaDompet: map['namaDompet'] ?? '',
      saldo: (map['saldo'] as num?)?.toDouble() ?? 0.0,
      diperbarui: _parseDateTime(map['diperbarui']),
      isDeleted: map['isDeleted'] == true || map['isDeleted'] == 1,
      diarsipkan: _parseDateTime(map['diarsipkan']),
    );
  }

  Map<String, dynamic> toMapForSqlite() {
    return {
      'id': id,
      'namaDompet': namaDompet,
      'saldo': saldo,
      'diperbarui': diperbarui?.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }

  Map<String, dynamic> toMapForFirebase() {
    return {
      'id': id,
      'namaDompet': namaDompet,
      'saldo': saldo,
      'diperbarui': diperbarui?.toIso8601String(),
      'isDeleted': isDeleted,
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }
}
