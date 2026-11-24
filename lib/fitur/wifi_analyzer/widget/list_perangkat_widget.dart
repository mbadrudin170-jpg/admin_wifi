// path: lib/fitur/wifi_analyzer/widget/list_perangkat_widget.dart

import 'package:admin_wifi/fitur/wifi_analyzer/model/perangkat_wifi_model.dart';
import 'package:admin_wifi/fitur/wifi_analyzer/notifier/perangkat_wifi_notifier.dart';
import 'package:admin_wifi/fitur/wifi_analyzer/state/perangkat_wifi_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/core_shared.dart';

class ListPerangkatWidget extends ConsumerWidget {
  const ListPerangkatWidget({super.key, required this.state});

  final PerangkatWifiState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = this.state;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Perangkat Terhubung (${state.perangkat.length})',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (state.isLoading && state.perangkat.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (state.error != null && state.perangkat.isEmpty)
              EmptyStateView(
                ikon: Icons.error_outline,
                judul: 'Gagal memindai perangkat',
                deskripsi: state.error!,
                ctaLabel: 'Coba Lagi',
                onCta: () => ref.invalidate(perangkatWifiProvider),
              )
            else if (state.perangkat.isEmpty)
              EmptyStateView(
                ikon: Icons.devices_other,
                judul: 'Belum ada perangkat terdeteksi',
                deskripsi: 'Pemindaian berjalan otomatis saat halaman dibuka.',
                ctaLabel: 'Pindai',
                onCta: () => ref.invalidate(perangkatWifiProvider),
              )
            else
              ...state.perangkat.map((p) => _buildItemPerangkat(context, p)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemPerangkat(BuildContext context, PerangkatWifiModel p) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  p.ip,
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (p.latencyMs != null)
                  Text(
                    '${p.latencyMs} ms',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            if (p.nama != null)
              Text(p.nama!, style: Theme.of(context).textTheme.bodyMedium)
            else
              Text(
                'Perangkat tidak dikenal',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            if (p.mac != null)
              Text(
                'MAC: ${p.mac}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (p.vendor != null)
              Text(
                'Vendor: ${p.vendor}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}
