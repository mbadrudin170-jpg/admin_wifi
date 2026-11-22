// path: lib/enum/tipe_transaksi_enum.dart

enum TipeTransaksi {
  pemasukan,
  pengeluaran,
  transfer;

  String get label {
    switch (this) {
      case TipeTransaksi.pemasukan:
        return 'Pemasukan';
      case TipeTransaksi.pengeluaran:
        return 'Pengeluaran';
      case TipeTransaksi.transfer:
        return 'Transfer';
    }
  }
}
