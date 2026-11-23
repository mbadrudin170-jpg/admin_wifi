// path: lib/fitur/wifi_analyzer/widget/list_perangkat_widget.dart

import 'package:admin_wifi/fitur/wifi_analyzer/notifier/perangkat_wifi_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:network_tools/network_tools.dart';
import 'package:share_global_saya/core_shared.dart';

class ListPerangkatWidget extends ConsumerWidget {
  const ListPerangkatWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(perangkatWifiProvider);

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
                if (state.isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Pindai Perangkat',
                    onPressed: () =>
                        ref.read(perangkatWifiProvider.notifier).pindai(),
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
                onCta: () => ref.read(perangkatWifiProvider.notifier).pindai(),
              )
            else if (state.perangkat.isEmpty)
              EmptyStateView(
                ikon: Icons.devices_other,
                judul: 'Belum ada perangkat terdeteksi',
                deskripsi: 'Tekan tombol pindai untuk mencari perangkat di jaringan yang sama.',
                ctaLabel: 'Pindai',
                onCta: () => ref.read(perangkatWifiProvider.notifier).pindai(),
              )
            else
              ...state.perangkat.map(
                (host) => _buildItemPerangkat(context, host),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemPerangkat(BuildContext context, ActiveHost host) {
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
                  host.address,
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (host.responseTime != null)
                  Text(
                    '${host.responseTime!.inMilliseconds} ms',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            FutureBuilder<String>(
              future: host.deviceName,
              builder: (context, snapshot) {
                final nama = snapshot.data;
                if (nama == null ||
                    nama.isEmpty ||
                    nama == ActiveHost.generic) {
                  return const SizedBox.shrink();
                }
                return Text(
                  nama,
                  style: Theme.of(context).textTheme.bodyMedium,
                );
              },
            ),
            FutureBuilder<String?>(
              future: host.getMacAddress(),
              builder: (context, snapshot) {
                final mac = snapshot.data;
                if (mac == null || mac.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Text(
                  'MAC: $mac',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
            FutureBuilder<Vendor?>(
              future: host.vendor,
              builder: (context, snapshot) {
                final vendor = snapshot.data?.vendorName;
                if (vendor == null || vendor.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Text(
                  'Vendor: $vendor',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
