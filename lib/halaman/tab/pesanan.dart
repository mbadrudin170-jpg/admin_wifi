// path: lib/halaman/tab/pesanan.dart

// diubah: Mengganti path import, memperbaiki instansiasi, dan memperbaiki logika status
import 'package:admin_wifi/data/operasi/pesanan_operasi.dart';
import 'package:admin_wifi/fitur/pesanan/model/pesanan_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:share_global_saya/src/utils/navigator_helper.dart';

class HalamanPesan extends StatefulWidget {
  const HalamanPesan({super.key});

  @override
  State<HalamanPesan> createState() => _HalamanPesanState();
}

class _HalamanPesanState extends State<HalamanPesan> {
  final PesananOperasi _pesanOperasi = PesananOperasi();

  List<PesananModel> _daftarPesanan = [];
  bool _isLoading = true;
  String _filterStatus = 'semua';

  @override
  void initState() {
    super.initState();
    L.i('========================================');
    L.i('LIFECYCLE: initState() - Halaman HalamanPesan');
    L.i('Menginisialisasi halaman daftar pesanan.');
    L.i('Filter default: "semua" (menampilkan seluruh pesanan).');
    L.i('========================================');
    L.i('Memanggil _muatPesanan() untuk memuat data pesanan dari database.');
    _muatPesanan();
  }

  @override
  void dispose() {
    L.i('========================================');
    L.i('LIFECYCLE: dispose() - Halaman HalamanPesan');
    L.i('Membersihkan resource halaman daftar pesanan.');
    L.i('========================================');
    super.dispose();
  }

