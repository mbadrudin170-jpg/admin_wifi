// path: lib/fitur/dompet/state/dompet_state.dart

import 'package:admin_wifi/fitur/dompet/model/dompet_model.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dompet_state.freezed.dart';

@freezed
abstract class DompetState with _$DompetState {
  const DompetState._();

  const factory DompetState({
    @Default(<DompetModel>[]) List<DompetModel> listDompet,
    @Default(0) int jumlahDompet,
  }) = _DompetState;

  /// Mengambil daftar dompet aktif.
  List<DompetModel> getDompet({bool tampilkanDiarsipkan = false}) => listDompet;

  /// Mengambil satu dompet berdasarkan [id].
  ///
  /// Mengembalikan `null` bila tidak ditemukan.
  DompetModel? getById(String id) =>
      listDompet.firstWhereOrNull((item) => item.id == id);

  /// Mengambil satu dompet berdasarkan [id].
  ///
  /// Mengembalikan `null` bila tidak ditemukan.
  DompetModel? getDompetById(String id) => getById(id);

  /// Total saldo dari seluruh dompet aktif.
  double getTotalSaldo() =>
      listDompet.fold<double>(0.0, (sum, dompet) => sum + dompet.saldo);

  /// Total saldo positif dari dompet aktif.
  double getTotalSaldoPositif() => listDompet
      .where((dompet) => dompet.saldo > 0)
      .fold<double>(0.0, (sum, dompet) => sum + dompet.saldo);

  /// Total saldo negatif dari dompet aktif.
  double getTotalSaldoNegatif() => listDompet
      .where((dompet) => dompet.saldo < 0)
      .fold<double>(0.0, (sum, dompet) => sum + dompet.saldo);

  /// Mengambil dompet berdasarkan daftar [ids].
  List<DompetModel> getDompetByIds(List<String> ids) =>
      listDompet.where((dompet) => ids.contains(dompet.id)).toList();
}
