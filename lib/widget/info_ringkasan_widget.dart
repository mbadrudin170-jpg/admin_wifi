// path: lib/widget/info_ringkasan_widget.dart
import 'package:flutter/material.dart';
import 'package:admin_wifi/utils/format_util.dart';

// diubah: Semua parameter diubah menjadi named arguments untuk kejelasan dan keamanan tipe.
Widget bangunInfoRingkasan({
  required BuildContext context,
  required String label,
  required double jumlah,
  required Color warna,
  CrossAxisAlignment alignment = CrossAxisAlignment.center,
}) {
  return Column(
    crossAxisAlignment: alignment,
    children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 4),
      Text(
        FormatUang.formatMataUang(jumlah),
        style: TextStyle(
          color: warna,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ],
  );
}
