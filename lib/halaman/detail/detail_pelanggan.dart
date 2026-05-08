// path: lib/halaman/detail/detail_pelanggan.dart
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
import 'package:admin_wifi/halaman/pembantu/halaman_poin.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DetailPelangganPage extends StatefulWidget {
  final String idPelanggan;

  const DetailPelangganPage({super.key, required this.idPelanggan});

  @override
  State<DetailPelangganPage> createState() => _DetailPelangganPageState();
}

class _DetailPelangganPageState extends State<DetailPelangganPage> {
  final PelangganOperasi pelangganOperasi = PelangganOperasi();
  final TransaksiOperasi transaksiModel = TransaksiOperasi();

  PelangganModel? pelanggan;
  int totalPoin = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Fungsi ini bertujuan untuk memuat data pelanggan dan total poin.
  Future<void> _loadData() async {
    final hasilPelanggan = await pelangganOperasi.getPelangganById(
      widget.idPelanggan,
    );

    final hasilPoin = await transaksiModel.getTotalPoin(widget.idPelanggan);

    if (!mounted) return;

    setState(() {
      pelanggan = hasilPelanggan;
      totalPoin = hasilPoin;
      isLoading = false;
    });
  }

  // Fungsi ini bertujuan untuk menyalin semua info pelanggan.
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

    Clipboard.setData(ClipboardData(text: info));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Semua info berhasil disalin')),
    );
  }

  // Fungsi ini bertujuan untuk menyalin data.
  void _salinData(BuildContext context, String data) {
    Clipboard.setData(ClipboardData(text: data));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Data berhasil disalin')));
  }

  @override
  Widget build(BuildContext context) {
    if (pelanggan == null) {
      return const Scaffold(
        body: Center(child: Text('Pelanggan tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pelanggan')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HalamanPoin(idPelanggan: widget.idPelanggan),
                    ),
                  );
                },

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    children: [
                      const Text('Total Poin'),

                      Text(
                        '$totalPoin',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            _buildDetailRow(
              context,
              'Nama',
              pelanggan!.nama,
              () => _salinData(context, pelanggan!.nama),
            ),

            const Divider(),

            _buildDetailRow(
              context,
              'Telepon',
              pelanggan!.telepon,
              () => _salinData(context, pelanggan!.telepon),
            ),

            const Divider(),

            _buildDetailRow(
              context,
              'Alamat',
              pelanggan!.alamat,
              () => _salinData(context, pelanggan!.alamat),
            ),

            const Divider(),

            _buildDetailRow(
              context,
              'Password',
              pelanggan!.password,
              () => _salinData(context, pelanggan!.password),
            ),

            const Divider(),

            _buildDetailRow(
              context,
              'MAC Address',
              pelanggan!.macAddress,
              () => _salinData(context, pelanggan!.macAddress),
            ),

            const SizedBox(height: 16),

            TextButton.icon(
              onPressed: () {
                _salinSemuaInfo(context, pelanggan!);
              },

              icon: const Icon(Icons.copy),

              label: const Text('Salin Info'),
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
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            judul,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(child: Text(detail.isEmpty ? '-' : detail)),

              IconButton(
                onPressed: salinData,
                icon: const Icon(Icons.content_copy),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
