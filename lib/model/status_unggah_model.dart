// path: lib/model/status_unggah_model.dart
import 'dart:convert';

import 'package:admin_wifi/model/enum/nama_tabel_enum.dart';

class StatusUnggahModel {
  final NamaTabel tabel;
  final bool status;
  final List<String> ids;

  StatusUnggahModel({
    required this.tabel,
    required this.status,
    required this.ids,
  });

  StatusUnggahModel copyWith({
    NamaTabel? tabel,
    bool? status,
    List<String>? ids,
  }) {
    return StatusUnggahModel(
      tabel: tabel ?? this.tabel,
      status: status ?? this.status,
      ids: ids ?? this.ids,
    );
  }

  // diubah: Metode ini sekarang dapat menangani data dari SQLite (int) dan Firebase (bool).
  factory StatusUnggahModel.fromMap(Map<String, dynamic> map) {
    // --- Penanganan ID (List) ---
    List<String> parsedIds;
    final idsData = map['ids'];
    if (idsData is String) {
      // Sumber dari SQLite, di mana list disimpan sebagai string JSON.
      parsedIds = (jsonDecode(idsData) as List).cast<String>().toList();
    } else if (idsData is List) {
      // Sumber dari Firebase, di mana list adalah tipe data asli.
      parsedIds = idsData.cast<String>().toList();
    } else {
      parsedIds = [];
    }

    // --- Penanganan Status (Boolean) ---
    bool parsedStatus;
    final statusData = map['status'];
    if (statusData is bool) {
      // Sumber dari Firebase (true/false)
      parsedStatus = statusData;
    } else if (statusData is int) {
      // Sumber dari SQLite (1/0)
      parsedStatus = statusData == 1;
    } else {
      parsedStatus = false;
    }

    return StatusUnggahModel(
      tabel: NamaTabel.values.firstWhere((e) => e.name == map['tabel']),
      status: parsedStatus,
      ids: parsedIds,
    );
  }

  // Konversi untuk SQLite (menyimpan list sebagai JSON dan bool sebagai int)
  Map<String, dynamic> toMapForSqlite() {
    return {
      'tabel': tabel.name,
      'status': status ? 1 : 0,
      'ids': jsonEncode(ids),
    };
  }

  // ditambah: Konversi untuk Firebase (menggunakan tipe data asli Firebase)
  Map<String, dynamic> toMapForFirebase() {
    return {
      'tabel': tabel.name,
      'status': status, // Disimpan sebagai boolean
      'ids': ids, // Disimpan sebagai array
    };
  }
}


//docs :