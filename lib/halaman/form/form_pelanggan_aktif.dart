// path: lib/halaman/form/form_pelanggan_aktif.dart
// Halaman ini menyediakan formulir untuk mengaktifkan pelanggan dengan paket tertentu.
// diubah: Melakukan refactoring untuk menerapkan Dependency Injection.
// Sekarang, semua dependensi operasi (seperti PelangganOperasi) diterima
// melalui constructor untuk memudahkan pengujian (mocking).
// diubah: Mengganti ListView dengan SingleChildScrollView dan Column untuk memastikan semua widget dirender.
// diubah: Memisahkan logika penyimpanan dan navigasi untuk memastikan SnackBar sempat ditampilkan dalam pengujian.
// diubah: Memperbaiki bug dimana Dompet dan Kategori tidak diinisialisasi dalam mode edit.
// ditambahkan: Mengembalikan delay setelah menyimpan untuk memastikan SnackBar dapat diuji.
// diubah: Mengganti `value` dengan `initialValue` pada DropdownButtonFormField dan memperbaiki penggunaan BuildContext secara tidak aman.
// diubah: Memfilter daftar kategori agar hanya menampilkan tipe pemasukan.
// diubah: Memfilter daftar kategori untuk mengecualikan yang sudah dihapus (isDeleted == true).
// ditambahkan: filter untuk hanya menampilkan dompet yang isDeleted-nya false.

import 'dart:developer' as developer;
import 'package:admin_wifi/data/operasi/kategori_operasi.dart';
import 'package:admin_wifi/data/operasi/dompet_operasi.dart';
import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_aktif_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
import 'package:admin_wifi/model/kategori_model.dart';
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:admin_wifi/model/paket_model.dart';
import 'package:admin_wifi/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';
import 'package:admin_wifi/model/enum/status_pembayaran.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:admin_wifi/utils/format_util.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:uuid/uuid.dart';

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
  })  : pelangganOperasi = pelangganOperasi ?? PelangganOperasi(),
        paketOperasi = paketOperasi ?? PaketOperasi(),
        pelangganAktifOperasi =
            pelangganAktifOperasi ?? PelangganAktifOperasi(),
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
  List<KategoriModel> _kategoriList = [];

  PelangganModel? _selectedPelanggan;
  PaketModel? _selectedPaket;
  DompetModel? _selectedDompet;
  KategoriModel? _selectedKategori;

  bool _isLoading = true;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  StatusPembayaran _statusPembayaran = StatusPembayaran.lunas;

  bool get _isEditMode => widget.pelangganAktif != null;

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
      setState(() {
        _pelangganList = results[0] as List<PelangganModel>;
        _pelangganList.sort(
          (a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()),
        );
        _paketList = results[1] as List<PaketModel>;
        
        // diubah: Memfilter dompet untuk hanya menampilkan yang tidak dihapus.
        final semuaDompet = results[2] as List<DompetModel>;
        _daftarDompet = semuaDompet.where((dompet) => !dompet.isDeleted).toList();

        _kategoriList = (results[3] as List<KategoriModel>)
            .where(
              (k) => k.tipe == TipeKategori.pemasukan && k.isDeleted == false,
            )
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
        if (_selectedKategori == null && _kategoriList.isNotEmpty) {
          try {
            _selectedKategori = _kategoriList.firstWhere(
              (k) => k.nama.toLowerCase() == 'aktivasi paket',
            );
          } catch (e) {
            _selectedKategori = _kategoriList.first;
          }
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
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

  DateTime _hitungTanggalBerakhir(DateTime startDate, PaketModel paket) {
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

  Future<bool> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final selectedPaket = _selectedPaket;
      if (_selectedPelanggan != null &&
          selectedPaket != null &&
          _selectedDate != null &&
          _selectedTime != null &&
          _selectedDompet != null &&
          _selectedKategori != null) {
        final DateTime tanggalMulai = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );

        final DateTime tanggalBerakhir = _hitungTanggalBerakhir(
          tanggalMulai,
          selectedPaket,
        );

        final pelangganAktifData = PelangganAktifModel(
          id: _isEditMode ? widget.pelangganAktif!.id : '',
          idPelanggan: _selectedPelanggan!.id,
          idPaket: selectedPaket.id,
          tanggalMulai: tanggalMulai,
          tanggalBerakhir: tanggalBerakhir,
          status: _statusPembayaran,
          diperbarui: DateTime.now(),
        );

        try {
          if (_isEditMode) {
            await widget.pelangganAktifOperasi.updatePelangganAktif(
              pelangganAktifData,
            );
          } else {
            await widget.pelangganAktifOperasi.createPelangganAktif(
              pelangganAktifData,
            );
          }

          if (_statusPembayaran == StatusPembayaran.lunas) {
            final transaksi = TransaksiModel(
              id: const Uuid().v4(),
              tanggal: tanggalMulai,
              keterangan:
                  'Aktivasi paket: ${selectedPaket.nama} - ${_selectedPelanggan!.nama}',
              jumlah: selectedPaket.harga.toDouble(),
              tipe: TipeTransaksi.pemasukan,
              idDompet: _selectedDompet!.id,
              namaDompet: _selectedDompet!.namaDompet,
              idKategori: _selectedKategori!.id,
              namaKategori: _selectedKategori!.nama,
              idPelanggan: _selectedPelanggan!.id,
              namaPelanggan: _selectedPelanggan!.nama,
              idPaket: selectedPaket.id,
              namaPaket: selectedPaket.nama,
              diperbarui: DateTime.now(),
            );
            await widget.transaksiOperasi.tambahTransaksi(transaksi);
          }

          if (!mounted) return false;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Pelanggan berhasil ${_isEditMode ? 'diperbarui' : 'diaktifkan'}!',
              ),
            ),
          );
          return true;
        } catch (e, s) {
          developer.log(
            'Terjadi kesalahan saat menyimpan',
            name: 'admin_wifi.form.pelanggan_aktif',
            error: e,
            stackTrace: s,
          );

          if (!mounted) return false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan: $e. Cek log untuk detail.'),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Harap lengkapi semua data, termasuk Pelanggan, Paket, Dompet, dan Kategori.',
            ),
          ),
        );
      }
    }
    return false;
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
                      DropdownButtonFormField<PelangganModel>(
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
                        onChanged: (PelangganModel? newValue) {
                          setState(() {
                            _selectedPelanggan = newValue;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Pelanggan tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<PaketModel>(
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
                          setState(() {
                            _selectedKategori = newValue;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Kategori tidak boleh kosong' : null,
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
                                backgroundColor: _statusPembayaran ==
                                        StatusPembayaran.belumLunas
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[200],
                                foregroundColor: _statusPembayaran ==
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
                                      _hitungTanggalBerakhir(
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
                      const SizedBox(height: 24), // Spacer
                      ElevatedButton(
                        onPressed: () {
                          final navigator = Navigator.of(context);
                          () async {
                            final success = await _saveForm();
                            if (success) {
                              await Future.delayed(
                                const Duration(milliseconds: 500),
                              );
                              if (!mounted) return;
                              navigator.pop(true);
                            }
                          }();
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Simpan'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
