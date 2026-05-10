// path: lib/debug/log.dart

import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

class Log {
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _cyan = '\x1B[36m';

  /// Log Informasi (Hijau) - Untuk alur normal
  static void info(String message) {
    _logCustom(message, name: 'INFO', color: _green);
  }

  /// Log Peringatan (Kuning) - Untuk kondisi tidak ideal tapi bukan error
  static void warning(String message) {
    _logCustom(message, name: 'WARN', color: _yellow);
  }

  /// Log Error (Merah) - Untuk kegagalan fatal/try-catch
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    _logCustom(
      message,
      name: 'ERROR',
      color: _red,
      error: error,
      st: stackTrace,
    );
  }

  /// Log API/Firestore (Cyan) - Untuk pantau data masuk/keluar
  static void api(
    String path,
    Map<String, dynamic> data, {
    required String method,
  }) {
    _logCustom('[$method] $path | Data: $data', name: 'API', color: _cyan);
  }

  static void _logCustom(
    String message, {
    required String name,
    required String color,
    Object? error,
    StackTrace? st,
  }) {
    if (!kDebugMode) return;

    final trace = StackTrace.current.toString().split('\n');
    final String callerRow = trace.length > 2 ? trace[2] : 'Unknown';
    final match = RegExp(r'#2\s+(.+)\s+\((.+)\)').firstMatch(callerRow);

    String location = '';
    if (match != null) {
      final methodCaller = match.group(1);
      final fileInfo = match.group(2);
      location = '📍 $methodCaller - $fileInfo';
    }
    // Output digabung agar tetap satu baris di console
    dev.log(
      '$color$message- $location$_reset  ',
      name: name,
      time: DateTime.now(),
      error: error,
      stackTrace: st,
    );
  }
}
