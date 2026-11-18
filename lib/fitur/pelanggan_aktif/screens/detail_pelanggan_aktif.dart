// path: lib/fitur/pelanggan_aktif/screens/detail_pelanggan_aktif.dart
import 'dart:async';

import 'package:admin_wifi/fitur/paket/notifier/paket_notifier.dart';
import 'package:admin_wifi/fitur/paket/screens/detail_paket.dart';
import 'package:admin_wifi/fitur/pelanggan/notifier/pelanggan_notifier.dart';
import 'package:admin_wifi/fitur/pelanggan/screens/detail_pelanggan.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/notifer/pengguna_aktif_notifier.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/screens/form_pelanggan_aktif.dart';
import 'package:admin_wifi/utils/format_util.dart';
import 'package:admin_wifi/utils/perhitungan_util.dart';
import 'package:admin_wifi/whatsapp/info_paket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:share_global_saya/src/utils/navigator_helper.dart';
import 'package:share_global_saya/src/widget/toast_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPelangganAktif extends ConsumerStatefulWidget {
  final PelangganAktifModel pelanggan;

  const DetailPelangganAktif({super.key, required this.pelanggan});

  @override
  ConsumerState<DetailPelangganAktif> createState() {
    return _DetailPelangganAktifState();
  }
}

class _DetailPelangganAktifState extends ConsumerState<DetailPelangganAktif> {
  @override
  void initState() {
    super.initState();
    L.i(
      'DetailPelangganAktif initState, idPelangganAktif=${widget.pelanggan.id}',
    );
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    String formattedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    if (formattedNumber.startsWith('0')) {
      formattedNumber = '62${formattedNumber.substring(1)}';
    } else if (!formattedNumber.startsWith('62')) {
      formattedNumber = '62$formattedNumber';
    }

    final Uri whatsappUri = Uri.parse('https://wa.me/$formattedNumber');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        L.w('WhatsApp tidak terinstal; tidak dapat membuka $whatsappUri');
        throw StateError('WhatsApp tidak dapat dibuka: $whatsappUri');
      }
    } catch (e, s) {
      L.e('Gagal membuka WhatsApp untuk nomor $formattedNumber: $e $s');
      if (mounted) {
        AppToast.gagal(
          context,
          'Tidak dapat membuka WhatsApp. Pastikan sudah terinstal.',
        );
      }
    }
  }

  void _navigateToEdit(PelangganAktifModel pelangganAktif) async {
    try {
      await Nav.to(context, FormPelangganAktif(pelangganAktif: pelangganAktif));
    } catch (e, s) {
      L.e('Gagal membuka form edit pelanggan aktif: $e $s');
    }
  }

  @override
  void dispose() {
    L.i('DetailPelangganAktif dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final penggunaAktifAsync = ref.watch(penggunaAktifProvider);
    final pelangganAsync = ref.watch(pelangganProvider);
    final paketAsync = ref.watch(paketProvider);

    if (penggunaAktifAsync.isLoading ||
        pelangganAsync.isLoading ||
        paketAsync.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pelanggan')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (penggunaAktifAsync.hasError) {
      return _bangunLayarError(
        judul: 'Gagal memuat pelanggan aktif',
        pesan: '${penggunaAktifAsync.error}',
        onCobaLagi: () => ref.invalidate(penggunaAktifProvider),
      );
    }
    if (pelangganAsync.hasError) {
      return _bangunLayarError(
        judul: 'Gagal memuat daftar pelanggan',
        pesan: '${pelangganAsync.error}',
        onCobaLagi: () => ref.invalidate(pelangganProvider),
      );
    }
    if (paketAsync.hasError) {
      return _bangunLayarError(
        judul: 'Gagal memuat daftar paket',
        pesan: '${paketAsync.error}',
        onCobaLagi: () => ref.invalidate(paketProvider),
      );
    }

    final penggunaAktifState = penggunaAktifAsync.requireValue;
    final pelangganState = pelangganAsync.requireValue;
    final paketState = paketAsync.requireValue;

    // Ambil data terbaru dari notifier; fallback ke data dari widget
    // bila rekaman tidak (lagi) ada di daftar.
    final pelangganAktifTerkini =
        penggunaAktifState.getById(widget.pelanggan.id) ?? widget.pelanggan;

    final pelanggan = pelangganState.getById(pelangganAktifTerkini.idPelanggan);

    final idPaket = pelangganAktifTerkini.idPaket;
    final paket = idPaket.isEmpty ? null : paketState.getById(idPaket);

    return Scaffold(
      appBar: AppBar(
        title: Text(pelanggan?.nama ?? 'Detail Pelanggan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Nav.pop(context, true);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _navigateToEdit(pelangganAktifTerkini);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: TextButton(
                          onPressed: () {
                            if (pelanggan != null) {
                              unawaited(
                                Nav.to(
                                  context,
                                  DetailPelangganPage(
                                    idPelanggan: pelanggan.id,
                                  ),
                                ).catchError((Object e, StackTrace s) {
                                  L.e(
                                    'Gagal navigasi ke detail pelanggan: $e $s',
                                  );
                                  return null;
                                }),
                              );
                            } else {
                              L.w(
                                'Tidak dapat navigasi ke detail pelanggan karena data pelanggan masih null.',
                              );
                            }
                          },
                          child: Text(
                            pelanggan?.nama ??
                                pelangganAktifTerkini.idPelanggan,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      _buildWhatsAppInfoRow(
                        'No HP',
                        pelanggan?.telepon ?? 'Tidak ditemukan',
                      ),
                      InkWell(
                        onTap: () {
                          if (paket != null) {
                            unawaited(
                              Nav.to(
                                context,
                                DetailPaketPage(paket: paket),
                              ).catchError((Object e, StackTrace s) {
                                L.e('Gagal navigasi ke detail paket: $e $s');
                                return null;
                              }),
                            );
                          } else {
                            L.w(
                              'Tidak dapat navigasi ke detail paket karena data paket masih null.',
                            );
                          }
                        },
                        child: _buildInfoRow(
                          'Paket',
                          paket?.nama ??
                              '(ID: ${pelangganAktifTerkini.idPaket})',
                          isLink: true,
                        ),
                      ),
                      _buildInfoRow(
                        'Status',
                        pelangganAktifTerkini.status.label,
                      ),
                      if (paket != null)
                        _buildInfoRow(
                          'Poin Diperoleh',
                          '${paket.poinHadiah} Poin',
                        ),
                      _buildInfoRow(
                        'Mulai',
                        '${FormatTanggal.formatTanggalRingkas(pelangganAktifTerkini.tanggalMulai)} - ${FormatJam.formatJamMenit(pelangganAktifTerkini.tanggalMulai)}',
                      ),
                      _buildInfoRow(
                        'Berakhir',
                        '${FormatTanggal.formatTanggalRingkas(pelangganAktifTerkini.tanggalBerakhir)} - ${FormatJam.formatJamMenit(pelangganAktifTerkini.tanggalBerakhir)}',
                      ),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        PerhitunganUtil.getTeksSisaMasaAktif(
                          pelangganAktifTerkini.tanggalBerakhir,
                        ),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: PerhitunganUtil.getWarnaSisaMasaAktif(
                            pelangganAktifTerkini.tanggalBerakhir,
                          ),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.send_to_mobile),
                        label: const Text('Kirim Info via WhatsApp'),
                        onPressed: () {
                          unawaited(
                            PesanInfoPaket.kirimRincianPaket(
                              pelangganAktifTerkini,
                            ).catchError((Object e, StackTrace s) {
                              L.e('Gagal mengirim rincian paket: $e $s');
                            }),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.green.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bangunLayarError({
    required String judul,
    required String pesan,
    required void Function() onCobaLagi,
  }) {
    return Scaffold(
      appBar: AppBar(title: Text(judul)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              const Icon(Icons.error_outline, size: 48),
              Text(pesan, textAlign: TextAlign.center),
              FilledButton(
                onPressed: onCobaLagi,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 8,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isLink ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 8,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          InkWell(
            onTap: () {
              _launchWhatsApp(value);
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Row(
                spacing: 8,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  FaIcon(
                    FontAwesomeIcons.whatsapp,
                    color: Colors.green.shade700,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
