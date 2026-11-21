// path: lib/widget/transaksi_list_widgets.dart
// diubah: Menghapus operator null-aware yang tidak perlu dan memperbaiki penanganan error.

import 'package:admin_wifi/enum/tipe_transaksi_enum.dart';
import 'package:admin_wifi/fitur/kategori/notifier/kategori_notifier.dart';
import 'package:admin_wifi/fitur/transaksi/screens/detail_transaksi.dart';
import 'package:admin_wifi/fitur/transaksi/screens/form_transaksi.dart';
import 'package:admin_wifi/fitur/dompet/notifier/dompet_notifier.dart';
import 'package:admin_wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:admin_wifi/fitur/transaksi/notifier/transaksi_notifier.dart';
import 'package:admin_wifi/utils/format_util.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/src/utils/navigator_helper.dart';

Map<DateTime, List<TransaksiModel>> groupTransaksiByDate(
  List<TransaksiModel> transaksi,
) {
  final Map<DateTime, List<TransaksiModel>> grouped = {};
  for (final t in transaksi) {
    final date = DateTime(t.tanggal.year, t.tanggal.month, t.tanggal.day);
    if (grouped[date] == null) {
      grouped[date] = [];
    }
    grouped[date]!.add(t);
  }
  return grouped;
}

Widget bangunHeaderSeksi(DateTime tanggal, double total) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          FormatTanggal.formatTanggalBasic(tanggal),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          FormatUang.formatMataUang(total),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: total >= 0 ? Colors.green : Colors.red,
          ),
        ),
      ],
    ),
  );
}

class TransaksiTile extends ConsumerStatefulWidget {
  final TransaksiModel transaksi;
  final VoidCallback onDataChanged;

  const TransaksiTile({
    super.key,
    required this.transaksi,
    required this.onDataChanged,
  });

  @override
  ConsumerState<TransaksiTile> createState() => _TransaksiTileState();
}

class _TransaksiTileState extends ConsumerState<TransaksiTile> {
  void _arsipkanTransaksi() async {
    await ref
        .read(transaksiProvider.notifier)
        .arsipkanTransaksi(widget.transaksi.id);
    widget.onDataChanged();
  }

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;
    if (widget.transaksi.tipe == TipeTransaksi.pemasukan) {
      iconData = Icons.arrow_downward;
      iconColor = Colors.green;
    } else {
      iconData = Icons.arrow_upward;
      iconColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        key: ValueKey(widget.transaksi.id),
        onTap: () async {
          final result = await Nav.to(
            context,
            DetailTransaksiPage(transaksi: widget.transaksi),
          );
          if (result == true) {
            widget.onDataChanged();
          }
        },
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Opsi'),
              content: const Text(
                'Apa yang ingin Anda lakukan dengan transaksi ini?',
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    Nav.pop(context);
                    final result = await Nav.to(
                      context,
                      FormTransaksiPage(transaksi: widget.transaksi),
                    );
                    if (result == true) {
                      widget.onDataChanged();
                    }
                  },
                  child: const Text('Edit'),
                ),
                TextButton(
                  onPressed: () {
                    Nav.pop(context);
                    _arsipkanTransaksi();
                  },
                  child: const Text('Hapus'),
                ),
              ],
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: iconColor.withAlpha(25),
          child: Icon(iconData, color: iconColor),
        ),
        title: Text(widget.transaksi.keterangan),
        subtitle: Builder(
          builder: (context) {
            final kategoriState = ref.watch(kategoriProvider);
            final namaKategori =
                kategoriState.value?.getById(widget.transaksi.idKategori)?.nama ??
                'Tidak ada kategori';
            final dompetState = ref.watch(dompetProvider);
            final namaDompet =
                dompetState.value
                    ?.getDompetById(widget.transaksi.idDompet)
                    ?.namaDompet ??
                'Tidak ada dompet';
            return Text('$namaKategori | $namaDompet');
          },
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              FormatUang.formatMataUang(widget.transaksi.jumlah),
              style: TextStyle(fontWeight: FontWeight.bold, color: iconColor),
            ),
            Text(FormatJam.formatJamMenit(widget.transaksi.tanggal)),
          ],
        ),
      ),
    );
  }
}

Widget bangunItemTransaksi(
  BuildContext context,
  TransaksiModel transaksi,
  VoidCallback onDataChanged,
) {
  return TransaksiTile(transaksi: transaksi, onDataChanged: onDataChanged);
}
