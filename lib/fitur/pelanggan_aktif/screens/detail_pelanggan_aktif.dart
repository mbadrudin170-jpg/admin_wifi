// path: lib/fitur/pelanggan_aktif/screens/detail_pelanggan_aktif.dart
// diubah: Mengganti `jumlahPoin` yang sudah dihapus menjadi `poinHadiah`.
import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_aktif_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/screens/form_pelanggan_aktif.dart';
import 'package:admin_wifi/halaman/detail/detail_paket.dart';
import 'package:admin_wifi/halaman/detail/detail_pelanggan.dart';
import 'package:admin_wifi/fitur/paket/model/paket_model.dart';
import 'package:admin_wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:admin_wifi/utils/format_util.dart';
import 'package:admin_wifi/utils/perhitungan_util.dart';
import 'package:admin_wifi/whatsapp/info_paket.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPelangganAktif extends StatefulWidget {
  final PelangganAktifModel pelanggan;

  const DetailPelangganAktif({super.key, required this.pelanggan});

  @override
  // ignore: no_logic_in_create_state
  State<DetailPelangganAktif> createState() {
    L.i(
      'Membuat state untuk DetailPelangganAktif. '
      'ID Pelanggan Aktif: ${pelanggan.id}, '
      'ID Pelanggan: ${pelanggan.idPelanggan}, '
      'ID Paket: ${pelanggan.idPaket}, '
      'Status: ${pelanggan.status.label}',
    );
    return _DetailPelangganAktifState();
  }
}

class _DetailPelangganAktifState extends State<DetailPelangganAktif> {
  late PelangganAktifModel _pelangganAktif;
  PelangganModel? _pelanggan;
  PaketModel? _paket;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    L.i('========================================');
    L.i('LIFECYCLE: initState() - Halaman DetailPelangganAktif');
    L.i('Inisialisasi awal dengan data dari widget:');
    L.i('  - ID Pelanggan Aktif: ${widget.pelanggan.id}');
    L.i('  - ID Pelanggan: ${widget.pelanggan.idPelanggan}');
    L.i('  - ID Paket: ${widget.pelanggan.idPaket}');
    L.i('  - Status: ${widget.pelanggan.status.label}');
    L.i('  - Tanggal Mulai: ${widget.pelanggan.tanggalMulai}');
    L.i('  - Tanggal Berakhir: ${widget.pelanggan.tanggalBerakhir}');
    L.i('========================================');

    _pelangganAktif = widget.pelanggan;
    L.i(
      'Variabel lokal _pelangganAktif telah diinisialisasi dengan data dari widget.',
    );
    L.i(
      'Memanggil _loadDetails() untuk mengambil data pelengkap (data Pelanggan dan Paket) dari database.',
    );
    _loadDetails();
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    L.i('========================================');
    L.i('WHATSAPP: Mencoba membuka aplikasi WhatsApp');
    L.i('Nomor telepon mentah yang diterima: $phoneNumber');
    L.i('========================================');

    L.i(
      'Membersihkan format nomor telepon. Menghapus semua karakter non-digit.',
    );
    String formattedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    L.i('Nomor setelah dibersihkan: $formattedNumber');

    if (formattedNumber.startsWith('0')) {
      L.i(
        'Nomor diawali dengan "0". Mengkonversi ke format internasional (62).',
      );
      formattedNumber = '62${formattedNumber.substring(1)}';
      L.i('Nomor setelah konversi dari awalan 0: $formattedNumber');
    } else if (!formattedNumber.startsWith('62')) {
      L.i(
        'Nomor tidak diawali dengan "62". Menambahkan kode negara Indonesia (62).',
      );
      formattedNumber = '62$formattedNumber';
      L.i('Nomor setelah penambahan kode negara: $formattedNumber');
    } else {
      L.i(
        'Nomor sudah dalam format internasional (62). Tidak perlu modifikasi.',
      );
    }

    L.i('Membuat URI WhatsApp: https://wa.me/$formattedNumber');
    final Uri whatsappUri = Uri.parse('https://wa.me/$formattedNumber');

