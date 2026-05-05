// path: test/operasi/versi_apk_user_operasi_test.dart
import 'package:admin_wifi/data/data_dummy.dart';
import 'package:admin_wifi/data/operasi/versi_apk_user_operasi.dart';
// dihapus: Impor tidak digunakan dalam file ini.
// import 'package:admin_wifi/model/versi_apk_user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('VersiApkUserOperasi Tests', () {
    late VersiApkUserOperasi operasi;

    setUp(() {
      operasi = VersiApkUserOperasi();
    });

    test('ambilVersiApkUser harus mengembalikan data dari dummy data', () async {
      // Panggil metode yang akan diuji
      final hasil = await operasi.ambilVersiApkUser();

      // Verifikasi bahwa hasil yang dikembalikan adalah objek yang sama
      // dengan yang ada di data dummy.
      expect(hasil, equals(dummyVersiApkUser));
      expect(hasil.versiTerbaru, '1.2.3');
      expect(hasil.nomorBuildTerbaru['prod'], 10);
    });
  });
}
