// path: lib/fitur/kategori/screens/form_kategori.dart
// Halaman ini menyediakan formulir untuk menambah atau mengedit kategori dan sub-kategori.

import 'package:admin_wifi/data/operasi/kategori_operasi.dart';
import 'package:admin_wifi/data/sync/unggah_data.dart';
import 'package:admin_wifi/fitur/kategori/model/kategori_model.dart';
import 'package:admin_wifi/fitur/kategori/model/sub_kategori_model.dart';
import 'package:admin_wifi/services/cek_koneksi_internet.dart';
import 'package:flutter/material.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:share_global_saya/src/utils/navigator_helper.dart';
import 'package:uuid/uuid.dart';

class FormKategoriPage extends StatefulWidget {
  final KategoriModel? kategori;
  final SubKategoriModel? subKategori;
  final String? idKategoriInduk;

  const FormKategoriPage({
    super.key,
    this.kategori,
    this.subKategori,
    this.idKategoriInduk,
  });

  @override
  State<FormKategoriPage> createState() => _FormKategoriPageState();
}

class _FormKategoriPageState extends State<FormKategoriPage> {
  final _formKey = GlobalKey<FormState>();
  final KategoriOperasi _kategoriOperasi = KategoriOperasi();
  final LayananUnggahData _layananUnggahData = LayananUnggahData();

  late TipeKategori _tipe;
  late TextEditingController _namaController;
  final _namaFocusNode = FocusNode();

  final List<TextEditingController> _subKategoriControllers = [];

  bool get _isEditMode => widget.kategori != null || widget.subKategori != null;
  bool get _isSubKategoriMode =>
      widget.subKategori != null || widget.idKategoriInduk != null;

  final _cekKoneksi = KoneksiInternetService();

  @override
  void initState() {
    super.initState();
    final isEditMode = widget.kategori != null || widget.subKategori != null;
    final isSubKategoriMode =
        widget.subKategori != null || widget.idKategoriInduk != null;

    L.i(
      'Membuat state untuk FormKategoriPage. '
      'Mode: ${isEditMode ? "EDIT" : "TAMBAH BARU"}, '
      'Jenis: ${isSubKategoriMode ? "SUB-KATEGORI" : "KATEGORI UTAMA"}, '
      '${widget.kategori != null ? "Kategori: ${widget.kategori!.nama} (ID: ${widget.kategori!.id})" : ""}'
      '${widget.subKategori != null ? "Sub-Kategori: ${widget.subKategori!.nama} (ID: ${widget.subKategori!.id})" : ""}'
      '${widget.idKategoriInduk != null ? "ID Kategori Induk: ${widget.idKategoriInduk}" : ""}',
    );

    L.i('========================================');
    L.i('LIFECYCLE: initState() - Halaman FormKategoriPage');
    L.i('========================================');

    L.i('Membuat TextEditingController untuk input nama.');
    _namaController = TextEditingController();
    L.i('TextEditingController berhasil dibuat.');

    L.i('Membuat FocusNode untuk input nama.');
    L.i('FocusNode berhasil dibuat: ${_namaFocusNode.hashCode}');

    if (widget.kategori != null) {
      L.i('MODE EDIT KATEGORI UTAMA terdeteksi.');
      L.i('Data kategori yang akan diedit:');
      L.i('  - ID: ${widget.kategori!.id}');
      L.i('  - Nama: ${widget.kategori!.nama}');
      L.i('  - Tipe: ${widget.kategori!.tipe}');
      L.i('  - Jumlah Sub-Kategori: ${widget.kategori!.subKategori.length}');
      L.i('  - Diperbarui: ${widget.kategori!.diperbarui}');
      L.i('  - isDeleted: ${widget.kategori!.isDeleted}');
      L.i('  - Diarsipkan: ${widget.kategori!.diarsipkan ?? "NULL"}');

      L.i(
        'Mengisi TextEditingController dengan nama kategori: "${widget.kategori!.nama}"',
      );
      _namaController.text = widget.kategori!.nama;
      _tipe = widget.kategori!.tipe;
      L.i('Tipe kategori diatur ke: ${widget.kategori!.tipe}');
    } else if (widget.subKategori != null) {
      L.i('MODE EDIT SUB-KATEGORI terdeteksi.');
      L.i('Data sub-kategori yang akan diedit:');
      L.i('  - ID: ${widget.subKategori!.id}');
      L.i('  - Nama: ${widget.subKategori!.nama}');
      L.i('  - ID Kategori Induk: ${widget.subKategori!.idKategori}');
      L.i('  - Diperbarui: ${widget.subKategori!.diperbarui}');

      L.i(
        'Mengisi TextEditingController dengan nama sub-kategori: "${widget.subKategori!.nama}"',
      );
      _namaController.text = widget.subKategori!.nama;
    } else {
      L.i('MODE TAMBAH BARU terdeteksi.');
      L.i('Form akan membuat kategori baru dengan:');
      L.i('  - ID: Akan digenerate otomatis menggunakan UUID v4');
      L.i('  - Tipe Default: pemasukan');
      L.i('  - Nama: Dari input pengguna');
      L.i('  - Sub-Kategori: Opsional, bisa ditambahkan multiple');
      L.i('  - Diperbarui: DateTime.now()');

      L.i('Mengatur tipe default ke pemasukan.');
      _tipe = TipeKategori.pemasukan;
      L.i('Tipe kategori diatur ke: $_tipe');

      L.i('Menambahkan field input sub-kategori pertama secara default.');
      _tambahInputSubKategori();
    }

    L.i(
      'Inisialisasi FormKategoriPage selesai. Siap menerima input dari pengguna.',
    );
  }

