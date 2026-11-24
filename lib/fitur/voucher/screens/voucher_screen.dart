import 'package:admin_wifi/fitur/paket/model/paket_model.dart';
import 'package:admin_wifi/fitur/paket/notifier/paket_notifier.dart';
import 'package:admin_wifi/fitur/voucher/model/voucher_model.dart';
import 'package:admin_wifi/fitur/voucher/notifier/voucher_notifier.dart';
import 'package:admin_wifi/fitur/voucher/screens/detail_voucher_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_global_saya/core_shared.dart';

class VoucherScreen extends ConsumerStatefulWidget {
  const VoucherScreen({super.key});

  @override
  ConsumerState<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends ConsumerState<VoucherScreen> {

    String? idPaket;
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
    final paketAsync = ref.watch(paketProvider);

    final voucherState = voucherAsync.requireValue;
    final paketState = paketAsync.requireValue;
    return Scaffold(
      appBar: AppBar(title: const Text('data')),
      body: _buildListVocuher(voucherState.listVoucher),
    );
  }

Widget _buildTombolSort (List<PaketModel> listPaket){
    return ChoiceChip(label: label, selected: selected)
}
  Widget _buildListVocuher(List<VoucherModel> listVoucher) {
    return ListView.builder(
      itemCount: listVoucher.length,
      itemBuilder: (context, index) {
        final item = listVoucher[index];
        return InkWell(
          onTap: () => Nav.to(context, DetailVoucherScreen(id: item.id)),
          child: Card(child: Text(item.idPaket)),
        );
      },
    );
  }
}