  Future<void> _muatPesanan() async {
    L.i('========================================');
    L.i('MEMUAT DATA PESANAN');
    L.i('Filter status: "$_filterStatus"');
    L.i('========================================');

    L.i(
      'Mengatur state _isLoading menjadi true untuk menampilkan indikator loading.',
    );
    setState(() => _isLoading = true);

    try {
      List<PesananModel> pesanan;
      if (_filterStatus == 'semua') {
        L.i('Mengambil SEMUA pesanan dari database (tanpa filter status).');
        pesanan = await _pesanOperasi.ambilSemuaPesanan();
        L.i(
          'Berhasil mengambil semua pesanan. Jumlah: ${pesanan.length} pesanan.',
        );
      } else {
        L.i('Mengambil pesanan dengan filter status: "$_filterStatus".');
        pesanan = await _pesanOperasi.ambilPesananByStatus(_filterStatus);
        L.i(
          'Berhasil mengambil pesanan dengan status "$_filterStatus". Jumlah: ${pesanan.length} pesanan.',
        );
      }

      L.i('Memperbarui state dengan data pesanan yang telah diambil.');
      L.i('  - _daftarPesanan: ${pesanan.length} item');
      L.i('  - _isLoading: false');

      setState(() {
        _daftarPesanan = pesanan;
        _isLoading = false;
      });

      L.i(
        'State berhasil diperbarui. UI akan menampilkan ${pesanan.length} pesanan.',
      );
    } catch (e, s) {
      L.e(
        'Gagal memuat data pesanan dari database. '
        'Filter yang digunakan: "$_filterStatus". '
        'Kemungkinan penyebab: koneksi database gagal, tabel pesanan tidak ditemukan, '
        'atau terjadi error saat query data. Error: $e $s',
      );
      L.i('Mengatur _isLoading menjadi false meskipun terjadi error.');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(PesananModel pesanan, String statusBaru) async {
    L.i('========================================');
    L.i('MENGUBAH STATUS PESANAN');
    L.i('ID Pesanan: ${pesanan.id}');
    L.i('ID Pelanggan: ${pesanan.idPelanggan}');
    L.i('ID Paket: ${pesanan.idPaket}');
    L.i('Status Lama: "${pesanan.status}"');
    L.i('Status Baru: "$statusBaru"');
    L.i('========================================');

    try {
      L.i(
        'Memanggil _pesanOperasi.updateStatusPesanan() untuk mengubah status di database.',
      );
      await _pesanOperasi.updateStatusPesanan(pesanan.id, statusBaru);
      L.i(
        'Status pesanan berhasil diubah di database dari "${pesanan.status}" menjadi "$statusBaru".',
      );

      L.i(
        'Memanggil _muatPesanan() untuk memperbarui tampilan daftar pesanan.',
      );
      await _muatPesanan();
      L.i('Daftar pesanan berhasil dimuat ulang.');

      if (mounted) {
        L.i('Widget masih mounted. Menampilkan SnackBar sukses.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Status pesanan #${pesanan.id} diubah menjadi "$statusBaru"',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        L.i('SnackBar sukses telah ditampilkan.');
      } else {
        L.w('Widget sudah tidak mounted. Tidak dapat menampilkan SnackBar.');
      }
    } catch (e, s) {
      L.e(
        'Gagal mengubah status pesanan #${pesanan.id} dari "${pesanan.status}" menjadi "$statusBaru". '
        'Kemungkinan penyebab: koneksi database gagal, data pesanan tidak ditemukan, '
        'atau nilai status baru tidak valid. Error: $e $s',
      );
      if (mounted) {
        L.i('Menampilkan SnackBar error ke pengguna.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengubah status: $e'),
            backgroundColor: Colors.red,
          ),
        );
        L.i('SnackBar error telah ditampilkan.');
      }
    }
  }

  Future<void> _hapusPesanan(PesananModel pesanan) async {
    L.i('========================================');
    L.i('KONFIRMASI HAPUS PESANAN');
    L.i('ID Pesanan: ${pesanan.id}');
    L.i('ID Pelanggan: ${pesanan.idPelanggan}');
    L.i('ID Paket: ${pesanan.idPaket}');
    L.i('Status: "${pesanan.status}"');
    L.i('Menampilkan dialog konfirmasi kepada pengguna.');
    L.i('========================================');

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pesanan'),
        content: Text('Yakin hapus pesanan dari ${pesanan.idPelanggan}?'),
        actions: [
          TextButton(
            onPressed: () {
              L.i('Dialog Hapus: Pengguna memilih BATAL.');
              Nav.pop(context, false);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              L.i('Dialog Hapus: Pengguna memilih HAPUS.');
              Nav.pop(context, true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    L.i(
      'Hasil konfirmasi: ${konfirmasi == true ? "DISETUJUI (true)" : "DIBATALKAN (${konfirmasi ?? "null"})"}',
    );

    if (konfirmasi == true) {
      L.i('Pengguna mengkonfirmasi penghapusan. Memproses hapus pesanan...');
      try {
        L.i(
          'Memanggil _pesanOperasi.hapusPesanan() untuk menghapus pesanan #${pesanan.id} dari database.',
        );
        await _pesanOperasi.hapusPesanan(pesanan.id);
        L.i('Pesanan #${pesanan.id} berhasil dihapus dari database.');

        L.i(
          'Memanggil _muatPesanan() untuk memperbarui tampilan daftar pesanan.',
        );
        await _muatPesanan();
        L.i('Daftar pesanan berhasil dimuat ulang.');

        if (mounted) {
          L.i('Widget masih mounted. Menampilkan SnackBar sukses hapus.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pesanan berhasil dihapus'),
              backgroundColor: Colors.red,
            ),
          );
          L.i('SnackBar sukses hapus telah ditampilkan.');
        } else {
          L.w('Widget sudah tidak mounted. Tidak dapat menampilkan SnackBar.');
        }
      } catch (e, s) {
        L.e(
          'Gagal menghapus pesanan #${pesanan.id}. '
          'Kemungkinan penyebab: koneksi database gagal, data pesanan tidak ditemukan, '
          'atau terjadi constraint violation. Error: $e $s',
        );
        if (mounted) {
          L.i('Menampilkan SnackBar error ke pengguna.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus pesanan: $e'),
              backgroundColor: Colors.red,
            ),
          );
          L.i('SnackBar error telah ditampilkan.');
        }
      }
    } else {
      L.i('Penghapusan dibatalkan oleh pengguna. Tidak ada perubahan data.');
    }
  }

  @override
  Widget build(BuildContext context) {
    L.i('========================================');
    L.i('LIFECYCLE: build() - Membangun UI HalamanPesan');
    L.i('Status loading: $_isLoading');
    L.i('Filter aktif: "$_filterStatus"');
    L.i('Jumlah pesanan ditampilkan: ${_daftarPesanan.length}');
    L.i('========================================');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pesanan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              L.i('AKSI: Tombol Refresh ditekan. Memuat ulang data pesanan.');
              _muatPesanan();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          _buildSummaryCards(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _daftarPesanan.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Belum ada pesanan',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : _buildPesananList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip('Semua', 'semua'),
            const SizedBox(width: 8),
            _filterChip('Baru', 'baru'),
            const SizedBox(width: 8),
            _filterChip('Diproses', 'diproses'),
            const SizedBox(width: 8),
            _filterChip('Selesai', 'selesai'),
            const SizedBox(width: 8),
            _filterChip('Ditolak', 'ditolak'),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        L.i(
          'FILTER: FilterChip "$label" (value: "$value") dipilih. Selected: $selected',
        );
        L.i('  - Filter sebelumnya: "$_filterStatus"');
        L.i('  - Filter baru: "$value"');
        setState(() => _filterStatus = value);
        L.i(
          'State _filterStatus berhasil diperbarui. Memanggil _muatPesanan() dengan filter baru.',
        );
        _muatPesanan();
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _summaryCard(
              'Total Pesanan',
              '${_daftarPesanan.length}',
              Icons.receipt_long,
              Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPesananList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _daftarPesanan.length,
      itemBuilder: (context, index) {
        final pesanan = _daftarPesanan[index];
        L.i(
          'Membangun kartu pesanan ke-${index + 1}/${_daftarPesanan.length}: '
          '#${pesanan.id} (Status: ${pesanan.status})',
        );
        return _buildPesananCard(pesanan);
      },
    );
  }

  Widget _buildPesananCard(PesananModel pesanan) {
    final Color statusColor = _getStatusColor(pesanan);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withAlpha((0.3 * 255).round()),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          L.i(
            'TAP: Kartu pesanan #${pesanan.id} di-tap. Menampilkan detail pesanan.',
          );
          _showPesananDetail(pesanan);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: statusColor.withAlpha(25),
                        child: Icon(Icons.person, color: statusColor),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pesanan.idPelanggan,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Pesanan #${pesanan.id}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(pesanan),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.wifi, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pesanan.idPaket,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd MMM yyyy HH:mm').format(pesanan.tanggal),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _actionButton('Proses', Icons.play_arrow, Colors.blue, () {
                    L.i(
                      'AKSI: Tombol "Proses" ditekan untuk pesanan #${pesanan.id}.',
                    );
                    _updateStatus(pesanan, 'diproses');
                  }),
                  const SizedBox(width: 8),
                  _actionButton('Selesai', Icons.check_circle, Colors.green, () {
                    L.i(
                      'AKSI: Tombol "Selesai" ditekan untuk pesanan #${pesanan.id}.',
                    );
                    _updateStatus(pesanan, 'selesai');
                  }),
                  const SizedBox(width: 8),
                  _actionButton('Tolak', Icons.cancel, Colors.red, () {
                    L.i(
                      'AKSI: Tombol "Tolak" ditekan untuk pesanan #${pesanan.id}.',
                    );
                    _updateStatus(pesanan, 'ditolak');
                  }),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: () {
                      L.i(
                        'AKSI: Tombol "Hapus" ditekan untuk pesanan #${pesanan.id}.',
                      );
                      _hapusPesanan(pesanan);
                    },
                    tooltip: 'Hapus',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Color _getStatusColor(PesananModel pesanan) {
    switch (pesanan.status) {
      case 'baru':
        return Colors.blue;
      case 'diproses':
        return Colors.orange;
      case 'selesai':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        L.w(
          'Status pesanan tidak dikenal: "${pesanan.status}" untuk pesanan #${pesanan.id}. Menggunakan warna default (grey).',
        );
        return Colors.grey;
    }
  }

  String _getStatusText(PesananModel pesanan) {
    return pesanan.status.substring(0, 1).toUpperCase() +
        pesanan.status.substring(1);
  }

  void _showPesananDetail(PesananModel pesanan) {
    L.i('========================================');
    L.i('MENAMPILKAN DETAIL PESANAN (Bottom Sheet)');
    L.i('ID Pesanan: ${pesanan.id}');
    L.i('ID Pelanggan: ${pesanan.idPelanggan}');
    L.i('ID Paket: ${pesanan.idPaket}');
    L.i('Status: "${pesanan.status}"');
    L.i('Tanggal: ${DateFormat("dd MMM yyyy HH:mm").format(pesanan.tanggal)}');
    L.i('========================================');

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Detail Pesanan #${pesanan.id}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _detailRow('Nama Pelanggan', pesanan.idPelanggan),
            _detailRow('Paket', pesanan.idPaket),
            _detailRow(
              'Tanggal',
              DateFormat('dd MMM yyyy HH:mm').format(pesanan.tanggal),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ).then((_) {
      L.i('Bottom Sheet detail pesanan #${pesanan.id} ditutup.');
    });
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
