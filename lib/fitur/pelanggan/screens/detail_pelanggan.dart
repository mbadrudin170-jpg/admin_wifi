// path: lib/fitur/pelanggan/screens/detail_pelanggan.dart
import 'dart:async';

import 'package:admin_wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:admin_wifi/fitur/pelanggan/notifier/pelanggan_notifier.dart';
import 'package:admin_wifi/fitur/pelanggan/screens/form_pelanggan.dart';
import 'package:admin_wifi/halaman/pembantu/halaman_poin.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/core_shared.dart';
import 'package:flutter/services.dart';

// Mengganti developer log standar dengan log custom

class DetailPelangganPage extends StatefulWidget {
  final String idPelanggan;

  const DetailPelangganPage({super.key, required this.idPelanggan});

  @override
  State<DetailPelangganPage> createState() => _DetailPelangganPageState();
}

class _DetailPelangganPageState extends State<DetailPelangganPage> {
  // Global notifier untuk pelanggan (diakses lewat ProviderContainer terpisah)

  PelangganModel? pelanggan;
  int totalPoin = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Log inisialisasi state
    L.i(
      'Memulai siklus hidup initState pada DetailPelangganPage untuk ID Pelanggan: ${widget.idPelanggan}. Sistem akan segera memicu pemuatan data dari database.',
    );
    _loadData();
  }

  // Fungsi ini bertujuan untuk memuat data pelanggan dan total poin.
  Future<void> _loadData() async {
    L.i(
      'Menjalankan fungsi _loadData(). Mencoba melakukan pengambilan data paralel untuk profil pelanggan dan akumulasi poin dari database.',
    );
    try {
      // diubah: agar lebih ringkas
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      L.i(
        'Memulai request asinkron ke PelangganOperasi untuk mencari data dengan ID: ${widget.idPelanggan}',
      );
      final hasilPelanggan = await pelangganNotifierGlobal.getPelangganById(
        widget.idPelanggan,
      );

      L.i(
        'Memulai request asinkron ke TransaksiOperasi untuk menghitung total poin pelanggan ID: ${widget.idPelanggan}',
      );
      final hasilPoin = await pelangganNotifierGlobal.hitungTotalPoin(
        widget.idPelanggan,
      );

      if (!mounted) {
        L.w(
          'Fungsi _loadData() selesai tapi widget sudah tidak terpasang (not mounted) di pohon widget. Membatalkan pembaruan State untuk mencegah kebocoran memori.',
        );
        return;
      }

      setState(() {
        pelanggan = hasilPelanggan;
        totalPoin = hasilPoin;
        isLoading = false;
      });

      if (hasilPelanggan != null) {
        L.i(
          'Pemuatan data berhasil secara keseluruhan. Objek pelanggan atas nama "${hasilPelanggan.nama}" telah dimuat ke dalam state dan UI siap dirender ulang.',
        );
      } else {
        L.w(
          'Pemuatan data selesai tetapi mengembalikan nilai null. Pelanggan dengan ID: ${widget.idPelanggan} tidak ditemukan dalam koleksi database. UI akan menampilkan pesan data tidak ditemukan.',
        );
      }
    } catch (e, stackTrace) {
      L.e(
        'Terjadi kegagalan fatal saat proses pengambilan data di fungsi _loadData(). Hal ini bisa disebabkan oleh masalah koneksi database atau ketidakcocokan skema model. Error: $e $stackTrace',
      );
      if (mounted) {
        setState(() => isLoading = false);
        L.i(
          'State isLoading telah diatur ke false meskipun terjadi error agar spinner berhenti berputar.',
        );
      }
    }
  }

  // ditambahkan: fungsi untuk navigasi ke halaman edit
  void _editPelanggan() async {
    final p = pelanggan;
    if (p == null) return;
    L.i('Menavigasi ke FormPelanggan untuk mode edit dengan ID: ${p.id}');
    final result = await Nav.to(context, FormPelanggan(pelanggan: p));

    if (result == true && mounted) {
      L.i(
        'Kembali dari FormPelanggan dengan hasil true. Memuat ulang data pelanggan.',
      );
      _loadData(); // Muat ulang data untuk menampilkan perubahan
    } else {
      L.i('Kembali dari FormPelanggan tanpa menyimpan perubahan.');
    }
  }

  // Fungsi ini bertujuan untuk menyalin semua info pelanggan.
  void _salinSemuaInfo(BuildContext context, PelangganModel pelanggan) {
    L.i(
      'User memicu aksi _salinSemuaInfo(). Mempersiapkan penggabungan string untuk Nama: ${pelanggan.nama}, Telepon: ${pelanggan.telepon}, Alamat: ${pelanggan.alamat}, Password: ${pelanggan.password}, dan MAC: ${pelanggan.macAddress}.',
    );

    final info =
        '''
Nama : ${pelanggan.nama}
No HP : ${pelanggan.telepon}
Alamat : ${pelanggan.alamat}
Password : ${pelanggan.password}
MAC : ${pelanggan.macAddress}
'''
            .trim();

    Clipboard.setData(ClipboardData(text: info)).then((_) {
      L.i(
        'Data komprehensif pelanggan berhasil didorong ke sistem Clipboard perangkat.',
      );
    });

    AppToast.sukses(context, 'Semua info berhasil disalin');
  }

  // Fungsi ini bertujuan untuk menyalin data spesifik.
  void _salinData(BuildContext context, String label, String data) {
    L.i(
      'User memicu aksi _salinData() untuk bagian spesifik: $label dengan nilai data: $data.',
    );

    Clipboard.setData(ClipboardData(text: data)).then((_) {
      L.i('Berhasil menyalin data kategori $label ke Clipboard.');
    });

    AppToast.sukses(context, '$label berhasil disalin');
  }

  @override
  Widget build(BuildContext context) {
    L.i(
      'Membangun UI (build method) DetailPelangganPage. Status Loading: $isLoading, Pelanggan Terdeteksi: ${pelanggan != null}',
    );

    // Tampilkan loading spinner saat data sedang diambil
    if (isLoading) {
      L.i(
        'Merender tampilan CircularProgressIndicator karena status isLoading masih true.',
      );
      return Scaffold(
        appBar: AppBar(
          title: const Text('Memuat Detail...'),
        ), // diubah: judul appbar saat loading
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Cek jika data kosong setelah loading selesai
    final p = pelanggan;
    if (p == null) {
      L.w(
        'Merender tampilan pesan "Pelanggan tidak ditemukan" karena objek pelanggan bernilai null setelah proses loading selesai.',
      );
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pelanggan')),
        body: EmptyStateView(
          ikon: Icons.person_off,
          judul: 'Pelanggan tidak ditemukan',
          deskripsi: 'Data pelanggan dengan ID ini tidak tersedia.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pelanggan'),
        // ditambahkan: tombol edit di appbar
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Pelanggan',
            onPressed: _editPelanggan,
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
                  L.i(
                    'Interaksi pengguna: Mengetuk kartu Poin. Melakukan navigasi push ke HalamanPoin untuk pelanggan: ${p.nama}',
                  );
                  unawaited(
                    Nav.to(
                          context,
                          HalamanPoin(idPelanggan: widget.idPelanggan),
                        )
                        .then((_) {
                          L.i(
                            'Kembali dari HalamanPoin ke DetailPelangganPage.',
                          );
                          _loadData(); // ditambahkan: muat ulang data poin jika ada perubahan
                        })
                        .catchError((Object e, StackTrace s) {
                          L.e('Navigasi gagal: $e $s');
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
              L.i('Trigger tombol salin pada baris Nama.');
              _salinData(context, 'Nama', p.nama);
            }),
            const Divider(),
            _buildDetailRow(context, 'Telepon', p.telepon, () {
              L.i('Trigger tombol salin pada baris Telepon.');
              _salinData(context, 'No Telepon', p.telepon);
            }),
            const Divider(),
            _buildDetailRow(context, 'Alamat', p.alamat, () {
              L.i('Trigger tombol salin pada baris Alamat.');
              _salinData(context, 'Alamat', p.alamat);
            }),
            const Divider(),
            _buildDetailRow(context, 'Password', p.password, () {
              L.i('Trigger tombol salin pada baris Password.');
              _salinData(context, 'Password', p.password);
            }),
            const Divider(),
            _buildDetailRow(context, 'MAC Address', p.macAddress, () {
              L.i('Trigger tombol salin pada baris MAC Address.');
              _salinData(context, 'MAC Address', p.macAddress);
            }),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                L.i(
                  'Menekan tombol utama "Salin Semua Info" di bagian bawah layar.',
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
    // Log pembentukan widget row (opsional untuk sangat terperinci)
    // L.i('Membangun baris detail untuk kategori: $judul');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            judul,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
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
}
