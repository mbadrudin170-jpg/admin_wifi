// path: lib/fitur/pelanggan_aktif/screens/pelanggan_aktif_screen.dart

import 'dart:async';

import 'package:admin_wifi/data/operasi/pelanggan_aktif_operasi.dart';
import 'package:admin_wifi/data/sync/unggah_data.dart';
import 'package:admin_wifi/enum/status_pembayaran_enum.dart';
import 'package:admin_wifi/fitur/paket/notifier/paket_notifier.dart';
import 'package:admin_wifi/fitur/pelanggan/notifier/pelanggan_notifier.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/notifer/pengguna_aktif_notifier.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/screens/detail_pelanggan_aktif.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/screens/form_pelanggan_aktif.dart';
import 'package:admin_wifi/model/model.dart';
import 'package:admin_wifi/services/cek_koneksi_internet.dart';
import 'package:admin_wifi/utils/format_util.dart';
import 'package:admin_wifi/utils/perhitungan_util.dart';
import 'package:admin_wifi/utils/sync_manager.dart';
import 'package:admin_wifi/widget/nama_pelanggan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:share_global_saya/src/utils/l.dart';
import 'package:share_global_saya/src/utils/navigator_helper.dart';
import 'package:share_global_saya/src/widget/confirmation_dialog.dart';
import 'package:share_global_saya/src/widget/toast_widget.dart';

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

class PelangganAktifScreen extends ConsumerStatefulWidget {
  const PelangganAktifScreen({super.key});

  @override
  ConsumerState<PelangganAktifScreen> createState() =>
      _PelangganAktifScreenState();
}

class _PelangganAktifScreenState extends ConsumerState<PelangganAktifScreen> {
  final PelangganAktifOperasi _pelangganAktifOperasi = PelangganAktifOperasi();
  final now = DateTime.now();
  OpsiUrutkan _urutanAktif = OpsiUrutkan.tanggalBerakhir;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final KoneksiInternetService _koneksiService = KoneksiInternetService();

