// path: lib/halaman/form/form_pelanggan_aktif.dart
// Halaman ini menyediakan formulir untuk mengaktifkan pelanggan dengan paket tertentu.
// diubah: Melakukan refactoring untuk menerapkan Dependency Injection.
// diubah: Memisahkan logika penyimpanan dan navigasi untuk memastikan SnackBar sempat ditampilkan dalam pengujian.
// diubah: Memperbaiki bug dimana Dompet dan Kategori tidak diinisialisasi dalam mode edit.
// diubah: Mengganti `value` dengan `initialValue` pada DropdownButtonFormField.
// diubah: Memfilter daftar kategori agar hanya menampilkan tipe pemasukan dan yang tidak dihapus.
// ditambahkan: filter untuk hanya menampilkan dompet yang isDeleted-nya false.
// diubah: Transaksi sekarang dibuat tanpa pengecekan status pembayaran.
// diubah: poinYangDihasilkan sekarang mengambil nilai dari paket yang dipilih.
// diubah: Memperbaiki bug tampilan poin.
// ditambahkan: Logika `_hitungTanggalBerakhir` diekstrak menjadi fungsi top-level `hitungTanggalBerakhir` untuk kemudahan pengujian.
// diperbaiki: Kesalahan sintaks pada string multi-baris di SnackBar.
// diperbaiki: Memperbaiki bug dimana edit pelanggan aktif tidak mengupdate transaksi yang ada.

import 'package:admin_wifi/data/operasi/kategori_operasi.dart';
import 'package:admin_wifi/data/operasi/dompet_operasi.dart';
import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_aktif_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
import 'package:admin_wifi/enum/tipe_transaksi_enum.dart';
import 'package:admin_wifi/model/hasil_simpan_model.dart';
import 'package:admin_wifi/model/kategori_model.dart';
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:admin_wifi/model/paket_model.dart';
import 'package:admin_wifi/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';
import 'package:admin_wifi/enum/status_pembayaran_enum.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:admin_wifi/utils/format_util.dart';
import 'package:admin_wifi/debug/log.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:uuid/uuid.dart';
import 'package:admin_wifi/enum/enum.dart';

// ditambahkan: Fungsi ini diekstrak dari state untuk kemudahan pengujian.
DateTime hitungTanggalBerakhir(DateTime startDate, PaketModel paket) {
  Log.info('FUNGSI GLOBAL: hitungTanggalBerakhir() dipanggil.');
  Log.info('  - Tanggal Mulai: ${startDate.toIso8601String()}');
  Log.info('  - Nama Paket: ${paket.nama}');
  Log.info('  - Tipe Durasi: ${paket.tipe.displayName}');
  Log.info('  - Durasi: ${paket.durasi}');

  DateTime hasil;
  switch (paket.tipe) {
    case TipeDurasi.jam:
      Log.info('  - Perhitungan: $startDate + ${paket.durasi} jam');
      hasil = startDate.add(Duration(hours: paket.durasi));
      break;
    case TipeDurasi.hari:
      Log.info('  - Perhitungan: $startDate + ${paket.durasi} hari');
      hasil = startDate.add(Duration(days: paket.durasi));
      break;
    case TipeDurasi.bulan:
      Log.info(
        '  - Perhitungan: $startDate + ${paket.durasi} bulan (menggunakan Jiffy)',
      );
      hasil = Jiffy.parseFromDateTime(
        startDate,
      ).add(months: paket.durasi).dateTime;
      break;
    case TipeDurasi.menit:
      Log.info('  - Perhitungan: $startDate + ${paket.durasi} menit');
      hasil = startDate.add(Duration(minutes: paket.durasi));
      break;
  }

  Log.info('  - Hasil Tanggal Berakhir: ${hasil.toIso8601String()}');
  Log.info('  - Format: ${FormatTanggal.formatTanggalDanJam(hasil)}');
  return hasil;
}

class FormPelangganAktif extends StatefulWidget {
  final PelangganAktifModel? pelangganAktif;
  final PelangganOperasi pelangganOperasi;
  final PaketOperasi paketOperasi;
  final PelangganAktifOperasi pelangganAktifOperasi;
  final TransaksiOperasi transaksiOperasi;
  final DompetOperasi dompetOperasi;
  final KategoriOperasi kategoriOperasi;

