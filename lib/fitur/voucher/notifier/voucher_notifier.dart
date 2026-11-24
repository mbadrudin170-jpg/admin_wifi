import 'package:admin_wifi/fitur/voucher/dummy/voucher_dummy.dart';
import 'package:admin_wifi/fitur/voucher/state/voucher_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'voucher_notifier.g.dart';

@riverpod
class VoucherNotifier extends _$VoucherNotifier {
  @override
  Future<VoucherState> build() async {
    return VoucherState(listVoucher: VoucherDummy.dummyList);
  }

  void tambah() {}
  void ubah() {}
  void hapus() {}
}
