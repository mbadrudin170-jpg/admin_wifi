// path: lib/fitur/transaksi/state/transaksi_state.dart

import 'package:admin_wifi/enum/tipe_transaksi_enum.dart';
import 'package:admin_wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaksi_state.freezed.dart';

@freezed
abstract class TransaksiState with _$TransaksiState {
  const TransaksiState._();

  const factory TransaksiState({
    @Default(<TransaksiModel>[]) List<TransaksiModel> listTransaksi,
    @Default(0) int jumlahTransaksi,
  }) = _TransaksiState;

  /// Mengambil satu transaksi berdasarkan [id].
  ///
  /// Mengembalikan `null` bila tidak ditemukan.
  TransaksiModel? getById(String id) =>
      listTransaksi.firstWhereOrNull((item) => item.id == id);

  /// Total pemasukan dari seluruh transaksi.
  double get totalPemasukan => listTransaksi
      .where((t) => t.tipe == TipeTransaksi.pemasukan)
      .fold<double>(0.0, (sum, t) => sum + t.jumlah);

  /// Total pengeluaran dari seluruh transaksi.
  double get totalPengeluaran => listTransaksi
      .where((t) => t.tipe == TipeTransaksi.pengeluaran)
      .fold<double>(0.0, (sum, t) => sum + t.jumlah);

  /// Selisih pemasukan dikurangi pengeluaran.
  double get netTotal => totalPemasukan - totalPengeluaran;
}