  FormPelangganAktif({
    super.key,
    this.pelangganAktif,
    PelangganOperasi? pelangganOperasi,
    PaketOperasi? paketOperasi,
    PelangganAktifOperasi? pelangganAktifOperasi,
    TransaksiOperasi? transaksiOperasi,
    DompetOperasi? dompetOperasi,
    KategoriOperasi? kategoriOperasi,
  }) : pelangganOperasi = pelangganOperasi ?? PelangganOperasi(),
       paketOperasi = paketOperasi ?? PaketOperasi(),
       pelangganAktifOperasi = pelangganAktifOperasi ?? PelangganAktifOperasi(),
       transaksiOperasi = transaksiOperasi ?? TransaksiOperasi(),
       dompetOperasi = dompetOperasi ?? DompetOperasi(),
       kategoriOperasi = kategoriOperasi ?? KategoriOperasi() {
    Log.info('FormPelangganAktif instance dibuat.');
    Log.info(
      '  - Mode: ${pelangganAktif != null ? "EDIT (ID: ${pelangganAktif!.id})" : "TAMBAH BARU"}',
    );
    Log.info('  - PelangganOperasi: ${this.pelangganOperasi.hashCode}');
    Log.info('  - PaketOperasi: ${this.paketOperasi.hashCode}');
    Log.info(
      '  - PelangganAktifOperasi: ${this.pelangganAktifOperasi.hashCode}',
    );
    Log.info('  - TransaksiOperasi: ${this.transaksiOperasi.hashCode}');
    Log.info('  - DompetOperasi: ${this.dompetOperasi.hashCode}');
    Log.info('  - KategoriOperasi: ${this.kategoriOperasi.hashCode}');
  }

  @override
  State<FormPelangganAktif> createState() => _FormPelangganAktifState();
}

class _FormPelangganAktifState extends State<FormPelangganAktif> {
  final _formKey = GlobalKey<FormState>();

  List<PelangganModel> _pelangganList = [];
  List<PaketModel> _paketList = [];
  List<DompetModel> _daftarDompet = [];
  List<KategoriModel> _kategoriPemasukanList = [];
  List<KategoriModel> _kategoriPengeluaranList = [];

  List<KategoriModel> get _kategoriList =>
      _gunakanPoin ? _kategoriPengeluaranList : _kategoriPemasukanList;

  PelangganModel? _selectedPelanggan;
  PaketModel? _selectedPaket;
  DompetModel? _selectedDompet;
  KategoriModel? _selectedKategori;

  bool _isLoading = true;
  bool _gunakanPoin = false;
  int _saldoPoinPelanggan = 0;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  StatusPembayaranEnum _statusPembayaran = StatusPembayaranEnum.lunas;

  bool get _isEditMode => widget.pelangganAktif != null;

  int hitungPoinEfektif() {
    if (_selectedPaket == null) return 0;
    if (_gunakanPoin) {
      final poinEfektif = _selectedPaket!.poinPenukaran;
      Log.info(
        'PERHITUNGAN POIN EFEKTIF: Poin penukaran dari paket "${_selectedPaket!.nama}" = $poinEfektif',
      );
      return poinEfektif;
    }
    Log.info('PERHITUNGAN POIN EFEKTIF: Tidak menggunakan poin, return 0');
    return 0;
  }

  int hitungSisaPoin() {
    final pakai = hitungPoinEfektif();
    final sisa = (_saldoPoinPelanggan - pakai).clamp(0, 999999999);
    Log.info(
      'PERHITUNGAN SISA POIN: Saldo poin pelanggan: $_saldoPoinPelanggan, Poin dipakai: $pakai, Sisa: $sisa',
    );
    return sisa;
  }

