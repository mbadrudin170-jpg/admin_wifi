// path: lib/fitur/transaksi/state/transaksi_state.dart

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
}
