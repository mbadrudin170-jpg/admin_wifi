// path: lib/model/versi_apk_user_model.dart
import 'dart:convert'; // ditambah: untuk jsonEncode dan jsonDecode
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

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

  // untuk membuat instance VersiApkUserModel dengan nilai default.
  VersiApkUserModel({
    String? id,
    this.catatanRilis = '',
    this.nomorBuildTerbaru = const {},
    this.tautanUnduhan = const {},
    this.versiTerbaru = '',
    this.wajibUpdate = false,
    this.youtubeTutorial = '',
    // tambahan
    this.isDeleted = false,
    this.diarsipkan,
    this.diperbarui,
  }) : id = id ?? const Uuid().v4();

  // Helper untuk parsing tanggal dari berbagai format (Timestamp, String)
  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  // untuk membuat instance VersiApkUserModel dari Map, biasanya dari Firestore atau SQLite.
  factory VersiApkUserModel.fromMap(Map<String, dynamic> map) {
    // ditambah: helper untuk deserialisasi map dari JSON string jika perlu
    dynamic _decodeMap(dynamic value) {
      if (value is String) {
        try {
          return jsonDecode(value);
        } catch (e) {
          return {}; // Kembalikan map kosong jika ada error parsing
        }
      }
      return value ?? {};
    }

    return VersiApkUserModel(
      id: map['id'] as String?,
      catatanRilis: map['catatan_rilis'] as String? ?? '',
      // diubah: menggunakan helper _decodeMap untuk deserialisasi
      nomorBuildTerbaru: Map<String, int>.from(
        _decodeMap(map['nomor_build_terbaru']),
      ),
      tautanUnduhan: Map<String, String>.from(
        _decodeMap(map['tautan_unduhan']),
      ),
      versiTerbaru: map['versi_terbaru'] as String? ?? '',
      wajibUpdate: map['wajib_update'] == 1 || map['wajib_update'] == true, // diubah: kompatibel dengan bool dan int
      youtubeTutorial: map['youtube_tutorial'] as String? ?? '',

      // tambahan
      isDeleted: map['isDeleted'] == 1 || map['isDeleted'] == true, // diubah: kompatibel dengan bool dan int
      diarsipkan: _parseDateTime(map['diarsipkan']),
      diperbarui: _parseDateTime(map['diperbarui']),
    );
  }

  // untuk mengubah instance VersiApkUserModel menjadi Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'catatan_rilis': catatanRilis,
      // diubah: menggunakan jsonEncode untuk serialisasi Map ke String
      'nomor_build_terbaru': jsonEncode(nomorBuildTerbaru),
      'tautan_unduhan': jsonEncode(tautanUnduhan),
      'versi_terbaru': versiTerbaru,
      'wajib_update': wajibUpdate ? 1 : 0, // diubah: simpan bool sebagai integer
      'youtube_tutorial': youtubeTutorial,

      // tambahan
      'isDeleted': isDeleted ? 1 : 0, // diubah: simpan bool sebagai integer
      'diarsipkan': diarsipkan?.toIso8601String(),
      'diperbarui': diperbarui?.toIso8601String(),
    };
  }

  // untuk membuat salinan instance VersiApkUserModel dengan beberapa perubahan.
  VersiApkUserModel copyWith({
    String? id,
    String? catatanRilis,
    Map<String, int>? nomorBuildTerbaru,
    Map<String, String>? tautanUnduhan,
    String? versiTerbaru,
    bool? wajibUpdate,
    String? youtubeTutorial,
    // tambahan
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
      // tambahan
      isDeleted: isDeleted ?? this.isDeleted,
      diarsipkan: diarsipkan ?? this.diarsipkan,
      diperbarui: diperbarui ?? this.diperbarui,
    );
  }
}
