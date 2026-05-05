// path: lib/model/kritik_saran_model.dart
// diubah: Menambahkan copyWith dan id non-nullable untuk pengujian
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class KritikSaranModel {
  final String id;
  final String isi;
  final DateTime tanggal;
  final String userId;
  final DateTime? diperbarui;

  KritikSaranModel({
    String? id,
    required this.isi,
    required this.tanggal,
    required this.userId,
    this.diperbarui,
  }) : id = id ?? const Uuid().v4(); // ID akan dibuat jika null (untuk tes)

  KritikSaranModel copyWith({
    String? id,
    String? isi,
    DateTime? tanggal,
    String? userId,
    DateTime? diperbarui,
  }) {
    return KritikSaranModel(
      id: id ?? this.id,
      isi: isi ?? this.isi,
      tanggal: tanggal ?? this.tanggal,
      userId: userId ?? this.userId,
      diperbarui: diperbarui ?? this.diperbarui,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isi': isi,
      'tanggal': tanggal.toIso8601String(),
      'userId': userId,
      'diperbarui': diperbarui?.toIso8601String(),
    };
  }

  factory KritikSaranModel.fromMap(Map<String, dynamic> map) {
    var tanggalValue = map['tanggal'];
    DateTime parsedDate;
    if (tanggalValue is Timestamp) {
      parsedDate = tanggalValue.toDate();
    } else if (tanggalValue is String) {
      parsedDate = DateTime.parse(tanggalValue);
    } else {
      parsedDate = DateTime.now(); 
    }
    
    var diperbaruiValue = map['diperbarui'];
    DateTime? parsedDiperbarui;
    if (diperbaruiValue is Timestamp) {
      parsedDiperbarui = diperbaruiValue.toDate();
    } else if (diperbaruiValue is String) {
      parsedDiperbarui = DateTime.tryParse(diperbaruiValue);
    }

    return KritikSaranModel(
      id: map['id'] as String?,
      isi: map['isi'] ?? '',
      userId: map['userId'] ?? '',
      tanggal: parsedDate,
      diperbarui: parsedDiperbarui,
    );
  }
}