  @override
  void initState() {
    super.initState();
    Log.info('========================================');
    Log.info('LIFECYCLE: initState() - Halaman FormPelangganAktif');
    Log.info('Mode: ${_isEditMode ? "EDIT" : "TAMBAH BARU"}');
    Log.info('========================================');
    Log.info('Memanggil _loadAllData() untuk mengambil semua data referensi.');
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    Log.info('========================================');
    Log.info('MEMULAI PEMUATAN SEMUA DATA REFERENSI');
    Log.info('========================================');
    Log.info('Mengambil 4 jenis data secara paralel:');
    Log.info('  1. Daftar Pelanggan (getPelanggan)');
    Log.info('  2. Daftar Paket (getPaket)');
    Log.info('  3. Daftar Dompet (getDompet)');
    Log.info('  4. Daftar Kategori (getKategori)');

    try {
      final results = await Future.wait([
        widget.pelangganOperasi.getPelanggan(),
        widget.paketOperasi.getPaket(),
        widget.dompetOperasi.getDompet(),
        widget.kategoriOperasi.getKategori(),
      ]);

      Log.info('Keempat query selesai dijalankan. Memproses hasil...');

      if (!mounted) {
        Log.warning(
          'Widget sudah tidak mounted setelah data berhasil diambil. Membatalkan update state.',
        );
        return;
      }

      setState(() {
        _pelangganList = results[0] as List<PelangganModel>;
        Log.info(
          'Data Pelanggan: ${_pelangganList.length} pelanggan ditemukan.',
        );

        _pelangganList.sort(
          (a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()),
        );
        Log.info('Daftar pelanggan diurutkan berdasarkan nama (A-Z).');

        _paketList = results[1] as List<PaketModel>;
        Log.info('Data Paket: ${_paketList.length} paket ditemukan.');

        final semuaDompet = results[2] as List<DompetModel>;
        Log.info(
          'Data Dompet (sebelum filter): ${semuaDompet.length} dompet ditemukan.',
        );
        _daftarDompet = semuaDompet
            .where((dompet) => !dompet.isDeleted)
            .toList();
        Log.info(
          'Data Dompet (setelah filter isDeleted=false): ${_daftarDompet.length} dompet tersedia.',
        );

        final semuaKategori = results[3] as List<KategoriModel>;
        Log.info(
          'Data Kategori (sebelum filter): ${semuaKategori.length} kategori ditemukan.',
        );

        _kategoriPemasukanList = semuaKategori
            .where((k) => k.tipe == TipeKategori.pemasukan && !k.isDeleted)
            .toList();
        Log.info(
          'Kategori Pemasukan (setelah filter): ${_kategoriPemasukanList.length} kategori.',
        );
        for (var k in _kategoriPemasukanList) {
          Log.info('  - ${k.nama} (ID: ${k.id})');
        }

        _kategoriPengeluaranList = semuaKategori
            .where((k) => k.tipe == TipeKategori.pengeluaran && !k.isDeleted)
            .toList();
        Log.info(
          'Kategori Pengeluaran (setelah filter): ${_kategoriPengeluaranList.length} kategori.',
        );
        for (var k in _kategoriPengeluaranList) {
          Log.info('  - ${k.nama} (ID: ${k.id})');
        }

        if (_isEditMode) {
          Log.info('========================================');
          Log.info(
            'MODE EDIT: Melakukan mapping data pelanggan aktif yang sudah ada',
          );
          Log.info('========================================');
          final pa = widget.pelangganAktif!;
          Log.info('Data pelanggan aktif yang akan diedit:');
          Log.info('  - ID: ${pa.id}');
          Log.info('  - ID Pelanggan: ${pa.idPelanggan}');
          Log.info('  - ID Paket: ${pa.idPaket}');
          Log.info('  - ID Transaksi: ${pa.idTransaksi}');
          Log.info('  - Tanggal Mulai: ${pa.tanggalMulai}');
          Log.info('  - Tanggal Berakhir: ${pa.tanggalBerakhir}');
          Log.info('  - Status: ${pa.status}');

          try {
            _selectedPelanggan = _pelangganList.firstWhere(
              (p) => p.id == pa.idPelanggan,
            );
            Log.info(
              'Pelanggan berhasil ditemukan: ${_selectedPelanggan!.nama} (ID: ${_selectedPelanggan!.id})',
            );
          } catch (e) {
            Log.warning(
              'Pelanggan dengan ID ${pa.idPelanggan} tidak ditemukan dalam daftar.',
            );
            _selectedPelanggan = null;
          }

          try {
            _selectedPaket = _paketList.firstWhere((p) => p.id == pa.idPaket);
            Log.info(
              'Paket berhasil ditemukan: ${_selectedPaket!.nama} (ID: ${_selectedPaket!.id})',
            );
          } catch (e) {
            Log.warning(
              'Paket dengan ID ${pa.idPaket} tidak ditemukan dalam daftar.',
            );
            _selectedPaket = null;
            if (mounted) {
              Log.warning(
                'Menampilkan SnackBar peringatan paket tidak ditemukan.',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Peringatan: Paket asli (ID: ${pa.idPaket}) tidak ditemukan. Harap pilih paket baru.',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }

          final tglMulai = pa.tanggalMulai;
          _selectedDate = tglMulai;
          _selectedTime = TimeOfDay.fromDateTime(tglMulai);
          Log.info(
            'Tanggal dan waktu mulai diatur dari data yang ada: ${FormatTanggal.formatTanggalDanJam(tglMulai)}',
          );
          _statusPembayaran = pa.status;
          Log.info('Status pembayaran: $_statusPembayaran');
        } else {
          Log.info('MODE TAMBAH BARU: Mengatur waktu default ke sekarang.');
          _selectedDate = DateTime.now();
          _selectedTime = TimeOfDay.now();
          Log.info(
            'Tanggal default: ${FormatTanggal.formatTanggalBasic(_selectedDate!)}',
          );
          Log.info('Waktu default: ${_selectedTime!.format(context)}');
        }

        if (_selectedDompet == null && _daftarDompet.isNotEmpty) {
          _selectedDompet = _daftarDompet.first;
          Log.info(
            'Dompet default dipilih: ${_selectedDompet!.namaDompet} (ID: ${_selectedDompet!.id})',
          );
        } else if (_daftarDompet.isEmpty) {
          Log.warning('Tidak ada dompet yang tersedia. Daftar dompet kosong.');
        }

        if (_selectedKategori == null && _kategoriPemasukanList.isNotEmpty) {
          try {
            _selectedKategori = _kategoriPemasukanList.firstWhere(
              (k) => k.nama.toLowerCase() == 'aktivasi paket',
            );
            Log.info(
              'Kategori "Aktivasi Paket" ditemukan dan dipilih secara default.',
            );
          } catch (e) {
            _selectedKategori = _kategoriPemasukanList.first;
            Log.info(
              'Kategori "Aktivasi Paket" tidak ditemukan. Kategori pertama dipilih: ${_selectedKategori!.nama}',
            );
          }
        } else if (_kategoriPemasukanList.isEmpty &&
            _kategoriPengeluaranList.isEmpty) {
          Log.warning(
            'Tidak ada kategori yang tersedia. Kedua daftar kategori kosong.',
          );
        }

        _isLoading = false;
        Log.info('========================================');
        Log.info('PEMUATAN DATA REFERENSI SELESAI');
        Log.info('Ringkasan data yang dimuat:');
        Log.info('  - Pelanggan: ${_pelangganList.length} data');
        Log.info('  - Paket: ${_paketList.length} data');
        Log.info('  - Dompet: ${_daftarDompet.length} data');
        Log.info(
          '  - Kategori Pemasukan: ${_kategoriPemasukanList.length} data',
        );
        Log.info(
          '  - Kategori Pengeluaran: ${_kategoriPengeluaranList.length} data',
        );
        Log.info(
          '  - Pelanggan Terpilih: ${_selectedPelanggan?.nama ?? "Belum dipilih"}',
        );
        Log.info(
          '  - Paket Terpilih: ${_selectedPaket?.nama ?? "Belum dipilih"}',
        );
        Log.info(
          '  - Dompet Terpilih: ${_selectedDompet?.namaDompet ?? "Belum dipilih"}',
        );
        Log.info(
          '  - Kategori Terpilih: ${_selectedKategori?.nama ?? "Belum dipilih"}',
        );
        Log.info('========================================');
      });
    } catch (e, s) {
      Log.error(
        'Gagal memuat data referensi. '
        'Proses pengambilan data pelanggan, paket, dompet, atau kategori mengalami kegagalan. '
        'Kemungkinan penyebab: koneksi database gagal atau data corrupt.',
        error: e,
        stackTrace: s,
      );
      if (!mounted) {
        Log.warning(
          'Widget sudah tidak mounted setelah error. Tidak dapat memperbarui state atau menampilkan SnackBar.',
        );
        return;
      }
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    Log.info('========================================');
    Log.info('AKSI: Membuka DatePicker untuk memilih tanggal');
    Log.info(
      'Tanggal saat ini: ${_selectedDate != null ? FormatTanggal.formatTanggalBasic(_selectedDate!) : "Belum dipilih"}',
    );
    Log.info('========================================');

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      Log.info(
        'DatePicker: Tanggal baru dipilih: ${FormatTanggal.formatTanggalBasic(picked)}',
      );
      Log.info(
        'Tanggal sebelumnya: ${_selectedDate != null ? FormatTanggal.formatTanggalBasic(_selectedDate!) : "Belum dipilih"}',
      );
      setState(() {
        _selectedDate = picked;
      });
      Log.info('State _selectedDate berhasil diperbarui.');
    } else if (picked == null) {
      Log.info('DatePicker: Pengguna membatalkan pemilihan tanggal.');
    } else {
      Log.info(
        'DatePicker: Tanggal yang dipilih sama dengan sebelumnya. Tidak ada perubahan.',
      );
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    Log.info('========================================');
    Log.info('AKSI: Membuka TimePicker untuk memilih waktu');
    Log.info(
      'Waktu saat ini: ${_selectedTime != null ? "${_selectedTime!.hour}:${_selectedTime!.minute}" : "Belum dipilih"}',
    );
    Log.info('========================================');

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      Log.info(
        'TimePicker: Waktu baru dipilih: ${picked.hour}:${picked.minute}',
      );
      Log.info(
        'Waktu sebelumnya: ${_selectedTime != null ? "${_selectedTime!.hour}:${_selectedTime!.minute}" : "Belum dipilih"}',
      );
      setState(() {
        _selectedTime = picked;
      });
      Log.info('State _selectedTime berhasil diperbarui.');
    } else if (picked == null) {
      Log.info('TimePicker: Pengguna membatalkan pemilihan waktu.');
    } else {
      Log.info(
        'TimePicker: Waktu yang dipilih sama dengan sebelumnya. Tidak ada perubahan.',
      );
    }
  }

  Future<HasilSimpanModel> _saveForm() async {
    Log.info('========================================');
    Log.info('PROSES PENYIMPANAN FORM');
    Log.info('Mode: ${_isEditMode ? "EDIT" : "TAMBAH BARU"}');
    Log.info('========================================');

    Log.info('Memvalidasi form...');
    if (!_formKey.currentState!.validate()) {
      Log.warning('Validasi form GAGAL. Data belum lengkap atau tidak valid.');
      return HasilSimpanModel(sukses: false, pesan: 'Data belum lengkap');
    }
    Log.info('Validasi form BERHASIL.');

    final selectedPaket = _selectedPaket;

    Log.info('Memeriksa kelengkapan data...');
    Log.info(
      '  - Pelanggan: ${_selectedPelanggan != null ? _selectedPelanggan!.nama : "NULL"}',
    );
    Log.info(
      '  - Paket: ${selectedPaket != null ? selectedPaket.nama : "NULL"}',
    );
    Log.info(
      '  - Tanggal: ${_selectedDate != null ? FormatTanggal.formatTanggalBasic(_selectedDate!) : "NULL"}',
    );
    Log.info(
      '  - Waktu: ${_selectedTime != null ? "${_selectedTime!.hour}:${_selectedTime!.minute}" : "NULL"}',
    );
    Log.info(
      '  - Dompet: ${_selectedDompet != null ? _selectedDompet!.namaDompet : "NULL"}',
    );
    Log.info(
      '  - Kategori: ${_selectedKategori != null ? _selectedKategori!.nama : "NULL"}',
    );
    Log.info('  - Gunakan Poin: $_gunakanPoin');
    Log.info('  - Status Pembayaran: $_statusPembayaran');

    if (_selectedPelanggan == null ||
        selectedPaket == null ||
        _selectedDate == null ||
        _selectedTime == null ||
        _selectedDompet == null ||
        _selectedKategori == null) {
      Log.warning(
        'Salah satu field utama bernilai NULL. Penyimpanan tidak dapat dilanjutkan.',
      );
      return HasilSimpanModel(
        sukses: false,
        pesan: 'Harap lengkapi semua data',
      );
    }
    Log.info('Semua field utama terisi. Melanjutkan proses penyimpanan.');

    if (_gunakanPoin) {
      Log.info('========================================');
      Log.info('VALIDASI PENGGUNAAN POIN');
      Log.info('========================================');
      Log.info('Pengguna memilih untuk menggunakan poin.');
      Log.info(
        'Poin penukaran yang dibutuhkan: ${selectedPaket.poinPenukaran}',
      );
      Log.info('Saldo poin pelanggan: $_saldoPoinPelanggan');

      if (selectedPaket.poinPenukaran <= 0) {
        Log.warning(
          'Paket "${selectedPaket.nama}" tidak mendukung penukaran poin. poinPenukaran = ${selectedPaket.poinPenukaran}',
        );
        return HasilSimpanModel(
          sukses: false,
          pesan: 'Paket ini tidak mendukung penukaran poin',
        );
      }

      if (_saldoPoinPelanggan < selectedPaket.poinPenukaran) {
        Log.warning(
          'Poin pelanggan tidak mencukupi. Dibutuhkan: ${selectedPaket.poinPenukaran}, Tersedia: $_saldoPoinPelanggan',
        );
        return HasilSimpanModel(sukses: false, pesan: 'Poin tidak cukup');
      }

      Log.info('Validasi poin BERHASIL. Poin mencukupi untuk penukaran.');
    }

    try {
      Log.info('========================================');
      Log.info('MEMBUAT DATA PELANGGAN AKTIF DAN TRANSAKSI');
      Log.info('========================================');

      Log.info('Membuat objek DateTime untuk tanggal mulai...');
      final DateTime tanggalMulai = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      Log.info('Tanggal mulai: ${tanggalMulai.toIso8601String()}');
      Log.info('Format: ${FormatTanggal.formatTanggalDanJam(tanggalMulai)}');

      Log.info(
        'Menghitung tanggal berakhir menggunakan fungsi hitungTanggalBerakhir...',
      );
      final DateTime tanggalBerakhir = hitungTanggalBerakhir(
        tanggalMulai,
        selectedPaket,
      );
      Log.info('Tanggal berakhir: ${tanggalBerakhir.toIso8601String()}');
      Log.info('Format: ${FormatTanggal.formatTanggalDanJam(tanggalBerakhir)}');

      Log.info('Menentukan ID transaksi...');
      final String transaksiId =
          _isEditMode && widget.pelangganAktif?.idTransaksi != null
          ? widget.pelangganAktif!.idTransaksi!
          : const Uuid().v4();
      Log.info(
        'ID Transaksi: $transaksiId (${_isEditMode && widget.pelangganAktif?.idTransaksi != null ? "Menggunakan ID lama" : "UUID baru digenerate"})',
      );

      Log.info('Membuat objek PelangganAktifModel...');
      final pelangganAktifData = PelangganAktifModel(
        id: _isEditMode ? widget.pelangganAktif!.id : '',
        idPelanggan: _selectedPelanggan!.id,
        idPaket: selectedPaket.id,
        tanggalMulai: tanggalMulai,
        tanggalBerakhir: tanggalBerakhir,
        status: _statusPembayaran,
        diperbarui: DateTime.now(),
        idTransaksi: transaksiId,
      );
      Log.info('PelangganAktifModel berhasil dibuat:');
      Log.info('  - ID: ${pelangganAktifData.id}');
      Log.info('  - ID Pelanggan: ${pelangganAktifData.idPelanggan}');
      Log.info('  - ID Paket: ${pelangganAktifData.idPaket}');
      Log.info('  - Tanggal Mulai: ${pelangganAktifData.tanggalMulai}');
      Log.info('  - Tanggal Berakhir: ${pelangganAktifData.tanggalBerakhir}');
      Log.info('  - Status: ${pelangganAktifData.status}');
      Log.info('  - ID Transaksi: ${pelangganAktifData.idTransaksi}');

      Log.info('Membuat objek TransaksiModel...');
      final transaksiData = TransaksiModel(
        id: transaksiId,
        tanggal: tanggalMulai,
        keterangan: 'Aktivasi Paket: ${selectedPaket.nama}',
        jumlah: _gunakanPoin ? 0 : selectedPaket.harga.toDouble(),
        tipe: _gunakanPoin
            ? TipeTransaksi.pengeluaran
            : TipeTransaksi.pemasukan,
        idDompet: _selectedDompet!.id,
        idKategori: _selectedKategori!.id,
        idPelanggan: _selectedPelanggan!.id,
        idPaket: selectedPaket.id,
        statusPembayaran: _statusPembayaran,
        poinYangDihasilkan: _gunakanPoin ? 0 : selectedPaket.poinHadiah,
        poinYangDigunakan: _gunakanPoin ? selectedPaket.poinPenukaran : 0,
        diperbarui: DateTime.now(),
        durasiPaket: selectedPaket.durasi,
        tipeDurasiPaket: selectedPaket.tipe,
        tanggalMulai: tanggalMulai,
        tanggalBerakhir: tanggalBerakhir,
        aktivasiPaket: true,
      );
      Log.info('TransaksiModel berhasil dibuat:');
      Log.info('  - ID: ${transaksiData.id}');
      Log.info('  - Keterangan: ${transaksiData.keterangan}');
      Log.info('  - Jumlah: ${transaksiData.jumlah}');
      Log.info('  - Tipe: ${transaksiData.tipe}');
      Log.info('  - Poin Dihasilkan: ${transaksiData.poinYangDihasilkan}');
      Log.info('  - Poin Digunakan: ${transaksiData.poinYangDigunakan}');
      Log.info('  - Status Pembayaran: ${transaksiData.statusPembayaran}');

      if (_isEditMode) {
        Log.info('========================================');
        Log.info('PROSES UPDATE DATA (MODE EDIT)');
        Log.info('========================================');
        Log.info('Memperbarui data Pelanggan Aktif di database...');
        await widget.pelangganAktifOperasi.updatePelangganAktif(
          pelangganAktifData,
        );
        Log.info('Pelanggan Aktif berhasil diperbarui.');

        Log.info('Memperbarui data Transaksi di database...');
        await widget.transaksiOperasi.updateTransaksi(
          transaksiId,
          transaksiData,
        );
        Log.info('Transaksi berhasil diperbarui.');
      } else {
        Log.info('========================================');
        Log.info('PROSES SIMPAN DATA BARU (MODE TAMBAH)');
        Log.info('========================================');
        Log.info('Menyimpan data Pelanggan Aktif baru ke database...');
        await widget.pelangganAktifOperasi.createPelangganAktif(
          pelangganAktifData,
        );
        Log.info('Pelanggan Aktif baru berhasil disimpan.');

        Log.info('Menyimpan data Transaksi baru ke database...');
        await widget.transaksiOperasi.tambahTransaksi(transaksiData);
        Log.info('Transaksi baru berhasil disimpan.');
      }

      Log.info('========================================');
      Log.info('PENYIMPANAN DATA BERHASIL');
      Log.info('========================================');
      return HasilSimpanModel(sukses: true, pesan: 'Berhasil disimpan');
    } catch (e, s) {
      Log.error(
        'Gagal menyimpan data pelanggan aktif. '
        'Proses ${_isEditMode ? "update" : "create"} mengalami kegagalan. '
        'Kemungkinan penyebab: koneksi database gagal, constraint violation, '
        'atau data tidak valid.',
        error: e,
        stackTrace: s,
      );
      return HasilSimpanModel(sukses: false, pesan: 'Gagal menyimpan: $e');
    }
  }

  @override
  void dispose() {
    Log.info('========================================');
    Log.info('LIFECYCLE: dispose() - Halaman FormPelangganAktif');
    Log.info('Membersihkan resource halaman FormPelangganAktif.');
    Log.info('========================================');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Log.info('========================================');
    Log.info('LIFECYCLE: build() - Membangun UI FormPelangganAktif');
    Log.info('Mode: ${_isEditMode ? "EDIT" : "TAMBAH BARU"}');
    Log.info('Status Loading: $_isLoading');
    Log.info('Menggunakan Poin: $_gunakanPoin');
    Log.info('Saldo Poin: $_saldoPoinPelanggan');
    Log.info('Status Pembayaran: $_statusPembayaran');
    Log.info('========================================');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Pelanggan Aktif' : 'Form Pelanggan Aktif',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Log.info(
              'NAVIGASI: Tombol Kembali ditekan. Kembali dengan result false.',
            );
            Navigator.pop(context, false);
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Gunakan Poin',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                if (_gunakanPoin)
                                  Text(
                                    'Poin dipakai: ${hitungPoinEfektif()}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                Text(
                                  'Sisa poin: ${hitungSisaPoin()}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: _gunakanPoin,
                              onChanged: (bool value) {
                                Log.info('SWITCH: Status Gunakan Poin diubah.');
                                Log.info('  - Status Lama: $_gunakanPoin');
                                Log.info('  - Status Baru: $value');
                                setState(() {
                                  _gunakanPoin = value;
                                  if (!_kategoriList.contains(
                                    _selectedKategori,
                                  )) {
                                    final kategoriSebelumnya =
                                        _selectedKategori?.nama ?? "NULL";
                                    _selectedKategori = _kategoriList.isNotEmpty
                                        ? _kategoriList.first
                                        : null;
                                    Log.info(
                                      'Kategori direset karena perubahan mode poin.',
                                    );
                                    Log.info(
                                      '  - Kategori sebelumnya: $kategoriSebelumnya',
                                    );
                                    Log.info(
                                      '  - Kategori baru: ${_selectedKategori?.nama ?? "NULL"}',
                                    );
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<PelangganModel>(
                        key: const Key('pelanggan_dropdown'),
                        decoration: const InputDecoration(
                          labelText: 'Pilih Pelanggan',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _selectedPelanggan,
                        items: _pelangganList.map((PelangganModel pelanggan) {
                          return DropdownMenuItem<PelangganModel>(
                            value: pelanggan,
                            child: Text(pelanggan.nama),
                          );
                        }).toList(),
                        onChanged: (PelangganModel? newValue) async {
                          if (newValue == null) return;
                          Log.info('DROPDOWN: Pelanggan dipilih.');
                          Log.info('  - Nama: ${newValue.nama}');
                          Log.info('  - ID: ${newValue.id}');

                          Log.info(
                            'Mengambil saldo poin pelanggan ${newValue.nama}...',
                          );
                          final saldoPoin = await widget.transaksiOperasi
                              .getTotalPoin(newValue.id);
                          Log.info('Saldo poin ${newValue.nama}: $saldoPoin');

                          if (!mounted) {
                            Log.warning(
                              'Widget tidak mounted setelah mengambil saldo poin.',
                            );
                            return;
                          }

                          setState(() {
                            _selectedPelanggan = newValue;
                            _saldoPoinPelanggan = saldoPoin;
                          });
                          Log.info(
                            'State diperbarui: Pelanggan = ${newValue.nama}, Saldo Poin = $saldoPoin',
                          );
                        },
                        validator: (value) {
                          if (value == null) {
                            Log.warning('VALIDASI: Pelanggan belum dipilih.');
                            return 'Pelanggan tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<PaketModel>(
                        key: const Key('paket_dropdown'),
                        decoration: const InputDecoration(
                          labelText: 'Pilih Paket',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _selectedPaket,
                        items: _paketList.map((PaketModel paket) {
                          return DropdownMenuItem<PaketModel>(
                            value: paket,
                            child: Text(paket.nama),
                          );
                        }).toList(),
                        onChanged: (PaketModel? newValue) {
                          Log.info('DROPDOWN: Paket dipilih.');
                          Log.info('  - Nama: ${newValue?.nama}');
                          Log.info('  - Harga: ${newValue?.harga}');
                          Log.info(
                            '  - Durasi: ${newValue?.durasi} ${newValue?.tipe.displayName}',
                          );
                          Log.info('  - Poin Hadiah: ${newValue?.poinHadiah}');
                          Log.info(
                            '  - Poin Penukaran: ${newValue?.poinPenukaran}',
                          );
                          setState(() {
                            _selectedPaket = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            Log.warning('VALIDASI: Paket belum dipilih.');
                            return 'Paket tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<DompetModel>(
                        key: const Key('dompet_dropdown'),
                        decoration: const InputDecoration(
                          labelText: 'Pilih Dompet',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _selectedDompet,
                        items: _daftarDompet.map((DompetModel dompet) {
                          return DropdownMenuItem<DompetModel>(
                            value: dompet,
                            child: Text(dompet.namaDompet),
                          );
                        }).toList(),
                        onChanged: (DompetModel? newValue) {
                          Log.info('DROPDOWN: Dompet dipilih.');
                          Log.info('  - Nama: ${newValue?.namaDompet}');
                          Log.info('  - Saldo: ${newValue?.saldo}');
                          setState(() {
                            _selectedDompet = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            Log.warning('VALIDASI: Dompet belum dipilih.');
                            return 'Dompet tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<KategoriModel>(
                        key: const Key('kategori_dropdown'),
                        decoration: const InputDecoration(
                          labelText: 'Pilih Kategori Transaksi',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _selectedKategori,
                        items: _kategoriList.map((KategoriModel kategori) {
                          return DropdownMenuItem<KategoriModel>(
                            value: kategori,
                            child: Text(kategori.nama),
                          );
                        }).toList(),
                        onChanged: (KategoriModel? newValue) {
                          Log.info('DROPDOWN: Kategori dipilih.');
                          Log.info('  - Nama: ${newValue?.nama}');
                          Log.info('  - Tipe: ${newValue?.tipe}');
                          setState(() {
                            _selectedKategori = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            Log.warning('VALIDASI: Kategori belum dipilih.');
                            return 'Kategori tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Pilih Tanggal & Waktu Aktif:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton.icon(
                            onPressed: () => _selectDate(context),
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              _selectedDate == null
                                  ? 'Pilih Tanggal'
                                  : FormatTanggal.formatTanggalBasic(
                                      _selectedDate!,
                                    ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _selectTime(context),
                            icon: const Icon(Icons.access_time),
                            label: Text(
                              _selectedTime == null
                                  ? 'Pilih Jam'
                                  : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _statusPembayaran ==
                                        StatusPembayaranEnum.lunas
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[200],
                                foregroundColor:
                                    _statusPembayaran ==
                                        StatusPembayaranEnum.lunas
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              onPressed: () {
                                Log.info(
                                  'BUTTON: Status pembayaran diatur ke LUNAS.',
                                );
                                Log.info(
                                  '  - Status sebelumnya: $_statusPembayaran',
                                );
                                setState(() {
                                  _statusPembayaran =
                                      StatusPembayaranEnum.lunas;
                                });
                                Log.info('  - Status baru: $_statusPembayaran');
                              },
                              child: const Text('Lunas'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _statusPembayaran ==
                                        StatusPembayaranEnum.belumLunas
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[200],
                                foregroundColor:
                                    _statusPembayaran ==
                                        StatusPembayaranEnum.belumLunas
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              onPressed: () {
                                Log.info(
                                  'BUTTON: Status pembayaran diatur ke BELUM LUNAS.',
                                );
                                Log.info(
                                  '  - Status sebelumnya: $_statusPembayaran',
                                );
                                setState(() {
                                  _statusPembayaran =
                                      StatusPembayaranEnum.belumLunas;
                                });
                                Log.info('  - Status baru: $_statusPembayaran');
                              },
                              child: const Text('Belum Lunas'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Tanggal Mulai:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                (_selectedDate == null || _selectedTime == null)
                                    ? 'Pilih Tanggal & Jam'
                                    : FormatTanggal.formatTanggalDanJam(
                                        DateTime(
                                          _selectedDate!.year,
                                          _selectedDate!.month,
                                          _selectedDate!.day,
                                          _selectedTime!.hour,
                                          _selectedTime!.minute,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Tanggal Berakhir:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text((() {
                                if (_selectedDate != null &&
                                    _selectedPaket != null) {
                                  DateTime startDate = DateTime(
                                    _selectedDate!.year,
                                    _selectedDate!.month,
                                    _selectedDate!.day,
                                    _selectedTime?.hour ?? 0,
                                    _selectedTime?.minute ?? 0,
                                  );
                                  final DateTime endDate =
                                      hitungTanggalBerakhir(
                                        startDate,
                                        _selectedPaket!,
                                      );
                                  return FormatTanggal.formatTanggalDanJam(
                                    endDate,
                                  );
                                } else {
                                  return 'Pilih paket & tanggal mulai';
                                }
                              }())),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () async {
            Log.info('========================================');
            Log.info('AKSI: Tombol Simpan Ditekan');
            Log.info('========================================');

            final navigator = Navigator.of(context);
            final messenger = ScaffoldMessenger.of(context);

            Log.info('Memanggil _saveForm() untuk memproses penyimpanan...');
            final hasil = await _saveForm();
            Log.info(
              'Hasil penyimpanan: sukses=${hasil.sukses}, pesan="${hasil.pesan}"',
            );

            if (!mounted) {
              Log.warning(
                'Widget sudah tidak mounted setelah penyimpanan. Tidak dapat menampilkan SnackBar.',
              );
              return;
            }

            Log.info('Menampilkan SnackBar dengan hasil penyimpanan.');
            messenger.showSnackBar(
              SnackBar(
                content: Text(hasil.pesan),
                backgroundColor: hasil.sukses ? Colors.green : Colors.red,
              ),
            );
            Log.info('SnackBar telah ditampilkan.');

            if (hasil.sukses) {
              Log.info(
                'Penyimpanan berhasil. Menunggu 300ms sebelum navigasi kembali...',
              );
              await Future.delayed(const Duration(milliseconds: 300));

              if (!mounted) {
                Log.warning(
                  'Widget tidak mounted setelah delay. Tidak dapat melakukan navigasi.',
                );
                return;
              }

              Log.info(
                'Melakukan Navigator.pop(context, true) untuk kembali ke halaman sebelumnya.',
              );
              navigator.pop(true);
            } else {
              Log.warning(
                'Penyimpanan gagal. Tetap di halaman form. Pesan error: ${hasil.pesan}',
              );
            }
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Simpan'),
        ),
      ),
    );
  }
}
