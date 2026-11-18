// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paket_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaketModel {

 String get id; String get nama; int get harga; int get durasi; TipeDurasi get tipe; int get poinHadiah; int get poinPenukaran; bool get isPublic; DateTime? get diperbarui; bool get isDeleted; DateTime? get diarsipkan;
/// Create a copy of PaketModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaketModelCopyWith<PaketModel> get copyWith => _$PaketModelCopyWithImpl<PaketModel>(this as PaketModel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PaketModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaketModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.nama, _this.nama) || other.nama == _this.nama)&&(identical(other.harga, _this.harga) || other.harga == _this.harga)&&(identical(other.durasi, _this.durasi) || other.durasi == _this.durasi)&&(identical(other.tipe, _this.tipe) || other.tipe == _this.tipe)&&(identical(other.poinHadiah, _this.poinHadiah) || other.poinHadiah == _this.poinHadiah)&&(identical(other.poinPenukaran, _this.poinPenukaran) || other.poinPenukaran == _this.poinPenukaran)&&(identical(other.isPublic, _this.isPublic) || other.isPublic == _this.isPublic)&&(identical(other.diperbarui, _this.diperbarui) || other.diperbarui == _this.diperbarui)&&(identical(other.isDeleted, _this.isDeleted) || other.isDeleted == _this.isDeleted)&&(identical(other.diarsipkan, _this.diarsipkan) || other.diarsipkan == _this.diarsipkan));
}


@override
int get hashCode {
  final _this = this as PaketModel;
  return Object.hash(runtimeType,_this.id,_this.nama,_this.harga,_this.durasi,_this.tipe,_this.poinHadiah,_this.poinPenukaran,_this.isPublic,_this.diperbarui,_this.isDeleted,_this.diarsipkan);
}

@override
String toString() {
  final _this = this as PaketModel;
  return 'PaketModel(id: ${_this.id}, nama: ${_this.nama}, harga: ${_this.harga}, durasi: ${_this.durasi}, tipe: ${_this.tipe}, poinHadiah: ${_this.poinHadiah}, poinPenukaran: ${_this.poinPenukaran}, isPublic: ${_this.isPublic}, diperbarui: ${_this.diperbarui}, isDeleted: ${_this.isDeleted}, diarsipkan: ${_this.diarsipkan})';
}


}

/// @nodoc
abstract mixin class $PaketModelCopyWith<$Res>  {
  factory $PaketModelCopyWith(PaketModel value, $Res Function(PaketModel) _then) = _$PaketModelCopyWithImpl;
@useResult
$Res call({
 String id, String nama, int harga, int durasi, TipeDurasi tipe, int poinHadiah, int poinPenukaran, bool isPublic, DateTime? diperbarui, bool isDeleted, DateTime? diarsipkan
});




}
/// @nodoc
class _$PaketModelCopyWithImpl<$Res>
    implements $PaketModelCopyWith<$Res> {
  _$PaketModelCopyWithImpl(this._self, this._then);

  final PaketModel _self;
  final $Res Function(PaketModel) _then;

/// Create a copy of PaketModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nama = null,Object? harga = null,Object? durasi = null,Object? tipe = null,Object? poinHadiah = null,Object? poinPenukaran = null,Object? isPublic = null,Object? diperbarui = freezed,Object? isDeleted = null,Object? diarsipkan = freezed,}) {
  return _then(PaketModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nama: null == nama ? _self.nama : nama // ignore: cast_nullable_to_non_nullable
as String,harga: null == harga ? _self.harga : harga // ignore: cast_nullable_to_non_nullable
as int,durasi: null == durasi ? _self.durasi : durasi // ignore: cast_nullable_to_non_nullable
as int,tipe: null == tipe ? _self.tipe : tipe // ignore: cast_nullable_to_non_nullable
as TipeDurasi,poinHadiah: null == poinHadiah ? _self.poinHadiah : poinHadiah // ignore: cast_nullable_to_non_nullable
as int,poinPenukaran: null == poinPenukaran ? _self.poinPenukaran : poinPenukaran // ignore: cast_nullable_to_non_nullable
as int,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,diperbarui: freezed == diperbarui ? _self.diperbarui : diperbarui // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,diarsipkan: freezed == diarsipkan ? _self.diarsipkan : diarsipkan // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaketModel].
extension PaketModelPatterns on PaketModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaketModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaketModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaketModel value)  $default,){
final _that = this;
switch (_that) {
case _PaketModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaketModel value)?  $default,){
final _that = this;
switch (_that) {
case _PaketModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nama,  int harga,  int durasi,  TipeDurasi tipe,  int poinHadiah,  int poinPenukaran,  bool isPublic,  DateTime? diperbarui,  bool isDeleted,  DateTime? diarsipkan)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaketModel() when $default != null:
return $default(_that.id,_that.nama,_that.harga,_that.durasi,_that.tipe,_that.poinHadiah,_that.poinPenukaran,_that.isPublic,_that.diperbarui,_that.isDeleted,_that.diarsipkan);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nama,  int harga,  int durasi,  TipeDurasi tipe,  int poinHadiah,  int poinPenukaran,  bool isPublic,  DateTime? diperbarui,  bool isDeleted,  DateTime? diarsipkan)  $default,) {final _that = this;
switch (_that) {
case _PaketModel():
return $default(_that.id,_that.nama,_that.harga,_that.durasi,_that.tipe,_that.poinHadiah,_that.poinPenukaran,_that.isPublic,_that.diperbarui,_that.isDeleted,_that.diarsipkan);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nama,  int harga,  int durasi,  TipeDurasi tipe,  int poinHadiah,  int poinPenukaran,  bool isPublic,  DateTime? diperbarui,  bool isDeleted,  DateTime? diarsipkan)?  $default,) {final _that = this;
switch (_that) {
case _PaketModel() when $default != null:
return $default(_that.id,_that.nama,_that.harga,_that.durasi,_that.tipe,_that.poinHadiah,_that.poinPenukaran,_that.isPublic,_that.diperbarui,_that.isDeleted,_that.diarsipkan);case _:
  return null;

}
}

}

