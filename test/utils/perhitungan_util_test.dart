// path: test/utils/perhitungan_util_test.dart
// diubah: Mengganti logika tes getPoinHangus untuk mencerminkan aturan bisnis baru (berdasarkan selisih 30 hari dari tanggal mulai).

import 'package:flutter_test/flutter_test.dart';
import 'package:admin_wifi/utils/perhitungan_util.dart';
import 'package:flutter/material.dart';

void main() {
  group('PerhitunganUtil', () {
    group('sisaHari', () {
      test('harus mengembalikan selisih hari positif jika belum lewat', () {
        final now = DateTime(2026, 1, 1);
        final tanggalBerakhir = DateTime(2026, 1, 10);

        final hasil = PerhitunganUtil.sisaHari(tanggalBerakhir, now: now);

        expect(hasil, 9);
      });

      test('harus mengembalikan 0 jika hari yang sama', () {
        final now = DateTime(2026, 1, 10);
        final tanggalBerakhir = DateTime(2026, 1, 10);

        final hasil = PerhitunganUtil.sisaHari(tanggalBerakhir, now: now);

        expect(hasil, 0);
      });

      test('harus mengembalikan negatif jika sudah lewat', () {
        final now = DateTime(2026, 1, 10);
        final tanggalBerakhir = DateTime(2026, 1, 5);

        final hasil = PerhitunganUtil.sisaHari(tanggalBerakhir, now: now);

        expect(hasil, -5);
      });
    });

    group('2. getPoinHangus', () {
      test(
        '2.1 harus menampilkan teks Hangus jika tanggal mulai sudah lebih dari 30 hari',
        () {
          final now = DateTime(2026, 2, 1);
          final tanggalMulai = DateTime(2026, 1, 1); // 31 hari yang lalu

          final hasil = PerhitunganUtil.getPoinHangus(
            tanggalMulai: tanggalMulai,
            now: now,
          );

          expect(hasil, 'Hangus');
        },
      );

      test(
        '2.2 harus menampilkan  jika tanggal mulai kurang dari atau sama dengan 30 hari',
        () {
          final now = DateTime(2026, 1, 31);
          final tanggalMulai = DateTime(2026, 1, 1); // Tepat 30 hari yang lalu

          final hasil = PerhitunganUtil.getPoinHangus(
            tanggalMulai: tanggalMulai,
            now: now,
          );

          expect(hasil, '');
        },
      );
    });

    group('getTeksSisaMasaAktif', () {
      test('harus menampilkan "Berakhir" jika sudah lewat', () {
        final now = DateTime(2026, 1, 10, 12);

        final hasil = PerhitunganUtil.getTeksSisaMasaAktif(
          DateTime(2026, 1, 9),
          now: now,
        );

        expect(hasil, 'Berakhir');
      });

      test('harus menampilkan sisa hari jika > 0 hari', () {
        final now = DateTime(2026, 1, 1);

        final hasil = PerhitunganUtil.getTeksSisaMasaAktif(
          DateTime(2026, 1, 5),
          now: now,
        );

        expect(hasil, 'Sisa 4 hari');
      });

      test('harus menampilkan jam jika < 1 hari tapi masih jam', () {
        final now = DateTime(2026, 1, 1, 10, 0);

        final hasil = PerhitunganUtil.getTeksSisaMasaAktif(
          DateTime(2026, 1, 1, 15, 0),
          now: now,
        );

        expect(hasil, 'Sisa 5 jam');
      });

      test('harus menampilkan menit jika < 1 jam', () {
        final now = DateTime(2026, 1, 1, 10, 0);

        final hasil = PerhitunganUtil.getTeksSisaMasaAktif(
          DateTime(2026, 1, 1, 10, 30),
          now: now,
        );

        expect(hasil, 'Sisa 30 menit');
      });
    });

    group('getWarnaSisaMasaAktif', () {
      test('harus hijau jika sisa > 7 hari', () {
        final now = DateTime(2026, 1, 1);

        final warna = PerhitunganUtil.getWarnaSisaMasaAktif(
          DateTime(2026, 1, 15),
          now: now,
        );

        expect(warna, Colors.green);
      });

      test('harus oranye jika sisa 1-7 hari', () {
        final now = DateTime(2026, 1, 1);

        final warna = PerhitunganUtil.getWarnaSisaMasaAktif(
          DateTime(2026, 1, 5),
          now: now,
        );

        expect(warna, Colors.orange);
      });

      test('harus merah jika sudah lewat atau hari ini', () {
        final now = DateTime(2026, 1, 10);

        final warna = PerhitunganUtil.getWarnaSisaMasaAktif(
          DateTime(2026, 1, 9),
          now: now,
        );

        expect(warna, Colors.red);
      });
    });
  });
}
