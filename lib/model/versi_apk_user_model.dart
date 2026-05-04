// path: lib/model/versi_apk_user_model.dart
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

  // untuk membuat instance VersiApkUserModel dari Map, biasanya dari Firestore.
  factory VersiApkUserModel.fromMap(Map<String, dynamic> map) {
    return VersiApkUserModel(
      id: map['id'] as String?,
      catatanRilis: map['catatan_rilis'] as String? ?? '',
      nomorBuildTerbaru: Map<String, int>.from(
        map['nomor_build_terbaru'] as Map? ?? {},
      ),
      tautanUnduhan: Map<String, String>.from(
        map['tautan_unduhan'] as Map? ?? {},
      ),
      versiTerbaru: map['versi_terbaru'] as String? ?? '',
      wajibUpdate: map['wajib_update'] as bool? ?? false,
      youtubeTutorial: map['youtube_tutorial'] as String? ?? '',

      // tambahan
      isDeleted: map['isDeleted'] == 1 || map['isDeleted'] == true,
      diarsipkan: _parseDateTime(map['diarsipkan']),
      diperbarui: _parseDateTime(map['diperbarui']),
    );
  }

  // untuk mengubah instance VersiApkUserModel menjadi Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'catatan_rilis': catatanRilis,
      'nomor_build_terbaru': nomorBuildTerbaru,
      'tautan_unduhan': tautanUnduhan,
      'versi_terbaru': versiTerbaru,
      'wajib_update': wajibUpdate,
      'youtube_tutorial': youtubeTutorial,

      // tambahan
      'isDeleted': isDeleted ? 1 : 0,
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
