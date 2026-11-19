// path: lib/db/supabase/operasi_supabase.dart

import 'package:admin_wifi/db/supabase/supabase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_global_saya/src/utils/l.dart';

/// Operasi CRUD generik langsung ke Supabase (tanpa status unggah/sync).
/// Menyediakan fungsi dasar: ambil, tambah, ubah, hapus, dan tambahBatch.
class OperasiSupabase {
  /// Mengambil baris dari tabel.
  /// - [select]: kolom yang diambil (default `*`).
  /// - [filter]: pasangan kolom=nilai untuk `.match(...)` (opsional).
  /// - [orderBy]/[ascending]: pengurutan opsional.
  /// - [limit]/[offset]: paginasi opsional.
  Future<List<Map<String, dynamic>>> ambil(
    String tabel, {
    String select = '*',
    Map<String, dynamic>? filter,
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
  }) async {
    L.i('Memulai ambil data dari Supabase tabel: $tabel');
    try {
      final client = SupabaseKlien.instance.client;
      dynamic query = client.from(tabel).select(select);
      if (filter != null && filter.isNotEmpty) {
        query = query.match(Map<String, Object>.from(filter));
      }
      if (orderBy != null && orderBy.trim().isNotEmpty) {
        query = query.order(orderBy, ascending: ascending);
      }
      if (limit != null) {
        query = query.limit(limit);
      }
      if (offset != null) {
        final to = (limit != null) ? offset + limit - 1 : offset + 999;
        query = query.range(offset, to);
      }
      final hasil = await query;
      final list = (hasil as List).cast<Map<String, dynamic>>();
      L.i('Berhasil mengambil ${list.length} data dari Supabase tabel: $tabel');
      return list;
    } catch (e, s) {
      L.e('Gagal ambil data dari Supabase tabel: $tabel Error: $e $s');
      rethrow;
    }
  }

  /// Menambahkan satu baris data ke tabel.
  /// Mengembalikan baris yang tersimpan (jika [kembalikan] true).
  Future<Map<String, dynamic>?> tambah(
    String tabel,
    Map<String, dynamic> data, {
    bool kembalikan = false,
  }) async {
    L.i('Memulai tambah data ke Supabase tabel: $tabel Data: $data');
    try {
      final client = SupabaseKlien.instance.client;
      final hasil = await client
          .from(tabel)
          .insert(data)
          .select()
          .maybeSingle();
      L.i('Berhasil tambah data ke Supabase tabel: $tabel');
      if (!kembalikan) return null;
      return hasil;
    } catch (e, s) {
      L.e('Gagal tambah data ke Supabase tabel: $tabel Error: $e $s');
      rethrow;
    }
  }

  /// Mengubah baris data di tabel berdasarkan [filter] (kolom=nilai).
  /// Mengembalikan jumlah baris yang terpengaruh tidak tersedia dari SDK;
  /// gunakan [kembalikan] untuk mendapatkan baris hasil.
  Future<List<Map<String, dynamic>>> ubah(
    String tabel,
    Map<String, dynamic> data, {
    required Map<String, dynamic> filter,
    bool kembalikan = false,
  }) async {
    L.i('Memulai ubah data di Supabase tabel: $tabel Data: $data Filter: $filter');
    try {
      final client = SupabaseKlien.instance.client;
      var query = client.from(tabel).update(data).match(Map<String, Object>.from(filter));
      if (kembalikan) {
        final hasil = await query.select();
        final list = (hasil as List).cast<Map<String, dynamic>>();
        L.i('Berhasil ubah ${list.length} baris di Supabase tabel: $tabel');
        return list;
      }
      await query;
      L.i('Berhasil ubah data di Supabase tabel: $tabel');
      return const <Map<String, dynamic>>[];
    } catch (e, s) {
      L.e('Gagal ubah data di Supabase tabel: $tabel Error: $e $s');
      rethrow;
    }
  }

  /// Menghapus baris data dari tabel berdasarkan [filter] (kolom=nilai).
  Future<void> hapus(
    String tabel, {
    required Map<String, dynamic> filter,
  }) async {
    L.i('Memulai hapus data dari Supabase tabel: $tabel Filter: $filter');
    try {
      final client = SupabaseKlien.instance.client;
      await client.from(tabel).delete().match(Map<String, Object>.from(filter));
      L.i('Berhasil hapus data dari Supabase tabel: $tabel');
    } catch (e, s) {
      L.e('Gagal hapus data dari Supabase tabel: $tabel Error: $e $s');
      rethrow;
    }
  }

  /// Menambahkan banyak baris data sekaligus (batch) ke tabel.
  Future<void> tambahBatch(
    String tabel,
    List<Map<String, dynamic>> daftarData,
  ) async {
    if (daftarData.isEmpty) {
      L.w('Daftar data batch kosong, operasi dibatalkan: $tabel');
      return;
    }
    L.i('Memulai tambahBatch ke Supabase tabel: $tabel total: ${daftarData.length}');
    try {
      final client = SupabaseKlien.instance.client;
      await client.from(tabel).insert(daftarData);
      L.i('Berhasil tambahBatch ke Supabase tabel: $tabel');
    } catch (e, s) {
      L.e('Gagal tambahBatch ke Supabase tabel: $tabel Error: $e $s');
      rethrow;
    }
  }
}

/// Provider Riverpod untuk instance [OperasiSupabase].
final operasiSupabaseProvider = Provider<OperasiSupabase>((ref) {
  return OperasiSupabase();
});
