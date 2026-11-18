// Path: lib/whatsapp/info_paket.dart
import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/model/paket_model.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';
import 'package:admin_wifi/utils/format_util.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:url_launcher/url_launcher.dart';

/// Kelas utilitas untuk membuat dan mengirim pesan informasi paket.
class PesanInfoPaket {
  /// Mengambil detail pelanggan dan paket, membuat pesan,
  /// lalu secara otomatis mengirimkannya melalui WhatsApp.
  ///
  /// [pelangganAktif]: Objek PelangganAktifModel yang baru saja dibuat atau diperbarui.
  static Future<void> kirimRincianPaket(
    PelangganAktifModel pelangganAktif,
  ) async {
    L.i(
      'Memulai proses pengiriman rincian paket via WhatsApp untuk pelanggan aktif ID: ${pelangganAktif.id}',
    );
    final pelangganOperasi = PelangganOperasi();
    final paketOperasi = PaketOperasi();

    try {
      // 1. Ambil data lengkap pelanggan dan paket dari database lokal.
      L.i('Mengambil data pelanggan dengan ID: ${pelangganAktif.idPelanggan}');
      final PelangganModel? pelanggan = await pelangganOperasi.getPelangganById(
        pelangganAktif.idPelanggan,
      );
      L.i('Mengambil data paket dengan ID: ${pelangganAktif.idPaket}');
      final PaketModel? paket = await paketOperasi.getPaketById(
        pelangganAktif.idPaket,
      );

      if (pelanggan == null) {
        L.w(
          'Pengiriman pesan dibatalkan. Pelanggan dengan ID ${pelangganAktif.idPelanggan} tidak ditemukan di database lokal.',
        );
        return;
      }
      if (paket == null) {
        L.w(
          'Pengiriman pesan dibatalkan. Paket dengan ID ${pelangganAktif.idPaket} tidak ditemukan di database lokal.',
        );
        return;
      }

      L.i(
        'Berhasil menemukan data pelanggan: ${pelanggan.nama} dan paket: ${paket.nama}',
      );

      // 2. Dapatkan status pembayaran langsung dari model PelangganAktif.
      final String statusPembayaran = pelangganAktif.status.label;
      L.i('Status pembayaran yang akan dikirim: $statusPembayaran');

      // 3. Buat string pesan yang akan dikirim.
      L.i('Membuat konten pesan WhatsApp.');
      final String pesan = _buatPesan(
        pelanggan,
        paket,
        pelangganAktif,
        statusPembayaran,
      );

      // 4. Kirim pesan yang sudah diformat ke nomor telepon pelanggan via WhatsApp.
      L.i('Memulai proses pengiriman ke nomor: ${pelanggan.telepon}.');
      await _kirimViaWhatsApp(pelanggan.telepon, pesan);
    } catch (e, s) {
      L.e(
        'Terjadi kesalahan fatal saat proses kirimRincianPaket. Error: $e $s',
      );
    }
  }

  static String _buatPesan(
    PelangganModel pelanggan,
    PaketModel paket,
    PelangganAktifModel pelangganAktif,
    String statusPembayaran,
  ) {
    final namaPelanggan = pelanggan.nama;
    final namaPaket = paket.nama;
    final hargaPaket = FormatUang.formatMataUang(paket.harga.toDouble());
    final tanggalMulai = FormatTanggal.formatTanggalDanJam(
      pelangganAktif.tanggalMulai,
    );
    final tanggalBerakhir = FormatTanggal.formatTanggalDanJam(
      pelangganAktif.tanggalBerakhir,
    );

    final pesanDibuat =
        '''
*-- Rincian Aktivasi Paket --*

Halo, *$namaPelanggan*.
Terima kasih telah melakukan aktivasi.

Berikut adalah detail paket Anda:
-----------------------------------
📦 *Paket:*
  $namaPaket

💰 *Harga:*
  $hargaPaket

▶️ *Mulai Aktif:*
  $tanggalMulai

⏹️ *Berakhir Pada:*
  $tanggalBerakhir

✅ *Status Pembayaran:*
  $statusPembayaran
-----------------------------------

Semoga harimu menyenangkan!
''';
    L.i('Konten pesan berhasil dibuat:\n$pesanDibuat');
    return pesanDibuat;
  }

  static Future<void> _kirimViaWhatsApp(
    String nomorTelepon,
    String pesan,
  ) async {
    // 1. Format nomor telepon ke standar internasional (misal: 62812...)
    L.i('Memformat nomor telepon: $nomorTelepon');
    String formattedNumber = nomorTelepon.replaceAll(RegExp(r'[^0-9]'), '');
    if (formattedNumber.startsWith('0')) {
      formattedNumber = '62${formattedNumber.substring(1)}';
    } else if (!formattedNumber.startsWith('62')) {
      formattedNumber = '62$formattedNumber';
    }
    L.i('Nomor telepon setelah diformat: $formattedNumber');

    // 2. Buat URI untuk WhatsApp
    final whatsappUri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: formattedNumber,
      queryParameters: {'text': pesan},
    );
    L.i('Membuat URI WhatsApp: $whatsappUri');

    // 3. Coba luncurkan URL dengan penanganan error
    try {
      if (await canLaunchUrl(whatsappUri)) {
        L.i('Membuka WhatsApp dengan URL...');
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        L.i('Berhasil membuka aplikasi WhatsApp.');
      } else {
        L.e(
          'Tidak dapat membuka URL WhatsApp. Kemungkinan aplikasi WhatsApp tidak terinstal atau ada masalah konfigurasi di AndroidManifest.xml (queries).',
        );
      }
    } catch (e, s) {
      L.e('Gagal total saat mencoba meluncurkan URL WhatsApp. Error: $e $s');
    }
  }
}
