// path: lib/widget/nama_paket.dart
// Widget ini berfungsi untuk menampilkan nama paket berdasarkan ID.

import 'package:admin_wifi/fitur/paket/notifier/paket_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class NamaPaketWidget extends ConsumerWidget {
  final String idPaket;
  final TextStyle? style;

  const NamaPaketWidget({super.key, required this.idPaket, this.style});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paketAsync = ref.watch(paketProvider);

    if (paketAsync.isLoading) {
      return const SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (paketAsync.hasError) {
      return Text(
        'Paket tidak tersedia',
        style: style?.copyWith(color: Theme.of(context).colorScheme.error),
      );
    }
    final state = paketAsync.requireValue;
    final paket = state.getById(idPaket);
    if (paket == null) {
      return Text(
        'Paket tidak tersedia',
        style: style?.copyWith(color: Theme.of(context).colorScheme.error),
      );
    }
    return Text(paket.nama, style: style);
  }
}
