// path: lib/fitur/pelanggan_aktif/screens/form_pelanggan_aktif.dart

import 'package:admin_wifi/fitur/transaksi/enum/status_pembayaran_enum.dart';
import 'package:admin_wifi/fitur/transaksi/enum/tipe_transaksi_enum.dart';
import 'package:admin_wifi/fitur/dompet/model/dompet_model.dart';
import 'package:admin_wifi/fitur/dompet/notifier/dompet_notifier.dart';
import 'package:admin_wifi/fitur/kategori/model/kategori_model.dart';
import 'package:admin_wifi/fitur/kategori/notifier/kategori_notifier.dart';
import 'package:admin_wifi/fitur/paket/model/paket_model.dart';
import 'package:admin_wifi/fitur/paket/notifier/paket_notifier.dart';
import 'package:admin_wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:admin_wifi/fitur/pelanggan/notifier/pelanggan_notifier.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/notifer/pengguna_aktif_notifier.dart';
import 'package:admin_wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:admin_wifi/fitur/transaksi/notifier/transaksi_notifier.dart';
import 'package:admin_wifi/utils/format_util.dart';
import 'package:admin_wifi/whatsapp/info_paket.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/jiffy.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_global_saya/core_shared.dart' hide FormatTanggal;
import 'package:uuid/uuid.dart';

DateTime hitungTanggalBerakhir(DateTime startDate, PaketModel paket) {
  DateTime hasil;
  switch (paket.tipe) {
    case TipeDurasi.jam:
      hasil = startDate.add(Duration(hours: paket.durasi));
      break;
    case TipeDurasi.hari:
      hasil = startDate.add(Duration(days: paket.durasi));
      break;
    case TipeDurasi.bulan:
      hasil = Jiffy.parseFromDateTime(
        startDate,
      ).add(months: paket.durasi).dateTime;
      break;
    case TipeDurasi.menit:
      hasil = startDate.add(Duration(minutes: paket.durasi));
      break;
  }

  L.i('  - Hasil Tanggal Berakhir: ${hasil.toIso8601String()}');
  return hasil;
}

class FormPelangganAktif extends ConsumerStatefulWidget {
  final PelangganAktifModel? pelangganAktif;
  final bool modePerpanjang;

  const FormPelangganAktif({
    super.key,
    this.pelangganAktif,
    this.modePerpanjang = false,
  });

  @override
  ConsumerState<FormPelangganAktif> createState() => _FormPelangganAktifState();
}

class _FormPelangganAktifState extends ConsumerState<FormPelangganAktif> {
  bool get _modePerpanjang => widget.modePerpanjang;
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

  bool _awalDipetakan = false;
  String? _peringatanPaket;
  bool _gunakanPoin = false;
  int _saldoPoinPelanggan = 0;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  StatusPembayaranEnum _statusPembayaran = StatusPembayaranEnum.lunas;

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

  /// Memetakan nilai awal (edit/baru) satu kali saat seluruh data referensi
  /// dari notifier sudah tersedia. Dipanggil dari `build()`.
  void _petakanAwal() {
    if (_isEditMode) {
      _petakanModeEdit();
    } else {
      _petakanModeBaru();
    }
  }

  void _petakanModeEdit() {
    final pa = widget.pelangganAktif!;
    Future.microtask(() {
      if (!mounted) return;
      setState(() {
        Future.microtask(() async {
          if (!mounted) return;
          final pelangganState = await ref.read(pelangganProvider.future);
          _selectedPelanggan = pelangganState.getById(pa.idPelanggan);
          final paketState = await ref.read(paketProvider.future);
          _selectedPaket = paketState.getById(pa.idPaket);
          if (_selectedPaket == null) {
            _peringatanPaket =
                'Peringatan: Paket asli (ID: ${pa.idPaket}) tidak ditemukan. Harap pilih paket baru.';
          }
          if (_daftarDompet.isNotEmpty && _selectedDompet == null) {
            _selectedDompet = _daftarDompet.first;
          }
          if (_kategoriPemasukanList.isNotEmpty && _selectedKategori == null) {
            _selectedKategori =
                _kategoriPemasukanList.firstWhereOrNull(
                  (k) => k.nama.toLowerCase() == 'aktivasi paket',
                ) ??
                _kategoriPemasukanList.first;
          }
        });
      });
    });

    final tglMulai = _modePerpanjang ? pa.tanggalBerakhir : pa.tanggalMulai;
    _selectedDate = tglMulai;
    _selectedTime = TimeOfDay.fromDateTime(tglMulai);
    _statusPembayaran = _modePerpanjang
        ? StatusPembayaranEnum.belumLunas
        : pa.status;
  }

