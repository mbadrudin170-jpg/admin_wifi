// path: lib/halaman/lainnya/pengaturan.dart

import 'package:flutter/material.dart';
import 'package:admin_wifi/model/pengaturan_model.dart';
import 'package:admin_wifi/data/operasi/pengaturan_operasi.dart';
import '../form/form_pengaturan.dart';

// Halaman untuk menampilkan konfigurasi pengaturan aplikasi.
class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  final PengaturanOperasi _pengaturanOperasi = PengaturanOperasi();
  late Future<PengaturanModel> _futurePengaturan;

  @override
  void initState() {
    super.initState();
    _loadPengaturan();
  }

  // Fungsi untuk memuat data pengaturan dari database.
  void _loadPengaturan() {
    setState(() {
      _futurePengaturan = _pengaturanOperasi.getPengaturan();
    });
  }

  // Fungsi untuk menavigasi ke halaman form edit dan memuat ulang data jika ada perubahan.
  void _editPengaturan(PengaturanModel pengaturan) async {
    final hasil = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormPengaturan(pengaturan: pengaturan),
      ),
    );

    if (hasil == true && mounted) {
      _loadPengaturan();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Aplikasi')),
      body: FutureBuilder<PengaturanModel>(
        future: _futurePengaturan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final pengaturan = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        _buildInfoCard(
                          judul: 'Sinkronisasi Otomatis',
                          nilai:
                              '${pengaturan.intervalSinkronisasiOtomatis} Jam',
                          ikon: Icons.sync,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          judul: 'Hapus Arsip Otomatis',
                          nilai: '${pengaturan.hapusOtomatisDataArsip} Hari',
                          ikon: Icons.auto_delete_outlined,
                        ),
                        const Divider(height: 24, thickness: 1),
                        // ditambahkan: Card untuk semua pengaturan terkait pemeliharaan
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              SwitchListTile(
                                title: const Text(
                                  'Mode Pemeliharaan',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                value: pengaturan.modePemeliharaan,
                                onChanged: null, // Read-only di halaman ini
                                secondary: Icon(
                                  Icons.construction_outlined,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              // ditambahkan: Tampilkan info pemeliharaan hanya jika mode aktif
                              if (pengaturan.modePemeliharaan)
                                ListTile(
                                  leading: const Icon(Icons.info_outline),
                                  title: const Text(
                                    'Info Pemeliharaan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    pengaturan.infoPemeliharaan.isNotEmpty
                                        ? pengaturan.infoPemeliharaan
                                        : '(Tidak ada pesan diatur)',
                                  ),
                                  isThreeLine: true,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Pengaturan'),
                    onPressed: () => _editPengaturan(pengaturan),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Pengaturan tidak ditemukan.'));
          }
        },
      ),
    );
  }

  // Widget helper untuk membuat card informasi yang konsisten.
  Widget _buildInfoCard({
    required String judul,
    required String nilai,
    required IconData ikon,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 15,
        ),
        leading: Icon(ikon, size: 40, color: Theme.of(context).primaryColor),
        title: Text(judul, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          nilai,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
