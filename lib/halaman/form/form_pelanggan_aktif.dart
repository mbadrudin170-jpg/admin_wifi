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
import 'package:admin_wifi/enum/status_pembayaran.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:admin_wifi/utils/format_util.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:uuid/uuid.dart';
import 'package:admin_wifi/enum/enum.dart';

// ditambahkan: Fungsi ini diekstrak dari state untuk kemudahan pengujian.
DateTime hitungTanggalBerakhir(DateTime startDate, PaketModel paket) {
  switch (paket.tipe) {
    case TipeDurasi.jam:
      return startDate.add(Duration(hours: paket.durasi));
    case TipeDurasi.hari:
      return startDate.add(Duration(days: paket.durasi));
    case TipeDurasi.bulan:
      return Jiffy.parseFromDateTime(
        startDate,
      ).add(months: paket.durasi).dateTime;
    case TipeDurasi.menit:
      return startDate.add(Duration(minutes: paket.durasi));
  }
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
       kategoriOperasi = kategoriOperasi ?? KategoriOperasi();

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

  // diubah: Menggunakan getter untuk mendapatkan daftar kategori yang aktif
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

  StatusPembayaran _statusPembayaran = StatusPembayaran.lunas;

  bool get _isEditMode => widget.pelangganAktif != null;
  int hitungPoinEfektif() {
    if (_selectedPaket == null) return 0;

    if (_gunakanPoin) {
      return _selectedPaket!.poinPenukaran;
    }

    return 0;
  }

  int hitungSisaPoin() {
    final pakai = hitungPoinEfektif();
    return (_saldoPoinPelanggan - pakai).clamp(0, 999999999);
  }

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      final results = await Future.wait([
        widget.pelangganOperasi.getPelanggan(),
        widget.paketOperasi.getPaket(),
        widget.dompetOperasi.getDompet(),
        widget.kategoriOperasi.getKategori(),
      ]);
      if (!mounted) return;

      setState(() {
        _pelangganList = results[0] as List<PelangganModel>;
        _pelangganList.sort(
          (a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()),
        );
        _paketList = results[1] as List<PaketModel>;

        final semuaDompet = results[2] as List<DompetModel>;
        _daftarDompet = semuaDompet
            .where((dompet) => !dompet.isDeleted)
            .toList();
        final semuaKategori = results[3] as List<KategoriModel>;
        _kategoriPemasukanList = semuaKategori
            .where((k) => k.tipe == TipeKategori.pemasukan && !k.isDeleted)
            .toList();

        _kategoriPengeluaranList = semuaKategori
            .where((k) => k.tipe == TipeKategori.pengeluaran && !k.isDeleted)
            .toList();

        if (_isEditMode) {
          final pa = widget.pelangganAktif!;
          try {
            _selectedPelanggan = _pelangganList.firstWhere(
              (p) => p.id == pa.idPelanggan,
            );
          } catch (e) {
            _selectedPelanggan = null;
          }
          try {
            _selectedPaket = _paketList.firstWhere((p) => p.id == pa.idPaket);
          } catch (e) {
            _selectedPaket = null;
            if (mounted) {
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
          _statusPembayaran = pa.status;
        } else {
          _selectedDate = DateTime.now();
          _selectedTime = TimeOfDay.now();
        }

        if (_selectedDompet == null && _daftarDompet.isNotEmpty) {
          _selectedDompet = _daftarDompet.first;
        }
        // diubah: Logika inisialisasi _selectedKategori diperbaiki
        if (_selectedKategori == null && _kategoriPemasukanList.isNotEmpty) {
          try {
            _selectedKategori = _kategoriPemasukanList.firstWhere(
              (k) => k.nama.toLowerCase() == 'aktivasi paket',
            );
          } catch (e) {
            _selectedKategori = _kategoriPemasukanList.first;
          }
        }

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
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
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<HasilSimpanModel> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return HasilSimpanModel(sukses: false, pesan: 'Data belum lengkap');
    }

    final selectedPaket = _selectedPaket;

    if (_selectedPelanggan == null ||
        selectedPaket == null ||
        _selectedDate == null ||
        _selectedTime == null ||
        _selectedDompet == null ||
        _selectedKategori == null) {
      return HasilSimpanModel(
        sukses: false,
        pesan: 'Harap lengkapi semua data',
      );
    }

    if (_gunakanPoin) {
      if (selectedPaket.poinPenukaran <= 0) {
        return HasilSimpanModel(
          sukses: false,
          pesan: 'Paket ini tidak mendukung penukaran poin',
        );
      }

      if (_saldoPoinPelanggan < selectedPaket.poinPenukaran) {
        return HasilSimpanModel(sukses: false, pesan: 'Poin tidak cukup');
      }
    }

    try {
      final DateTime tanggalMulai = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final DateTime tanggalBerakhir = hitungTanggalBerakhir(
        tanggalMulai,
        selectedPaket,
      );

      final String transaksiId =
          _isEditMode && widget.pelangganAktif?.idTransaksi != null
          ? widget.pelangganAktif!.idTransaksi!
          : const Uuid().v4();

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

      if (_isEditMode) {
        await widget.pelangganAktifOperasi.updatePelangganAktif(
          pelangganAktifData,
        );
        await widget.transaksiOperasi.updateTransaksi(
          transaksiId,
          transaksiData,
        );
      } else {
        await widget.pelangganAktifOperasi.createPelangganAktif(
          pelangganAktifData,
        );
        await widget.transaksiOperasi.tambahTransaksi(transaksiData);
      }

      return HasilSimpanModel(sukses: true, pesan: 'Berhasil disimpan');
    } catch (e) {
      return HasilSimpanModel(sukses: false, pesan: 'Gagal menyimpan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Pelanggan Aktif' : 'Form Pelanggan Aktif',
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
                                setState(() {
                                  _gunakanPoin = value;
                                  // diubah: Reset kategori jika tidak ada di daftar yang baru
                                  if (!_kategoriList.contains(
                                    _selectedKategori,
                                  )) {
                                    _selectedKategori = _kategoriList.isNotEmpty
                                        ? _kategoriList.first
                                        : null;
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

                          final saldoPoin = await widget.transaksiOperasi
                              .getTotalPoin(newValue.id);

                          if (!mounted) return;

                          setState(() {
                            _selectedPelanggan = newValue;
                            _saldoPoinPelanggan = saldoPoin;
                          });
                        },
                        validator: (value) => value == null
                            ? 'Pelanggan tidak boleh kosong'
                            : null,
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
                          setState(() {
                            _selectedPaket = newValue;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Paket tidak boleh kosong' : null,
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
                          setState(() {
                            _selectedDompet = newValue;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Dompet tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<KategoriModel>(
                        key: const Key('kategori_dropdown'),
                        decoration: const InputDecoration(
                          labelText: 'Pilih Kategori Transaksi',
                          border: OutlineInputBorder(),
                        ),
                        // diubah: Menggunakan _kategoriList (getter)
                        initialValue: _selectedKategori,
                        items: _kategoriList.map((KategoriModel kategori) {
                          return DropdownMenuItem<KategoriModel>(
                            value: kategori,
                            child: Text(kategori.nama),
                          );
                        }).toList(),
                        onChanged: (KategoriModel? newValue) {
                          setState(() {
                            _selectedKategori = newValue;
                          });
                        },
                        validator: (value) => value == null
                            ? 'Kategori tidak boleh kosong'
                            : null,
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
                                    _statusPembayaran == StatusPembayaran.lunas
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[200],
                                foregroundColor:
                                    _statusPembayaran == StatusPembayaran.lunas
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _statusPembayaran = StatusPembayaran.lunas;
                                });
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
                                        StatusPembayaran.belumLunas
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[200],
                                foregroundColor:
                                    _statusPembayaran ==
                                        StatusPembayaran.belumLunas
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _statusPembayaran =
                                      StatusPembayaran.belumLunas;
                                });
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
            final navigator = Navigator.of(context);
            final messenger = ScaffoldMessenger.of(context);

            final hasil = await _saveForm();

            if (!mounted) return;

            messenger.showSnackBar(
              SnackBar(
                content: Text(hasil.pesan),
                backgroundColor: hasil.sukses ? Colors.green : Colors.red,
              ),
            );

            if (hasil.sukses) {
              await Future.delayed(const Duration(milliseconds: 300));

              if (!mounted) return;
              navigator.pop(true);
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
