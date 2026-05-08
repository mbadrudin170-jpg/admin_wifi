// path: lib/model/transaksi_model.dart
// diubah: Penamaan metode diseragamkan dan logika Firebase diperbaiki.
import 'package:admin_wifi/enum/status_pembayaran.dart';
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
  final StatusPembayaran statusPembayaran;
  final int poinYangDihasilkan;
  final int poinYangDigunakan;
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
    this.statusPembayaran = StatusPembayaran.belumLunas,
    this.poinYangDihasilkan = 0,
    this.poinYangDigunakan = 0,
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

  // diubah: Nama metode dari fromMap menjadi fromSqlite
  factory TransaksiModel.fromSqlite(Map<String, dynamic> map) {
    return TransaksiModel(
      id: map['id'] as String? ?? const Uuid().v4(),
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
      statusPembayaran: StatusPembayaran.values.firstWhere(
        (e) => e.name == map['status_pembayaran'],
        orElse: () => StatusPembayaran.belumLunas,
      ),
      poinYangDihasilkan: (map['poin_yang_dihasilkan'] as num? ?? 0).toInt(),
      poinYangDigunakan: (map['poin_yang_digunakan'] as num? ?? 0).toInt(),
      diperbarui: _parseDateTime(map['diperbarui']),
      diarsipkan: _parseDateTime(map['diarsipkan']),
      isDeleted: map['isDeleted'] == 1 || map['isDeleted'] == true,
    );
  }

  // diubah: Nama metode dari toMapForSqlite menjadi toSqlite
  Map<String, dynamic> toSqlite() {
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
      'status_pembayaran': statusPembayaran.name,
      'poin_yang_dihasilkan': poinYangDihasilkan,
      'poin_yang_digunakan': poinYangDigunakan,
      'diperbarui': diperbarui?.toIso8601String(),
      'diarsipkan': diarsipkan?.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  // ditambahkan: Factory fromFirebase
  factory TransaksiModel.fromFirebase(String id, Map<String, dynamic> data) {
    return TransaksiModel(
      id: id,
      tanggal: _parseDateTime(data['tanggal']) ?? DateTime.now(),
      keterangan: data['keterangan'] ?? '',
      jumlah: (data['jumlah'] as num? ?? 0).toDouble(),
      tipe: TipeTransaksi.values.firstWhere(
        (e) => e.name == data['tipe'],
        orElse: () => TipeTransaksi.pengeluaran,
      ),
      idDompet: data['id_dompet'] ?? '',
      namaDompet: data['nama_dompet'] ?? '',
      idDompetTujuan: data['id_dompet_tujuan'],
      namaDompetTujuan: data['nama_dompet_tujuan'],
      idKategori: data['id_kategori'] ?? '',
      namaKategori: data['nama_kategori'] ?? '',
      idPelanggan: data['id_pelanggan'],
      namaPelanggan: data['nama_pelanggan'],
      idPaket: data['id_paket'],
      namaPaket: data['nama_paket'],
      idSubKategori: data['id_sub_kategori'],
      namaSubKategori: data['nama_sub_kategori'],
      statusPembayaran: StatusPembayaran.values.firstWhere(
        (e) => e.name == data['status_pembayaran'],
        orElse: () => StatusPembayaran.belumLunas,
      ),
      poinYangDihasilkan: (data['poin_yang_dihasilkan'] as num? ?? 0).toInt(),
      poinYangDigunakan: (data['poin_yang_digunakan'] as num? ?? 0).toInt(),
      diperbarui: _parseDateTime(data['diperbarui']),
      diarsipkan: _parseDateTime(data['diarsipkan']),
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  // diubah: Nama metode dan logika diperbarui diubah
  Map<String, dynamic> toFirebase() {
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
      'status_pembayaran': statusPembayaran.name,
      'poin_yang_dihasilkan': poinYangDihasilkan,
      'poin_yang_digunakan': poinYangDigunakan,
      'diperbarui': FieldValue.serverTimestamp(), // diubah
      'diarsipkan': diarsipkan,
      'isDeleted': isDeleted,
    };
  }

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
    StatusPembayaran? statusPembayaran,
    int? poinYangDihasilkan,
    int? poinYangDigunakan,
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
      statusPembayaran: statusPembayaran ?? this.statusPembayaran,
      poinYangDihasilkan: poinYangDihasilkan ?? this.poinYangDihasilkan,
      poinYangDigunakan: poinYangDigunakan ?? this.poinYangDigunakan,
      diperbarui: diperbarui ?? this.diperbarui,
      diarsipkan: diarsipkan ?? this.diarsipkan,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
