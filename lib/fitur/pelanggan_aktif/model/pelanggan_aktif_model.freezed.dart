// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pelanggan_aktif_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PelangganAktifModel {

 String get id; String get idPelanggan; String get idPaket; String? get idTransaksi; DateTime get tanggalMulai; DateTime get tanggalBerakhir; StatusPembayaranEnum get status; DateTime? get diperbarui; bool get isDeleted; DateTime? get diarsipkan;
/// Create a copy of PelangganAktifModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PelangganAktifModelCopyWith<PelangganAktifModel> get copyWith => _$PelangganAktifModelCopyWithImpl<PelangganAktifModel>(this as PelangganAktifModel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PelangganAktifModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PelangganAktifModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.idPelanggan, _this.idPelanggan) || other.idPelanggan == _this.idPelanggan)&&(identical(other.idPaket, _this.idPaket) || other.idPaket == _this.idPaket)&&(identical(other.idTransaksi, _this.idTransaksi) || other.idTransaksi == _this.idTransaksi)&&(identical(other.tanggalMulai, _this.tanggalMulai) || other.tanggalMulai == _this.tanggalMulai)&&(identical(other.tanggalBerakhir, _this.tanggalBerakhir) || other.tanggalBerakhir == _this.tanggalBerakhir)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.diperbarui, _this.diperbarui) || other.diperbarui == _this.diperbarui)&&(identical(other.isDeleted, _this.isDeleted) || other.isDeleted == _this.isDeleted)&&(identical(other.diarsipkan, _this.diarsipkan) || other.diarsipkan == _this.diarsipkan));
}


@override
int get hashCode {
  final _this = this as PelangganAktifModel;
  return Object.hash(runtimeType,_this.id,_this.idPelanggan,_this.idPaket,_this.idTransaksi,_this.tanggalMulai,_this.tanggalBerakhir,_this.status,_this.diperbarui,_this.isDeleted,_this.diarsipkan);
}

@override
String toString() {
  final _this = this as PelangganAktifModel;
  return 'PelangganAktifModel(id: ${_this.id}, idPelanggan: ${_this.idPelanggan}, idPaket: ${_this.idPaket}, idTransaksi: ${_this.idTransaksi}, tanggalMulai: ${_this.tanggalMulai}, tanggalBerakhir: ${_this.tanggalBerakhir}, status: ${_this.status}, diperbarui: ${_this.diperbarui}, isDeleted: ${_this.isDeleted}, diarsipkan: ${_this.diarsipkan})';
}


}

/// @nodoc
abstract mixin class $PelangganAktifModelCopyWith<$Res>  {
  factory $PelangganAktifModelCopyWith(PelangganAktifModel value, $Res Function(PelangganAktifModel) _then) = _$PelangganAktifModelCopyWithImpl;
@useResult
$Res call({
 String id, String idPelanggan, String idPaket, String? idTransaksi, DateTime tanggalMulai, DateTime tanggalBerakhir, StatusPembayaranEnum status, DateTime? diperbarui, bool isDeleted, DateTime? diarsipkan
});




}
/// @nodoc
class _$PelangganAktifModelCopyWithImpl<$Res>
    implements $PelangganAktifModelCopyWith<$Res> {
  _$PelangganAktifModelCopyWithImpl(this._self, this._then);

  final PelangganAktifModel _self;
  final $Res Function(PelangganAktifModel) _then;

/// Create a copy of PelangganAktifModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? idPelanggan = null,Object? idPaket = null,Object? idTransaksi = freezed,Object? tanggalMulai = null,Object? tanggalBerakhir = null,Object? status = null,Object? diperbarui = freezed,Object? isDeleted = null,Object? diarsipkan = freezed,}) {
  return _then(PelangganAktifModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,idPelanggan: null == idPelanggan ? _self.idPelanggan : idPelanggan // ignore: cast_nullable_to_non_nullable
as String,idPaket: null == idPaket ? _self.idPaket : idPaket // ignore: cast_nullable_to_non_nullable
as String,idTransaksi: freezed == idTransaksi ? _self.idTransaksi : idTransaksi // ignore: cast_nullable_to_non_nullable
as String?,tanggalMulai: null == tanggalMulai ? _self.tanggalMulai : tanggalMulai // ignore: cast_nullable_to_non_nullable
as DateTime,tanggalBerakhir: null == tanggalBerakhir ? _self.tanggalBerakhir : tanggalBerakhir // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StatusPembayaranEnum,diperbarui: freezed == diperbarui ? _self.diperbarui : diperbarui // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,diarsipkan: freezed == diarsipkan ? _self.diarsipkan : diarsipkan // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PelangganAktifModel].
extension PelangganAktifModelPatterns on PelangganAktifModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PelangganAktifModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PelangganAktifModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PelangganAktifModel value)  $default,){
final _that = this;
switch (_that) {
case _PelangganAktifModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PelangganAktifModel value)?  $default,){
final _that = this;
switch (_that) {
case _PelangganAktifModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String idPelanggan,  String idPaket,  String? idTransaksi,  DateTime tanggalMulai,  DateTime tanggalBerakhir,  StatusPembayaranEnum status,  DateTime? diperbarui,  bool isDeleted,  DateTime? diarsipkan)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PelangganAktifModel() when $default != null:
return $default(_that.id,_that.idPelanggan,_that.idPaket,_that.idTransaksi,_that.tanggalMulai,_that.tanggalBerakhir,_that.status,_that.diperbarui,_that.isDeleted,_that.diarsipkan);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String idPelanggan,  String idPaket,  String? idTransaksi,  DateTime tanggalMulai,  DateTime tanggalBerakhir,  StatusPembayaranEnum status,  DateTime? diperbarui,  bool isDeleted,  DateTime? diarsipkan)  $default,) {final _that = this;
switch (_that) {
case _PelangganAktifModel():
return $default(_that.id,_that.idPelanggan,_that.idPaket,_that.idTransaksi,_that.tanggalMulai,_that.tanggalBerakhir,_that.status,_that.diperbarui,_that.isDeleted,_that.diarsipkan);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String idPelanggan,  String idPaket,  String? idTransaksi,  DateTime tanggalMulai,  DateTime tanggalBerakhir,  StatusPembayaranEnum status,  DateTime? diperbarui,  bool isDeleted,  DateTime? diarsipkan)?  $default,) {final _that = this;
switch (_that) {
case _PelangganAktifModel() when $default != null:
return $default(_that.id,_that.idPelanggan,_that.idPaket,_that.idTransaksi,_that.tanggalMulai,_that.tanggalBerakhir,_that.status,_that.diperbarui,_that.isDeleted,_that.diarsipkan);case _:
  return null;

}
}

}

