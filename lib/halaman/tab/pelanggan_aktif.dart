// path: lib/halaman/tab/pelanggan_aktif.dart
// diubah: Menghapus impor dan field yang tidak terpakai.

import 'package:admin_wifi/data/sync/unggah_data.dart';
import 'package:admin_wifi/model/enum/status_pembayaran.dart';
import 'package:admin_wifi/utils/format_util.dart';
import 'package:admin_wifi/utils/perhitungan_util.dart';
import 'package:admin_wifi/utils/sync_manager.dart';
import 'package:flutter/material.dart';
import 'package:admin_wifi/data/operasi/pelanggan_aktif_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/halaman/detail/detail_pelanggan_aktif.dart';
import 'package:admin_wifi/halaman/form/form_pelanggan_aktif.dart';
import 'package:admin_wifi/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/widget/nama_paket.dart';
import 'package:admin_wifi/widget/nama_pelanggan.dart';
import 'package:admin_wifi/services/cek_koneksi_internet.dart';

enum OpsiHapusPilihan { hapusSemua, arsipkanKadaluarsa, batal }

enum OpsiUrutkan {
  tanggalBerakhir,
  tanggalMulai,
  diPerbarui,
  namaAZ,
  namaZA,
  lunas,
  belumLunas,
  paketAktif,
  paketTidakAktif,
}

class PelangganAktifPage extends StatefulWidget {
  const PelangganAktifPage({super.key});

  @override
  State<PelangganAktifPage> createState() => _PelangganAktifPageState();
}