    try {
      L.i('Memeriksa apakah perangkat dapat membuka URI WhatsApp.');
      if (await canLaunchUrl(whatsappUri)) {
        L.i(
          'URI WhatsApp dapat dibuka. Meluncurkan WhatsApp dengan mode external application.',
        );
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        L.i('WhatsApp berhasil dibuka. Nomor yang dituju: $formattedNumber');
      } else {
        L.w(
          'URI WhatsApp tidak dapat dibuka. Kemungkinan WhatsApp tidak terinstal di perangkat.',
        );
        throw 'Could not launch $whatsappUri';
      }
    } catch (e) {
      L.e(
        'Gagal membuka aplikasi WhatsApp untuk nomor: $formattedNumber. '
        'Kemungkinan penyebab: WhatsApp tidak terinstal, URI tidak valid, atau izin aplikasi tidak cukup. Error: $e',
      );
      if (mounted) {
        L.i('Widget masih mounted. Menampilkan SnackBar error ke pengguna.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tidak dapat membuka WhatsApp. Pastikan sudah terinstal.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        L.i('SnackBar error WhatsApp telah ditampilkan.');
      } else {
        L.w(
          'Widget sudah tidak mounted. Tidak dapat menampilkan SnackBar error WhatsApp.',
        );
      }
    }
  }

  Future<void> _loadDetails() async {
    L.i('========================================');
    L.i('MEMULAI PROSES PEMUATAN DATA DETAIL PELANGGAN AKTIF');
    L.i('========================================');

    if (!mounted) {
      L.w(
        'Widget sudah tidak mounted saat _loadDetails() dipanggil. '
        'Membatalkan proses pemuatan data untuk mencegah memory leak.',
      );
      return;
    }

    L.i('Widget masih mounted. Melanjutkan proses pemuatan data.');
    L.i(
      'Mengatur state _isLoading menjadi true untuk menampilkan indikator loading.',
    );
    setState(() => _isLoading = true);

    L.i(
      'Membuat instance PelangganOperasi untuk mengambil data pelanggan dari database.',
    );
    final pelangganOperasi = PelangganOperasi();
    L.i('PelangganOperasi instance dibuat: ${pelangganOperasi.hashCode}');

    L.i(
      'Membuat instance PaketOperasi untuk mengambil data paket dari database.',
    );
    final paketOperasi = PaketOperasi();
    L.i('PaketOperasi instance dibuat: ${paketOperasi.hashCode}');

    L.i(
      'Menyiapkan query paralel untuk mengambil data pelanggan dan paket secara bersamaan.',
    );
    L.i('  - Query 1: getPelangganById(${_pelangganAktif.idPelanggan})');

    final idPaket = _pelangganAktif.idPaket;
    L.i('  - ID Paket: ${idPaket.isNotEmpty ? idPaket : "KOSONG"}');
    L.i(
      '  - Query 2: ${idPaket.isNotEmpty ? "getPaketById($idPaket)" : "Future.value(null) karena ID Paket kosong"}',
    );

    try {
      L.i(
        'Menjalankan Future.wait untuk mengeksekusi kedua query secara paralel.',
      );
      final results = await Future.wait([
        pelangganOperasi.getPelangganById(_pelangganAktif.idPelanggan),
        if (idPaket.isNotEmpty)
          paketOperasi.getPaketById(idPaket)
        else
          Future.value(null),
      ]);

      L.i('Kedua query selesai dijalankan. Memproses hasil...');
      L.i(
        'Hasil query 1 (Pelanggan): ${results[0] != null ? "Ditemukan (Nama: ${(results[0] as PelangganModel).nama})" : "NULL - Pelanggan tidak ditemukan"}',
      );
      L.i(
        'Hasil query 2 (Paket): ${results.length > 1 && results[1] != null ? "Ditemukan (Nama: ${(results[1] as PaketModel).nama})" : "NULL atau tidak dicari"}',
      );

      if (mounted) {
        L.i(
          'Widget masih mounted. Memperbarui state dengan data yang telah diambil.',
        );
        setState(() {
          _pelanggan = results[0] as PelangganModel?;
          _paket = results.length > 1 ? results[1] as PaketModel? : null;
          _isLoading = false;
        });

        L.i('State berhasil diperbarui:');
        L.i(
          '  - _pelanggan: ${_pelanggan != null ? _pelanggan!.nama : "NULL"}',
        );
        L.i(
          '  - _paket: ${_paket != null ? "${_paket!.nama} (Poin Hadiah: ${_paket!.poinHadiah})" : "NULL"}',
        );
        L.i('  - _isLoading: $_isLoading');

        L.i('========================================');
        L.i('PEMUATAN DATA DETAIL PELANGGAN AKTIF BERHASIL');
        L.i('========================================');
      } else {
        L.w(
          'Widget sudah tidak mounted setelah data berhasil diambil. '
          'Data tidak akan diupdate ke state untuk mencegah error.',
        );
      }
    } catch (e, s) {
      L.e(
        'Gagal memuat detail pelanggan aktif. '
        'Proses _loadDetails() mengalami kegagalan. '
        'Kemungkinan penyebab: koneksi database gagal, data pelanggan tidak ditemukan, '
        'data paket tidak ditemukan, atau terjadi error saat menggabungkan hasil query. Error: $e $s',
      );
      if (mounted) {
        L.i(
          'Widget masih mounted. Mengatur _isLoading menjadi false agar UI menampilkan data yang tersedia.',
        );
        setState(() => _isLoading = false);
      } else {
        L.w(
          'Widget sudah tidak mounted. Tidak dapat memperbarui state _isLoading.',
        );
      }
    }
  }

