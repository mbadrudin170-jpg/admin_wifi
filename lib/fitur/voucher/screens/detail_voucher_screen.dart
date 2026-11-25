import 'package:admin_wifi/fitur/paket/notifier/paket_notifier.dart';
import 'package:admin_wifi/fitur/voucher/notifier/voucher_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DetailVoucherScreen extends ConsumerWidget {
  final String id;
  const DetailVoucherScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voucherAsync = ref.watch(voucherProvider);
    final paketAsync = ref.watch(paketProvider);

    final voucherState = voucherAsync.requireValue;
    final paketState = paketAsync.requireValue;
    final item = voucherState.getById(id);
    if (item == null) return SizedBox();
    final paket = paketState.getById(item.idPaket);
    return Scaffold(
      appBar: AppBar(title: const Text('data')),
      body: Card(child: _buildItemCustom('voucher', item.voucher)),
    );
  }

  Widget _buildItemCustom(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        FittedBox(child: Text(value)),
      ],
    );
  }
}
