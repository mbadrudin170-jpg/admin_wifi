import 'package:admin_wifi/fitur/voucher/model/voucher_model.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'voucher_state.freezed.dart';

@freezed
abstract class VoucherState with _$VoucherState {
  const VoucherState._();

  const factory VoucherState({@Default([]) List<VoucherModel> listVoucher}) =
      _VoucherState;

  /// Mengambil satu voucher berdasarkan [id].
  ///
  /// Mengembalikan `null` bila tidak ditemukan.
  VoucherModel? getById(String id) =>
      listVoucher.firstWhereOrNull((item) => item.id == id);

  /// Mengambil daftar voucher berdasarkan [idPaket].
  ///
  /// Mengembalikan list kosong bila tidak ditemukan.
  List<VoucherModel> getListByIdPaket(String idPaket) =>
      listVoucher.where((item) => item.idPaket == idPaket).toList();
}
