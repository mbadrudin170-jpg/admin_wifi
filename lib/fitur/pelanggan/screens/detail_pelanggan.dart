// path: lib/fitur/pelanggan/screens/detail_pelanggan.dart

import 'dart:async';

import 'package:admin_wifi/fitur/pelanggan/helper/pelanggan_poin_helper.dart';
import 'package:admin_wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:admin_wifi/fitur/pelanggan/notifier/pelanggan_notifier.dart';
import 'package:admin_wifi/fitur/pelanggan/screens/form_pelanggan.dart';
import 'package:admin_wifi/fitur/pelanggan/state/pelanggan_state.dart';
import 'package:admin_wifi/fitur/transaksi/notifier/transaksi_notifier.dart';
import 'package:admin_wifi/halaman/pembantu/halaman_poin.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/core_shared.dart';

/// Halaman detail satu pelanggan.
///
/// Data pelanggan dan total poin dibaca dari provider Riverpod via [ref.watch]
/// di [build]. Query data dilakukan di state Freezed sebagai method in-memory
/// (`getById`, `getPoinYangDihasilkan`, `getPoinYangDigunakan`), bukan via
/// `pelangganNotifierGlobal` yang langsung query DB (code.md #29).
class DetailPelangganPage extends ConsumerStatefulWidget {
  final String idPelanggan;

  const DetailPelangganPage({super.key, required this.idPelanggan});

  @override
  ConsumerState<DetailPelangganPage> createState() =>
      _DetailPelangganPageState();
}

class _DetailPelangganPageState extends ConsumerState<DetailPelangganPage> {
  /// Navigasi ke halaman edit pelanggan; refresh data saat perubahan disimpan.
  void _editPelanggan(PelangganState pelangganState) {
    final p = pelangganState.getById(widget.idPelanggan);
    if (p == null) {
      AppToast.gagal(context, 'Pelanggan tidak ditemukan');
      return;
    }

    L.i('Menavigasi ke FormPelanggan untuk mode edit dengan ID: ${p.id}');
    unawaited(
      Nav.to(context, FormPelanggan(pelanggan: p)).catchError((
        Object e,
        StackTrace s,
      ) {
        L.e('Navigasi ke FormPelanggan gagal: $e $s');
        return null;
      }),
    );
  }

  /// Menyalin seluruh info pelanggan ke Clipboard.
  void _salinSemuaInfo(BuildContext context, PelangganModel pelanggan) {
    final info =
        '''
Nama : ${pelanggan.nama}
No HP : ${pelanggan.telepon}
Alamat : ${pelanggan.alamat}
Password : ${pelanggan.password}
MAC : ${pelanggan.macAddress}
'''
            .trim();

    unawaited(
      Clipboard.setData(ClipboardData(text: info))
          .then((_) {
            L.i(
              'Semua info pelanggan "${pelanggan.nama}" disalin ke Clipboard.',
            );
            AppToast.sukses(context, 'Semua info berhasil disalin');
          })
          .catchError((Object e, StackTrace s) {
            L.e('Gagal menyalin semua info ke Clipboard: $e $s');
            AppToast.gagal(context, 'Gagal menyalin semua info: $e');
            return null;
          }),
    );
  }

  /// Menyalin data spesifik [label] dengan nilai [data] ke Clipboard.
  void _salinData(BuildContext context, String label, String data) {
    unawaited(
      Clipboard.setData(ClipboardData(text: data))
          .then((_) {
            L.i('Data "$label" berhasil disalin ke Clipboard.');
            AppToast.sukses(context, '$label berhasil disalin');
          })
          .catchError((Object e, StackTrace s) {
            L.e('Gagal menyalin data "$label" ke Clipboard: $e $s');
            AppToast.gagal(context, 'Gagal menyalin $label: $e');
            return null;
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncPelanggan = ref.watch(pelangganProvider);
    final asyncTransaksi = ref.watch(transaksiProvider);

    // Loading gabungan: jika salah satu provider masih loading, tampilkan indikator.
    if (asyncPelanggan.isLoading || asyncTransaksi.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Error per provider ditangani secara terpisah via satu helper bersama;
    // retry memakai ref.refresh dengan hasil yang dipakai (code.md #24 / #41).
    if (asyncPelanggan.hasError) {
      return _buildError(
        'Gagal memuat data pelanggan: ${asyncPelanggan.error}',
        () => ref.refresh(pelangganProvider),
      );
    }
    if (asyncTransaksi.hasError) {
      return _buildError(
        'Gagal memuat data transaksi: ${asyncTransaksi.error}',
        () => ref.refresh(transaksiProvider),
      );
    }

    final pelangganState = asyncPelanggan.requireValue;
    final transaksiState = asyncTransaksi.requireValue;

    // Query in-memory di state (Freezed), bukan query DB langsung dari notifier.
    final p = pelangganState.getById(widget.idPelanggan);
    if (p == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pelanggan')),
        body: const EmptyStateView(
          ikon: Icons.person_off,
          judul: 'Pelanggan tidak ditemukan',
          deskripsi: 'Data pelanggan dengan ID ini tidak tersedia.',
        ),
      );
    }

    final poinAwal = p.poinAwal;
    final poinDihasilkan = transaksiState.getPoinYangDihasilkan(
      widget.idPelanggan,
    );
    final poinDigunakan = transaksiState.getPoinYangDigunakan(
      widget.idPelanggan,
    );
    final totalPoin = PelangganPoinHelper.hitungTotalPoin(
      poinAwal: poinAwal,
      poinDihasilkan: poinDihasilkan,
      poinDigunakan: poinDigunakan,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pelanggan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Pelanggan',
            onPressed: () => _editPelanggan(pelangganState),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  L.i('Kartu poin diklik untuk pelanggan: ${p.nama}');
                  unawaited(
                    Nav.to(
                      context,
                      HalamanPoin(idPelanggan: widget.idPelanggan),
                    ).catchError((Object e, StackTrace s) {
                      L.e('Navigasi ke HalamanPoin gagal: $e $s');
                      return null;
                    }),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Total Poin',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$totalPoin',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      Text(
                        'Klik untuk detail riwayat poin',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow(context, 'Nama', p.nama, () {
              _salinData(context, 'Nama', p.nama);
            }),
            const Divider(),
            _buildDetailRow(context, 'Telepon', p.telepon, () {
              _salinData(context, 'No Telepon', p.telepon);
            }),
            const Divider(),
            _buildDetailRow(context, 'Alamat', p.alamat, () {
              _salinData(context, 'Alamat', p.alamat);
            }),
            const Divider(),
            _buildDetailRow(context, 'Password', p.password, () {
              _salinData(context, 'Password', p.password);
            }),
            const Divider(),
            _buildDetailRow(context, 'MAC Address', p.macAddress, () {
              _salinData(context, 'MAC Address', p.macAddress);
            }),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                L.i(
                  'Menekan tombol utama "Salin Semua Info" untuk pelanggan: ${p.nama}',
                );
                _salinSemuaInfo(context, p);
              },
              icon: const Icon(Icons.copy_all),
              label: const Text('Salin Semua Info'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String judul,
    String detail,
    VoidCallback salinData,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        spacing: 4,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            judul,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  detail.isEmpty ? '-' : detail,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              IconButton(
                onPressed: salinData,
                icon: const Icon(Icons.content_copy, size: 20),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                tooltip: 'Salin $judul',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildError(String pesan, VoidCallback onRetry) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            Text(
              pesan,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            FilledButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}
