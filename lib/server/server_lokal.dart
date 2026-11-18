// path: lib/server/server_lokal.dart

import 'dart:convert';
import 'dart:io';
import 'package:share_global_saya/src/utils/l.dart';

import 'package:admin_wifi/data/operasi/pesanan_operasi.dart';
import 'package:admin_wifi/model/pesanan_model.dart';

class ServerLokal {
  final PesananOperasi operasi;

  ServerSocket? _server;

  ServerLokal(this.operasi);

  /// Menjalankan server TCP lokal untuk menerima data pesanan
  /// langsung dari perangkat customer.
  Future<void> jalankanServer(Function(PesananModel) onPesananMasuk) async {
    L.i('Memulai proses inisialisasi server lokal.');

    if (_server != null) {
      L.w('Permintaan menjalankan server diabaikan karena server sudah aktif.');

      return;
    }

    try {
      L.i(
        'Mencoba binding server socket ke semua interface IPv4 pada port 8080.',
      );

      _server = await ServerSocket.bind(InternetAddress.anyIPv4, 8080);

      L.i(
        'Server TCP berhasil dijalankan pada host: ${_server!.address.address} dan port: ${_server!.port}.',
      );

      _server!.listen(
        (Socket client) {
          final clientInfo =
              '${client.remoteAddress.address}:${client.remotePort}';

          L.i('Koneksi client baru diterima dari $clientInfo.');

          client.listen(
            (List<int> data) async {
              L.i(
                'Menerima paket data sebesar ${data.length} bytes dari client $clientInfo.',
              );

              try {
                L.i('Memulai proses decode UTF8 data dari client $clientInfo.');

                final String rawJson = utf8.decode(data);

                L.i('Payload mentah berhasil diterima: $rawJson');

                L.i('Memulai proses decode JSON payload.');

                final Map<String, dynamic> jsonMap = json.decode(rawJson);

                L.i(
                  'Payload JSON berhasil diubah menjadi Map<String, dynamic>.',
                );

                L.i('Memulai konversi data JSON menjadi PesananModel.');

                final pesanan = PesananModel.fromSqlite(jsonMap);

                L.i(
                  'Berhasil membuat object PesananModel dengan ID: ${pesanan.id}.',
                );

                L.i('Memulai penyimpanan pesanan ke database lokal SQLite.');

                await operasi.simpanPesanan(pesanan);

                L.i(
                  'Pesanan dengan ID: ${pesanan.id} berhasil disimpan ke database lokal.',
                );

                L.i(
                  'Mengirim ACK konfirmasi penerimaan data ke client $clientInfo.',
                );

                client.write('ACK: DATA_RECEIVED_AND_SAVED');

                L.i('ACK berhasil dikirim ke client $clientInfo.');

                L.i(
                  'Menjalankan callback onPesananMasuk untuk memperbarui UI atau state aplikasi.',
                );

                onPesananMasuk(pesanan);

                L.i('Callback onPesananMasuk berhasil dijalankan.');
              } catch (e, s) {
                L.w(
                  'Terjadi kegagalan saat memproses payload dari client $clientInfo. Mengirim pesan error ke client.',
                );

                client.write('ERROR_FAILED_TO_PROCESS_JSON');

                L.e(
                  'Gagal memproses payload JSON dari client $clientInfo. Error: $e $s',
                );
              }
            },
            onError: (error, s) {
              L.e(
                'Terjadi kesalahan pada stream client $clientInfo. Error: $error $s',
              );
            },
            onDone: () {
              L.i('Koneksi client $clientInfo telah selesai dan akan ditutup.');

              client.destroy();

              L.i('Socket client $clientInfo berhasil dihancurkan.');
            },
            cancelOnError: true,
          );
        },
        onError: (e, s) {
          L.e('Terjadi fatal error pada listener utama server. Error: $e $s');
        },
      );

      L.i('Server listener berhasil aktif dan siap menerima koneksi client.');
    } catch (e, s) {
      L.e('Gagal menginisialisasi server socket pada port 8080. Error: $e $s');

      L.w(
        'Instance server akan dikosongkan kembali karena proses inisialisasi gagal.',
      );

      _server = null;
    }
  }

  /// Menghentikan server dan membebaskan port yang digunakan.
  void stop() {
    L.i('Memulai proses penghentian server lokal.');

    if (_server != null) {
      L.i('Menutup server socket yang sedang aktif.');

      _server?.close();

      L.i('Server socket berhasil ditutup.');

      _server = null;

      L.i('Instance server berhasil dibersihkan dari memory.');
    } else {
      L.w('Permintaan stop server diabaikan karena server belum berjalan.');
    }
  }
}
