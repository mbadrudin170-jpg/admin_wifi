// path: lib/widget/transaksi_list_widgets.dart
import 'package:flutter/material.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:admin_wifi/utils/format_util.dart';
import 'package:admin_wifi/halaman/detail/detail_transaksi.dart';
import 'package:admin_wifi/halaman/form/form_transaksi.dart';
import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';

// Fungsi untuk mengelompokkan transaksi berdasarkan tanggal (tanpa jam)
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

// Widget untuk membangun header seksi per tanggal
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

// Widget untuk membangun satu item dalam daftar transaksi
Widget bangunItemTransaksi(
  BuildContext context,
  TransaksiModel transaksi,
  VoidCallback onDataChanged, // Callback untuk memuat ulang data
) {
  IconData iconData;
  Color iconColor;
  if (transaksi.tipe == TipeTransaksi.pemasukan) {
    iconData = Icons.arrow_downward;
    iconColor = Colors.green;
  } else {
    iconData = Icons.arrow_upward;
    iconColor = Colors.red;
  }

  void arsipkanTransaksi() async {
    final transaksiOperasi = TransaksiOperasi();
    await transaksiOperasi.arsipkanTransaksi(transaksi.id);
    onDataChanged();
  }

  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: ListTile(
      key: ValueKey(transaksi.id),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailTransaksiPage(transaksi: transaksi),
          ),
        );
        if (result == true) {
          onDataChanged();
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
                  Navigator.pop(context); // Tutup dialog
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FormTransaksiPage(transaksi: transaksi),
                    ),
                  );
                  if (result == true) {
                    onDataChanged();
                  }
                },
                child: const Text('Edit'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                  arsipkanTransaksi();
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
      title: Text(
        transaksi.keterangan.isNotEmpty
            ? transaksi.keterangan
            : (transaksi.namaKategori),
      ),
      subtitle: Text(transaksi.namaDompet),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            FormatUang.formatMataUang(transaksi.jumlah),
            style: TextStyle(fontWeight: FontWeight.bold, color: iconColor),
          ),
          Text(FormatJam.formatJamMenit(transaksi.tanggal)),
        ],
      ),
    ),
  );
}
