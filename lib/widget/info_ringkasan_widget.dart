// path: lib/widget/info_ringkasan_widget.dart
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/core_shared.dart';

// diubah: Menambahkan parameter `textKey` opsional.
Widget bangunInfoRingkasan({
  required BuildContext context,
  required String label,
  required double jumlah,
  required Color warna,
  CrossAxisAlignment alignment = CrossAxisAlignment.center,
  Key? textKey, // ditambahkan: Parameter `textKey` opsional.
}) {
  return Column(
    spacing: 4,
    crossAxisAlignment: alignment,
    children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      Text(
        FormatUang.formatRupiah(jumlah),
        // diubah: Menggunakan `textKey` jika tersedia.
        key: textKey ?? ValueKey(label),
        style: TextStyle(
          color: warna,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ],
  );
}
