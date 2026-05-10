// path: lib/server/server_lokal.dart
import 'dart:io';
import 'dart:convert';
import 'package:admin_wifi/debug/log.dart';
import 'package:admin_wifi/data/operasi/pesanan_operasi.dart';
import 'package:admin_wifi/model/pesanan_model.dart';

class ServerLokal {
  final PesananOperasi operasi;
  ServerSocket? _server;

  ServerLokal(this.operasi);

  // untuk menjalankan server lokal
  Future<void> jalankanServer(Function(PesananModel) onPesananMasuk) async {
    if (_server != null) {
      Log.info("Server sudah berjalan", name: 'server.lokal'); // diubah: menggunakan Log.info
      return;
    }

    try {
      _server = await ServerSocket.bind(InternetAddress.anyIPv4, 8080);
      Log.info("Server Aktif di Port 8080", name: 'server.lokal'); // diubah: menggunakan Log.info

      _server!.listen((Socket client) {
        Log.info("Client terhubung: ${client.remoteAddress}", name: 'server.lokal'); // diubah: menggunakan Log.info

        client.listen(
          (data) async {
            try {
              String rawJson = utf8.decode(data);
              Map<String, dynamic> jsonMap = json.decode(rawJson);
              final pesanan = PesananModel.fromSqlite(jsonMap);

              await operasi.simpanPesanan(pesanan);
              client.write("OK");
              onPesananMasuk(pesanan);
            } catch (e, s) {
              // ditambah: stacktrace
              client.write("ERROR: ${e.toString()}");
              Log.error("Gagal proses data", error: e, stackTrace: s, name: 'server.lokal.error'); // diubah: menggunakan Log.error
            }
          },
          onError: (error, s) {
            // ditambah: stacktrace
            Log.error("Client error", error: error, stackTrace: s, name: 'server.lokal.error'); // diubah: menggunakan Log.error
          },
          onDone: () {
            Log.info("Client disconnected", name: 'server.lokal'); // diubah: menggunakan Log.info
            client.destroy();
          },
        );
      });
    } catch (e, s) {
      // ditambah: stacktrace
      Log.error("Server Error", error: e, stackTrace: s, name: 'server.lokal.error'); // diubah: menggunakan Log.error
      _server = null;
    }
  }

  // untuk menghentikan server lokal
  void stop() {
    _server?.close();
    _server = null;
  }
}
