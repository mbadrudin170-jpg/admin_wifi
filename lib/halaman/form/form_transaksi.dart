// path: lib/halaman/form/form_transaksi.dart
import 'package:admin_wifi/data/operasi/kategori_operasi.dart';
import 'package:admin_wifi/data/operasi/dompet_operasi.dart';
import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
import 'package:admin_wifi/enum/tipe_transaksi_enum.dart';
import 'package:admin_wifi/model/kategori_model.dart';
import 'package:admin_wifi/model/sub_kategori_model.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:flutter/material.dart';
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:uuid/uuid.dart';

class FormTransaksiPage extends StatefulWidget {
  final TransaksiModel? transaksi;
  const FormTransaksiPage({super.key, this.transaksi});

  @override
  State<FormTransaksiPage> createState() => _FormTransaksiPageState();
}

class _FormTransaksiPageState extends State<FormTransaksiPage> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  final _keteranganController = TextEditingController();
  DateTime _tanggal = DateTime.now();

  KategoriModel? _selectedKategori;
  SubKategoriModel? _selectedSubKategori;
  TipeTransaksi _tipe = TipeTransaksi.pemasukan;
  DompetModel? _selectedDompet;
  DompetModel? _selectedDompetTujuan;

  final DompetOperasi _dompetOperasi = DompetOperasi();
  final KategoriOperasi _kategoriOperasi = KategoriOperasi();
  final TransaksiOperasi _transaksiOperasi = TransaksiOperasi();

  List<KategoriModel> _kategoriList = [];
  List<DompetModel> _dompetList = [];
  List<KategoriModel> _kategoriFiltered = [];

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAndPopulateInitialData();
  }

  Future<void> _loadAndPopulateInitialData() async {
    try {
      final dompetList = await _dompetOperasi.getDompet();
      final kategoriList = await _kategoriOperasi.getKategori();

      setState(() {
        _dompetList = dompetList;
        _kategoriList = kategoriList;
      });

      if (widget.transaksi != null) {
        final trx = widget.transaksi!;
        _tipe = trx.tipe;
        _keteranganController.text = trx.keterangan;
        _jumlahController.text = trx.jumlah.abs().toString();
        _tanggal = trx.tanggal;

        _selectedDompet = _dompetList.firstWhere(
          (d) => d.id == trx.idDompet,
          orElse: () => _dompetList.first,
        );
        if (trx.tipe == TipeTransaksi.transfer && trx.idDompetTujuan != null) {
          _selectedDompetTujuan = _dompetList.firstWhere(
            (d) => d.id == trx.idDompetTujuan,
          );
        }

        _filterKategori();

        if (trx.idKategori.isNotEmpty) {
          _selectedKategori = _kategoriFiltered.firstWhere(
            (k) => k.id == trx.idKategori,
          );
          if (trx.idSubKategori != null && _selectedKategori != null) {
            _selectedSubKategori = _selectedKategori!.subKategori.firstWhere(
              (sk) => sk.id == trx.idSubKategori,
            );
          }
        }
      } else {
        _filterKategori();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterKategori() {
    setState(() {
      _kategoriFiltered = _kategoriList.where((k) {
        final tipeKategoriTarget = _tipe == TipeTransaksi.pemasukan
            ? TipeKategori.pemasukan
            : TipeKategori.pengeluaran;
        return k.tipe == tipeKategoriTarget;
      }).toList();
      _selectedKategori = null;
      _selectedSubKategori = null;
    });
  }

  Future<void> _pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _tanggal) {
      setState(() {
        _tanggal = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _tanggal.hour,
          _tanggal.minute,
        );
      });
    }
  }

  Future<void> _pilihWaktu(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_tanggal),
    );
    if (picked != null) {
      setState(() {
        _tanggal = DateTime(
          _tanggal.year,
          _tanggal.month,
          _tanggal.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _simpanForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      final isEditMode = widget.transaksi != null;
      // diubah: Jumlah sekarang selalu positif, logika (+/-) dipusatkan di fungsi hitung ulang.
      final double jumlah = double.parse(_jumlahController.text).abs();

      final transaksi = TransaksiModel(
        id: isEditMode ? widget.transaksi!.id : const Uuid().v4(),
        keterangan: _keteranganController.text,
        jumlah: jumlah,
        tanggal: _tanggal,
        tipe: _tipe,
        idDompet: _selectedDompet!.id,
        idDompetTujuan: _tipe == TipeTransaksi.transfer
            ? _selectedDompetTujuan?.id
            : null,
        idKategori: _selectedKategori?.id ?? '',
        idSubKategori: _selectedSubKategori?.id,
        diperbarui: DateTime.now(),
      );

      try {
        if (isEditMode) {
          await _transaksiOperasi.updateTransaksi(
            widget.transaksi!.id,
            transaksi,
          );
        } else {
          await _transaksiOperasi.tambahTransaksi(transaksi);
        }
        if (!mounted) return;
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan transaksi: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaksi != null ? 'Edit Transaksi' : 'Tambah Transaksi',
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: SegmentedButton<TipeTransaksi>(
                          segments: TipeTransaksi.values.map((
                            TipeTransaksi tipe,
                          ) {
                            return ButtonSegment<TipeTransaksi>(
                              value: tipe,
                              label: Text(tipe.name.toUpperCase()),
                            );
                          }).toList(),
                          selected: <TipeTransaksi>{_tipe},
                          onSelectionChanged:
                              (Set<TipeTransaksi> newSelection) {
                                setState(() {
                                  _tipe = newSelection.first;
                                  _selectedKategori = null;
                                  _selectedSubKategori = null;
                                  _selectedDompetTujuan = null;
                                  _filterKategori();
                                });
                              },
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _keteranganController,
                      decoration: const InputDecoration(
                        labelText: 'Keterangan',
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Keterangan tidak boleh kosong'
                          : null,
                    ),
                    TextFormField(
                      controller: _jumlahController,
                      decoration: const InputDecoration(labelText: 'Jumlah'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jumlah tidak boleh kosong';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Format jumlah tidak valid';
                        }
                        return null;
                      },
                    ),
                    ListTile(
                      title: Text(
                        'Tanggal & Jam: ${_tanggal.toLocal().toString().split('.')[0]}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _pilihTanggal(context),
                            tooltip: 'Pilih Tanggal',
                          ),
                          IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () => _pilihWaktu(context),
                            tooltip: 'Pilih Jam',
                          ),
                        ],
                      ),
                    ),
                    DropdownButtonFormField<DompetModel>(
                      initialValue: _selectedDompet,
                      decoration: const InputDecoration(labelText: 'Dompet'),
                      items: _dompetList.map((DompetModel dompet) {
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
                          value == null ? 'Dompet harus dipilih' : null,
                    ),
                    if (_tipe == TipeTransaksi.transfer)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: DropdownButtonFormField<DompetModel>(
                          initialValue: _selectedDompetTujuan,
                          decoration: const InputDecoration(
                            labelText: 'Dompet Tujuan',
                          ),
                          items: _dompetList.map((DompetModel dompet) {
                            return DropdownMenuItem<DompetModel>(
                              value: dompet,
                              child: Text(dompet.namaDompet),
                            );
                          }).toList(),
                          onChanged: (DompetModel? newValue) {
                            setState(() {
                              _selectedDompetTujuan = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Dompet tujuan harus dipilih';
                            }
                            if (value == _selectedDompet) {
                              return 'Dompet tujuan tidak boleh sama dengan dompet asal';
                            }
                            return null;
                          },
                        ),
                      ),
                    if (_kategoriFiltered.isNotEmpty)
                      DropdownButtonFormField<KategoriModel>(
                        initialValue: _selectedKategori,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                        ),
                        items: _kategoriFiltered.map((KategoriModel kategori) {
                          return DropdownMenuItem<KategoriModel>(
                            value: kategori,
                            child: Text(kategori.nama),
                          );
                        }).toList(),
                        onChanged: (KategoriModel? newValue) {
                          setState(() {
                            _selectedKategori = newValue;
                            _selectedSubKategori = null;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Kategori harus dipilih' : null,
                      ),
                    if (_selectedKategori != null &&
                        _selectedKategori!.subKategori.isNotEmpty)
                      DropdownButtonFormField<SubKategoriModel>(
                        initialValue: _selectedSubKategori,
                        decoration: const InputDecoration(
                          labelText: 'Sub Kategori',
                        ),
                        items: _selectedKategori!.subKategori.map((
                          SubKategoriModel sub,
                        ) {
                          return DropdownMenuItem<SubKategoriModel>(
                            value: sub,
                            child: Text(sub.nama),
                          );
                        }).toList(),
                        onChanged: (SubKategoriModel? newValue) {
                          setState(() {
                            _selectedSubKategori = newValue;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Sub Kategori harus dipilih' : null,
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _simpanForm,
                      child: _isSaving
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            )
                          : const Text('Simpan'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }
}
