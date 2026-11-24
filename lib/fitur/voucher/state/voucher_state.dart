
import 'package:admin_wifi/fitur/voucher/model/voucher_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'voucher_state.freezed.dart';

@freezed
abstract class VoucherState with _$VoucherState {
  const VoucherState._();

  const factory VoucherState({
    @Default([]) List<VoucherModel> listVoucher,
  }) = _VoucherState;
}