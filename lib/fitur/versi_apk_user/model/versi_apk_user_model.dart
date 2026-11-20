// path: lib/fitur/versi_apk_user/model/versi_apk_user_model.dart
// diubah: Penamaan metode diseragamkan dan logika Firebase disesuaikan.
import 'dart:convert';
import 'package:admin_wifi/enum/arsitektur_apk_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:share_global_saya/src/utils/parser_util.dart';

part 'versi_apk_user_model.freezed.dart';

@freezed
abstract class VersiApkUserModel with _$VersiApkUserModel {
  const VersiApkUserModel._();

  const factory VersiApkUserModel({
    required String id,
    @Default('') String catatanRilis,
    @Default(VersiApkUserModel.defaultNomorBuildTerbaru)
    Map<ArsitekturApkEnum, int> nomorBuildTerbaru,
    @Default(VersiApkUserModel.defaultTautanUnduhan)
    Map<ArsitekturApkEnum, String> tautanUnduhan,
    @Default('') String versiTerbaru,
    @Default(false) bool wajibUpdate,
    @Default('') String youtubeTutorial,
    @Default(false) bool isDeleted,
    DateTime? diarsipkan,
    DateTime? diperbarui,
  }) = _VersiApkUserModel;

  // =========================
  // SQLITE
  // =========================
  factory VersiApkUserModel.fromSqlite(Map<String, dynamic> map) {
    return VersiApkUserModel(
      id: ParserUtil.parseString(map[VersiApkUserSkema.id]),
      catatanRilis: ParserUtil.parseString(map[VersiApkUserSkema.catatanRilis]),
      versiTerbaru: ParserUtil.parseString(map[VersiApkUserSkema.versiTerbaru]),
      youtubeTutorial: ParserUtil.parseString(
        map[VersiApkUserSkema.youtubeTutorial],
      ),
      wajibUpdate: ParserUtil.parseBool(map[VersiApkUserSkema.wajibUpdate]),
      isDeleted: ParserUtil.parseBool(map[VersiApkUserSkema.isDeleted]),
      nomorBuildTerbaru: _parseNomorBuild(
        map[VersiApkUserSkema.nomorBuildTerbaru],
      ),
      tautanUnduhan: _parseTautanUnduhan(map[VersiApkUserSkema.tautanUnduhan]),
      diarsipkan: _parseTanggal(map[VersiApkUserSkema.diarsipkan]),
      diperbarui: _parseTanggal(map[VersiApkUserSkema.diperbarui]),
    );
  }

  /// Supabase mengembalikan baris sebagai `Map<String, dynamic>` dengan
  /// kunci yang sama dengan SQLite, jadi parsing sama dengan fromSqlite.
  factory VersiApkUserModel.fromSupabase(Map<String, dynamic> map) {
    return VersiApkUserModel.fromSqlite(map);
  }

  Map<String, dynamic> toSqlite() {
    return {
      VersiApkUserSkema.id: id,
      VersiApkUserSkema.catatanRilis: catatanRilis,
      VersiApkUserSkema.versiTerbaru: versiTerbaru,
      VersiApkUserSkema.youtubeTutorial: youtubeTutorial,
      VersiApkUserSkema.diarsipkan: diarsipkan?.toUtc().toIso8601String(),
      VersiApkUserSkema.diperbarui: diperbarui?.toUtc().toIso8601String(),
      VersiApkUserSkema.nomorBuildTerbaru: jsonEncode(
        nomorBuildTerbaru.map((key, value) => MapEntry(key.name, value)),
      ),
      VersiApkUserSkema.tautanUnduhan: jsonEncode(
        tautanUnduhan.map((key, value) => MapEntry(key.name, value)),
      ),
      VersiApkUserSkema.wajibUpdate: wajibUpdate ? 1 : 0,
      VersiApkUserSkema.isDeleted: isDeleted ? 1 : 0,
    };
  }

