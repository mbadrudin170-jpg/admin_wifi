// path: lib/fitur/kritik_saran/screens/kritik_saran.dart
// diubah: Sesuaikan dengan aturan code.md dan skill terkait (impor core_shared, hapus log narasi,
// empty state EmptyStateView, hasError tombol retry, warna ColorScheme, unawaited+catchError, L.e $e $s).

import 'dart:async';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:admin_wifi/fitur/kritik_saran/model/kritik_saran_model.dart';
import 'package:admin_wifi/fitur/kritik_saran/notifier/kritik_saran_notifier.dart';
import 'package:admin_wifi/fitur/kritik_saran/screens/detail_kritik_saran.dart';
import 'package:admin_wifi/widget/nama_pelanggan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/core_shared.dart';

class KritikSaranPage extends ConsumerStatefulWidget {
  const KritikSaranPage({super.key});

  @override
  ConsumerState<KritikSaranPage> createState() => _KritikSaranPageState();
}

class _KritikSaranPageState extends ConsumerState<KritikSaranPage> {
  Future<void> _hapusKritikSaran(KritikSaranModel item) async {
    try {
      final konfirmasi = await showOkCancelAlertDialog(
        context: context,
        title: 'Konfirmasi Hapus',
        message: 'Apakah Anda yakin ingin menghapus kritik dan saran ini?',
        okLabel: 'Hapus',
        cancelLabel: 'Batal',
        isDestructiveAction: true,
      );

      if (konfirmasi != OkCancelResult.ok) {
        return;
      }

      if (!mounted) return;

      await ref.read(kritikSaranProvider.notifier).hapusKritikSaran(item.id);

      if (mounted) {
        AppToast.sukses(context, 'Kritik dan saran berhasil dihapus');
      }
    } catch (e, s) {
      L.e('Gagal menghapus kritik/saran ID: ${item.id}: $e $s');
      if (mounted) {
        AppToast.gagal(context, 'Gagal menghapus kritik dan saran.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncKritikSaran = ref.watch(kritikSaranProvider);

    if (asyncKritikSaran.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (asyncKritikSaran.hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kritik & Saran')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              const Icon(Icons.error_outline, size: 48),
              Text(
                'Gagal memuat data kritik dan saran: ${asyncKritikSaran.error}',
                textAlign: TextAlign.center,
              ),
              FilledButton(
                onPressed: () => ref.refresh(kritikSaranProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final listKritikSaran = asyncKritikSaran.requireValue.listKritikSaran;
    if (listKritikSaran.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kritik & Saran')),
        body: EmptyStateView(
          ikon: CupertinoIcons.list_bullet,
          judul: 'Belum ada kritik dan saran',
          deskripsi:
              'Kritik dan saran akan muncul di sini setelah tersampaikan.',
          ctaLabel: 'Muat Ulang',
          onCta: () => ref.refresh(kritikSaranProvider),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Kritik & Saran')),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: listKritikSaran.length,
        itemBuilder: (context, index) {
          final item = listKritikSaran[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () async {
                await Nav.to(context, DetailKritikSaranPage(id: item.id));
              },
              onLongPress: () {
                unawaited(
                  _hapusKritikSaran(item).catchError((Object e, StackTrace s) {
                    L.e(
                      'Gagal konfirmasi hapus kritik/saran ID: ${item.id}: $e $s',
                    );
                  }),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person_pin,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        NamaPelangganWidget(
                          idPelanggan: item.userId,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.isi,
                      style: const TextStyle(fontSize: 15, height: 1.4),
                    ),
                    const Divider(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        FormatTanggal.formatDasar(item.tanggal),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
