// path: lib/widget/nama_paket.dart
// Widget ini berfungsi untuk menampilkan nama paket berdasarkan ID.

import 'package:admin_wifi/fitur/paket/notifier/paket_notifier.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class NamaPaketWidget extends ConsumerWidget {
  final String idPaket;
  final TextStyle? style;

  const NamaPaketWidget({super.key, required this.idPaket, this.style});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paketAsync = ref.watch(paketProvider);

    return paketAsync.when(
      data: (state) {
        final paket = state.listPaket.firstWhereOrNull((p) => p.id == idPaket);
        if (paket == null) {
          return Text(
            'Paket tidak tersedia',
            style: style?.copyWith(color: Colors.red),
          );
        }
        return Text(paket.nama, style: style);
      },
      loading: () => const SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => Text(
        'Paket tidak tersedia',
        style: style?.copyWith(color: Colors.red),
      ),
    );
  }
}
