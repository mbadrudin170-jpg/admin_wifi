// path: lib/halaman/detail/detail_paket.dart
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:admin_wifi/model/paket_model.dart';
import 'package:admin_wifi/halaman/form/form_paket.dart';

class DetailPaketPage extends StatefulWidget {
  final PaketModel paket;

  const DetailPaketPage({super.key, required this.paket});

  @override
  State<DetailPaketPage> createState() => _DetailPaketPageState();
}

class _DetailPaketPageState extends State<DetailPaketPage> {
  late PaketModel _paket;

  @override
  void initState() {
    super.initState();
    _paket = widget.paket;
    developer.log('[DetailPaket] 📦 : Menampilkan detail paket: ${_paket.nama} (ID: ${_paket.id})');
  }

  void _editPaket() async {
    developer.log('[DetailPaket] 📝 : Menuju Form Edit Paket: ${_paket.nama}');
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormPaket(paket: _paket),
      ),
    );

    if (result == true) {
      developer.log('[DetailPaket] 🔄 : Mendeteksi perubahan data paket.');
      if (mounted) {
        // Karena data paket kemungkinan besar berubah di DB, 
        // kita kirim sinyal 'true' ke halaman daftar untuk refresh list.
        developer.log('[DetailPaket] ⬅️ : Kembali ke list untuk menyegarkan data terbaru.');
        Navigator.pop(context, true);
      }
    } else {
      developer.log('[DetailPaket] ℹ️ : Pengguna membatalkan edit atau tidak ada perubahan.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_paket.nama),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            developer.log('[DetailPaket] 🔙 : Kembali ke halaman sebelumnya');
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: _editPaket,
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Paket',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.inventory_2, color: Colors.blueAccent),
                    const SizedBox(width: 8),
                    Text(
                      'Informasi Layanan',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDetailRow('Nama Paket', _paket.nama),
                _buildDetailRow('Harga Sewa', 'Rp ${_paket.harga}'),
                _buildDetailRow(
                  'Masa Aktif',
                  '${_paket.durasi} ${_paket.tipe.name}',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(thickness: 1),
                ),
                Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      'Sistem Poin',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Poin Hadiah', '${_paket.poinHadiah} Poin', 
                    subTitle: 'Didapat saat beli paket'),
                _buildDetailRow('Poin Penukaran', '${_paket.poinPenukaran} Poin',
                    subTitle: 'Syarat tukar gratis'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(thickness: 1),
                ),
                _buildDetailRow(
                  'Status Publik', 
                  _paket.isPublic ? 'Tersedia di Aplikasi' : 'Hanya Admin',
                  customValueColor: _paket.isPublic ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {String? subTitle, Color? customValueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                if (subTitle != null)
                  Text(
                    subTitle,
                    style: const TextStyle(
                      color: Colors.black38,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: customValueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}