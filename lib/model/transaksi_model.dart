// path: lib/model/transaksi_model.dart
import 'package:admin_wifi/model/enum/sync_status.dart';
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
  final SyncStatus syncStatus;

  // tambahan lifecycle
  final bool isDeleted;

  TransaksiModel({
    String? id,
    required this.tanggal,
    required this.keterangan,
    required this.jumlah,
    required this.tipe,
    required this.idDompet,
    required this.namaDompet,
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
    this.syncStatus = SyncStatus.write,
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
      id: map['id'],
      tanggal: _parseDateTime(map['tanggal']) ?? DateTime.now(),
      keterangan: map['keterangan'] ?? '',
      jumlah: (map['jumlah'] as num? ?? 0).toDouble(),
      tipe: TipeTransaksi.values.firstWhere(
        (e) => e.name == map['tipe'],
        orElse: () => TipeTransaksi.pengeluaran,
      ),

      idDompet: map['id_dompet'] ?? '',
      namaDompet: map['nama_dompet'] ?? '',
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

      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.name == map['sync_status'],
        orElse: () => SyncStatus.synced,
      ),

      // tambahan soft delete
      isDeleted: map['isDeleted'] == true || map['isDeleted'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tanggal': tanggal.toIso8601String(),
      'keterangan': keterangan,
      'jumlah': jumlah,
      'tipe': tipe.name,

      'id_dompet': idDompet,
      'nama_dompet': namaDompet,
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

      'sync_status': syncStatus.name,

      // tambahan lifecycle
      'isDeleted': isDeleted,
    };
  }

  TransaksiModel salinDengan({
    String? id,
    DateTime? tanggal,
    String? keterangan,
    double? jumlah,
    TipeTransaksi? tipe,
    String? idDompet,
    String? namaDompet,
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
    SyncStatus? syncStatus,
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

      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
