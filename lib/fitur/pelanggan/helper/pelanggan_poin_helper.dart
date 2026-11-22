// path: lib/fitur/pelanggan/helper/pelanggan_poin_helper.dart

/// Helper murni untuk menghitung total poin pelanggan.
///
/// Total poin = poin awal (baseline dari biodata/pelanggan) + poin yang
/// dihasilkan dari transaksi − poin yang digunakan (penukaran hadiah).
///
/// Helper ini hanya menerima parameter primitif dan tidak bergantung pada
/// `BuildContext` maupun provider, sehingga dapat dipakai dari layar, notifier,
/// maupun test.
class PelangganPoinHelper {
  const PelangganPoinHelper._();

  /// Menghitung total poin pelanggan.
  ///
  /// [poinAwal] adalah poin awal yang disimpan pada data pelanggan.
  /// [poinDihasilkan] adalah akumulasi poin dari transaksi (hasilkan).
  /// [poinDigunakan] adalah akumulasi poin yang dipakai (penukaran).
  static int hitungTotalPoin({
    required double poinAwal,
    required int poinDihasilkan,
    required int poinDigunakan,
  }) {
    return (poinAwal + poinDihasilkan - poinDigunakan).round();
  }
}
