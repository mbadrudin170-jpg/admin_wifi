// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaksi_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TransaksiModel {

 String get id; DateTime get tanggal; String get keterangan; double get jumlah; TipeTransaksi get tipe; String get idDompet; String get idKategori; String? get idDompetTujuan; String? get idPelanggan; String? get idPaket; String? get idSubKategori; StatusPembayaranEnum get statusPembayaran; int get poinYangDihasilkan; int get poinYangDigunakan; DateTime? get diperbarui; DateTime? get diarsipkan; bool get isDeleted; int? get durasiPaket; TipeDurasi? get tipeDurasiPaket; DateTime? get tanggalMulai; DateTime? get tanggalBerakhir; bool get aktivasiPaket;
/// Create a copy of TransaksiModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransaksiModelCopyWith<TransaksiModel> get copyWith => _$TransaksiModelCopyWithImpl<TransaksiModel>(this as TransaksiModel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TransaksiModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransaksiModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.tanggal, _this.tanggal) || other.tanggal == _this.tanggal)&&(identical(other.keterangan, _this.keterangan) || other.keterangan == _this.keterangan)&&(identical(other.jumlah, _this.jumlah) || other.jumlah == _this.jumlah)&&(identical(other.tipe, _this.tipe) || other.tipe == _this.tipe)&&(identical(other.idDompet, _this.idDompet) || other.idDompet == _this.idDompet)&&(identical(other.idKategori, _this.idKategori) || other.idKategori == _this.idKategori)&&(identical(other.idDompetTujuan, _this.idDompetTujuan) || other.idDompetTujuan == _this.idDompetTujuan)&&(identical(other.idPelanggan, _this.idPelanggan) || other.idPelanggan == _this.idPelanggan)&&(identical(other.idPaket, _this.idPaket) || other.idPaket == _this.idPaket)&&(identical(other.idSubKategori, _this.idSubKategori) || other.idSubKategori == _this.idSubKategori)&&(identical(other.statusPembayaran, _this.statusPembayaran) || other.statusPembayaran == _this.statusPembayaran)&&(identical(other.poinYangDihasilkan, _this.poinYangDihasilkan) || other.poinYangDihasilkan == _this.poinYangDihasilkan)&&(identical(other.poinYangDigunakan, _this.poinYangDigunakan) || other.poinYangDigunakan == _this.poinYangDigunakan)&&(identical(other.diperbarui, _this.diperbarui) || other.diperbarui == _this.diperbarui)&&(identical(other.diarsipkan, _this.diarsipkan) || other.diarsipkan == _this.diarsipkan)&&(identical(other.isDeleted, _this.isDeleted) || other.isDeleted == _this.isDeleted)&&(identical(other.durasiPaket, _this.durasiPaket) || other.durasiPaket == _this.durasiPaket)&&(identical(other.tipeDurasiPaket, _this.tipeDurasiPaket) || other.tipeDurasiPaket == _this.tipeDurasiPaket)&&(identical(other.tanggalMulai, _this.tanggalMulai) || other.tanggalMulai == _this.tanggalMulai)&&(identical(other.tanggalBerakhir, _this.tanggalBerakhir) || other.tanggalBerakhir == _this.tanggalBerakhir)&&(identical(other.aktivasiPaket, _this.aktivasiPaket) || other.aktivasiPaket == _this.aktivasiPaket));
}


@override
int get hashCode {
  final _this = this as TransaksiModel;
  return Object.hashAll([runtimeType,_this.id,_this.tanggal,_this.keterangan,_this.jumlah,_this.tipe,_this.idDompet,_this.idKategori,_this.idDompetTujuan,_this.idPelanggan,_this.idPaket,_this.idSubKategori,_this.statusPembayaran,_this.poinYangDihasilkan,_this.poinYangDigunakan,_this.diperbarui,_this.diarsipkan,_this.isDeleted,_this.durasiPaket,_this.tipeDurasiPaket,_this.tanggalMulai,_this.tanggalBerakhir,_this.aktivasiPaket]);
}

