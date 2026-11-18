// path: lib/halaman/detail/detail_paket.dart

import 'package:admin_wifi/fitur/paket/screens/form_paket.dart';
import 'package:admin_wifi/fitur/paket/model/paket_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:share_global_saya/src/utils/navigator_helper.dart';

class DetailPaketPage extends ConsumerStatefulWidget {
  final PaketModel paket;

  const DetailPaketPage({super.key, required this.paket});

  @override
  ConsumerState<DetailPaketPage> createState() => _DetailPaketPageState();
}

class _DetailPaketPageState extends ConsumerState<DetailPaketPage> {
  late PaketModel _paket;

  @override
  void initState() {
    super.initState();

    L.i('Membuka halaman detail paket.');

    _paket = widget.paket;

    L.i(
      'Data paket berhasil dimuat dengan nama paket: ${_paket.nama} dan ID: ${_paket.id}.',
    );
  }

  void _editPaket() async {
    L.i(
      'Memulai navigasi ke halaman form edit paket untuk paket: ${_paket.nama}.',
    );

    final result = await Nav.to<bool>(context, FormPaket(paket: _paket));

    L.i('Halaman edit paket selesai ditutup dengan hasil: $result.');

    if (result == true) {
      L.i('Terdeteksi perubahan data paket setelah proses edit.');

      if (mounted) {
        L.i(
          'Widget masih mounted. Mengirim sinyal refresh ke halaman sebelumnya.',
        );

        Nav.pop(context, true);

        L.i('Berhasil kembali ke halaman sebelumnya dengan status refresh.');
      } else {
        L.w(
          'Widget sudah tidak mounted saat ingin kembali ke halaman sebelumnya.',
        );
      }
    } else {
      L.w('Pengguna membatalkan edit atau tidak ada perubahan data paket.');
    }
  }

  @override
  Widget build(BuildContext context) {
    L.i('Membangun UI halaman detail paket.');

    return Scaffold(
      appBar: AppBar(
        title: Text(_paket.nama),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            L.i('Pengguna menekan tombol kembali pada halaman detail paket.');

            Nav.pop(context);

            L.i('Berhasil kembali ke halaman sebelumnya.');
          },
        ),
        actions: [
          IconButton(
            onPressed: _editPaket,
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Paket',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Icon(
                      Icons.inventory_2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    Text(
                      'Informasi Layanan',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDetailRow('Nama Paket', _paket.nama),
                _buildDetailRow('Harga Sewa', 'Rp ${_paket.harga}'),
                _buildDetailRow(
                  'Masa Aktif',
                  '${_paket.durasi} ${_paket.tipe.name}',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(thickness: 1),
                ),
                Row(
                  spacing: 8,
                  children: [
                    Icon(
                      Icons.stars,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    Text(
                      'Sistem Poin',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Poin Hadiah',
                  '${_paket.poinHadiah} Poin',
                  subTitle: 'Didapat saat beli paket',
                ),
                _buildDetailRow(
                  'Poin Penukaran',
                  '${_paket.poinPenukaran} Poin',
                  subTitle: 'Syarat tukar gratis',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(thickness: 1),
                ),
                _buildDetailRow(
                  'Status Publik',
                  _paket.isPublic ? 'Tersedia di Aplikasi' : 'Hanya Admin',
                  customValueColor: _paket.isPublic ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    String? subTitle,
    Color? customValueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                if (subTitle != null)
                  Text(
                    subTitle,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color:
                    customValueColor ?? Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