  @override
  void initState() {
    super.initState();
    L.i('Halaman Pelanggan Aktif sedang diinisialisasi.');
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    L.i('Halaman Pelanggan Aktif sedang dibersihkan.');
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Nilai turunan (filter/urut) dihitung ulang saat build; cukup memicu rebuild.
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _refreshData() async {
    L.i('Memuat ulang data Pelanggan Aktif karena permintaan pengguna.');
    await _loadData(forceRefresh: true);
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    if (!mounted) return;

    final syncManager = provider.Provider.of<SyncManager>(
      context,
      listen: false,
    );

    try {
      final koneksiTersedia = await _koneksiService.cekKoneksi();
      L.i(
        'Status koneksi internet saat ini: ${koneksiTersedia ? "Online" : "Offline"}.',
      );

      if (koneksiTersedia && forceRefresh) {
        L.i('Memulai pengunggahan data pelanggan aktif ke server.');
        await LayananUnggahData().unggahDataPelangganAktif().timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            L.w('Waktu unggah data habis.');
            throw 'Waktu sinkronisasi habis, periksa kembali koneksi internet Anda.';
          },
        );

        await syncManager.setTerakhirUnggah(now);
        L.i('Pengunggahan data pelanggan aktif berhasil.');
      } else if (!koneksiTersedia && forceRefresh) {
        L.w('Gagal memuat ulang data karena tidak ada koneksi internet.');
        if (mounted) {
          AppToast.warning(
            context,
            'Jaringan tidak tersedia. Menampilkan data lokal.',
          );
        }
      }

      if (forceRefresh) {
        // Paksa sinkronisasi ulang dari database lokal lewat notifier.
        await ref.read(pelangganProvider.notifier).muatUlang();
        await ref.read(paketProvider.notifier).muatUlang();
        await ref.read(penggunaAktifProvider.notifier).muatUlang();
        final jumlah =
            ref.read(penggunaAktifProvider).value?.jumlahPelangganAktif ?? 0;
        L.i(
          'Berhasil memuat $jumlah data pelanggan aktif dari database lokal.',
        );
      }
    } catch (e, s) {
      L.e('Terjadi kesalahan saat memuat data pelanggan aktif. Error: $e $s');
      if (mounted) {
        AppToast.gagal(context, 'Gagal memuat data: $e');
      }
    }
  }

  List<PelangganAktifModel> _filterAndSort(
    List<PelangganAktifModel> semua,
    Map<String, String> mapNamaPelanggan,
  ) {
    List<PelangganAktifModel> tempResult;
    final query = _searchController.text.toLowerCase();

    if (query.isNotEmpty) {
      tempResult = semua.where((pelanggan) {
        final nama =
            mapNamaPelanggan[pelanggan.idPelanggan]?.toLowerCase() ?? '';
        return nama.contains(query);
      }).toList();
    } else {
      tempResult = List.of(semua);
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
          final namaA = mapNamaPelanggan[a.idPelanggan] ?? '';
          final namaB = mapNamaPelanggan[b.idPelanggan] ?? '';
          return _urutanAktif == OpsiUrutkan.namaAZ
              ? namaA.compareTo(namaB)
              : namaB.compareTo(namaA);
        };
        break;
      case OpsiUrutkan.lunas:
      case OpsiUrutkan.belumLunas:
        comparator = (a, b) {
          final isLunasA = a.status == StatusPembayaranEnum.lunas;
          final isLunasB = b.status == StatusPembayaranEnum.lunas;
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
    return tempResult;
  }

  Future<void> _arsipkanPelanggan(PelangganAktifModel pelangganAktif) async {
    L.i(
      'Meminta konfirmasi untuk mengarsipkan pelanggan aktif dengan ID: ${pelangganAktif.id}.',
    );
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
              onPressed: () => Nav.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Nav.pop(context, true),
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
        await ref.read(penggunaAktifProvider.notifier).hapus(pelangganAktif.id);
        L.i(
          'Pelanggan aktif dengan ID: ${pelangganAktif.id} berhasil diarsipkan.',
        );

        if (!mounted) return;
        AppToast.sukses(context, 'Pelanggan berhasil diarsipkan.');
      } catch (e, s) {
        L.e(
          'Gagal mengarsipkan pelanggan aktif dengan ID: ${pelangganAktif.id}. Error: $e $s',
        );
        if (!mounted) return;
        AppToast.gagal(context, 'Gagal mengarsipkan pelanggan: $e');
      }
    }
  }

  void _showUrutkanDialog() async {
    L.i('Membuka dialog untuk memilih opsi pengurutan.');
    final OpsiUrutkan? pilihan = await showDialog<OpsiUrutkan>(
      context: context,
      builder: (BuildContext context) {
        Widget buildOption(String text, OpsiUrutkan value) {
          final bool isSelected = _urutanAktif == value;
          return Container(
            color: isSelected ? Theme.of(context).highlightColor : null,
            child: SimpleDialogOption(
              onPressed: () => Nav.pop(context, value),
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
              onPressed: () => Nav.pop(context),
            ),
          ],
        );
      },
    );

    if (pilihan != null && pilihan != _urutanAktif) {
      L.i('Data diurutkan berdasarkan: ${pilihan.name}.');
      if (mounted) {
        setState(() {
          _urutanAktif = pilihan;
        });
      }
    }
  }

  void _tambahPelangganAktif() async {
    L.i('Navigasi ke halaman tambah pelanggan aktif.');
    final result = await Nav.to(context, FormPelangganAktif());
    if (!mounted) return;
    if (result == true) {
      L.i('Berhasil menambahkan pelanggan aktif baru.');
      _loadData(forceRefresh: true);
    }
  }

  void _opsiLanjutan() async {
    L.i('Membuka dialog opsi lanjutan.');
    final OpsiHapusPilihan? pilihan = await showDialog<OpsiHapusPilihan>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Opsi Lanjutan'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () =>
                  Nav.pop(context, OpsiHapusPilihan.arsipkanKadaluarsa),
              child: const Text('Arsipkan pelanggan kadaluarsa'),
            ),
            SimpleDialogOption(
              onPressed: () => Nav.pop(context, OpsiHapusPilihan.hapusSemua),
              child: Text(
                'Hapus Semua Pelanggan Aktif',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Nav.pop(context, OpsiHapusPilihan.batal),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    switch (pilihan) {
      case OpsiHapusPilihan.hapusSemua:
        L.w('Meminta konfirmasi untuk menghapus semua pelanggan aktif.');
        final bool? konfirmasi = await ConfirmationDialog.showDeleteAll(
          context: context,
          itemName: 'pelanggan aktif',
          title: 'Konfirmasi Hapus Semua',
        );

        if (konfirmasi == true) {
          await _pelangganAktifOperasi.arsipkanSemuaPelangganAktif();
          L.i('Semua pelanggan aktif berhasil diarsipkan.');
          _loadData(forceRefresh: true);
        }
        break;
      case OpsiHapusPilihan.arsipkanKadaluarsa:
        L.i(
          'Memulai proses pengarsipan pelanggan aktif yang sudah kadaluarsa.',
        );
        final int jumlahDiarsipkan = await _pelangganAktifOperasi
            .arsipkanPelangganKadaluarsa();
        L.i(
          'Berhasil mengarsipkan $jumlahDiarsipkan pelanggan aktif yang sudah kadaluarsa.',
        );
        if (!mounted) return;
        AppToast.sukses(
          context,
          '$jumlahDiarsipkan pelanggan kadaluarsa berhasil diarsipkan.',
        );
        _loadData(forceRefresh: true);
        break;
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
                  onPressed: () => _searchController.clear(),
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
          L.i('Menutup mode pencarian.');
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
          L.i('Membuka mode pencarian.');
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

  Widget _buildMuatGagal(String pesan, VoidCallback onCobaLagi) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            const Icon(Icons.error_outline, size: 48),
            Text(pesan, textAlign: TextAlign.center),
            FilledButton(onPressed: onCobaLagi, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncPelangganAktif = ref.watch(penggunaAktifProvider);
    final asyncPelanggan = ref.watch(pelangganProvider);
    final asyncPaket = ref.watch(paketProvider);

    Widget buildBody() {
      if (asyncPelangganAktif.isLoading ||
          asyncPelanggan.isLoading ||
          asyncPaket.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (asyncPelangganAktif.hasError) {
        return _buildMuatGagal(
          'Gagal memuat data: ${asyncPelangganAktif.error}',
          () => ref.refresh(penggunaAktifProvider),
        );
      }
      if (asyncPelanggan.hasError) {
        return _buildMuatGagal(
          'Gagal memuat data: ${asyncPelanggan.error}',
          () => ref.refresh(pelangganProvider),
        );
      }
      if (asyncPaket.hasError) {
        return _buildMuatGagal(
          'Gagal memuat data: ${asyncPaket.error}',
          () => ref.refresh(paketProvider),
        );
      }

      final pelangganState = asyncPelanggan.requireValue;
      final paketState = asyncPaket.requireValue;
      final pelangganAktifAsync = asyncPelangganAktif.requireValue;

      final semuaPelanggan = pelangganAktifAsync.listPelangganAktif;
      final mapNamaPelanggan = {
        for (final p in pelangganState.listPelanggan) p.id: p.nama,
      };
      final hasilFilter = _filterAndSort(semuaPelanggan, mapNamaPelanggan);

      return RefreshIndicator(
        onRefresh: _refreshData,
        child: semuaPelanggan.isEmpty
            ? const Center(child: Text('Tidak ada pelanggan aktif ditemukan.'))
            : hasilFilter.isEmpty && _searchController.text.isNotEmpty
            ? const Center(child: Text('Pelanggan tidak ditemukan.'))
            : ListView.builder(
                itemCount: hasilFilter.length,
                itemBuilder: (context, index) {
                  final pelangganAktif = hasilFilter[index];
                  final statusPembayaran = pelangganAktif.status;
                  final pelanggan = pelangganState.getById(
                    pelangganAktif.idPelanggan,
                  );
                  final paket = paketState.getById(pelangganAktif.idPaket);
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onLongPress: () => _arsipkanPelanggan(pelangganAktif),
                      onTap: () async {
                        L.i(
                          'Navigasi ke halaman detail pelanggan aktif dengan ID: ${pelangganAktif.id}.',
                        );
                        await Nav.to(
                          context,
                          DetailPelangganAktif(pelanggan: pelangganAktif),
                        );
                        _loadData(forceRefresh: true);
                      },
                      child: ListTile(
                        title: Text(
                          pelanggan?.nama ?? 'Pelanggan tidak ditemukan',
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            Text(paket?.nama ?? 'Paket tidak ditemukan'),
                            Text(
                              'Pembayaran: ${statusPembayaran.label}',
                              style: TextStyle(
                                color:
                                    statusPembayaran ==
                                        StatusPembayaranEnum.lunas
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Status: ${PerhitunganUtil.getTeksSisaMasaAktif(pelangganAktif.tanggalBerakhir)}',
                              style: TextStyle(
                                color: PerhitunganUtil.getWarnaSisaMasaAktif(
                                  pelangganAktif.tanggalBerakhir,
                                ),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Berakhir: ${FormatTanggal.formatTanggalBasic(pelangganAktif.tanggalBerakhir)} ${FormatJam.formatJamMenit(pelangganAktif.tanggalBerakhir)}',
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                  );
                },
              ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahPelangganAktif,
        child: const Icon(Icons.add),
      ),
    );
  }
}
