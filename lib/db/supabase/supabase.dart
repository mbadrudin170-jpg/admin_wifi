// path: lib/db/supabase/supabase.dart

import 'package:share_global_saya/src/utils/l.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Klien Supabase singleton untuk proyek `admin_wifi`.
///
/// Inisialisasi wajib dipanggil sekali di `main()` sebelum `runApp`:
/// ```dart
/// await SupabaseKlien.instance.inisialisasi(
///   url: const String.fromEnvironment('SUPABASE_URL'),
///   publishableKey: const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
/// );
/// ```
class SupabaseKlien {
  SupabaseKlien._internal();
  static final SupabaseKlien instance = SupabaseKlien._internal();

  bool _sudahDiinisialisasi = false;

  /// Mengembalikan [SupabaseClient] yang sudah siap.
  /// Melempar [StateError] bila [inisialisasi] belum dipanggil.
  SupabaseClient get client {
    if (!_sudahDiinisialisasi) {
      throw StateError(
        'SupabaseKlien belum diinisialisasi. '
        'Panggil SupabaseKlien.instance.inisialisasi() di main() terlebih dahulu.',
      );
    }
    return Supabase.instance.client;
  }

  /// Inisialisasi SDK Supabase. Idempoten: pemanggilan kedua dilewati.
  /// Minimal salah satu dari [publishableKey] atau [anonKey] harus diisi.
  Future<void> inisialisasi({
    required String url,
    String? publishableKey,
    String? anonKey,
  }) async {
    if (_sudahDiinisialisasi) {
      L.w('SupabaseKlien sudah diinisialisasi; pemanggilan dilewati.');
      return;
    }
    final pk = publishableKey?.trim();
    final ak = anonKey?.trim();
    if (url.trim().isEmpty) {
      throw ArgumentError('url Supabase tidak boleh kosong.');
    }
    if ((pk == null || pk.isEmpty) && (ak == null || ak.isEmpty)) {
      throw ArgumentError(
        'publishableKey atau anonKey Supabase tidak boleh kosong.',
      );
    }
    L.i('Memulai inisialisasi Supabase (url: $url).');
    try {
      await Supabase.initialize(
        url: url,
        publishableKey: pk,
        // ignore: deprecated_member_use
        anonKey: ak,
      );
      _sudahDiinisialisasi = true;
      L.i('Supabase berhasil diinisialisasi.');
    } catch (e, s) {
      L.e('Gagal inisialisasi Supabase: $e $s');
      rethrow;
    }
  }

  /// Status inisialisasi (berguna untuk guard di UI/test).
  bool get sudahDiinisialisasi => _sudahDiinisialisasi;
}