@override
String toString() {
  final _this = this as TransaksiModel;
  return 'TransaksiModel(id: ${_this.id}, tanggal: ${_this.tanggal}, keterangan: ${_this.keterangan}, jumlah: ${_this.jumlah}, tipe: ${_this.tipe}, idDompet: ${_this.idDompet}, idKategori: ${_this.idKategori}, idDompetTujuan: ${_this.idDompetTujuan}, idPelanggan: ${_this.idPelanggan}, idPaket: ${_this.idPaket}, idSubKategori: ${_this.idSubKategori}, statusPembayaran: ${_this.statusPembayaran}, poinYangDihasilkan: ${_this.poinYangDihasilkan}, poinYangDigunakan: ${_this.poinYangDigunakan}, diperbarui: ${_this.diperbarui}, diarsipkan: ${_this.diarsipkan}, isDeleted: ${_this.isDeleted}, durasiPaket: ${_this.durasiPaket}, tipeDurasiPaket: ${_this.tipeDurasiPaket}, tanggalMulai: ${_this.tanggalMulai}, tanggalBerakhir: ${_this.tanggalBerakhir}, aktivasiPaket: ${_this.aktivasiPaket})';
}


}

/// @nodoc
abstract mixin class $TransaksiModelCopyWith<$Res>  {
  factory $TransaksiModelCopyWith(TransaksiModel value, $Res Function(TransaksiModel) _then) = _$TransaksiModelCopyWithImpl;
@useResult
$Res call({
 String id, DateTime tanggal, String keterangan, double jumlah, TipeTransaksi tipe, String idDompet, String idKategori, String? idDompetTujuan, String? idPelanggan, String? idPaket, String? idSubKategori, StatusPembayaranEnum statusPembayaran, int poinYangDihasilkan, int poinYangDigunakan, DateTime? diperbarui, DateTime? diarsipkan, bool isDeleted, int? durasiPaket, TipeDurasi? tipeDurasiPaket, DateTime? tanggalMulai, DateTime? tanggalBerakhir, bool aktivasiPaket
});




}
/// @nodoc
class _$TransaksiModelCopyWithImpl<$Res>
    implements $TransaksiModelCopyWith<$Res> {
  _$TransaksiModelCopyWithImpl(this._self, this._then);

  final TransaksiModel _self;
  final $Res Function(TransaksiModel) _then;

/// Create a copy of TransaksiModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tanggal = null,Object? keterangan = null,Object? jumlah = null,Object? tipe = null,Object? idDompet = null,Object? idKategori = null,Object? idDompetTujuan = freezed,Object? idPelanggan = freezed,Object? idPaket = freezed,Object? idSubKategori = freezed,Object? statusPembayaran = null,Object? poinYangDihasilkan = null,Object? poinYangDigunakan = null,Object? diperbarui = freezed,Object? diarsipkan = freezed,Object? isDeleted = null,Object? durasiPaket = freezed,Object? tipeDurasiPaket = freezed,Object? tanggalMulai = freezed,Object? tanggalBerakhir = freezed,Object? aktivasiPaket = null,}) {
  return _then(TransaksiModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tanggal: null == tanggal ? _self.tanggal : tanggal // ignore: cast_nullable_to_non_nullable
as DateTime,keterangan: null == keterangan ? _self.keterangan : keterangan // ignore: cast_nullable_to_non_nullable
as String,jumlah: null == jumlah ? _self.jumlah : jumlah // ignore: cast_nullable_to_non_nullable
as double,tipe: null == tipe ? _self.tipe : tipe // ignore: cast_nullable_to_non_nullable
as TipeTransaksi,idDompet: null == idDompet ? _self.idDompet : idDompet // ignore: cast_nullable_to_non_nullable
as String,idKategori: null == idKategori ? _self.idKategori : idKategori // ignore: cast_nullable_to_non_nullable
as String,idDompetTujuan: freezed == idDompetTujuan ? _self.idDompetTujuan : idDompetTujuan // ignore: cast_nullable_to_non_nullable
as String?,idPelanggan: freezed == idPelanggan ? _self.idPelanggan : idPelanggan // ignore: cast_nullable_to_non_nullable
as String?,idPaket: freezed == idPaket ? _self.idPaket : idPaket // ignore: cast_nullable_to_non_nullable
as String?,idSubKategori: freezed == idSubKategori ? _self.idSubKategori : idSubKategori // ignore: cast_nullable_to_non_nullable
as String?,statusPembayaran: null == statusPembayaran ? _self.statusPembayaran : statusPembayaran // ignore: cast_nullable_to_non_nullable
as StatusPembayaranEnum,poinYangDihasilkan: null == poinYangDihasilkan ? _self.poinYangDihasilkan : poinYangDihasilkan // ignore: cast_nullable_to_non_nullable
as int,poinYangDigunakan: null == poinYangDigunakan ? _self.poinYangDigunakan : poinYangDigunakan // ignore: cast_nullable_to_non_nullable
as int,diperbarui: freezed == diperbarui ? _self.diperbarui : diperbarui // ignore: cast_nullable_to_non_nullable
as DateTime?,diarsipkan: freezed == diarsipkan ? _self.diarsipkan : diarsipkan // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,durasiPaket: freezed == durasiPaket ? _self.durasiPaket : durasiPaket // ignore: cast_nullable_to_non_nullable
as int?,tipeDurasiPaket: freezed == tipeDurasiPaket ? _self.tipeDurasiPaket : tipeDurasiPaket // ignore: cast_nullable_to_non_nullable
as TipeDurasi?,tanggalMulai: freezed == tanggalMulai ? _self.tanggalMulai : tanggalMulai // ignore: cast_nullable_to_non_nullable
as DateTime?,tanggalBerakhir: freezed == tanggalBerakhir ? _self.tanggalBerakhir : tanggalBerakhir // ignore: cast_nullable_to_non_nullable
as DateTime?,aktivasiPaket: null == aktivasiPaket ? _self.aktivasiPaket : aktivasiPaket // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TransaksiModel].
extension TransaksiModelPatterns on TransaksiModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransaksiModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransaksiModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransaksiModel value)  $default,){
final _that = this;
switch (_that) {
case _TransaksiModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransaksiModel value)?  $default,){
final _that = this;
switch (_that) {
case _TransaksiModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime tanggal,  String keterangan,  double jumlah,  TipeTransaksi tipe,  String idDompet,  String idKategori,  String? idDompetTujuan,  String? idPelanggan,  String? idPaket,  String? idSubKategori,  StatusPembayaranEnum statusPembayaran,  int poinYangDihasilkan,  int poinYangDigunakan,  DateTime? diperbarui,  DateTime? diarsipkan,  bool isDeleted,  int? durasiPaket,  TipeDurasi? tipeDurasiPaket,  DateTime? tanggalMulai,  DateTime? tanggalBerakhir,  bool aktivasiPaket)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransaksiModel() when $default != null:
return $default(_that.id,_that.tanggal,_that.keterangan,_that.jumlah,_that.tipe,_that.idDompet,_that.idKategori,_that.idDompetTujuan,_that.idPelanggan,_that.idPaket,_that.idSubKategori,_that.statusPembayaran,_that.poinYangDihasilkan,_that.poinYangDigunakan,_that.diperbarui,_that.diarsipkan,_that.isDeleted,_that.durasiPaket,_that.tipeDurasiPaket,_that.tanggalMulai,_that.tanggalBerakhir,_that.aktivasiPaket);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime tanggal,  String keterangan,  double jumlah,  TipeTransaksi tipe,  String idDompet,  String idKategori,  String? idDompetTujuan,  String? idPelanggan,  String? idPaket,  String? idSubKategori,  StatusPembayaranEnum statusPembayaran,  int poinYangDihasilkan,  int poinYangDigunakan,  DateTime? diperbarui,  DateTime? diarsipkan,  bool isDeleted,  int? durasiPaket,  TipeDurasi? tipeDurasiPaket,  DateTime? tanggalMulai,  DateTime? tanggalBerakhir,  bool aktivasiPaket)  $default,) {final _that = this;
switch (_that) {
case _TransaksiModel():
return $default(_that.id,_that.tanggal,_that.keterangan,_that.jumlah,_that.tipe,_that.idDompet,_that.idKategori,_that.idDompetTujuan,_that.idPelanggan,_that.idPaket,_that.idSubKategori,_that.statusPembayaran,_that.poinYangDihasilkan,_that.poinYangDigunakan,_that.diperbarui,_that.diarsipkan,_that.isDeleted,_that.durasiPaket,_that.tipeDurasiPaket,_that.tanggalMulai,_that.tanggalBerakhir,_that.aktivasiPaket);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime tanggal,  String keterangan,  double jumlah,  TipeTransaksi tipe,  String idDompet,  String idKategori,  String? idDompetTujuan,  String? idPelanggan,  String? idPaket,  String? idSubKategori,  StatusPembayaranEnum statusPembayaran,  int poinYangDihasilkan,  int poinYangDigunakan,  DateTime? diperbarui,  DateTime? diarsipkan,  bool isDeleted,  int? durasiPaket,  TipeDurasi? tipeDurasiPaket,  DateTime? tanggalMulai,  DateTime? tanggalBerakhir,  bool aktivasiPaket)?  $default,) {final _that = this;
switch (_that) {
case _TransaksiModel() when $default != null:
return $default(_that.id,_that.tanggal,_that.keterangan,_that.jumlah,_that.tipe,_that.idDompet,_that.idKategori,_that.idDompetTujuan,_that.idPelanggan,_that.idPaket,_that.idSubKategori,_that.statusPembayaran,_that.poinYangDihasilkan,_that.poinYangDigunakan,_that.diperbarui,_that.diarsipkan,_that.isDeleted,_that.durasiPaket,_that.tipeDurasiPaket,_that.tanggalMulai,_that.tanggalBerakhir,_that.aktivasiPaket);case _:
  return null;

}
}

}

