import 'package:freezed_annotation/freezed_annotation.dart';

part 'voucher_model.freezed.dart';

@freezed
abstract class VoucherModel with _$VoucherModel {
  const VoucherModel._();

  const factory VoucherModel({
    required String id,
    required String idPaket,
    required DateTime tanggalDibuat,
    required String voucher,
    required DateTime? kadaluarsa,
  }) = _VoucherModel;
}
