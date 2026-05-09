// path: lib/halaman/detail/detail_pelanggan.dart
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
import 'package:admin_wifi/halaman/pembantu/halaman_poin.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer; // Import developer log

class DetailPelangganPage extends StatefulWidget {
  final String idPelanggan;

  const DetailPelangganPage({super.key, required this.idPelanggan});

  @override
  State<DetailPelangganPage> createState() => _DetailPelangganPageState();
}

class _DetailPelangganPageState extends State<DetailPelangganPage> {
  final PelangganOperasi pelangganOperasi = PelangganOperasi();
  final TransaksiOperasi transaksiOperasi = TransaksiOperasi();

  PelangganModel? pelanggan;
  int totalPoin = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    developer.log('[DetailPelanggan] 🚀 : Membuka detail pelanggan ID: ${widget.idPelanggan}');
    _loadData();
  }

  // Fungsi ini bertujuan untuk memuat data pelanggan dan total poin.
  Future<void> _loadData() async {
    try {
      developer.log('[DetailPelanggan] 📡 : Mengambil data dari database...');
      
      final hasilPelanggan = await pelangganOperasi.getPelangganById(
        widget.idPelanggan,
      );

      final hasilPoin = await transaksiOperasi.getTotalPoin(widget.idPelanggan);

      if (!mounted) return;

      setState(() {
        pelanggan = hasilPelanggan;
        totalPoin = hasilPoin;
        isLoading = false;
      });

      if (hasilPelanggan != null) {
        developer.log('[DetailPelanggan] ✅ : Data ditemukan: ${hasilPelanggan.nama}');
      } else {
        developer.log('[DetailPelanggan] ⚠️ : Data pelanggan tidak ditemukan di DB');
      }
    } catch (e, stackTrace) {
      developer.log(
        '[DetailPelanggan] ❌ : Error saat load data',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Fungsi ini bertujuan untuk menyalin semua info pelanggan.
  void _salinSemuaInfo(BuildContext context, PelangganModel pelanggan) {
    developer.log('[DetailPelanggan] 📋 : Menyalin semua info ke clipboard');
    final info = '''
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

  // Fungsi ini bertujuan untuk menyalin data spesifik.
  void _salinData(BuildContext context, String label, String data) {
    developer.log('[DetailPelanggan] 📎 : Menyalin $label');
    Clipboard.setData(ClipboardData(text: data));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label berhasil disalin')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading spinner saat data sedang diambil
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pelanggan')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Cek jika data kosong setelah loading selesai
    if (pelanggan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pelanggan')),
        body: const Center(child: Text('Pelanggan tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pelanggan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  developer.log('[DetailPelanggan] 🪙 : Menuju Halaman Poin');
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
                      const Text(
                        'Total Poin',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$totalPoin',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const Text(
                        'Klik untuk detail riwayat poin',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow(
              context,
              'Nama',
              pelanggan!.nama,
              () => _salinData(context, 'Nama', pelanggan!.nama),
            ),
            const Divider(),
            _buildDetailRow(
              context,
              'Telepon',
              pelanggan!.telepon,
              () => _salinData(context, 'No Telepon', pelanggan!.telepon),
            ),
            const Divider(),
            _buildDetailRow(
              context,
              'Alamat',
              pelanggan!.alamat,
              () => _salinData(context, 'Alamat', pelanggan!.alamat),
            ),
            const Divider(),
            _buildDetailRow(
              context,
              'Password',
              pelanggan!.password,
              () => _salinData(context, 'Password', pelanggan!.password),
            ),
            const Divider(),
            _buildDetailRow(
              context,
              'MAC Address',
              pelanggan!.macAddress,
              () => _salinData(context, 'MAC Address', pelanggan!.macAddress),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _salinSemuaInfo(context, pelanggan!),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            judul,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  detail.isEmpty ? '-' : detail,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              IconButton(
                onPressed: salinData,
                icon: const Icon(Icons.content_copy, size: 20),
                color: Colors.grey,
                tooltip: 'Salin $judul',
              ),
            ],
          ),
        ],
      ),
    );
  }
}