/// @nodoc


class _TransaksiModel extends TransaksiModel {
  const _TransaksiModel({required this.id, required this.tanggal, required this.keterangan, required this.jumlah, required this.tipe, required this.idDompet, required this.idKategori, this.idDompetTujuan, this.idPelanggan, this.idPaket, this.idSubKategori, this.statusPembayaran = StatusPembayaranEnum.belumLunas, this.poinYangDihasilkan = 0, this.poinYangDigunakan = 0, this.diperbarui, this.diarsipkan, this.isDeleted = false, this.durasiPaket, this.tipeDurasiPaket, this.tanggalMulai, this.tanggalBerakhir, this.aktivasiPaket = false}): super._();
  

@override final  String id;
@override final  DateTime tanggal;
@override final  String keterangan;
@override final  double jumlah;
@override final  TipeTransaksi tipe;
@override final  String idDompet;
@override final  String idKategori;
@override final  String? idDompetTujuan;
@override final  String? idPelanggan;
@override final  String? idPaket;
@override final  String? idSubKategori;
@override@JsonKey() final  StatusPembayaranEnum statusPembayaran;
@override@JsonKey() final  int poinYangDihasilkan;
@override@JsonKey() final  int poinYangDigunakan;
@override final  DateTime? diperbarui;
@override final  DateTime? diarsipkan;
@override@JsonKey() final  bool isDeleted;
@override final  int? durasiPaket;
@override final  TipeDurasi? tipeDurasiPaket;
@override final  DateTime? tanggalMulai;
@override final  DateTime? tanggalBerakhir;
@override@JsonKey() final  bool aktivasiPaket;

/// Create a copy of TransaksiModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransaksiModelCopyWith<_TransaksiModel> get copyWith => __$TransaksiModelCopyWithImpl<_TransaksiModel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransaksiModel&&(identical(other.id, id) || other.id == id)&&(identical(other.tanggal, tanggal) || other.tanggal == tanggal)&&(identical(other.keterangan, keterangan) || other.keterangan == keterangan)&&(identical(other.jumlah, jumlah) || other.jumlah == jumlah)&&(identical(other.tipe, tipe) || other.tipe == tipe)&&(identical(other.idDompet, idDompet) || other.idDompet == idDompet)&&(identical(other.idKategori, idKategori) || other.idKategori == idKategori)&&(identical(other.idDompetTujuan, idDompetTujuan) || other.idDompetTujuan == idDompetTujuan)&&(identical(other.idPelanggan, idPelanggan) || other.idPelanggan == idPelanggan)&&(identical(other.idPaket, idPaket) || other.idPaket == idPaket)&&(identical(other.idSubKategori, idSubKategori) || other.idSubKategori == idSubKategori)&&(identical(other.statusPembayaran, statusPembayaran) || other.statusPembayaran == statusPembayaran)&&(identical(other.poinYangDihasilkan, poinYangDihasilkan) || other.poinYangDihasilkan == poinYangDihasilkan)&&(identical(other.poinYangDigunakan, poinYangDigunakan) || other.poinYangDigunakan == poinYangDigunakan)&&(identical(other.diperbarui, diperbarui) || other.diperbarui == diperbarui)&&(identical(other.diarsipkan, diarsipkan) || other.diarsipkan == diarsipkan)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.durasiPaket, durasiPaket) || other.durasiPaket == durasiPaket)&&(identical(other.tipeDurasiPaket, tipeDurasiPaket) || other.tipeDurasiPaket == tipeDurasiPaket)&&(identical(other.tanggalMulai, tanggalMulai) || other.tanggalMulai == tanggalMulai)&&(identical(other.tanggalBerakhir, tanggalBerakhir) || other.tanggalBerakhir == tanggalBerakhir)&&(identical(other.aktivasiPaket, aktivasiPaket) || other.aktivasiPaket == aktivasiPaket));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,id,tanggal,keterangan,jumlah,tipe,idDompet,idKategori,idDompetTujuan,idPelanggan,idPaket,idSubKategori,statusPembayaran,poinYangDihasilkan,poinYangDigunakan,diperbarui,diarsipkan,isDeleted,durasiPaket,tipeDurasiPaket,tanggalMulai,tanggalBerakhir,aktivasiPaket]);
}

