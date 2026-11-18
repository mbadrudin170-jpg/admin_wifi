// path: lib/fitur/pelanggan_aktif/screens/detail_pelanggan_aktif.dart
import 'dart:async';

// diubah: Mengganti `jumlahPoin` yang sudah dihapus menjadi `poinHadiah`.
import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_aktif_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/screens/form_pelanggan_aktif.dart';
import 'package:admin_wifi/fitur/paket/screens/detail_paket.dart';
import 'package:admin_wifi/fitur/pelanggan/screens/detail_pelanggan.dart';
import 'package:admin_wifi/fitur/paket/model/paket_model.dart';
import 'package:admin_wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:admin_wifi/utils/format_util.dart';
import 'package:admin_wifi/utils/perhitungan_util.dart';
import 'package:admin_wifi/whatsapp/info_paket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_global_saya/src/utils/l.dart';
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
  late PelangganAktifModel _pelangganAktif;
  PelangganModel? _pelanggan;
  PaketModel? _paket;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    L.i(
      'DetailPelangganAktif initState, idPelangganAktif=${widget.pelanggan.id}',
    );

    _pelangganAktif = widget.pelanggan;
    unawaited(
      _loadDetails().catchError((Object e, StackTrace s) {
        L.e('Gagal memuat detail pelanggan aktif: $e $s');
      }),
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

  Future<void> _loadDetails() async {
    if (!mounted) {
      return;
    }

    setState(() => _isLoading = true);

    final pelangganOperasi = PelangganOperasi();
    final paketOperasi = PaketOperasi();

    final idPaket = _pelangganAktif.idPaket;

    try {
      final results = await Future.wait([
        pelangganOperasi.getPelangganById(_pelangganAktif.idPelanggan),
        if (idPaket.isNotEmpty)
          paketOperasi.getPaketById(idPaket)
        else
          Future.value(null),
      ]);

      if (mounted) {
        setState(() {
          _pelanggan = results[0] as PelangganModel?;
          _paket = results.length > 1 ? results[1] as PaketModel? : null;
          _isLoading = false;
        });
      }
    } catch (e, s) {
      L.e('Gagal memuat detail pelanggan aktif: $e $s');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FormPelangganAktif(pelangganAktif: _pelangganAktif),
      ),
    );

    if (result != true) {
      return;
    }

    final operasi = PelangganAktifOperasi();
    final updatedPelangganAktif = await operasi.ambilSatuPelangganAktif(
      _pelangganAktif.id,
    );

    if (!mounted) {
      return;
    }

    if (updatedPelangganAktif != null) {
      setState(() {
        _pelangganAktif = updatedPelangganAktif;
      });
      unawaited(
        _loadDetails().catchError((Object e, StackTrace s) {
          L.e('Gagal memuat detail pelanggan aktif: $e $s');
        }),
      );
    } else {
      L.w(
        'Data pelanggan aktif terbaru tidak ditemukan; kemungkinan sudah dihapus',
      );
    }
  }

  @override
  void dispose() {
    L.i('DetailPelangganAktif dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pelanggan?.nama ?? 'Detail Pelanggan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _navigateToEdit();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                                  if (_pelanggan != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DetailPelangganPage(
                                              idPelanggan: _pelanggan!.id,
                                            ),
                                      ),
                                    );
                                  } else {
                                    L.w(
                                      'Tidak dapat navigasi ke detail pelanggan karena data _pelanggan masih null.',
                                    );
                                  }
                                },
                                child: Text(
                                  _pelanggan?.nama ??
                                      _pelangganAktif.idPelanggan,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            _buildWhatsAppInfoRow(
                              'No HP',
                              _pelanggan?.telepon ?? 'Tidak ditemukan',
                            ),
                            InkWell(
                              onTap: () {
                                if (_paket != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailPaketPage(paket: _paket!),
                                    ),
                                  );
                                } else {
                                  L.w(
                                    'Tidak dapat navigasi ke detail paket karena data _paket masih null.',
                                  );
                                }
                              },
                              child: _buildInfoRow(
                                'Paket',
                                _paket?.nama ??
                                    '(ID: ${_pelangganAktif.idPaket})',
                                isLink: true,
                              ),
                            ),
                            _buildInfoRow(
                              'Status',
                              _pelangganAktif.status.label,
                            ),
                            if (_paket != null)
                              _buildInfoRow(
                                'Poin Diperoleh',
                                '${_paket!.poinHadiah} Poin',
                              ),
                            _buildInfoRow(
                              'Mulai',
                              '${FormatTanggal.formatTanggalRingkas(_pelangganAktif.tanggalMulai)} - ${FormatJam.formatJamMenit(_pelangganAktif.tanggalMulai)}',
                            ),
                            _buildInfoRow(
                              'Berakhir',
                              '${FormatTanggal.formatTanggalRingkas(_pelangganAktif.tanggalBerakhir)} - ${FormatJam.formatJamMenit(_pelangganAktif.tanggalBerakhir)}',
                            ),
                            const Divider(),
                            const SizedBox(height: 16),
                            Text(
                              PerhitunganUtil.getTeksSisaMasaAktif(
                                _pelangganAktif.tanggalBerakhir,
                              ),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color:
                                        PerhitunganUtil.getWarnaSisaMasaAktif(
                                          _pelangganAktif.tanggalBerakhir,
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
                                    _pelangganAktif,
                                  ).catchError((Object e, StackTrace s) {
                                    L.e('Gagal mengirim rincian paket: $e $s');
                                  }),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
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
