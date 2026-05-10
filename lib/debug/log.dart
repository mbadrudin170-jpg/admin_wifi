// path: lib/debug/log.dart

import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

class Log {
  static const String _reset = '\x1B[0m';

  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _cyan = '\x1B[36m';

  /// ✅ Log Informasi
  /// Digunakan untuk alur normal aplikasi
  static void info(String message, {String? name}) {
    // diubah: Tambah parameter name
    _logCustom(
      message,
      name: name ?? 'INFO',
      color: _green,
      icon: '✅',
      level: 800,
    ); // diubah: Teruskan name
  }

  /// ⚠️ Log Warning
  /// Digunakan untuk kondisi tidak ideal tapi bukan error fatal
  static void warning(String message, {String? name}) {
    // diubah: Tambah parameter name
    _logCustom(
      message,
      name: name ?? 'WARN',
      color: _yellow,
      icon: '⚠️',
      level: 900,
    ); // diubah: Teruskan name
  }

  /// ❌ Log Error
  /// Digunakan untuk try-catch / error fatal
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? name,
  }) {
    // diubah: Tambah parameter name
    _logCustom(
      message,
      name: name ?? 'ERROR', // diubah: Teruskan name
      color: _red,
      icon: '❌',
      level: 1000,
      error: error,
      st: stackTrace,
    );
  }

  /// 🌐 Log API / Firestore
  /// Digunakan untuk monitoring request dan response data
  static void api(
    String path,
    Map<String, dynamic> data, {
    required String method,
    String? name, // diubah: Tambah parameter name
  }) {
    _logCustom(
      '[$method] $path | Data: $data',
      name: name ?? 'API', // diubah: Teruskan name
      color: _cyan,
      icon: '🌐',
      level: 500,
    );
  }

  /// Method utama logger
  static void _logCustom(
    String message, {
    required String name,
    required String color,
    required String icon,
    required int level,
    Object? error,
    StackTrace? st,
  }) {
    // Logger hanya aktif saat debug mode
    if (!kDebugMode) return;

    // Ambil stack trace saat ini
    final trace = StackTrace.current.toString().split('\n');

    // Ambil caller asli
    final String callerRow = trace.length > 2 ? trace[2] : 'Unknown';

    // Regex untuk parsing lokasi caller
    final match = RegExp(r'#2\s+(.+)\s+\((.+)\)').firstMatch(callerRow);

    String location = '';

    if (match != null) {
      final methodCaller = match.group(1);
      final fileInfo = match.group(2);

      location = '$methodCaller - $fileInfo';
    }

    // Output log
    dev.log(
      '$color $icon $message - $location$_reset',
      name: name,
      level: level,
      time: DateTime.now(),
      error: error,
      stackTrace: st,
    );
  }
}
