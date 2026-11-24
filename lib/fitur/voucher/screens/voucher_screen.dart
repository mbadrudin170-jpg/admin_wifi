import 'package:admin_wifi/fitur/voucher/model/voucher_model.dart';
import 'package:admin_wifi/fitur/voucher/notifier/voucher_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VoucherScreen extends ConsumerStatefulWidget {
  const VoucherScreen({super.key});

  @override
  ConsumerState<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends ConsumerState<VoucherScreen> {
  @override
  void initState() {
    super.initState();
    // TODO: implement initState
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voucherAsync = ref.watch(voucherProvider);

    final voucherState = voucherAsync.requireValue;
    return Scaffold(
      appBar: AppBar(title: const Text('data')),
      body: _buildListVocuher(voucherState.listVoucher),
    );
  }

  Widget _buildListVocuher(List<VoucherModel> listVoucher) {
    return ListView.builder(
      itemCount: listVoucher.length,
      itemBuilder: (context, index) {
        final item = listVoucher[index];
        return Card(child: Text(item.idPaket));
      },
    );
  }
}