/// @nodoc


class _PelangganAktifModel extends PelangganAktifModel {
  const _PelangganAktifModel({required this.id, required this.idPelanggan, required this.idPaket, this.idTransaksi, required this.tanggalMulai, required this.tanggalBerakhir, required this.status, this.diperbarui, this.isDeleted = false, this.diarsipkan}): super._();
  

@override final  String id;
@override final  String idPelanggan;
@override final  String idPaket;
@override final  String? idTransaksi;
@override final  DateTime tanggalMulai;
@override final  DateTime tanggalBerakhir;
@override final  StatusPembayaranEnum status;
@override final  DateTime? diperbarui;
@override@JsonKey() final  bool isDeleted;
@override final  DateTime? diarsipkan;

/// Create a copy of PelangganAktifModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PelangganAktifModelCopyWith<_PelangganAktifModel> get copyWith => __$PelangganAktifModelCopyWithImpl<_PelangganAktifModel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PelangganAktifModel&&(identical(other.id, id) || other.id == id)&&(identical(other.idPelanggan, idPelanggan) || other.idPelanggan == idPelanggan)&&(identical(other.idPaket, idPaket) || other.idPaket == idPaket)&&(identical(other.idTransaksi, idTransaksi) || other.idTransaksi == idTransaksi)&&(identical(other.tanggalMulai, tanggalMulai) || other.tanggalMulai == tanggalMulai)&&(identical(other.tanggalBerakhir, tanggalBerakhir) || other.tanggalBerakhir == tanggalBerakhir)&&(identical(other.status, status) || other.status == status)&&(identical(other.diperbarui, diperbarui) || other.diperbarui == diperbarui)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.diarsipkan, diarsipkan) || other.diarsipkan == diarsipkan));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,idPelanggan,idPaket,idTransaksi,tanggalMulai,tanggalBerakhir,status,diperbarui,isDeleted,diarsipkan);
}

@override
String toString() {
    return 'PelangganAktifModel(id: $id, idPelanggan: $idPelanggan, idPaket: $idPaket, idTransaksi: $idTransaksi, tanggalMulai: $tanggalMulai, tanggalBerakhir: $tanggalBerakhir, status: $status, diperbarui: $diperbarui, isDeleted: $isDeleted, diarsipkan: $diarsipkan)';
}


}

/// @nodoc
abstract mixin class _$PelangganAktifModelCopyWith<$Res> implements $PelangganAktifModelCopyWith<$Res> {
  factory _$PelangganAktifModelCopyWith(_PelangganAktifModel value, $Res Function(_PelangganAktifModel) _then) = __$PelangganAktifModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String idPelanggan, String idPaket, String? idTransaksi, DateTime tanggalMulai, DateTime tanggalBerakhir, StatusPembayaranEnum status, DateTime? diperbarui, bool isDeleted, DateTime? diarsipkan
});




}
/// @nodoc
class __$PelangganAktifModelCopyWithImpl<$Res>
    implements _$PelangganAktifModelCopyWith<$Res> {
  __$PelangganAktifModelCopyWithImpl(this._self, this._then);

  final _PelangganAktifModel _self;
  final $Res Function(_PelangganAktifModel) _then;

/// Create a copy of PelangganAktifModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? idPelanggan = null,Object? idPaket = null,Object? idTransaksi = freezed,Object? tanggalMulai = null,Object? tanggalBerakhir = null,Object? status = null,Object? diperbarui = freezed,Object? isDeleted = null,Object? diarsipkan = freezed,}) {
  return _then(_PelangganAktifModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,idPelanggan: null == idPelanggan ? _self.idPelanggan : idPelanggan // ignore: cast_nullable_to_non_nullable
as String,idPaket: null == idPaket ? _self.idPaket : idPaket // ignore: cast_nullable_to_non_nullable
as String,idTransaksi: freezed == idTransaksi ? _self.idTransaksi : idTransaksi // ignore: cast_nullable_to_non_nullable
as String?,tanggalMulai: null == tanggalMulai ? _self.tanggalMulai : tanggalMulai // ignore: cast_nullable_to_non_nullable
as DateTime,tanggalBerakhir: null == tanggalBerakhir ? _self.tanggalBerakhir : tanggalBerakhir // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StatusPembayaranEnum,diperbarui: freezed == diperbarui ? _self.diperbarui : diperbarui // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,diarsipkan: freezed == diarsipkan ? _self.diarsipkan : diarsipkan // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
