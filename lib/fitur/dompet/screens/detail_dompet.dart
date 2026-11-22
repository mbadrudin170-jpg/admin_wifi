// path: lib/fitur/dompet/screens/detail_dompet.dart
import 'package:admin_wifi/fitur/transaksi/enum/tipe_transaksi_enum.dart';
import 'package:admin_wifi/fitur/dompet/model/dompet_model.dart';
import 'package:admin_wifi/fitur/dompet/notifier/dompet_notifier.dart';
import 'package:admin_wifi/fitur/dompet/screens/form_dompet.dart';
import 'package:admin_wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:admin_wifi/fitur/transaksi/notifier/transaksi_notifier.dart';
import 'package:admin_wifi/widget/info_ringkasan_widget.dart';
import 'package:admin_wifi/widget/transaksi_list_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:share_global_saya/src/utils/navigator_helper.dart';

class DetailDompet extends ConsumerStatefulWidget {
  final DompetModel dompet;

  const DetailDompet({super.key, required this.dompet});

  @override
  ConsumerState<DetailDompet> createState() => _DetailDompetState();
}

class _DetailDompetState extends ConsumerState<DetailDompet> {
  @override
  void initState() {
    super.initState();
    L.i(
      'Membuat state untuk DetailDompet. ID Dompet: ${widget.dompet.id}, Nama Dompet: ${widget.dompet.namaDompet}',
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncDompet = ref.watch(dompetProvider);
    final asyncTransaksi = ref.watch(transaksiProvider);

    if (asyncDompet.isLoading || asyncTransaksi.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (asyncDompet.hasError) {
      return Scaffold(body: Center(child: Text('Error: ${asyncDompet.error}')));
    }

    if (asyncTransaksi.hasError) {
      return Scaffold(
        body: Center(child: Text('Error: ${asyncTransaksi.error}')),
      );
    }

    final dompetTerbaru = asyncDompet.requireValue.getById(widget.dompet.id);
    if (dompetTerbaru == null) {
      return const Scaffold(
        body: Center(child: Text('Dompet tidak ditemukan.')),
      );
    }

    final daftarTransaksi = asyncTransaksi.requireValue
        .ambilTransaksiByDompetId(widget.dompet.id);

    double pemasukan = 0;
    double pengeluaran = 0;
    for (final trx in daftarTransaksi) {
      if (trx.tipe == TipeTransaksi.pemasukan) {
        pemasukan += trx.jumlah;
      } else if (trx.tipe == TipeTransaksi.pengeluaran) {
        pengeluaran += trx.jumlah;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(dompetTerbaru.namaDompet),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Nav.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Nav.to(context, FormDompet(dompet: dompetTerbaru));
            },
          ),
        ],
      ),
      body: Column(
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
                  jumlah: pemasukan,
                  warna: Colors.green,
                ),
                bangunInfoRingkasan(
                  context: context,
                  label: 'Pengeluaran',
                  jumlah: pengeluaran,
                  warna: Colors.red,
                ),
                bangunInfoRingkasan(
                  context: context,
                  label: 'Saldo',
                  jumlah: dompetTerbaru.saldo,
                  warna: dompetTerbaru.saldo >= 0
                      ? Theme.of(context).colorScheme.primary
                      : Colors.red,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: daftarTransaksi.isEmpty
                ? const Center(child: Text('Belum ada transaksi.'))
                : _buildTransaksiList(daftarTransaksi),
          ),
        ],
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
            bangunHeaderSeksi(context, tanggal, totalHarian),
            ...transaksiPadaTanggal.map(
              (transaksi) => bangunItemTransaksi(context, transaksi, () {}),
            ),
          ],
        );
      },
    );
  }
}
