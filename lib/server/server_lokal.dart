// path: lib/server/server_lokal.dart

import 'dart:convert';
import 'dart:io';

import 'package:admin_wifi/data/operasi/pesanan_operasi.dart';
import 'package:admin_wifi/debug/log.dart';
import 'package:admin_wifi/model/pesanan_model.dart';

class ServerLokal {
  final PesananOperasi operasi;

  ServerSocket? _server;

  ServerLokal(this.operasi);

  /// Menjalankan server TCP lokal untuk menerima data pesanan
  /// langsung dari perangkat customer.
  Future<void> jalankanServer(
    Function(PesananModel) onPesananMasuk,
  ) async {
    Log.info(
      'Memulai proses inisialisasi server lokal.',
    );

    if (_server != null) {
      Log.warning(
        'Permintaan menjalankan server diabaikan karena server sudah aktif.',
      );

      return;
    }

    try {
      Log.info(
        'Mencoba binding server socket ke semua interface IPv4 pada port 8080.',
      );

      _server = await ServerSocket.bind(
        InternetAddress.anyIPv4,
        8080,
      );

      Log.info(
        'Server TCP berhasil dijalankan pada host: ${_server!.address.address} dan port: ${_server!.port}.',
      );

      _server!.listen(
        (Socket client) {
          final clientInfo =
              '${client.remoteAddress.address}:${client.remotePort}';

          Log.info(
            'Koneksi client baru diterima dari $clientInfo.',
          );

          client.listen(
            (List<int> data) async {
              Log.info(
                'Menerima paket data sebesar ${data.length} bytes dari client $clientInfo.',
              );

              try {
                Log.info(
                  'Memulai proses decode UTF8 data dari client $clientInfo.',
                );

                final String rawJson = utf8.decode(data);

                Log.info(
                  'Payload mentah berhasil diterima: $rawJson',
                );

                Log.info(
                  'Memulai proses decode JSON payload.',
                );

                final Map<String, dynamic> jsonMap = json.decode(
                  rawJson,
                );

                Log.info(
                  'Payload JSON berhasil diubah menjadi Map<String, dynamic>.',
                );

                Log.info(
                  'Memulai konversi data JSON menjadi PesananModel.',
                );

                final pesanan = PesananModel.fromSqlite(
                  jsonMap,
                );

                Log.info(
                  'Berhasil membuat object PesananModel dengan ID: ${pesanan.id}.',
                );

                Log.info(
                  'Memulai penyimpanan pesanan ke database lokal SQLite.',
                );

                await operasi.simpanPesanan(
                  pesanan,
                );

                Log.info(
                  'Pesanan dengan ID: ${pesanan.id} berhasil disimpan ke database lokal.',
                );

                Log.info(
                  'Mengirim ACK konfirmasi penerimaan data ke client $clientInfo.',
                );

                client.write(
                  'ACK: DATA_RECEIVED_AND_SAVED',
                );

                Log.info(
                  'ACK berhasil dikirim ke client $clientInfo.',
                );

                Log.info(
                  'Menjalankan callback onPesananMasuk untuk memperbarui UI atau state aplikasi.',
                );

                onPesananMasuk(
                  pesanan,
                );

                Log.info(
                  'Callback onPesananMasuk berhasil dijalankan.',
                );
              } catch (e, s) {
                Log.warning(
                  'Terjadi kegagalan saat memproses payload dari client $clientInfo. Mengirim pesan error ke client.',
                );

                client.write(
                  'ERROR_FAILED_TO_PROCESS_JSON',
                );

                Log.error(
                  'Gagal memproses payload JSON dari client $clientInfo.',
                  error: e,
                  stackTrace: s,
                );
              }
            },
            onError: (error, s) {
              Log.error(
                'Terjadi kesalahan pada stream client $clientInfo.',
                error: error,
                stackTrace: s,
              );
            },
            onDone: () {
              Log.info(
                'Koneksi client $clientInfo telah selesai dan akan ditutup.',
              );

              client.destroy();

              Log.info(
                'Socket client $clientInfo berhasil dihancurkan.',
              );
            },
            cancelOnError: true,
          );
        },
        onError: (e, s) {
          Log.error(
            'Terjadi fatal error pada listener utama server.',
            error: e,
            stackTrace: s,
          );
        },
      );

      Log.info(
        'Server listener berhasil aktif dan siap menerima koneksi client.',
      );
    } catch (e, s) {
      Log.error(
        'Gagal menginisialisasi server socket pada port 8080.',
        error: e,
        stackTrace: s,
      );

      Log.warning(
        'Instance server akan dikosongkan kembali karena proses inisialisasi gagal.',
      );

      _server = null;
    }
  }

  /// Menghentikan server dan membebaskan port yang digunakan.
  void stop() {
    Log.info(
      'Memulai proses penghentian server lokal.',
    );

    if (_server != null) {
      Log.info(
        'Menutup server socket yang sedang aktif.',
      );

      _server?.close();

      Log.info(
        'Server socket berhasil ditutup.',
      );

      _server = null;

      Log.info(
        'Instance server berhasil dibersihkan dari memory.',
      );
    } else {
      Log.warning(
        'Permintaan stop server diabaikan karena server belum berjalan.',
      );
    }
  }
}