  @override
  void dispose() {
    L.i('========================================');
    L.i('LIFECYCLE: dispose() - Halaman FormKategoriPage');
    L.i('Membersihkan resource:');
    L.i('  - Mendispose TextEditingController utama (_namaController)');
    L.i('  - Mendispose FocusNode (_namaFocusNode)');
    L.i(
      '  - Mendispose ${_subKategoriControllers.length} TextEditingController sub-kategori',
    );
    L.i('========================================');

    _namaController.dispose();
    _namaFocusNode.dispose();

    for (int i = 0; i < _subKategoriControllers.length; i++) {
      L.i('  Mendispose sub-kategori controller ke-${i + 1}');
      _subKategoriControllers[i].dispose();
    }

    L.i('Semua resource berhasil dibersihkan.');
    super.dispose();
  }

  void _tambahInputSubKategori() {
    L.i('========================================');
    L.i('AKSI: Menambahkan field input sub-kategori baru');
    L.i(
      'Jumlah field sub-kategori sebelum ditambah: ${_subKategoriControllers.length}',
    );
    L.i('========================================');

    setState(() {
      _subKategoriControllers.add(TextEditingController());
    });

    L.i('Field sub-kategori baru berhasil ditambahkan.');
    L.i(
      'Jumlah field sub-kategori sekarang: ${_subKategoriControllers.length}',
    );
    L.i('Index field baru: ${_subKategoriControllers.length - 1}');
  }

  void _hapusInputSubKategori(int index) {
    L.i('========================================');
    L.i('AKSI: Menghapus field input sub-kategori');
    L.i('Index yang akan dihapus: $index');
    L.i(
      'Jumlah field sub-kategori sebelum dihapus: ${_subKategoriControllers.length}',
    );

    if (index >= 0 && index < _subKategoriControllers.length) {
      L.i(
        'Nilai field sebelum dihapus: "${_subKategoriControllers[index].text}"',
      );
    } else {
      L.w(
        'Index $index tidak valid. Jumlah field: ${_subKategoriControllers.length}',
      );
    }
    L.i('========================================');

    setState(() {
      L.i('Mendispose controller pada index $index.');
      _subKategoriControllers[index].dispose();
      L.i('Menghapus controller dari list.');
      _subKategoriControllers.removeAt(index);
    });

    L.i('Field sub-kategori berhasil dihapus.');
    L.i(
      'Jumlah field sub-kategori sekarang: ${_subKategoriControllers.length}',
    );
  }

