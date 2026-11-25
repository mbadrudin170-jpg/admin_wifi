import 'package:admin_wifi/fitur/paket/model/paket_model.dart';
import 'package:admin_wifi/fitur/paket/notifier/paket_notifier.dart';
import 'package:admin_wifi/fitur/voucher/notifier/voucher_notifier.dart';
import 'package:admin_wifi/fitur/voucher/screens/detail_voucher_screen.dart';
import 'package:admin_wifi/fitur/voucher/state/voucher_state.dart';
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
      body: Column(
        children: [
          _buildTombolSort(paketState.listPaket),
          Expanded(child: _buildListVocuher(voucherState)),
        ],
      ),
    );
  }

  Widget _buildTombolSort(List<PaketModel> listPaket) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 8,
        children: listPaket
            .map(
              (paket) => FilterChip(
                label: Text(paket.nama),
                selected: idPaket == paket.id,
                onSelected: (_) => setState(() => idPaket = paket.id),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildListVocuher(VoucherState state) {
    final paket = idPaket;
    final listVoucher = paket == null
        ? state.listVoucher
        : state.getListByIdPaket(paket);
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
