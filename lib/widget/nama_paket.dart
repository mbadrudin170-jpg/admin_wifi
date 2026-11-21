// path: lib/widget/nama_paket.dart
// Widget ini berfungsi untuk menampilkan nama paket berdasarkan ID.

import 'package:admin_wifi/fitur/paket/notifier/paket_notifier.dart';
import 'package:admin_wifi/fitur/paket/model/paket_model.dart';
import 'package:material_ui/material_ui.dart';

class NamaPaketWidget extends StatelessWidget {
  final String idPaket;
  final TextStyle? style;

  const NamaPaketWidget({super.key, required this.idPaket, this.style});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PaketModel?>(
      future: paketNotifierGlobal.getPaketById(idPaket),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // diubah: Menampilkan indikator loading yang lebih halus.
          return const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data == null) {
          return Text(
            'Paket tidak tersedia',
            style: style?.copyWith(color: Colors.red),
          );
        } else {
          return Text(snapshot.data!.nama, style: style);
        }
      },
    );
  }
}
