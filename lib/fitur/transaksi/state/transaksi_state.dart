// path: lib/fitur/transaksi/state/transaksi_state.dart

import 'package:admin_wifi/enum/tipe_transaksi_enum.dart';
import 'package:admin_wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaksi_state.freezed.dart';

@freezed
abstract class TransaksiState with _$TransaksiState {
  const TransaksiState._();

  const factory TransaksiState({
    @Default(<TransaksiModel>[]) List<TransaksiModel> listTransaksi,
    @Default(0) int jumlahTransaksi,
  }) = _TransaksiState;

  /// Mengambil satu transaksi berdasarkan [id].
  ///
  /// Mengembalikan `null` bila tidak ditemukan.
  TransaksiModel? getById(String id) =>
      listTransaksi.firstWhereOrNull((item) => item.id == id);

  /// Total pemasukan dari seluruh transaksi.
  double get totalPemasukan => listTransaksi
      .where((t) => t.tipe == TipeTransaksi.pemasukan)
      .fold<double>(0.0, (sum, t) => sum + t.jumlah);

  /// Total pengeluaran dari seluruh transaksi.
  double get totalPengeluaran => listTransaksi
      .where((t) => t.tipe == TipeTransaksi.pengeluaran)
      .fold<double>(0.0, (sum, t) => sum + t.jumlah);

  /// Selisih pemasukan dikurangi pengeluaran.
  double get netTotal => totalPemasukan - totalPengeluaran;

  /// Total poin yang dihasilkan untuk [idPelanggan].
  int getPoinYangDihasilkan(String idPelanggan) => listTransaksi
      .where((t) => t.idPelanggan == idPelanggan)
      .fold<int>(0, (sum, t) => sum + t.poinYangDihasilkan);

  /// Total poin yang digunakan untuk [idPelanggan].
  int getPoinYangDigunakan(String idPelanggan) => listTransaksi
      .where((t) => t.idPelanggan == idPelanggan)
      .fold<int>(0, (sum, t) => sum + t.poinYangDigunakan);

  /// Saldo poin akhir untuk [idPelanggan].
  int getTotalPoin(String idPelanggan) =>
      getPoinYangDihasilkan(idPelanggan) - getPoinYangDigunakan(idPelanggan);

  /// Mengambil transaksi yang id-nya ada di [ids].
  List<TransaksiModel> getTransaksiByIds(List<String> ids) =>
      listTransaksi.where((t) => ids.contains(t.id)).toList();

  /// Mengambil satu transaksi berdasarkan [id].
  TransaksiModel? getTransaksiById(String id) =>
      listTransaksi.firstWhereOrNull((t) => t.id == id);

  /// Mengambil transaksi berdasarkan [pelangganId].
  List<TransaksiModel> ambilTransaksiByPelangganId(String pelangganId) =>
      listTransaksi
          .where((t) => t.idPelanggan == pelangganId)
          .sorted((a, b) => b.tanggal.compareTo(a.tanggal));

  /// Mengambil transaksi poin (ada poin dihasilkan/digunakan) untuk [pelangganId].
  List<TransaksiModel> ambilTransaksiPoinByPelangganId(String pelangganId) =>
      listTransaksi
          .where((t) =>
              t.idPelanggan == pelangganId &&
              (t.poinYangDihasilkan > 0 || t.poinYangDigunakan > 0))
          .sorted((a, b) => b.tanggal.compareTo(a.tanggal));

  /// Mengambil transaksi berdasarkan [dompetId] (asal/tujuan).
  List<TransaksiModel> ambilTransaksiByDompetId(String dompetId) =>
      listTransaksi
          .where((t) => t.idDompet == dompetId || t.idDompetTujuan == dompetId)
          .sorted((a, b) => b.tanggal.compareTo(a.tanggal));

  /// Mengambil transaksi dengan aktivasi paket.
  List<TransaksiModel> getTransaksiByAktivasiPaket() =>
      listTransaksi
          .where((t) => t.aktivasiPaket)
          .sorted((a, b) => b.tanggal.compareTo(a.tanggal));
}
