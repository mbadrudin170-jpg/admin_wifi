// path: lib/fitur/transaksi/screens/form_transaksi.dart

import 'dart:async';

import 'package:admin_wifi/enum/tipe_transaksi_enum.dart';
import 'package:admin_wifi/fitur/dompet/model/dompet_model.dart';
import 'package:admin_wifi/fitur/dompet/notifier/dompet_notifier.dart';
import 'package:admin_wifi/fitur/kategori/model/kategori_model.dart';
import 'package:admin_wifi/fitur/kategori/model/sub_kategori_model.dart';
import 'package:admin_wifi/fitur/kategori/notifier/kategori_notifier.dart';
import 'package:admin_wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:admin_wifi/fitur/transaksi/notifier/transaksi_notifier.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/core_shared.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class FormTransaksiPage extends ConsumerStatefulWidget {
  final TransaksiModel? transaksi;

  const FormTransaksiPage({super.key, this.transaksi});

  @override
  ConsumerState<FormTransaksiPage> createState() => _FormTransaksiPageState();
}

class _FormTransaksiPageState extends ConsumerState<FormTransaksiPage> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  final _keteranganController = TextEditingController();
  DateTime _tanggal = DateTime.now();

  KategoriModel? _selectedKategori;
  SubKategoriModel? _selectedSubKategori;
  TipeTransaksi _tipe = TipeTransaksi.pemasukan;
  DompetModel? _selectedDompet;
  DompetModel? _selectedDompetTujuan;

  List<KategoriModel> _kategoriList = [];
  List<DompetModel> _dompetList = [];
  List<KategoriModel> _kategoriFiltered = [];

  bool get _isEditMode => widget.transaksi != null;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    unawaited(
      _muatDataAwal().catchError((Object e, StackTrace s) {
        L.e('Gagal memuat data awal form transaksi: $e $s');
      }),
    );
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _muatDataAwal() async {
    try {
      final dompetState = await ref.read(dompetProvider.future);
      final kategoriState = await ref.read(kategoriProvider.future);

      if (!mounted) return;

      setState(() {
        _dompetList = dompetState.listDompet;
        _kategoriList = kategoriState.listKategori;

        if (_isEditMode) {
          final trx = widget.transaksi;
          if (trx != null) {
            _tipe = trx.tipe;
            _keteranganController.text = trx.keterangan;
            _jumlahController.text = trx.jumlah.abs().toString();
            _tanggal = trx.tanggal;

            _selectedDompet = dompetState.getById(trx.idDompet);
            if (_selectedDompet == null && _dompetList.isNotEmpty) {
              _selectedDompet = _dompetList.first;
            }

            if (trx.tipe == TipeTransaksi.transfer &&
                trx.idDompetTujuan != null) {
              _selectedDompetTujuan = dompetState.getById(trx.idDompetTujuan!);
              if (_selectedDompetTujuan == null && _dompetList.isNotEmpty) {
                _selectedDompetTujuan = _dompetList.first;
              }
            }

            _filterKategoriInternal();

            if (trx.idKategori.isNotEmpty) {
              _selectedKategori = kategoriState.getById(trx.idKategori);

              final idSubKategori = trx.idSubKategori;
              final selectedKategori = _selectedKategori;
              if (idSubKategori != null && selectedKategori != null) {
                _selectedSubKategori = kategoriState.getSubKategoriById(
                  idSubKategori,
                );
              }
            }
          }
        } else {
          _filterKategoriInternal();
        }

        _isLoading = false;
      });
    } catch (e, s) {
      L.e('Gagal memuat data awal form transaksi: $e $s');
      if (!mounted) return;
      AppToast.gagal(context, 'Gagal memuat data penting: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterKategoriInternal() {
    final tipeKategoriTarget = _tipe == TipeTransaksi.pemasukan
        ? TipeKategori.pemasukan
        : TipeKategori.pengeluaran;

    _kategoriFiltered = _kategoriList
        .where((k) => k.tipe == tipeKategoriTarget)
        .toList();
  }

  void _filterKategori() {
    setState(() {
      _filterKategoriInternal();
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

    if (!mounted || picked == null) return;

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

  Future<void> _simpanForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    unawaited(
      EasyLoading.show(
        status: 'Menyimpan...',
        maskType: EasyLoadingMaskType.black,
      ).catchError((Object e, StackTrace s) {
        L.e('Gagal menampilkan loading: $e $s');
      }),
    );

    final double jumlah = InputAngka.parseAngkaRibuan(
      _jumlahController.text,
    ).abs();

    final selectedDompet = _selectedDompet;
    if (selectedDompet == null) {
      unawaited(
        EasyLoading.dismiss().catchError((Object e, StackTrace s) {
          L.e('Gagal menutup loading: $e $s');
        }),
      );
      return;
    }

    final transaksi = TransaksiModel(
      id: widget.transaksi?.id ?? const Uuid().v4(),
      keterangan: _keteranganController.text,
      jumlah: jumlah,
      tanggal: _tanggal,
      tipe: _tipe,
      idDompet: selectedDompet.id,
      idDompetTujuan: _tipe == TipeTransaksi.transfer
          ? _selectedDompetTujuan?.id
          : null,
      idKategori: _selectedKategori?.id ?? '',
      idSubKategori: _selectedSubKategori?.id,
      diperbarui: DateTime.now(),
    );

    try {
      final notifier = ref.read(transaksiProvider.notifier);
      if (_isEditMode) {
        await notifier.ubah(transaksi);
      } else {
        await notifier.tambah(transaksi);
      }

      if (!mounted) return;
      AppToast.sukses(
        context,
        'Transaksi berhasil ${_isEditMode ? 'diperbarui' : 'disimpan'}!',
      );
      Nav.pop(context, true);
    } on DatabaseException catch (e, s) {
      L.e('Gagal menyimpan transaksi: $e $s');
      if (!mounted) return;
      AppToast.gagal(context, 'Gagal menyimpan transaksi: $e');
    } catch (e, s) {
      L.e('Gagal menyimpan transaksi: $e $s');
      if (!mounted) return;
      AppToast.gagal(context, 'Gagal menyimpan transaksi: $e');
    } finally {
      unawaited(
        EasyLoading.dismiss().catchError((Object e, StackTrace s) {
          L.e('Gagal menutup loading: $e $s');
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedKategori = _selectedKategori;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Transaksi' : 'Tambah Transaksi'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Column(
                      spacing: 16,
                      children: [
                        Center(
                          child: SegmentedButton<TipeTransaksi>(
                            segments: TipeTransaksi.values
                                .map(
                                  (tipe) => ButtonSegment<TipeTransaksi>(
                                    value: tipe,
                                    label: Text(tipe.label),
                                  ),
                                )
                                .toList(),
                            selected: <TipeTransaksi>{_tipe},
                            onSelectionChanged: (newSelection) {
                              setState(() {
                                _tipe = newSelection.first;
                                _filterKategori();
                                _selectedDompetTujuan = null;
                              });
                            },
                          ),
                        ),
                        InputTeks(
                          controller: _keteranganController,
                          label: 'Keterangan',
                          validator: (value) => value == null || value.isEmpty
                              ? 'Keterangan tidak boleh kosong'
                              : null,
                        ),
                        InputAngka(
                          controller: _jumlahController,
                          label: 'Jumlah',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Jumlah tidak boleh kosong';
                            }
                            if (double.tryParse(
                                  value.replaceAll(RegExp(r'[^0-9\-]'), ''),
                                ) ==
                                null) {
                              return 'Format jumlah tidak valid';
                            }
                            return null;
                          },
                        ),
                        PemilihTanggalWaktuWidget(
                          tanggalTerpilih: _tanggal,
                          waktuTerpilih: TimeOfDay.fromDateTime(_tanggal),
                          onPilihTanggal: () => _pilihTanggal(context),
                          onPilihWaktu: () => _pilihWaktu(context),
                          onResetKeSekarang: () =>
                              setState(() => _tanggal = DateTime.now()),
                        ),
                        InputDropdown<DompetModel>(
                          value: _selectedDompet,
                          label: 'Dompet',
                          items: _dompetList,
                          displayString: (dompet) => dompet.namaDompet,
                          onChanged: (val) =>
                              setState(() => _selectedDompet = val),
                          validator: (val) =>
                              val == null ? 'Dompet harus dipilih' : null,
                        ),
                        if (_tipe == TipeTransaksi.transfer)
                          InputDropdown<DompetModel>(
                            value: _selectedDompetTujuan,
                            label: 'Dompet Tujuan',
                            items: _dompetList,
                            displayString: (dompet) => dompet.namaDompet,
                            onChanged: (val) =>
                                setState(() => _selectedDompetTujuan = val),
                            validator: (val) {
                              if (val == null)
                                return 'Dompet tujuan harus dipilih';
                              if (val == _selectedDompet) {
                                return 'Dompet tidak boleh sama';
                              }
                              return null;
                            },
                          ),
                        if (_kategoriFiltered.isNotEmpty)
                          InputDropdown<KategoriModel>(
                            value: selectedKategori,
                            label: 'Kategori',
                            items: _kategoriFiltered,
                            displayString: (kategori) => kategori.nama,
                            onChanged: (val) {
                              setState(() {
                                _selectedKategori = val;
                                _selectedSubKategori = null;
                              });
                            },
                            validator: (val) =>
                                val == null ? 'Kategori harus dipilih' : null,
                          ),
                        if (selectedKategori != null &&
                            selectedKategori.subKategori.isNotEmpty)
                          InputDropdown<SubKategoriModel>(
                            value: _selectedSubKategori,
                            label: 'Sub Kategori',
                            items: selectedKategori.subKategori,
                            displayString: (sub) => sub.nama,
                            onChanged: (val) =>
                                setState(() => _selectedSubKategori = val),
                            validator: (val) => val == null
                                ? 'Sub Kategori harus dipilih'
                                : null,
                          ),
                        ElevatedButton(
                          onPressed: _simpanForm,
                          child: const Text('Simpan'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