  void _navigateToEdit() async {
    L.i('========================================');
    L.i('NAVIGASI: Menuju halaman edit pelanggan aktif');
    L.i('Data yang akan diedit:');
    L.i('  - ID Pelanggan Aktif: ${_pelangganAktif.id}');
    L.i('  - ID Pelanggan: ${_pelangganAktif.idPelanggan}');
    L.i('  - ID Paket: ${_pelangganAktif.idPaket}');
    L.i('  - Status Saat Ini: ${_pelangganAktif.status.label}');
    L.i('========================================');

    L.i(
      'Membuka halaman FormPelangganAktif dengan Navigator.push. '
      'Mengirim data _pelangganAktif terbaru ke form.',
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FormPelangganAktif(pelangganAktif: _pelangganAktif),
      ),
    );

    L.i('========================================');
    L.i('KEMBALI DARI FORM PELANGGAN AKTIF');
    L.i('Nilai result yang diterima: $result');
    L.i('========================================');

    if (result == true) {
      L.i('Result bernilai TRUE. User telah melakukan perubahan data di form.');
      L.i(
        'Akan mengambil data terbaru dari database untuk memperbarui tampilan.',
      );

      L.i('Membuat instance PelangganAktifOperasi untuk query data terbaru.');
      final operasi = PelangganAktifOperasi();

      L.i(
        'Mengambil data pelanggan aktif terbaru dengan ID: ${_pelangganAktif.id}',
      );
      final updatedPelangganAktif = await operasi.ambilSatuPelangganAktif(
        _pelangganAktif.id,
      );

      L.i(
        'Hasil query data terbaru: ${updatedPelangganAktif != null ? "Ditemukan (Status: ${updatedPelangganAktif.status.label})" : "NULL - Data tidak ditemukan"}',
      );

      if (mounted && updatedPelangganAktif != null) {
        L.i(
          'Widget masih mounted dan data terbaru ditemukan. Memperbarui state.',
        );
        setState(() {
          _pelangganAktif = updatedPelangganAktif;
        });
        L.i(
          '_pelangganAktif berhasil diperbarui. '
          'Status baru: ${updatedPelangganAktif.status.label}, '
          'Tanggal Berakhir: ${updatedPelangganAktif.tanggalBerakhir}',
        );

        L.i(
          'Memanggil _loadDetails() untuk memperbarui data pelanggan dan paket terkait.',
        );
        _loadDetails();
      } else if (!mounted) {
        L.w('Widget sudah tidak mounted. Tidak dapat memperbarui state.');
      } else if (updatedPelangganAktif == null) {
        L.w(
          'Data pelanggan aktif terbaru tidak ditemukan. '
          'Kemungkinan data telah dihapus dari database.',
        );
      }
    } else if (result == false) {
      L.i(
        'Result bernilai FALSE. User tidak melakukan perubahan data. Tidak perlu refresh.',
      );
    } else if (result == null) {
      L.i(
        'Result bernilai NULL. User menekan tombol back tanpa menyimpan. Tidak perlu refresh.',
      );
    } else {
      L.i(
        'Result bernilai: $result. Tidak ada tindakan refresh yang diperlukan.',
      );
    }
  }

  @override
  void dispose() {
    L.i('========================================');
    L.i('LIFECYCLE: dispose() - Halaman DetailPelangganAktif');
    L.i('ID Pelanggan Aktif: ${_pelangganAktif.id}');
    L.i('Membersihkan resource dan state halaman DetailPelangganAktif.');
    L.i('========================================');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    L.i('========================================');
    L.i('LIFECYCLE: build() - Membangun UI DetailPelangganAktif');
    L.i('Status loading: $_isLoading');
    L.i('Nama Pelanggan: ${_pelanggan?.nama ?? "Belum dimuat"}');
    L.i('Nama Paket: ${_paket?.nama ?? "Belum dimuat / Tidak ada"}');
    L.i('========================================');

    return Scaffold(
      appBar: AppBar(
        title: Text(_pelanggan?.nama ?? 'Detail Pelanggan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            L.i(
              'NAVIGASI: Tombol Kembali ditekan. '
              'Kembali ke halaman sebelumnya dengan result true.',
            );
            Navigator.pop(context, true);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              L.i('AKSI: Tombol Edit pada AppBar ditekan.');
              L.i('Memanggil _navigateToEdit() untuk membuka form edit.');
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
                                    L.i(
                                      'NAVIGASI: TextButton nama pelanggan ditekan.',
                                    );
                                    L.i(
                                      'Menuju halaman DetailPelangganPage dengan ID: ${_pelanggan!.id}',
                                    );
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
                                      ?.copyWith(color: Colors.blue),
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
                                  L.i('NAVIGASI: Row paket ditekan.');
                                  L.i(
                                    'Menuju halaman DetailPaketPage dengan data paket: ${_paket!.nama}',
                                  );
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
                                L.i('========================================');
                                L.i(
                                  'AKSI: Tombol Kirim Info via WhatsApp ditekan',
                                );
                                L.i(
                                  'Mengirim rincian paket ke pelanggan: ${_pelanggan?.nama ?? _pelangganAktif.idPelanggan}',
                                );
                                L.i('Data yang akan dikirim:');
                                L.i(
                                  '  - ID Pelanggan Aktif: ${_pelangganAktif.id}',
                                );
                                L.i(
                                  '  - Nama Paket: ${_paket?.nama ?? "Tidak ada"}',
                                );
                                L.i(
                                  '  - Status: ${_pelangganAktif.status.label}',
                                );
                                L.i(
                                  '  - Masa Aktif: ${PerhitunganUtil.getTeksSisaMasaAktif(_pelangganAktif.tanggalBerakhir)}',
                                );
                                L.i('========================================');
                                PesanInfoPaket.kirimRincianPaket(
                                  _pelangganAktif,
                                );
                                L.i(
                                  'Fungsi kirimRincianPaket telah dipanggil.',
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
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
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isLink ? Colors.blue : null,
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
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          InkWell(
            onTap: () {
              L.i(
                'WHATSAPP: Row nomor HP ditekan. Memanggil _launchWhatsApp dengan nomor: $value',
              );
              _launchWhatsApp(value);
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Row(
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(width: 8),
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