  void _simpanForm() async {
    L.i('========================================');
    L.i('AKSI: Tombol Simpan Ditekan');
    L.i('Mode: ${_isEditMode ? "EDIT" : "TAMBAH BARU"}');
    L.i('Jenis: ${_isSubKategoriMode ? "SUB-KATEGORI" : "KATEGORI UTAMA"}');
    L.i('Nama yang akan disimpan: "${_namaController.text}"');
    L.i('Tipe kategori: $_tipe');
    L.i('========================================');

    L.i('Memvalidasi form...');
    if (_formKey.currentState!.validate()) {
      L.i('Validasi form BERHASIL. Semua input valid.');

      try {
        if (_isEditMode && widget.subKategori != null) {
          L.i('========================================');
          L.i('PROSES UPDATE SUB-KATEGORI (MODE EDIT SUB-KATEGORI)');
          L.i('========================================');

          L.i('Data sub-kategori sebelum update:');
          L.i('  - ID: ${widget.subKategori!.id}');
          L.i('  - Nama Lama: ${widget.subKategori!.nama}');
          L.i('  - Nama Baru: ${_namaController.text}');
          L.i('  - ID Kategori Induk: ${widget.idKategoriInduk}');

          if (widget.idKategoriInduk == null) {
            L.e(
              'ID kategori induk tidak ditemukan saat mengedit sub-kategori. '
              'Ini adalah kesalahan logika karena sub-kategori harus selalu memiliki kategori induk.',
            );
            throw Exception(
              'ID kategori induk tidak ditemukan saat mengedit sub-kategori.',
            );
          }

          L.i(
            'Mengambil data kategori induk dengan ID: ${widget.idKategoriInduk}',
          );
          final kategoriInduk = await _kategoriOperasi.getKategoriById(
            widget.idKategoriInduk!,
          );

          L.i(
            'Kategori induk ditemukan: ${kategoriInduk.nama} (memiliki ${kategoriInduk.subKategori.length} sub-kategori).',
          );
          L.i(
            'Mencari index sub-kategori dengan ID: ${widget.subKategori!.id} dalam daftar sub-kategori.',
          );

          final subKategoriIndex = kategoriInduk.subKategori.indexWhere(
            (s) => s.id == widget.subKategori!.id,
          );

          if (subKategoriIndex != -1) {
            L.i('Sub-kategori ditemukan pada index: $subKategoriIndex');
            L.i(
              'Nama sub-kategori sebelum update: "${kategoriInduk.subKategori[subKategoriIndex].nama}"',
            );

            L.i(
              'Membuat salinan sub-kategori dengan nama baru dan timestamp diperbarui.',
            );
            final subKategoriDiperbarui = kategoriInduk
                .subKategori[subKategoriIndex]
                .copyWith(
                  nama: _namaController.text,
                  diperbarui: DateTime.now(),
                );

            L.i(
              'Mengganti sub-kategori pada index $subKategoriIndex dengan data baru.',
            );
            kategoriInduk.subKategori[subKategoriIndex] = subKategoriDiperbarui;

            L.i(
              'Memanggil _kategoriOperasi.update() untuk menyimpan perubahan kategori induk.',
            );
            await _kategoriOperasi.update(kategoriInduk);

            L.i('Update sub-kategori BERHASIL.');
            L.i(
              'Nama sub-kategori berubah dari "${widget.subKategori!.nama}" menjadi "${_namaController.text}"',
            );
          } else {
            L.e(
              'Sub-kategori dengan ID ${widget.subKategori!.id} tidak ditemukan dalam daftar sub-kategori kategori induk.',
            );
            throw Exception('Sub-kategori tidak ditemukan untuk diedit.');
          }
        } else if (_isEditMode && widget.kategori != null) {
          L.i('========================================');
          L.i('PROSES UPDATE KATEGORI UTAMA (MODE EDIT KATEGORI)');
          L.i('========================================');

          L.i('Data kategori sebelum update:');
          L.i('  - ID: ${widget.kategori!.id}');
          L.i('  - Nama Lama: ${widget.kategori!.nama}');
          L.i('  - Nama Baru: ${_namaController.text}');
          L.i('  - Tipe Lama: ${widget.kategori!.tipe}');
          L.i('  - Tipe Baru: $_tipe');

          L.i(
            'Membuat salinan kategori dengan data baru dan timestamp diperbarui.',
          );
          final kategoriDiperbarui = widget.kategori!.copyWith(
            nama: _namaController.text,
            tipe: _tipe,
            diperbarui: DateTime.now(),
          );

          L.i('Objek KategoriModel baru:');
          L.i('  - ID: ${kategoriDiperbarui.id}');
          L.i('  - Nama: ${kategoriDiperbarui.nama}');
          L.i('  - Tipe: ${kategoriDiperbarui.tipe}');
          L.i('  - Diperbarui: ${kategoriDiperbarui.diperbarui}');

          L.i('Memanggil _kategoriOperasi.update() untuk menyimpan perubahan.');
          await _kategoriOperasi.update(kategoriDiperbarui);

          L.i('Update kategori utama BERHASIL.');
          L.i(
            'Nama kategori berubah dari "${widget.kategori!.nama}" menjadi "${_namaController.text}"',
          );
          L.i(
            'Tipe kategori berubah dari "${widget.kategori!.tipe}" menjadi "$_tipe"',
          );
        } else {
          L.i('========================================');
          L.i('PROSES TAMBAH KATEGORI BARU (MODE TAMBAH)');
          L.i('========================================');

          L.i('Menggenerate UUID v4 untuk ID kategori baru.');
          final String kategoriId = const Uuid().v4();
          L.i('UUID berhasil digenerate: $kategoriId');

          L.i(
            'Memproses ${_subKategoriControllers.length} field input sub-kategori.',
          );

          int subKategoriKosong = 0;
          int subKategoriTerisi = 0;

          final List<SubKategoriModel> subKategoriList = _subKategoriControllers
              .where((controller) {
                final isEmpty = controller.text.isEmpty;
                if (isEmpty) {
                  subKategoriKosong++;
                  L.i(
                    '  Sub-kategori dengan nilai "${controller.text}" akan DIABAIKAN karena kosong.',
                  );
                } else {
                  subKategoriTerisi++;
                  L.i(
                    '  Sub-kategori dengan nilai "${controller.text}" akan DISIMPAN.',
                  );
                }
                return !isEmpty;
              })
              .map(
                (controller) => SubKategoriModel(
                  id: const Uuid().v4(),
                  nama: controller.text,
                  idKategori: kategoriId,
                  diperbarui: DateTime.now(),
                ),
              )
              .toList();

          L.i(
            'Ringkasan sub-kategori: $subKategoriTerisi akan disimpan, $subKategoriKosong diabaikan.',
          );

          L.i('Membuat objek KategoriModel baru.');
          final kategoriBaru = KategoriModel(
            id: kategoriId,
            nama: _namaController.text,
            tipe: _tipe,
            subKategori: subKategoriList,
            diperbarui: DateTime.now(),
          );

          L.i('Objek KategoriModel berhasil dibuat:');
          L.i('  - ID: ${kategoriBaru.id}');
          L.i('  - Nama: ${kategoriBaru.nama}');
          L.i('  - Tipe: ${kategoriBaru.tipe}');
          L.i('  - Jumlah Sub-Kategori: ${kategoriBaru.subKategori.length}');
          L.i('  - Diperbarui: ${kategoriBaru.diperbarui}');

          L.i(
            'Memanggil _kategoriOperasi.createKategori() untuk menyimpan kategori baru.',
          );
          await _kategoriOperasi.createKategori(kategoriBaru);

          L.i('Kategori baru BERHASIL disimpan ke database lokal.');
        }

        L.i('========================================');
        L.i('MEMERIKSA KONEKSI INTERNET UNTUK SINKRONISASI');
        L.i('========================================');

        L.i('Memeriksa koneksi internet...');
        final isOnline = await _cekKoneksi.cekKoneksi();
        L.i('Status koneksi: ${isOnline ? "ONLINE" : "OFFLINE"}');

        if (isOnline) {
          L.i(
            'Koneksi internet tersedia. Melakukan sinkronisasi data kategori ke Firestore.',
          );
          await _layananUnggahData.unggahDataKategori();
          L.i('Sinkronisasi data kategori ke cloud BERHASIL.');
        } else {
          L.i('Tidak ada koneksi internet. Data hanya disimpan secara lokal.');
          L.i('Sinkronisasi akan dilakukan saat koneksi tersedia nanti.');
        }

        L.i('========================================');
        L.i('PENYIMPANAN DATA BERHASIL');
        L.i('========================================');

        if (!mounted) {
          L.w(
            'Widget sudah tidak mounted setelah penyimpanan berhasil. '
            'Tidak dapat menampilkan SnackBar atau melakukan Nav.pop.',
          );
          return;
        }

        L.i('Widget masih mounted. Menampilkan SnackBar sukses.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_isSubKategoriMode ? 'Sub-Kategori' : 'Kategori'} berhasil disimpan!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        L.i('SnackBar sukses telah ditampilkan.');

        L.i(
          'Melakukan Nav.pop(context, true) untuk kembali ke halaman sebelumnya.',
        );
        L.i(
          'Nilai result true dikirim untuk memberitahu halaman sebelumnya bahwa ada perubahan data.',
        );
        Nav.pop(context, true);
        L.i('Nav.pop berhasil dijalankan.');
      } catch (e, s) {
        L.e(
          'Gagal menyimpan ${_isSubKategoriMode ? 'sub-kategori' : 'kategori'}. '
          'Proses ${_isEditMode ? 'update' : 'create'} mengalami kegagalan. '
          'Kemungkinan penyebab: koneksi database gagal, constraint violation, '
          'data tidak valid, atau terjadi error saat operasi database. '
          'Error: $e $s',
        );

        if (!mounted) {
          L.w(
            'Widget sudah tidak mounted setelah error. Tidak dapat menampilkan SnackBar error.',
          );
          return;
        }

        L.i('Widget masih mounted. Menampilkan SnackBar error ke pengguna.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
        L.i('SnackBar error telah ditampilkan.');
      }
    } else {
      L.w('Validasi form GAGAL. Terdapat input yang tidak valid.');
      L.w(
        'Kemungkinan penyebab: Nama kategori/sub-kategori kosong atau tidak memenuhi kriteria validasi.',
      );
      L.i('Form tidak akan disimpan sampai semua input valid.');
    }
  }

  @override
  Widget build(BuildContext context) {
    String judul = 'Form Kategori';
    if (_isEditMode && widget.kategori != null) judul = 'Edit Kategori';
    if (_isEditMode && widget.subKategori != null) judul = 'Edit Sub-Kategori';
    if (!_isEditMode && widget.idKategoriInduk != null)
      judul = 'Tambah Sub-Kategori';
    if (!_isEditMode && widget.kategori == null && widget.subKategori == null)
      judul = 'Tambah Kategori Baru';

    L.i('========================================');
    L.i('LIFECYCLE: build() - Membangun UI FormKategoriPage');
    L.i('Judul halaman: "$judul"');
    L.i('Mode: ${_isEditMode ? "EDIT" : "TAMBAH BARU"}');
    L.i('Jenis: ${_isSubKategoriMode ? "SUB-KATEGORI" : "KATEGORI UTAMA"}');
    L.i('Nama di controller: "${_namaController.text}"');
    L.i('Tipe terpilih: $_tipe');
    L.i('Jumlah field sub-kategori: ${_subKategoriControllers.length}');
    L.i('========================================');

    return Scaffold(
      appBar: AppBar(
        title: Text(judul),
        leading: BackButton(
          onPressed: () {
            L.i(
              'NAVIGASI: Tombol Kembali ditekan. '
              'Kembali ke halaman sebelumnya dengan result false (tidak ada perubahan).',
            );
            Nav.pop(context, false);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _namaController,
                  focusNode: _namaFocusNode,
                  decoration: InputDecoration(
                    labelText: _isSubKategoriMode
                        ? 'Nama Sub-Kategori'
                        : 'Nama Kategori',
                    border: const OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    L.i(
                      'INPUT: Field nama disubmit melalui keyboard (TextInputAction.done).',
                    );
                    L.i('Nilai yang disubmit: "${_namaController.text}"');
                    L.i('Menghilangkan fokus dari input.');
                    FocusScope.of(context).unfocus();
                  },
                  onChanged: (value) {
                    L.i(
                      'INPUT: Nama ${_isSubKategoriMode ? "sub-kategori" : "kategori"} berubah menjadi: "$value" (panjang: ${value.length} karakter)',
                    );
                  },
                  validator: (value) {
                    L.i(
                      'VALIDASI: Memvalidasi input nama. Nilai: "${value ?? "NULL"}"',
                    );
                    if (value == null || value.isEmpty) {
                      L.w('VALIDASI GAGAL: Nama kosong.');
                      return 'Nama tidak boleh kosong';
                    }
                    L.i('VALIDASI BERHASIL: Nama valid.');
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (!_isEditMode && !_isSubKategoriMode) ...[
                  DropdownButtonFormField<TipeKategori>(
                    initialValue: _tipe,
                    decoration: const InputDecoration(
                      labelText: 'Tipe',
                      border: OutlineInputBorder(),
                    ),
                    items: TipeKategori.values
                        .where((tipe) => tipe != TipeKategori.transfer)
                        .map((TipeKategori tipe) {
                          return DropdownMenuItem<TipeKategori>(
                            value: tipe,
                            child: Text(
                              tipe.name.substring(0, 1).toUpperCase() +
                                  tipe.name.substring(1),
                            ),
                          );
                        })
                        .toList(),
                    onChanged: (TipeKategori? newValue) {
                      if (newValue != null) {
                        L.i('DROPDOWN: Tipe kategori diubah.');
                        L.i('  - Tipe Lama: $_tipe');
                        L.i('  - Tipe Baru: $newValue');
                        setState(() {
                          _tipe = newValue;
                        });
                        L.i('State _tipe berhasil diperbarui ke: $_tipe');
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Tambah Sub-Kategori (Opsional)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _subKategoriControllers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _subKategoriControllers[index],
                                decoration: InputDecoration(
                                  labelText: 'Nama Sub-Kategori ${index + 1}',
                                  border: const OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  L.i(
                                    'INPUT: Sub-kategori ke-${index + 1} berubah menjadi: "$value" (panjang: ${value.length} karakter)',
                                  );
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                L.i(
                                  'AKSI: Tombol hapus sub-kategori ke-${index + 1} ditekan.',
                                );
                                _hapusInputSubKategori(index);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        L.i(
                          'AKSI: Tombol "Tambah Input" sub-kategori ditekan.',
                        );
                        _tambahInputSubKategori();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Input'),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    L.i('AKSI: Tombol Simpan ditekan oleh pengguna.');
                    _simpanForm();
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