@override
String toString() {
    return 'TransaksiModel(id: $id, tanggal: $tanggal, keterangan: $keterangan, jumlah: $jumlah, tipe: $tipe, idDompet: $idDompet, idKategori: $idKategori, idDompetTujuan: $idDompetTujuan, idPelanggan: $idPelanggan, idPaket: $idPaket, idSubKategori: $idSubKategori, statusPembayaran: $statusPembayaran, poinYangDihasilkan: $poinYangDihasilkan, poinYangDigunakan: $poinYangDigunakan, diperbarui: $diperbarui, diarsipkan: $diarsipkan, isDeleted: $isDeleted, durasiPaket: $durasiPaket, tipeDurasiPaket: $tipeDurasiPaket, tanggalMulai: $tanggalMulai, tanggalBerakhir: $tanggalBerakhir, aktivasiPaket: $aktivasiPaket)';
}


}

/// @nodoc
abstract mixin class _$TransaksiModelCopyWith<$Res> implements $TransaksiModelCopyWith<$Res> {
  factory _$TransaksiModelCopyWith(_TransaksiModel value, $Res Function(_TransaksiModel) _then) = __$TransaksiModelCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime tanggal, String keterangan, double jumlah, TipeTransaksi tipe, String idDompet, String idKategori, String? idDompetTujuan, String? idPelanggan, String? idPaket, String? idSubKategori, StatusPembayaranEnum statusPembayaran, int poinYangDihasilkan, int poinYangDigunakan, DateTime? diperbarui, DateTime? diarsipkan, bool isDeleted, int? durasiPaket, TipeDurasi? tipeDurasiPaket, DateTime? tanggalMulai, DateTime? tanggalBerakhir, bool aktivasiPaket
});




}
/// @nodoc
class __$TransaksiModelCopyWithImpl<$Res>
    implements _$TransaksiModelCopyWith<$Res> {
  __$TransaksiModelCopyWithImpl(this._self, this._then);

  final _TransaksiModel _self;
  final $Res Function(_TransaksiModel) _then;

/// Create a copy of TransaksiModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tanggal = null,Object? keterangan = null,Object? jumlah = null,Object? tipe = null,Object? idDompet = null,Object? idKategori = null,Object? idDompetTujuan = freezed,Object? idPelanggan = freezed,Object? idPaket = freezed,Object? idSubKategori = freezed,Object? statusPembayaran = null,Object? poinYangDihasilkan = null,Object? poinYangDigunakan = null,Object? diperbarui = freezed,Object? diarsipkan = freezed,Object? isDeleted = null,Object? durasiPaket = freezed,Object? tipeDurasiPaket = freezed,Object? tanggalMulai = freezed,Object? tanggalBerakhir = freezed,Object? aktivasiPaket = null,}) {
  return _then(_TransaksiModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tanggal: null == tanggal ? _self.tanggal : tanggal // ignore: cast_nullable_to_non_nullable
as DateTime,keterangan: null == keterangan ? _self.keterangan : keterangan // ignore: cast_nullable_to_non_nullable
as String,jumlah: null == jumlah ? _self.jumlah : jumlah // ignore: cast_nullable_to_non_nullable
as double,tipe: null == tipe ? _self.tipe : tipe // ignore: cast_nullable_to_non_nullable
as TipeTransaksi,idDompet: null == idDompet ? _self.idDompet : idDompet // ignore: cast_nullable_to_non_nullable
as String,idKategori: null == idKategori ? _self.idKategori : idKategori // ignore: cast_nullable_to_non_nullable
as String,idDompetTujuan: freezed == idDompetTujuan ? _self.idDompetTujuan : idDompetTujuan // ignore: cast_nullable_to_non_nullable
as String?,idPelanggan: freezed == idPelanggan ? _self.idPelanggan : idPelanggan // ignore: cast_nullable_to_non_nullable
as String?,idPaket: freezed == idPaket ? _self.idPaket : idPaket // ignore: cast_nullable_to_non_nullable
as String?,idSubKategori: freezed == idSubKategori ? _self.idSubKategori : idSubKategori // ignore: cast_nullable_to_non_nullable
as String?,statusPembayaran: null == statusPembayaran ? _self.statusPembayaran : statusPembayaran // ignore: cast_nullable_to_non_nullable
as StatusPembayaranEnum,poinYangDihasilkan: null == poinYangDihasilkan ? _self.poinYangDihasilkan : poinYangDihasilkan // ignore: cast_nullable_to_non_nullable
as int,poinYangDigunakan: null == poinYangDigunakan ? _self.poinYangDigunakan : poinYangDigunakan // ignore: cast_nullable_to_non_nullable
as int,diperbarui: freezed == diperbarui ? _self.diperbarui : diperbarui // ignore: cast_nullable_to_non_nullable
as DateTime?,diarsipkan: freezed == diarsipkan ? _self.diarsipkan : diarsipkan // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,durasiPaket: freezed == durasiPaket ? _self.durasiPaket : durasiPaket // ignore: cast_nullable_to_non_nullable
as int?,tipeDurasiPaket: freezed == tipeDurasiPaket ? _self.tipeDurasiPaket : tipeDurasiPaket // ignore: cast_nullable_to_non_nullable
as TipeDurasi?,tanggalMulai: freezed == tanggalMulai ? _self.tanggalMulai : tanggalMulai // ignore: cast_nullable_to_non_nullable
as DateTime?,tanggalBerakhir: freezed == tanggalBerakhir ? _self.tanggalBerakhir : tanggalBerakhir // ignore: cast_nullable_to_non_nullable
as DateTime?,aktivasiPaket: null == aktivasiPaket ? _self.aktivasiPaket : aktivasiPaket // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
