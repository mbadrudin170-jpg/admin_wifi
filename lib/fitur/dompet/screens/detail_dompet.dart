// path: lib/fitur/dompet/screens/detail_dompet.dart
import 'package:admin_wifi/fitur/dompet/notifier/dompet_notifier.dart';
import 'package:admin_wifi/fitur/transaksi/notifier/transaksi_notifier.dart';
import 'package:admin_wifi/enum/tipe_transaksi_enum.dart';
import 'package:admin_wifi/fitur/dompet/screens/form_dompet.dart';
import 'package:admin_wifi/fitur/dompet/model/dompet_model.dart';
import 'package:admin_wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:admin_wifi/widget/info_ringkasan_widget.dart';
import 'package:admin_wifi/widget/transaksi_list_widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:share_global_saya/src/utils/navigator_helper.dart';

class DetailDompetData {
  final DompetModel dompet;
  final List<TransaksiModel> transaksi;
  final double totalPemasukan;
  final double totalPengeluaran;

  DetailDompetData({
    required this.dompet,
    required this.transaksi,
    required this.totalPemasukan,
    required this.totalPengeluaran,
  });
}

class DetailDompet extends ConsumerStatefulWidget {
  final DompetModel dompet;
  final DompetNotifier? dompetOperasi;
  final TransaksiNotifier? transaksiOperasi;

  const DetailDompet({
    super.key,
    required this.dompet,
    this.dompetOperasi,
    this.transaksiOperasi,
  });

  @override
  ConsumerState<DetailDompet> createState() => _DetailDompetState();
}

class _DetailDompetState extends ConsumerState<DetailDompet> {
  late Future<DetailDompetData> _futureDetailData;
  late final DompetNotifier _dompetOperasi;

  String? _namaDompetTerbaru;

  @override
  void initState() {
    super.initState();
    L.i(
      'Membuat state untuk DetailDompet. ID Dompet: ${widget.dompet.id}, Nama Dompet: ${widget.dompet.namaDompet}',
    );

    _dompetOperasi = widget.dompetOperasi ?? dompetNotifierGlobal;
    _futureDetailData = _loadData();
  }

  Future<DetailDompetData> _loadData() async {
    try {
      final results = await Future.wait([
        _dompetOperasi.getDompetById(widget.dompet.id),
        Future.value(
          ref
                  .read(transaksiProvider)
                  .value
                  ?.ambilTransaksiByDompetId(widget.dompet.id) ??
              <TransaksiModel>[],
        ),
      ]);

      final dompetTerbaru = results[0] as DompetModel?;
      final daftarTransaksi = results[1] as List<TransaksiModel>;

      if (dompetTerbaru == null) {
        L.w(
          'Dompet dengan ID ${widget.dompet.id} tidak ditemukan di database.',
        );
        throw Exception('Dompet tidak ditemukan.');
      }

      if (mounted) {
        setState(() {
          _namaDompetTerbaru = dompetTerbaru.namaDompet;
        });
      }

      double pemasukan = 0;
      double pengeluaran = 0;

      for (int i = 0; i < daftarTransaksi.length; i++) {
        var trx = daftarTransaksi[i];
        if (trx.tipe == TipeTransaksi.pemasukan) {
          pemasukan += trx.jumlah;
        } else if (trx.tipe == TipeTransaksi.pengeluaran) {
          pengeluaran += trx.jumlah;
        }
      }

      return DetailDompetData(
        dompet: dompetTerbaru,
        transaksi: daftarTransaksi,
        totalPemasukan: pemasukan,
        totalPengeluaran: pengeluaran,
      );
    } catch (e, s) {
      L.e(
        'Gagal memuat data detail dompet untuk ID: ${widget.dompet.id}. Error: $e $s',
      );
      rethrow;
    }
  }

  void _muatUlangData() {
    setState(() {
      _futureDetailData = _loadData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_namaDompetTerbaru ?? widget.dompet.namaDompet),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Nav.pop(context, true);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final namaDompetTerbaru = _namaDompetTerbaru;
              final dompetUntukEdit = namaDompetTerbaru != null
                  ? widget.dompet.copyWith(namaDompet: namaDompetTerbaru)
                  : widget.dompet;

              final result = await Nav.to(
                context,
                FormDompet(dompet: dompetUntukEdit),
              );

              if (result == true) {
                _muatUlangData();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<DetailDompetData>(
        future: _futureDetailData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            L.e('FutureBuilder error: $snapshot.error $snapshot.stackTrace');
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Data Kosong'));
          }

          final data = snapshot.data!;

          return Column(
            children: [
              Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    bangunInfoRingkasan(
                      context: context,
                      label: 'Pemasukan',
                      jumlah: data.totalPemasukan,
                      warna: Colors.green,
                    ),
                    bangunInfoRingkasan(
                      context: context,
                      label: 'Pengeluaran',
                      jumlah: data.totalPengeluaran,
                      warna: Colors.red,
                    ),
                    bangunInfoRingkasan(
                      context: context,
                      label: 'Saldo',
                      jumlah: data.dompet.saldo,
                      warna: data.dompet.saldo >= 0
                          ? Theme.of(context).colorScheme.primary
                          : Colors.red,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: data.transaksi.isEmpty
                    ? const Center(child: Text('Belum ada transaksi.'))
                    : _buildTransaksiList(data.transaksi),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTransaksiList(List<TransaksiModel> transaksiData) {
    final groupedTransaksi = groupTransaksiByDate(transaksiData);

    return ListView.builder(
      itemCount: groupedTransaksi.length,
      itemBuilder: (context, index) {
        final tanggal = groupedTransaksi.keys.elementAt(index);
        final transaksiPadaTanggal = groupedTransaksi[tanggal]!;

        final totalHarian = transaksiPadaTanggal.fold(
          0.0,
          (sum, item) =>
              sum +
              (item.tipe == TipeTransaksi.pemasukan
                  ? item.jumlah
                  : -item.jumlah),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bangunHeaderSeksi(tanggal, totalHarian),
            ...transaksiPadaTanggal.map(
              (transaksi) => bangunItemTransaksi(context, transaksi, () {
                _muatUlangData();
              }),
            ),
          ],
        );
      },
    );
  }
}
