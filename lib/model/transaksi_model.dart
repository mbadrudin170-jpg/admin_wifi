// path: lib/model/transaksi_model.dart
// diubah: Standarisasi nama metode toMap, toMapForFirebase, dan copyWith.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

enum TipeTransaksi { pemasukan, pengeluaran, transfer }

class TransaksiModel {
  final String id;
  final DateTime tanggal;
  final String keterangan;
  final double jumlah;
  final TipeTransaksi tipe;
  final String idDompet;
  final String namaDompet;
  final String? idDompetTujuan;
  final String? namaDompetTujuan;
  final String idKategori;
  final String namaKategori;
  final String? idPelanggan;
  final String? namaPelanggan;
  final String? idPaket;
  final String? namaPaket;
  final String? idSubKategori;
  final String? namaSubKategori;
  final DateTime? diperbarui;
  final DateTime? diarsipkan;
  final bool isDeleted;

  TransaksiModel({
    String? id,
    required this.tanggal,
    required this.keterangan,
    required this.jumlah,
    required this.tipe,
    required this.idDompet,
    required this.namaDompet,
    this.idDompetTujuan,
    this.namaDompetTujuan,
    required this.idKategori,
    required this.namaKategori,
    this.idPelanggan,
    this.namaPelanggan,
    this.idPaket,
    this.namaPaket,
    this.idSubKategori,
    this.namaSubKategori,
    this.diperbarui,
    this.diarsipkan,
    this.isDeleted = false,
  }) : id = id ?? const Uuid().v4();

  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  factory TransaksiModel.fromMap(Map<String, dynamic> map) {
    return TransaksiModel(
      id: map['id'] as String? ?? '',
      tanggal: _parseDateTime(map['tanggal']) ?? DateTime.now(),
      keterangan: map['keterangan'] ?? '',
      jumlah: (map['jumlah'] as num? ?? 0).toDouble(),
      tipe: TipeTransaksi.values.firstWhere(
        (e) => e.name == map['tipe'],
        orElse: () => TipeTransaksi.pengeluaran,
      ),
      idDompet: map['id_dompet'] ?? '',
      namaDompet: map['nama_dompet'] ?? '',
      idDompetTujuan: map['id_dompet_tujuan'],
      namaDompetTujuan: map['nama_dompet_tujuan'],
      idKategori: map['id_kategori'] ?? '',
      namaKategori: map['nama_kategori'] ?? '',
      idPelanggan: map['id_pelanggan'],
      namaPelanggan: map['nama_pelanggan'],
      idPaket: map['id_paket'],
      namaPaket: map['nama_paket'],
      idSubKategori: map['id_sub_kategori'],
      namaSubKategori: map['nama_sub_kategori'],
      diperbarui: _parseDateTime(map['diperbarui']),
      diarsipkan: _parseDateTime(map['diarsipkan']),
      isDeleted: map['isDeleted'] == 1 || map['isDeleted'] == true,
    );
  }

  // diubah: Nama metode menjadi toMapForSqlite
  Map<String, dynamic> toMapForSqlite() {
    return {
      'id': id,
      'tanggal': tanggal.toIso8601String(),
      'keterangan': keterangan,
      'jumlah': jumlah,
      'tipe': tipe.name,
      'id_dompet': idDompet,
      'nama_dompet': namaDompet,
      'id_dompet_tujuan': idDompetTujuan,
      'nama_dompet_tujuan': namaDompetTujuan,
      'id_kategori': idKategori,
      'nama_kategori': namaKategori,
      'id_pelanggan': idPelanggan,
      'nama_pelanggan': namaPelanggan,
      'id_paket': idPaket,
      'nama_paket': namaPaket,
      'id_sub_kategori': idSubKategori,
      'nama_sub_kategori': namaSubKategori,
      'diperbarui': diperbarui?.toIso8601String(),
      'diarsipkan': diarsipkan?.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  // ditambahkan: Metode toMapForFirebase
  Map<String, dynamic> toMapForFirebase() {
    return {
      'id': id,
      'tanggal': tanggal,
      'keterangan': keterangan,
      'jumlah': jumlah,
      'tipe': tipe.name,
      'id_dompet': idDompet,
      'nama_dompet': namaDompet,
      'id_dompet_tujuan': idDompetTujuan,
      'nama_dompet_tujuan': namaDompetTujuan,
      'id_kategori': idKategori,
      'nama_kategori': namaKategori,
      'id_pelanggan': idPelanggan,
      'nama_pelanggan': namaPelanggan,
      'id_paket': idPaket,
      'nama_paket': namaPaket,
      'id_sub_kategori': idSubKategori,
      'nama_sub_kategori': namaSubKategori,
      'diperbarui': diperbarui,
      'diarsipkan': diarsipkan,
      'isDeleted': isDeleted,
    };
  }

  // diubah: Nama metode menjadi copyWith
  TransaksiModel copyWith({
    String? id,
    DateTime? tanggal,
    String? keterangan,
    double? jumlah,
    TipeTransaksi? tipe,
    String? idDompet,
    String? namaDompet,
    String? idDompetTujuan,
    String? namaDompetTujuan,
    String? idKategori,
    String? namaKategori,
    String? idPelanggan,
    String? namaPelanggan,
    String? idPaket,
    String? namaPaket,
    String? idSubKategori,
    String? namaSubKategori,
    DateTime? diperbarui,
    DateTime? diarsipkan,
    bool? isDeleted,
  }) {
    return TransaksiModel(
      id: id ?? this.id,
      tanggal: tanggal ?? this.tanggal,
      keterangan: keterangan ?? this.keterangan,
      jumlah: jumlah ?? this.jumlah,
      tipe: tipe ?? this.tipe,
      idDompet: idDompet ?? this.idDompet,
      namaDompet: namaDompet ?? this.namaDompet,
      idDompetTujuan: idDompetTujuan ?? this.idDompetTujuan,
      namaDompetTujuan: namaDompetTujuan ?? this.namaDompetTujuan,
      idKategori: idKategori ?? this.idKategori,
      namaKategori: namaKategori ?? this.namaKategori,
      idPelanggan: idPelanggan ?? this.idPelanggan,
      namaPelanggan: namaPelanggan ?? this.namaPelanggan,
      idPaket: idPaket ?? this.idPaket,
      namaPaket: namaPaket ?? this.namaPaket,
      idSubKategori: idSubKategori ?? this.idSubKategori,
      namaSubKategori: namaSubKategori ?? this.namaSubKategori,
      diperbarui: diperbarui ?? this.diperbarui,
      diarsipkan: diarsipkan ?? this.diarsipkan,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