  // =========================
  // FIREBASE
  // =========================
  factory VersiApkUserModel.fromFirebase(String id, Map<String, dynamic> map) {
    return VersiApkUserModel(
      id: id,
      catatanRilis: ParserUtil.parseString(map[VersiApkUserSkema.catatanRilis]),
      versiTerbaru: ParserUtil.parseString(map[VersiApkUserSkema.versiTerbaru]),
      youtubeTutorial: ParserUtil.parseString(
        map[VersiApkUserSkema.youtubeTutorial],
      ),
      wajibUpdate: ParserUtil.parseBool(map[VersiApkUserSkema.wajibUpdate]),
      isDeleted: ParserUtil.parseBool(map[VersiApkUserSkema.isDeleted]),
      nomorBuildTerbaru: _parseNomorBuild(
        map[VersiApkUserSkema.nomorBuildTerbaru],
      ),
      tautanUnduhan: _parseTautanUnduhan(map[VersiApkUserSkema.tautanUnduhan]),
      diarsipkan: _parseTanggal(map[VersiApkUserSkema.diarsipkan]),
      diperbarui: _parseTanggal(map[VersiApkUserSkema.diperbarui]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      VersiApkUserSkema.id: id,
      VersiApkUserSkema.catatanRilis: catatanRilis,
      VersiApkUserSkema.versiTerbaru: versiTerbaru,
      VersiApkUserSkema.youtubeTutorial: youtubeTutorial,
      VersiApkUserSkema.diperbarui: FieldValue.serverTimestamp(),
      if (diarsipkan != null)
        VersiApkUserSkema.diarsipkan: Timestamp.fromDate(diarsipkan!.toUtc()),
      VersiApkUserSkema.nomorBuildTerbaru: nomorBuildTerbaru.map(
        (key, value) => MapEntry(key.name, value),
      ),
      VersiApkUserSkema.tautanUnduhan: tautanUnduhan.map(
        (key, value) => MapEntry(key.name, value),
      ),
      VersiApkUserSkema.wajibUpdate: wajibUpdate,
      VersiApkUserSkema.isDeleted: isDeleted,
    };
  }

  Map<String, dynamic> toSupabase() {
    return {
      VersiApkUserSkema.id: id,
      VersiApkUserSkema.catatanRilis: catatanRilis,
      VersiApkUserSkema.versiTerbaru: versiTerbaru,
      VersiApkUserSkema.youtubeTutorial: youtubeTutorial,
      VersiApkUserSkema.diperbarui: (diperbarui ?? DateTime.now()).toUtc().toIso8601String(),
      if (diarsipkan != null)
        VersiApkUserSkema.diarsipkan: diarsipkan?.toUtc().toIso8601String(),
      VersiApkUserSkema.nomorBuildTerbaru: nomorBuildTerbaru.map(
        (key, value) => MapEntry(key.name, value),
      ),
      VersiApkUserSkema.tautanUnduhan: tautanUnduhan.map(
        (key, value) => MapEntry(key.name, value),
      ),
      VersiApkUserSkema.wajibUpdate: wajibUpdate,
      VersiApkUserSkema.isDeleted: isDeleted,
    };
  }

  // =========================
  // HELPERS
  // =========================

  /// Firestore menyimpan `Timestamp`; SQLite menyimpan ISO-8601 string (UTC).
  /// Keduanya dinormalisasi lewat [ParserUtil.parseDateTime].
  static DateTime? _parseTanggal(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toLocal();
    }

    return ParserUtil.parseDateTime(value)?.toLocal();
  }

  static const Map<ArsitekturApkEnum, int> defaultNomorBuildTerbaru = {
    ArsitekturApkEnum.bit_32: 0,
    ArsitekturApkEnum.bit_64: 0,
    ArsitekturApkEnum.universal: 0,
  };

  static const Map<ArsitekturApkEnum, String> defaultTautanUnduhan = {
    ArsitekturApkEnum.bit_32: '',
    ArsitekturApkEnum.bit_64: '',
    ArsitekturApkEnum.universal: '',
  };

  static Map<ArsitekturApkEnum, int> _parseNomorBuild(dynamic data) {
    final hasil = <ArsitekturApkEnum, int>{};
    Map<dynamic, dynamic>? mapData;

    if (data is Map) {
      mapData = data;
    } else if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) {
          mapData = decoded;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Gagal parse nomor build: $e');
        }
      }
    }

    if (mapData != null) {
      for (final item in mapData.entries) {
        final arsitektur = ParserUtil.safeParseEnum(
          ArsitekturApkEnum.values,
          item.key.toString(),
        );
        if (arsitektur != null) {
          hasil[arsitektur] = ParserUtil.parseInt(item.value);
        }
      }
    }

    return {...defaultNomorBuildTerbaru, ...hasil};
  }

  static Map<ArsitekturApkEnum, String> _parseTautanUnduhan(dynamic data) {
    final hasil = <ArsitekturApkEnum, String>{};
    Map<dynamic, dynamic>? mapData;

    if (data is Map) {
      mapData = data;
    } else if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) {
          mapData = decoded;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Gagal parse tautan unduhan: $e');
        }
      }
    }

    if (mapData != null) {
      for (final item in mapData.entries) {
        final arsitektur = ParserUtil.safeParseEnum(
          ArsitekturApkEnum.values,
          item.key.toString(),
        );
        if (arsitektur != null) {
          hasil[arsitektur] = ParserUtil.parseString(item.value);
        }
      }
    }

    return {...defaultTautanUnduhan, ...hasil};
  }
}

abstract final class VersiApkUserSkema {
  static const String tabel = 'versi_apk_user';
  static const String id = 'id';
  static const String catatanRilis = 'catatan_rilis';
  static const String nomorBuildTerbaru = 'nomor_build_terbaru';
  static const String tautanUnduhan = 'tautan_unduhan';
  static const String versiTerbaru = 'versi_terbaru';
  static const String wajibUpdate = 'wajib_update';
  static const String youtubeTutorial = 'youtube_tutorial';
  static const String isDeleted = 'isDeleted';
  static const String diarsipkan = 'diarsipkan';
  static const String diperbarui = 'diperbarui';
}