/// @nodoc


class _PaketModel extends PaketModel {
  const _PaketModel({required this.id, required this.nama, required this.harga, required this.durasi, required this.tipe, this.poinHadiah = 0, this.poinPenukaran = 0, this.isPublic = true, this.diperbarui, this.isDeleted = false, this.diarsipkan}): super._();
  

@override final  String id;
@override final  String nama;
@override final  int harga;
@override final  int durasi;
@override final  TipeDurasi tipe;
@override@JsonKey() final  int poinHadiah;
@override@JsonKey() final  int poinPenukaran;
@override@JsonKey() final  bool isPublic;
@override final  DateTime? diperbarui;
@override@JsonKey() final  bool isDeleted;
@override final  DateTime? diarsipkan;

/// Create a copy of PaketModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaketModelCopyWith<_PaketModel> get copyWith => __$PaketModelCopyWithImpl<_PaketModel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaketModel&&(identical(other.id, id) || other.id == id)&&(identical(other.nama, nama) || other.nama == nama)&&(identical(other.harga, harga) || other.harga == harga)&&(identical(other.durasi, durasi) || other.durasi == durasi)&&(identical(other.tipe, tipe) || other.tipe == tipe)&&(identical(other.poinHadiah, poinHadiah) || other.poinHadiah == poinHadiah)&&(identical(other.poinPenukaran, poinPenukaran) || other.poinPenukaran == poinPenukaran)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.diperbarui, diperbarui) || other.diperbarui == diperbarui)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.diarsipkan, diarsipkan) || other.diarsipkan == diarsipkan));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,nama,harga,durasi,tipe,poinHadiah,poinPenukaran,isPublic,diperbarui,isDeleted,diarsipkan);
}

@override
String toString() {
    return 'PaketModel(id: $id, nama: $nama, harga: $harga, durasi: $durasi, tipe: $tipe, poinHadiah: $poinHadiah, poinPenukaran: $poinPenukaran, isPublic: $isPublic, diperbarui: $diperbarui, isDeleted: $isDeleted, diarsipkan: $diarsipkan)';
}


}

/// @nodoc
abstract mixin class _$PaketModelCopyWith<$Res> implements $PaketModelCopyWith<$Res> {
  factory _$PaketModelCopyWith(_PaketModel value, $Res Function(_PaketModel) _then) = __$PaketModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String nama, int harga, int durasi, TipeDurasi tipe, int poinHadiah, int poinPenukaran, bool isPublic, DateTime? diperbarui, bool isDeleted, DateTime? diarsipkan
});




}
/// @nodoc
class __$PaketModelCopyWithImpl<$Res>
    implements _$PaketModelCopyWith<$Res> {
  __$PaketModelCopyWithImpl(this._self, this._then);

  final _PaketModel _self;
  final $Res Function(_PaketModel) _then;

/// Create a copy of PaketModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nama = null,Object? harga = null,Object? durasi = null,Object? tipe = null,Object? poinHadiah = null,Object? poinPenukaran = null,Object? isPublic = null,Object? diperbarui = freezed,Object? isDeleted = null,Object? diarsipkan = freezed,}) {
  return _then(_PaketModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nama: null == nama ? _self.nama : nama // ignore: cast_nullable_to_non_nullable
as String,harga: null == harga ? _self.harga : harga // ignore: cast_nullable_to_non_nullable
as int,durasi: null == durasi ? _self.durasi : durasi // ignore: cast_nullable_to_non_nullable
as int,tipe: null == tipe ? _self.tipe : tipe // ignore: cast_nullable_to_non_nullable
as TipeDurasi,poinHadiah: null == poinHadiah ? _self.poinHadiah : poinHadiah // ignore: cast_nullable_to_non_nullable
as int,poinPenukaran: null == poinPenukaran ? _self.poinPenukaran : poinPenukaran // ignore: cast_nullable_to_non_nullable
as int,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,diperbarui: freezed == diperbarui ? _self.diperbarui : diperbarui // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,diarsipkan: freezed == diarsipkan ? _self.diarsipkan : diarsipkan // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
