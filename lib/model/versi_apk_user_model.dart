// path: lib/model/versi_apk_user_model.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class VersiApkUserModel {
  final String id;
  final String catatanRilis;
  final Map<String, int> nomorBuildTerbaru;
  final Map<String, String> tautanUnduhan;
  final String versiTerbaru;
  final bool wajibUpdate;
  final String youtubeTutorial;
  final bool isDeleted;
  final DateTime? diarsipkan;
  final DateTime? diperbarui;

  VersiApkUserModel({
    required this.id,
    this.catatanRilis = '',
    this.nomorBuildTerbaru = const {},
    this.tautanUnduhan = const {},
    this.versiTerbaru = '',
    this.wajibUpdate = false,
    this.youtubeTutorial = '',
    this.isDeleted = false,
    this.diarsipkan,
    this.diperbarui,
  });

  // Fungsi PENTING: Untuk membuat objek dari berbagai sumber data
  factory VersiApkUserModel.fromMap(Map<String, dynamic> map) {
    return VersiApkUserModel(
      id: map['id'] as String? ?? '',
      catatanRilis: map['catatan_rilis'] as String? ?? '',
      versiTerbaru: map['versi_terbaru'] as String? ?? '',
      youtubeTutorial: map['youtube_tutorial'] as String? ?? '',

      // diubah: Logika fleksibel untuk boolean (bisa baca int 1/0 atau bool true/false)
      wajibUpdate: map['wajib_update'] == 1 || map['wajib_update'] == true,
      isDeleted: map['isDeleted'] == 1 || map['isDeleted'] == true,

      // diubah: Logika fleksibel untuk Map (bisa baca String JSON atau Map asli)
      nomorBuildTerbaru: _parseNomorBuild(map['nomor_build_terbaru']),
      tautanUnduhan: _parseTautanUnduhan(map['tautan_unduhan']),

      diarsipkan: _parseDateTime(map['diarsipkan']),
      diperbarui: _parseDateTime(map['diperbarui']),
    );
  }

  // --- FUNGSI UNTUK FIREBASE ---
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'catatan_rilis': catatanRilis,
      'versi_terbaru': versiTerbaru,
      'youtube_tutorial': youtubeTutorial,
      'diarsipkan': diarsipkan,
      'diperbarui': diperbarui,
      'nomor_build_terbaru': nomorBuildTerbaru, // Dikirim sebagai MAP
      'tautan_unduhan': tautanUnduhan, // Dikirim sebagai MAP
      'wajib_update': wajibUpdate, // Dikirim sebagai BOOLEAN
      'isDeleted': isDeleted, // Dikirim sebagai BOOLEAN
    };
  }

  // --- FUNGSI UNTUK SQLITE ---
  Map<String, dynamic> toMapForSqlite() {
    return {
      'id': id,
      'catatan_rilis': catatanRilis,
      'versi_terbaru': versiTerbaru,
      'youtube_tutorial': youtubeTutorial,
      'diarsipkan': diarsipkan?.toIso8601String(),
      'diperbarui': diperbarui?.toIso8601String(),
      'nomor_build_terbaru': jsonEncode(
        nomorBuildTerbaru,
      ), // Diubah jadi STRING JSON
      'tautan_unduhan': jsonEncode(tautanUnduhan), // Diubah jadi STRING JSON
      'wajib_update': wajibUpdate ? 1 : 0, // Diubah jadi INTEGER
      'isDeleted': isDeleted ? 1 : 0, // Diubah jadi INTEGER
    };
  }

  // --- FUNGSI-FUNGSI BANTU (HELPERS) ---

  static DateTime? _parseDateTime(dynamic date) {
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.tryParse(date);
    return null;
  }

  static Map<String, int> _parseNomorBuild(dynamic data) {
    if (data is Map) {
      return Map<String, int>.from(
        data.map((key, value) => MapEntry(key, (value as num).toInt())),
      );
    }
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) {
          return Map<String, int>.from(
            decoded.map((key, value) => MapEntry(key, (value as num).toInt())),
          );
        }
      } catch (_) {}
    }
    return {};
  }

  static Map<String, String> _parseTautanUnduhan(dynamic data) {
    if (data is Map) {
      return Map<String, String>.from(
        data.map((key, value) => MapEntry(key, value as String)),
      );
    }
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) {
          return Map<String, String>.from(
            decoded.map((key, value) => MapEntry(key, value as String)),
          );
        }
      } catch (_) {}
    }
    return {};
  }

  // Fungsi copyWith untuk memudahkan update objek
  VersiApkUserModel copyWith({
    String? id,
    String? catatanRilis,
    Map<String, int>? nomorBuildTerbaru,
    Map<String, String>? tautanUnduhan,
    String? versiTerbaru,
    bool? wajibUpdate,
    String? youtubeTutorial,
    bool? isDeleted,
    DateTime? diarsipkan,
    DateTime? diperbarui,
  }) {
    return VersiApkUserModel(
      id: id ?? this.id,
      catatanRilis: catatanRilis ?? this.catatanRilis,
      nomorBuildTerbaru: nomorBuildTerbaru ?? this.nomorBuildTerbaru,
      tautanUnduhan: tautanUnduhan ?? this.tautanUnduhan,
      versiTerbaru: versiTerbaru ?? this.versiTerbaru,
      wajibUpdate: wajibUpdate ?? this.wajibUpdate,
      youtubeTutorial: youtubeTutorial ?? this.youtubeTutorial,
      isDeleted: isDeleted ?? this.isDeleted,
      diarsipkan: diarsipkan ?? this.diarsipkan,
      diperbarui: diperbarui ?? this.diperbarui,
    );
  }
}
