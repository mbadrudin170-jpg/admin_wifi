// path: lib/halaman/tab/pesanan.dart

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:admin_wifi/fitur/paket/notifier/paket_notifier.dart';
import 'package:admin_wifi/fitur/paket/state/paket_state.dart';
import 'package:admin_wifi/fitur/pelanggan/notifier/pelanggan_notifier.dart';
import 'package:admin_wifi/fitur/pelanggan/state/pelanggan_state.dart';
import 'package:admin_wifi/fitur/pesanan/model/pesanan_model.dart';
import 'package:admin_wifi/fitur/pesanan/notifier/pesanan_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/core_shared.dart';

class HalamanPesan extends ConsumerStatefulWidget {
  const HalamanPesan({super.key});

  @override
  ConsumerState<HalamanPesan> createState() => _HalamanPesanState();
}

class _HalamanPesanState extends ConsumerState<HalamanPesan> {
  String _filterStatus = 'semua';

  List<PesananModel> _filteredList(List<PesananModel> list) {
    if (_filterStatus == 'semua') return list;
    return list.where((p) => p.status == _filterStatus).toList();
  }

  Future<void> _muatPesanan() async {
    try {
      await ref.read(pesananProvider.notifier).muatUlang();
    } catch (e, s) {
      L.e('Gagal memuat data pesanan: $e $s');
    }
  }

  Future<void> _updateStatus(PesananModel pesanan, String statusBaru) async {
    try {
      await ref
          .read(pesananProvider.notifier)
          .updateStatusPesanan(pesanan.id, statusBaru);
      if (mounted) {
        AppToast.sukses(
          context,
          'Status pesanan #${pesanan.id} diubah menjadi "$statusBaru"',
        );
      }
    } catch (e, s) {
      L.e('Gagal mengubah status pesanan #${pesanan.id}: $e $s');
      if (mounted) {
        AppToast.gagal(context, 'Gagal mengubah status: $e');
      }
    }
  }

  Future<void> _hapusPesanan(PesananModel pesanan) async {
    final konfirmasi = await showOkCancelAlertDialog(
      context: context,
      title: 'Hapus Pesanan',
      message: 'Yakin hapus pesanan dari ${pesanan.idPelanggan}?',
      okLabel: 'Hapus',
      cancelLabel: 'Batal',
      isDestructiveAction: true,
    );
    if (konfirmasi != OkCancelResult.ok) return;
    try {
      await ref.read(pesananProvider.notifier).hapusPesanan(pesanan.id);
      if (mounted) {
        AppToast.sukses(context, 'Pesanan berhasil dihapus');
      }
    } catch (e, s) {
      L.e('Gagal menghapus pesanan #${pesanan.id}: $e $s');
      if (mounted) {
        AppToast.gagal(context, 'Gagal menghapus pesanan: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncPesanan = ref.watch(pesananProvider);

    if (asyncPesanan.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (asyncPesanan.hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Daftar Pesanan')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              const Icon(Icons.error_outline, size: 48),
              Text('Gagal memuat data pesanan: ${asyncPesanan.error}'),
              FilledButton(
                onPressed: () => ref.refresh(pesananProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final state = asyncPesanan.requireValue;
    final daftar = _filteredList(state.listPesanan);
    final pelangganState = ref.read(pelangganProvider);
    final paketState = ref.read(paketProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pesanan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _muatPesanan,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          _buildSummaryCards(daftar.length),
          Expanded(
            child: daftar.isEmpty
                ? EmptyStateView(
                    ikon: Icons.inbox,
                    judul: 'Belum ada pesanan',
                    deskripsi: 'Pesanan akan muncul di sini setelah dibuat.',
                  )
                : _buildPesananList(daftar, pelangganState, paketState),
          ),
        ],
      ),
    );
  }

  void _showPesananDetail(
    PesananModel pesanan,
    AsyncValue<PelangganState> pelangganState,
    AsyncValue<PaketState> paketState,
  ) {
    final namaPelanggan =
        pelangganState.value?.getById(pesanan.idPelanggan)?.nama ??
        pesanan.idPelanggan;
    final namaPaket =
        paketState.value?.getById(pesanan.idPaket)?.nama ?? pesanan.idPaket;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Detail Pesanan #${pesanan.id}',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _detailRow('Nama Pelanggan', namaPelanggan),
            _detailRow('Paket', namaPaket),
            _detailRow(
              'Tanggal',
              DateFormat('dd MMM yyyy HH:mm').format(pesanan.tanggal),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(PesananModel pesanan) {
    switch (pesanan.status) {
      case 'baru':
        return Colors.blue;
      case 'diproses':
        return Colors.orange;
      case 'selesai':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(PesananModel pesanan) {
    return pesanan.status.substring(0, 1).toUpperCase() +
        pesanan.status.substring(1);
  }

  Widget _actionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 8,
          children: [
            _filterChip('Semua', 'semua'),
            _filterChip('Baru', 'baru'),
            _filterChip('Diproses', 'diproses'),
            _filterChip('Selesai', 'selesai'),
            _filterChip('Ditolak', 'ditolak'),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterStatus = value);
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      showCheckmark: false,
    );
  }

  Widget _buildSummaryCards(int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _summaryCard(
              'Total Pesanan',
              '$total',
              Icons.receipt_long,
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPesananCard(
    PesananModel pesanan,
    AsyncValue<PelangganState> pelangganState,
    AsyncValue<PaketState> paketState,
  ) {
    final Color statusColor = _getStatusColor(pesanan);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withValues(alpha: 0.3), width: 1),
      ),
      child: InkWell(
        onTap: () => _showPesananDetail(pesanan, pelangganState, paketState),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: 12,
                    children: [
                      CircleAvatar(
                        backgroundColor: statusColor.withValues(
                          alpha: 25 / 255,
                        ),
                        child: Icon(Icons.person, color: statusColor),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pesanan.idPelanggan,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Pesanan #${pesanan.id}',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 25 / 255),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(pesanan),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                spacing: 8,
                children: [
                  const Icon(Icons.wifi, size: 16, color: Colors.grey),
                  Expanded(
                    child: Text(
                      pesanan.idPaket,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 8,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  Text(
                    DateFormat('dd MMM yyyy HH:mm').format(pesanan.tanggal),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 8,
                children: [
                  _actionButton('Proses', Icons.play_arrow, Colors.blue, () {
                    _updateStatus(pesanan, 'diproses');
                  }),
                  _actionButton(
                    'Selesai',
                    Icons.check_circle,
                    Colors.green,
                    () {
                      _updateStatus(pesanan, 'selesai');
                    },
                  ),
                  _actionButton('Tolak', Icons.cancel, Colors.red, () {
                    _updateStatus(pesanan, 'ditolak');
                  }),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: () => _hapusPesanan(pesanan),
                    tooltip: 'Hapus',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              spacing: 8,
              children: [
                Icon(icon, color: color, size: 24),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPesananList(
    List<PesananModel> daftar,
    AsyncValue<PelangganState> pelangganState,
    AsyncValue<PaketState> paketState,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: daftar.length,
      itemBuilder: (context, index) {
        final pesanan = daftar[index];
        return _buildPesananCard(pesanan, pelangganState, paketState);
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
