// path: lib/model/versi_apk_user_model.dart
import 'dart:convert';
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

  VersiApkUserModel({
    String? id,
    this.catatanRilis = '',
    this.nomorBuildTerbaru = const {},
    this.tautanUnduhan = const {},
    this.versiTerbaru = '',
    this.wajibUpdate = false,
    this.youtubeTutorial = '',
    this.isDeleted = false,
    this.diarsipkan,
    this.diperbarui,
  }) : id = id ?? const Uuid().v4();

  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  factory VersiApkUserModel.fromMap(Map<String, dynamic> map) {
    // diubah: nama fungsi lokal tidak diawali dengan underscore.
    dynamic decodeMap(dynamic value) {
      if (value is String) {
        try {
          return jsonDecode(value);
        } catch (e) {
          return {};
        }
      }
      return value ?? {};
    }

    return VersiApkUserModel(
      id: map['id'] as String?,
      catatanRilis: map['catatan_rilis'] as String? ?? '',
      nomorBuildTerbaru: Map<String, int>.from(
        decodeMap(map['nomor_build_terbaru']), // diubah
      ),
      tautanUnduhan: Map<String, String>.from(
        decodeMap(map['tautan_unduhan']), // diubah
      ),
      versiTerbaru: map['versi_terbaru'] as String? ?? '',
      wajibUpdate: map['wajib_update'] == 1 || map['wajib_update'] == true,
      youtubeTutorial: map['youtube_tutorial'] as String? ?? '',
      isDeleted: map['isDeleted'] == 1 || map['isDeleted'] == true,
      diarsipkan: _parseDateTime(map['diarsipkan']),
      diperbarui: _parseDateTime(map['diperbarui']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'catatan_rilis': catatanRilis,
      'nomor_build_terbaru': jsonEncode(nomorBuildTerbaru),
      'tautan_unduhan': jsonEncode(tautanUnduhan),
      'versi_terbaru': versiTerbaru,
      'wajib_update': wajibUpdate ? 1 : 0,
      'youtube_tutorial': youtubeTutorial,
      'isDeleted': isDeleted ? 1 : 0,
      'diarsipkan': diarsipkan?.toIso8601String(),
      'diperbarui': diperbarui?.toIso8601String(),
    };
  }

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