class _PelangganAktifPageState extends State<PelangganAktifPage>
    with AutomaticKeepAliveClientMixin<PelangganAktifPage> {
  final PelangganAktifOperasi _pelangganAktifOperasi = PelangganAktifOperasi();
  final PelangganOperasi _pelangganOperasi = PelangganOperasi();
  final now = DateTime.now();
  // State untuk data
  List<PelangganAktifModel> _semuaPelanggan = [];
  List<PelangganAktifModel> _hasilFilter = [];
  Map<String, String> _mapNamaPelanggan = {};
  bool _isLoading = true;
  OpsiUrutkan _urutanAktif = OpsiUrutkan.tanggalBerakhir;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _applyFilterAndSort();
  }

  Future<void> _refreshData() async {
    await _loadData(forceRefresh: true);
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final koneksiTersedia = await KoneksiInternetService.cekKoneksi();
      if (koneksiTersedia && forceRefresh) {
        await LayananUnggahData().unggahDataPelangganAktif();
        await SyncManager().setLastSyncTimestamp(now);
        await Future.delayed(const Duration(milliseconds: 500));
      }
      final pelangganList = await _pelangganOperasi.getPelanggan();
      _mapNamaPelanggan = {for (var p in pelangganList) p.id: p.nama};

      final pelangganAktifList = await _pelangganAktifOperasi
          .ambilSemuaPelangganAktif();
      _semuaPelanggan = pelangganAktifList;

      _applyFilterAndSort();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilterAndSort() {
    List<PelangganAktifModel> tempResult;

    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      tempResult = _semuaPelanggan.where((pelanggan) {
        final nama = _mapNamaPelanggan[pelanggan.idPelanggan]!.toLowerCase();
        return nama.contains(query);
      }).toList();
    } else {
      tempResult = List.of(_semuaPelanggan);
    }

    int Function(PelangganAktifModel, PelangganAktifModel) comparator;

    switch (_urutanAktif) {
      case OpsiUrutkan.tanggalBerakhir:
        comparator = (a, b) => a.tanggalBerakhir.compareTo(b.tanggalBerakhir);
        break;
      case OpsiUrutkan.tanggalMulai:
        comparator = (a, b) => a.tanggalMulai.compareTo(b.tanggalMulai);
        break;
      case OpsiUrutkan.diPerbarui:
        comparator = (a, b) {
          final dateA = a.diperbarui ?? a.tanggalMulai;
          final dateB = b.diperbarui ?? b.tanggalMulai;
          return dateB.compareTo(dateA);
        };
        break;
      case OpsiUrutkan.namaAZ:
      case OpsiUrutkan.namaZA:
        comparator = (a, b) {
          final namaA = _mapNamaPelanggan[a.idPelanggan] ?? '';
          final namaB = _mapNamaPelanggan[b.idPelanggan] ?? '';
          return _urutanAktif == OpsiUrutkan.namaAZ
              ? namaA.compareTo(namaB)
              : namaB.compareTo(namaA);
        };
        break;
      case OpsiUrutkan.lunas:
      case OpsiUrutkan.belumLunas:
        comparator = (a, b) {
          final isLunasA = a.status == StatusPembayaran.lunas;
          final isLunasB = b.status == StatusPembayaran.lunas;
          if (isLunasA == isLunasB) return 0;
          return (_urutanAktif == OpsiUrutkan.lunas)
              ? (isLunasA ? -1 : 1)
              : (isLunasA ? 1 : -1);
        };
        break;
      case OpsiUrutkan.paketAktif:
      case OpsiUrutkan.paketTidakAktif:
        comparator = (a, b) {
          final isAktifA = PerhitunganUtil.sisaHari(a.tanggalBerakhir) >= 0;
          final isAktifB = PerhitunganUtil.sisaHari(b.tanggalBerakhir) >= 0;
          if (isAktifA == isAktifB) return 0;
          return (_urutanAktif == OpsiUrutkan.paketAktif)
              ? (isAktifA ? -1 : 1)
              : (isAktifA ? 1 : -1);
        };
        break;
    }

    tempResult.sort(comparator);

    if (mounted) {
      setState(() {
        _hasilFilter = tempResult;
      });
    }
  }

  Future<void> _arsipkanPelanggan(PelangganAktifModel pelangganAktif) async {
    final bool? konfirmasi = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Arsipkan'),
          content: Wrap(
            children: [
              const Text('Yakin ingin mengarsipkan '),
              NamaPelangganWidget(
                idPelanggan: pelangganAktif.idPelanggan,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('?'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Arsipkan',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );

    if (konfirmasi == true) {
      try {
        await _pelangganAktifOperasi.arsipkanPelangganAktif(pelangganAktif.id);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pelanggan berhasil diarsipkan.'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _semuaPelanggan.removeWhere((p) => p.id == pelangganAktif.id);
          _hasilFilter.removeWhere((p) => p.id == pelangganAktif.id);
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengarsipkan pelanggan: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showUrutkanDialog() async {
    final OpsiUrutkan? pilihan = await showDialog<OpsiUrutkan>(
      context: context,
      builder: (BuildContext context) {
        Widget buildOption(String text, OpsiUrutkan value) {
          final bool isSelected = _urutanAktif == value;
          return Container(
            color: isSelected ? Theme.of(context).highlightColor : null,
            child: SimpleDialogOption(
              onPressed: () => Navigator.pop(context, value),
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }

        return SimpleDialog(
          title: const Text('Urutkan Berdasarkan'),
          children: <Widget>[
            buildOption('Tanggal Berakhir', OpsiUrutkan.tanggalBerakhir),
            buildOption('Tanggal Mulai', OpsiUrutkan.tanggalMulai),
            buildOption('Terakhir Diperbarui', OpsiUrutkan.diPerbarui),
            buildOption('Nama (A-Z)', OpsiUrutkan.namaAZ),
            buildOption('Nama (Z-A)', OpsiUrutkan.namaZA),
            buildOption('Status Pembayaran (Lunas)', OpsiUrutkan.lunas),
            buildOption(
              'Status Pembayaran (Belum Lunas)',
              OpsiUrutkan.belumLunas,
            ),
            buildOption('Status Paket (Aktif)', OpsiUrutkan.paketAktif),
            buildOption(
              'Status Paket (Tidak Aktif)',
              OpsiUrutkan.paketTidakAktif,
            ),
            SimpleDialogOption(
              child: const Text('Batal'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );

    if (pilihan != null && pilihan != _urutanAktif) {
      if (mounted) {
        setState(() {
          _urutanAktif = pilihan;
        });
      }
      _applyFilterAndSort();
    }
  }

  void _tambahPelangganAktif() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormPelangganAktif()),
    );
    if (!mounted) return;
    if (result == true) {
      _loadData(forceRefresh: true);
    }
  }

  void _opsiLanjutan() async {
    final OpsiHapusPilihan? pilihan = await showDialog<OpsiHapusPilihan>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Opsi Lanjutan'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, OpsiHapusPilihan.arsipkanKadaluarsa);
              },
              child: const Text('Arsipkan pelanggan kadaluarsa'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, OpsiHapusPilihan.hapusSemua);
              },
              child: Text(
                'Hapus Semua Pelanggan Aktif',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, OpsiHapusPilihan.batal);
              },
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    switch (pilihan) {
      case OpsiHapusPilihan.hapusSemua:
        final bool? konfirmasi = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Konfirmasi Hapus Semua'),
              content: const Text(
                'Yakin ingin menghapus SEMUA pelanggan aktif? Tindakan ini tidak dapat dibatalkan.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Hapus Semua'),
                ),
              ],
            );
          },
        );

        if (konfirmasi == true) {
          await _pelangganAktifOperasi.arsipkanSemuaPelangganAktif();
          _loadData(forceRefresh: true);
        }
        break;
      case OpsiHapusPilihan.arsipkanKadaluarsa:
        final int jumlahDiarsipkan = await _pelangganAktifOperasi
            .arsipkanPelangganKadaluarsa();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$jumlahDiarsipkan pelanggan kadaluarsa berhasil diarsipkan.',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        _loadData(forceRefresh: true);
        break;
      case OpsiHapusPilihan.batal:
      default:
        break;
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: _isSearching ? _buildSearchField() : const Text('Pelanggan Aktif'),
      actions: _isSearching ? _buildSearchActions() : _buildDefaultActions(),
    );
  }

  Widget _buildSearchField() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          hintText: 'Cari nama pelanggan...',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
        ),
      ),
    );
  }

  List<Widget> _buildSearchActions() {
    return [
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          if (mounted) {
            setState(() {
              _isSearching = false;
            });
          }
          _searchController.clear();
        },
        tooltip: 'Tutup Pencarian',
      ),
    ];
  }

  List<Widget> _buildDefaultActions() {
    return [
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          if (mounted) {
            setState(() {
              _isSearching = true;
            });
          }
        },
        tooltip: 'Cari',
      ),
      IconButton(
        icon: const Icon(Icons.sort),
        onPressed: _showUrutkanDialog,
        tooltip: 'Urutkan',
      ),
      IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: _opsiLanjutan,
        tooltip: 'Lainnya',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: _semuaPelanggan.isEmpty
                  ? const Center(
                      child: Text('Tidak ada pelanggan aktif ditemukan.'),
                    )
                  : _hasilFilter.isEmpty && _searchController.text.isNotEmpty
                  ? const Center(child: Text('Pelanggan tidak ditemukan.'))
                  : ListView.builder(
                      itemCount: _hasilFilter.length,
                      itemBuilder: (context, index) {
                        final pelanggan = _hasilFilter[index];
                        final statusPembayaranText =
                            pelanggan.status.displayName;
                        final statusPembayaranColor =
                            pelanggan.status == StatusPembayaran.lunas
                            ? Colors.green
                            : Colors.red;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onLongPress: () {
                              _arsipkanPelanggan(pelanggan);
                            },
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPelangganAktif(
                                    pelanggan: pelanggan,
                                  ),
                                ),
                              );
                              _loadData(forceRefresh: true);
                            },
                            child: ListTile(
                              title: NamaPelangganWidget(
                                idPelanggan: pelanggan.idPelanggan,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  NamaPaketWidget(idPaket: pelanggan.idPaket),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Pembayaran: $statusPembayaranText',
                                    style: TextStyle(
                                      color: statusPembayaranColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Status: ${PerhitunganUtil.getTeksSisaMasaAktif(pelanggan.tanggalBerakhir)}',
                                    style: TextStyle(
                                      color:
                                          PerhitunganUtil.getWarnaSisaMasaAktif(
                                            pelanggan.tanggalBerakhir,
                                          ),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Berakhir: ${FormatTanggal.formatTanggalBasic(pelanggan.tanggalBerakhir)} ${FormatJam.formatJamMenit(pelanggan.tanggalBerakhir)}',
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahPelangganAktif,
        child: const Icon(Icons.add),
      ),
    );
  }
}
