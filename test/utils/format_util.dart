// path: test/utils/format_util_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:admin_wifi/utils/format_util.dart';

void main() {
  group('FormatTanggal', () {
    final sampleDate = DateTime(2024, 8, 17, 14, 30);

    test('formatTanggalBasic harus menghasilkan format "d MMM yyyy"', () {
      final result = FormatTanggal.formatTanggalBasic(sampleDate);
      expect(result, '17 Agu 2024');
    });

    test(
      'formatTanggalDanJam harus menghasilkan format "d MMM yyyy, HH:mm"',
      () {
        final result = FormatTanggal.formatTanggalDanJam(sampleDate);
        expect(result, '17 Agu 2024, 14:30');
      },
    );

    test('formatTanggalRingkas harus menghasilkan format "E, d MMM yy"', () {
      final result = FormatTanggal.formatTanggalRingkas(sampleDate);
      expect(result, 'Sab, 17 Agu 24');
    });
  });

  group('FormatJam', () {
    final sampleTime = DateTime(2024, 8, 17, 9, 5, 7);

    test('formatJamMenit harus menghasilkan format "HH:mm"', () {
      final result = FormatJam.formatJamMenit(sampleTime);
      expect(result, '09:05');
    });

    test('formatJamLengkap harus menghasilkan format "HH:mm:ss"', () {
      final result = FormatJam.formatJamLengkap(sampleTime);
      expect(result, '09:05:07');
    });

    test('formatTeksKeJam harus mengubah ISO string ke "HH:mm"', () {
      final result = FormatJam.formatTeksKeJam('2024-08-17T09:05:00');
      expect(result, '09:05');
    });

    test('formatTeksKeJam harus return "--:--" jika invalid', () {
      final result = FormatJam.formatTeksKeJam('invalid-format');
      expect(result, '--:--');
    });
  });

  group('FormatUang', () {
    test('formatMataUang harus menghasilkan format Rupiah tanpa desimal', () {
      final result = FormatUang.formatMataUang(50000);
      expect(result, 'Rp 50.000');
    });

    test('formatMataUang harus handle angka besar', () {
      final result = FormatUang.formatMataUang(1500000);
      expect(result, 'Rp 1.500.000');
    });

    test('formatMataUang harus handle nol', () {
      final result = FormatUang.formatMataUang(0);
      expect(result, 'Rp 0');
    });

    test('formatMataUang harus handle negatif', () {
      final result = FormatUang.formatMataUang(-50000);
      expect(result, '-Rp 50.000');
    });
  });
}
