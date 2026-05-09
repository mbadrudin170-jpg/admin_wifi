// path: lib/halaman/detail/detail_kritik_saran.dart
import 'dart:developer' as developer; // Ditambah: Import untuk logging
import 'package:admin_wifi/data/operasi/kritik_saran_operasi.dart';
import 'package:admin_wifi/model/kritik_saran_model.dart';
import 'package:admin_wifi/utils/format_util.dart';
import 'package:admin_wifi/widget/nama_dari_id.dart';
import 'package:flutter/material.dart';

class DetailKritikSaranPage extends StatefulWidget {
  final String id;

  const DetailKritikSaranPage({super.key, required this.id});

  @override
  State<DetailKritikSaranPage> createState() => _DetailKritikSaranPageState();
}

class _DetailKritikSaranPageState extends State<DetailKritikSaranPage> {
  final KritikSaranOperasi _kritikSaranOperasi = KritikSaranOperasi();
  late Future<KritikSaranModel> _kritikSaranFuture;

  @override
  void initState() {
    super.initState();
    developer.log('[DetailKritikSaran] 🚀 : Membuka detail ID: ${widget.id}');
    _loadData();
  }

  void _loadData() {
    _kritikSaranFuture = _kritikSaranOperasi.getKritikSaranById(widget.id).then((value) {
      developer.log('[DetailKritikSaran] ✅ : Data berhasil dimuat');
      return value;
    }).catchError((error) {
      developer.log('[DetailKritikSaran] ❌ : Error saat memuat data', error: error);
      throw error;
    });
  }

  // Fungsi untuk menghapus kritik saran
  Future<void> _hapusKritikSaran() async {
    developer.log('[DetailKritikSaran] 🗑️ : Meminta konfirmasi hapus');
    
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus kritik dan saran ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi == true && mounted) {
      developer.log('[DetailKritikSaran] ⏳ : Memulai proses penghapusan...');
      try {
        // Tampilkan loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        // Panggil fungsi hapus dari operasi
        await _kritikSaranOperasi.hapusKritikSaran(widget.id);

        // Tutup loading dialog
        if (mounted) Navigator.of(context).pop();

        developer.log('[DetailKritikSaran] ✨ : Kritik saran berhasil dihapus dari DB');

        // Tampilkan pesan sukses
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kritik dan saran berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Kembali ke halaman sebelumnya dengan sinyal 'true'
        if (mounted) Navigator.of(context).pop(true);
      } catch (e, stackTrace) {
        // Tutup loading dialog jika masih ada
        if (mounted) Navigator.of(context).pop();

        developer.log(
          '[DetailKritikSaran] ❌ : Gagal menghapus data', 
          error: e, 
          stackTrace: stackTrace
        );

        // Tampilkan pesan error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      developer.log('[DetailKritikSaran] ↩️ : Penghapusan dibatalkan oleh pengguna');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kritik & Saran'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _hapusKritikSaran,
            tooltip: 'Hapus Kritik & Saran',
          ),
        ],
      ),
      body: FutureBuilder<KritikSaranModel>(
        future: _kritikSaranFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final kritikSaran = snapshot.data!;
            return SingleChildScrollView( // Tambah scroll agar konten panjang aman
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: NamaDariIdWidget(
                              userId: kritikSaran.userId,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Pesan:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        kritikSaran.isi,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const Divider(height: 40),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          FormatTanggal.formatTanggalDanJam(kritikSaran.tanggal),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: Text('Data tidak ditemukan'));
          }
        },
      ),
    );
  }
}