  void _petakanModeBaru() {
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    if (_daftarDompet.isNotEmpty) {
      _selectedDompet = _daftarDompet.first;
    }
    if (_kategoriPemasukanList.isNotEmpty) {
      _selectedKategori =
          _kategoriPemasukanList.firstWhereOrNull(
            (k) => k.nama.toLowerCase() == 'aktivasi paket',
          ) ??
          _kategoriPemasukanList.first;
    }
  }

  /// Menampilkan peringatan yang ditunda dari `build()` (mis. paket edit
  /// mode tidak ditemukan) lewat post-frame callback.
  void _tampilkanPeringatanTertunda() {
    final pesan = _peringatanPaket;
    if (pesan == null) return;
    _peringatanPaket = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppToast.warning(context, pesan);
    });
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
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  /// Menyimpan data pelanggan aktif beserta transaksinya.
  ///
  /// Seluruh umpan balik kepada pengguna (toast), pengiriman WhatsApp,
  /// dan navigasi kembali ditangani di dalam fungsi ini.
  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      AppToast.gagal(context, 'Data belum lengkap');
      return;
    }

    final selectedPaket = _selectedPaket;
    if (_selectedPelanggan == null ||
        selectedPaket == null ||
        _selectedDate == null ||
        _selectedTime == null ||
        _selectedDompet == null ||
        _selectedKategori == null) {
      AppToast.gagal(context, 'Harap lengkapi semua data');
      return;
    }

    if (_gunakanPoin) {
      if (selectedPaket.poinPenukaran <= 0) {
        AppToast.gagal(context, 'Paket ini tidak mendukung penukaran poin');
        return;
      }
      if (_saldoPoinPelanggan < selectedPaket.poinPenukaran) {
        AppToast.gagal(context, 'Poin tidak cukup');
        return;
      }
    }

    try {
      final tanggalMulai = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      final tanggalBerakhir = hitungTanggalBerakhir(
        tanggalMulai,
        selectedPaket,
      );

      final transaksiId =
          (_isEditMode && !_modePerpanjang) &&
              widget.pelangganAktif?.idTransaksi != null
          ? widget.pelangganAktif!.idTransaksi!
          : const Uuid().v4();

      final pelangganAktifData = PelangganAktifModel(
        id: (_isEditMode && !_modePerpanjang) ? widget.pelangganAktif!.id : '',
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

      PelangganAktifModel pelangganAktifHasil;
      if (_modePerpanjang) {
        pelangganAktifHasil = await ref
            .read(penggunaAktifProvider.notifier)
            .tambah(pelangganAktifData);
        await ref.read(transaksiProvider.notifier).tambah(transaksiData);
      } else if (_isEditMode) {
        pelangganAktifHasil = await ref
            .read(penggunaAktifProvider.notifier)
            .ubah(pelangganAktifData);
        await ref.read(transaksiProvider.notifier).ubah(transaksiData);
      } else {
        pelangganAktifHasil = await ref
            .read(penggunaAktifProvider.notifier)
            .tambah(pelangganAktifData);
        await ref.read(transaksiProvider.notifier).tambah(transaksiData);
      }

      if (!mounted) return;

      AppToast.sukses(context, 'Berhasil disimpan');
      try {
        await PesanInfoPaket.kirimRincianPaket(pelangganAktifHasil);
      } catch (e) {
        L.w('Gagal mengirim pesan WhatsApp: $e');
        if (mounted) {
          AppToast.warning(
            context,
            'Gagal mengirim pesan WhatsApp. Aplikasi tidak terpasang?',
          );
        }
      }
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        Nav.pop(context);
      }
    } catch (e, s) {
      L.e('Gagal menyimpan data pelanggan aktif. Error: $e $s');
      if (!mounted) return;
      AppToast.gagal(context, 'Gagal menyimpan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pelangganAsync = ref.watch(pelangganProvider);
    final paketAsync = ref.watch(paketProvider);
    final dompetAsync = ref.watch(dompetProvider);
    final kategoriAsync = ref.watch(kategoriProvider);

    final bool isLoading =
        pelangganAsync.isLoading ||
        paketAsync.isLoading ||
        dompetAsync.isLoading ||
        kategoriAsync.isLoading;

    if (pelangganAsync.hasError) {
      return _buildMuatGagal(
        'Gagal memuat data pelanggan: ${pelangganAsync.error}',
        () => ref.refresh(pelangganProvider),
      );
    }
    if (paketAsync.hasError) {
      return _buildMuatGagal(
        'Gagal memuat data paket: ${paketAsync.error}',
        () => ref.refresh(paketProvider),
      );
    }
    if (dompetAsync.hasError) {
      return _buildMuatGagal(
        'Gagal memuat data dompet: ${dompetAsync.error}',
        () => ref.refresh(dompetProvider),
      );
    }
    if (kategoriAsync.hasError) {
      return _buildMuatGagal(
        'Gagal memuat data kategori: ${kategoriAsync.error}',
        () => ref.refresh(kategoriProvider),
      );
    }

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _modePerpanjang
                ? 'Perpanjang Masa Aktif'
                : (_isEditMode
                      ? 'Edit Pelanggan Aktif'
                      : 'Form Pelanggan Aktif'),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    _pelangganList = List<PelangganModel>.from(
      pelangganAsync.requireValue.listPelanggan,
    )..sort((a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()));
    _paketList = paketAsync.requireValue.listPaket;
    _daftarDompet = dompetAsync.requireValue.listDompet
        .where((d) => !d.isDeleted)
        .toList();
    final semuaKategori = kategoriAsync.requireValue.listKategori;
    _kategoriPemasukanList = semuaKategori
        .where((k) => k.tipe == TipeKategori.pemasukan && !k.isDeleted)
        .toList();
    _kategoriPengeluaranList = semuaKategori
        .where((k) => k.tipe == TipeKategori.pengeluaran && !k.isDeleted)
        .toList();

    if (!_awalDipetakan) {
      _petakanAwal();
      _awalDipetakan = true;
      _tampilkanPeringatanTertunda();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _modePerpanjang == true
              ? 'Perpanjang Masa Aktif'
              : (_isEditMode ? 'Edit Pelanggan Aktif' : 'Form Pelanggan Aktif'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              spacing: 16,
              children: [
                _buildPoinSwitch(),
                _buildPelangganDropdown(),
                _buildPaketDropdown(),
                _buildDompetDropdown(),
                _buildKategoriDropdown(),
                _buildDateTimePicker(),
                _buildStatusPembayaranButtons(),
                _buildInfoTanggal(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildSaveButton(),
    );
  }

  Widget _buildMuatGagal(String pesan, VoidCallback onCobaLagi) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _modePerpanjang == true
              ? 'Perpanjang Masa Aktif'
              : (_isEditMode ? 'Edit Pelanggan Aktif' : 'Form Pelanggan Aktif'),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              const Icon(Icons.error_outline, size: 48),
              Text(pesan, textAlign: TextAlign.center),
              FilledButton(
                onPressed: onCobaLagi,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPoinSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                'Gunakan Poin',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (_gunakanPoin)
                Text(
                  'Poin dipakai: ${hitungPoinEfektif()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              Text(
                'Sisa poin: ${hitungSisaPoin()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Switch(
            value: _gunakanPoin,
            onChanged: _saldoPoinPelanggan <= 0
                ? null
                : (bool value) {
                    setState(() {
                      _gunakanPoin = value;
                      if (!_kategoriList.contains(_selectedKategori)) {
                        _selectedKategori = _kategoriList.isNotEmpty
                            ? _kategoriList.first
                            : null;
                      }
                    });
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildPelangganDropdown() {
    final bool nonaktifkan = _modePerpanjang;
    return DropdownButtonFormField<PelangganModel>(
      key: const Key('pelanggan_dropdown'),
      decoration: const InputDecoration(
        labelText: 'Pilih Pelanggan',
        border: OutlineInputBorder(),
      ),
      initialValue: _selectedPelanggan,
      enabled: !nonaktifkan,
      items: _pelangganList
          .map((p) => DropdownMenuItem(value: p, child: Text(p.nama)))
          .toList(),
      onChanged: nonaktifkan
          ? null
          : (PelangganModel? newValue) async {
              if (newValue == null) return;
              final saldoPoin = await ref
                  .read(pelangganProvider.notifier)
                  .hitungTotalPoin(newValue.id);
              if (mounted) {
                setState(() {
                  _selectedPelanggan = newValue;
                  _saldoPoinPelanggan = saldoPoin;
                  if (saldoPoin <= 0) {
                    _gunakanPoin = false;
                  }
                });
              }
            },
      validator: (v) => v == null ? 'Pelanggan tidak boleh kosong' : null,
    );
  }

  Widget _buildPaketDropdown() {
    return DropdownButtonFormField<PaketModel>(
      key: const Key('paket_dropdown'),
      decoration: const InputDecoration(
        labelText: 'Pilih Paket',
        border: OutlineInputBorder(),
      ),
      initialValue: _selectedPaket,
      items: _paketList
          .map((p) => DropdownMenuItem(value: p, child: Text(p.nama)))
          .toList(),
      onChanged: (PaketModel? newValue) =>
          setState(() => _selectedPaket = newValue),
      validator: (v) => v == null ? 'Paket tidak boleh kosong' : null,
    );
  }

  Widget _buildDompetDropdown() {
    return DropdownButtonFormField<DompetModel>(
      key: const Key('dompet_dropdown'),
      decoration: const InputDecoration(
        labelText: 'Pilih Dompet',
        border: OutlineInputBorder(),
      ),
      initialValue: _selectedDompet,
      items: _daftarDompet
          .map((d) => DropdownMenuItem(value: d, child: Text(d.namaDompet)))
          .toList(),
      onChanged: (DompetModel? newValue) =>
          setState(() => _selectedDompet = newValue),
      validator: (v) => v == null ? 'Dompet tidak boleh kosong' : null,
    );
  }

  Widget _buildKategoriDropdown() {
    return DropdownButtonFormField<KategoriModel>(
      key: const Key('kategori_dropdown'),
      decoration: const InputDecoration(
        labelText: 'Pilih Kategori Transaksi',
        border: OutlineInputBorder(),
      ),
      initialValue: _selectedKategori,
      items: _kategoriList
          .map((k) => DropdownMenuItem(value: k, child: Text(k.nama)))
          .toList(),
      onChanged: (KategoriModel? newValue) =>
          setState(() => _selectedKategori = newValue),
      validator: (v) => v == null ? 'Kategori tidak boleh kosong' : null,
    );
  }

  Widget _buildDateTimePicker() {
    return Column(
      spacing: 8,
      children: [
        Text(
          'Pilih Tanggal & Waktu Aktif:',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _modePerpanjang ? null : () => _selectDate(context),
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _selectedDate == null
                    ? 'Pilih Tanggal'
                    : FormatTanggal.formatTanggalBasic(_selectedDate!),
              ),
            ),
            TextButton.icon(
              onPressed: _modePerpanjang ? null : () => _selectTime(context),
              icon: const Icon(Icons.access_time),
              label: Text(
                _selectedTime == null
                    ? 'Pilih Jam'
                    : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusPembayaranButtons() {
    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _statusPembayaran == StatusPembayaranEnum.lunas
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              foregroundColor: _statusPembayaran == StatusPembayaranEnum.lunas
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onPressed: () =>
                setState(() => _statusPembayaran = StatusPembayaranEnum.lunas),
            child: Text(StatusPembayaranEnum.lunas.label),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _statusPembayaran == StatusPembayaranEnum.belumLunas
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              foregroundColor:
                  _statusPembayaran == StatusPembayaranEnum.belumLunas
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onPressed: () => setState(
              () => _statusPembayaran = StatusPembayaranEnum.belumLunas,
            ),
            child: Text(StatusPembayaranEnum.belumLunas.label),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTanggal() {
    return Column(
      spacing: 8,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tanggal Mulai:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tanggal Berakhir:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text((() {
              if (_selectedDate != null && _selectedPaket != null) {
                DateTime startDate = DateTime(
                  _selectedDate!.year,
                  _selectedDate!.month,
                  _selectedDate!.day,
                  _selectedTime?.hour ?? 0,
                  _selectedTime?.minute ?? 0,
                );
                final DateTime endDate = hitungTanggalBerakhir(
                  startDate,
                  _selectedPaket!,
                );
                return FormatTanggal.formatTanggalDanJam(endDate);
              } else {
                return 'Pilih paket & tanggal mulai';
              }
            }())),
          ],
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () async {
          await _saveForm();
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text('Simpan'),
      ),
    );
  }
}
