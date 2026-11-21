// path: lib/halaman/pembantu/halaman_poin.dart
import 'package:admin_wifi/fitur/paket/model/paket_model.dart';
import 'package:admin_wifi/fitur/paket/notifier/paket_notifier.dart';
import 'package:admin_wifi/fitur/transaksi/notifier/transaksi_notifier.dart';
import 'package:admin_wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:admin_wifi/utils/format_util.dart';
import 'package:admin_wifi/widget/nama_pelanggan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:share_global_saya/src/utils/navigator_helper.dart';

// Enum untuk mengontrol tab yang aktif
enum MenuPoin { penukaran, riwayat }

extension MenuPoinLabel on MenuPoin {
  String get label {
    switch (this) {
      case MenuPoin.penukaran:
        return 'Penukaran Hadiah';
      case MenuPoin.riwayat:
        return 'Riwayat Poin';
    }
  }
}

class HalamanPoin extends ConsumerStatefulWidget {
  final String idPelanggan;

  const HalamanPoin({super.key, required this.idPelanggan});

  @override
  ConsumerState<HalamanPoin> createState() => _HalamanPoinState();
}

class _HalamanPoinState extends ConsumerState<HalamanPoin> {
  MenuPoin _menuPilihan = MenuPoin.penukaran;

  int _totalPoin = 0;
  List<PaketModel> _daftarHadiah = [];
  List<TransaksiModel> _riwayatTransaksi = [];
  bool _isLoading = false;
  bool _isLoadingRiwayat = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDataPoin();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadDataPoin() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final totalPoin = await ref
          .read(transaksiProvider.notifier)
          .hitungTotalPoin(widget.idPelanggan);

      final daftarHadiah = await ref
          .read(paketProvider.notifier)
          .getPaketByIsPublic();

      if (!mounted) return;

      setState(() {
        _totalPoin = totalPoin;
        _daftarHadiah = daftarHadiah;
        _isLoading = false;
      });

      if (_menuPilihan == MenuPoin.riwayat) {
        await _loadRiwayatTransaksi();
      }
    } catch (e, stackTrace) {
      L.e('Gagal memuat data poin: $e $stackTrace');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data: $e';
      });
    }
  }

  // Method untuk memuat riwayat transaksi
  Future<void> _loadRiwayatTransaksi() async {
    if (!mounted) return;

    setState(() {
      _isLoadingRiwayat = true;
    });

    try {
      final transaksiState = await ref.read(transaksiProvider.future);
      final riwayatTransaksi = transaksiState.ambilTransaksiPoinByPelangganId(
        widget.idPelanggan,
      );

      if (!mounted) return;

      setState(() {
        _riwayatTransaksi = riwayatTransaksi;
        _isLoadingRiwayat = false;
      });
    } catch (e, stackTrace) {
      L.e('Gagal memuat riwayat transaksi: $e $stackTrace');

      if (!mounted) return;

      setState(() {
        _isLoadingRiwayat = false;
        _riwayatTransaksi = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Poin: '),
            NamaPelangganWidget(idPelanggan: widget.idPelanggan),
          ],
        ),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Nav.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildInfoPoinHeader(),
          _buildSegmentedControl(),
          Expanded(child: _buildContentView()),
        ],
      ),
    );
  }

  // Widget untuk menampilkan informasi total poin
  Widget _buildInfoPoinHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Total Poin Anda',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            '$_totalPoin',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Widget untuk tombol segment (Penukaran/Riwayat)
  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: SegmentedButton<MenuPoin>(
        segments: [
          ButtonSegment<MenuPoin>(
            value: MenuPoin.penukaran,
            label: Text(MenuPoin.penukaran.label),
            icon: const Icon(Icons.card_giftcard),
          ),
          ButtonSegment<MenuPoin>(
            value: MenuPoin.riwayat,
            label: Text(MenuPoin.riwayat.label),
            icon: const Icon(Icons.history),
          ),
        ],
        selected: {_menuPilihan},
        onSelectionChanged: (Set<MenuPoin> newSelection) async {
          final selection = newSelection.first;
          setState(() {
            _menuPilihan = selection;
          });

          if (selection == MenuPoin.riwayat && _riwayatTransaksi.isEmpty) {
            await _loadRiwayatTransaksi();
          }
        },
      ),
    );
  }

  // Widget untuk menampilkan konten berdasarkan tab yang dipilih
  Widget _buildContentView() {
    switch (_menuPilihan) {
      case MenuPoin.penukaran:
        return _buildDaftarHadiah();
      case MenuPoin.riwayat:
        return _buildRiwayatPoin();
    }
  }

  // Widget daftar hadiah yang terhubung dengan database
  Widget _buildDaftarHadiah() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            CircularProgressIndicator(),
            Text('Memuat daftar hadiah...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            ElevatedButton(
              onPressed: _loadDataPoin,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_daftarHadiah.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            Icon(Icons.card_giftcard, size: 48, color: Colors.grey),
            Text(
              'Belum ada hadiah tersedia',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _daftarHadiah.length,
      itemBuilder: (context, index) {
        final hadiah = _daftarHadiah[index];
        final cukupPoin = _totalPoin >= hadiah.poinPenukaran;
        final progresPoin = hadiah.poinPenukaran > 0
            ? (_totalPoin / hadiah.poinPenukaran).clamp(0.0, 1.0)
            : 1.0;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            title: Text(hadiah.nama),
            subtitle: Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${hadiah.poinPenukaran} Poin'),
                LinearProgressIndicator(
                  value: progresPoin,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    cukupPoin ? Colors.green : Colors.orange,
                  ),
                  minHeight: 8,
                ),
                Text(
                  'Poin Anda: $_totalPoin / ${hadiah.poinPenukaran}',
                  style: TextStyle(
                    fontSize: 12,
                    color: cukupPoin
                        ? Colors.green
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget riwayat poin yang terhubung dengan database
  Widget _buildRiwayatPoin() {
    if (_isLoadingRiwayat) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            CircularProgressIndicator(),
            Text('Memuat riwayat poin...'),
          ],
        ),
      );
    }

    if (_riwayatTransaksi.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            Icon(Icons.history, size: 48, color: Colors.grey),
            Text(
              'Belum ada riwayat poin',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _riwayatTransaksi.length,
      itemBuilder: (context, index) {
        final transaksi = _riwayatTransaksi[index];
        final isPenambahan = transaksi.poinYangDihasilkan > 0;
        final poinValue = isPenambahan
            ? transaksi.poinYangDihasilkan
            : transaksi.poinYangDigunakan;
        final poinStr = isPenambahan ? '+$poinValue' : '-$poinValue';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            leading: Icon(
              isPenambahan
                  ? Icons.add_circle_outline
                  : Icons.remove_circle_outline,
              color: isPenambahan ? Colors.green : Colors.red,
            ),
            title: Text(transaksi.keterangan),
            subtitle: Text(
              FormatTanggal.formatTanggalBasic(transaksi.tanggal),
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Text(
              poinStr,
              style: TextStyle(
                color: isPenambahan ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}
