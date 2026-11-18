// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pesanan_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PesananModel {

 String get id; String get idPelanggan; String get idPaket; DateTime get tanggal; String get status; DateTime? get diperbarui; bool get isDeleted; DateTime? get diarsipkan;
/// Create a copy of PesananModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PesananModelCopyWith<PesananModel> get copyWith => _$PesananModelCopyWithImpl<PesananModel>(this as PesananModel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PesananModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PesananModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.idPelanggan, _this.idPelanggan) || other.idPelanggan == _this.idPelanggan)&&(identical(other.idPaket, _this.idPaket) || other.idPaket == _this.idPaket)&&(identical(other.tanggal, _this.tanggal) || other.tanggal == _this.tanggal)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.diperbarui, _this.diperbarui) || other.diperbarui == _this.diperbarui)&&(identical(other.isDeleted, _this.isDeleted) || other.isDeleted == _this.isDeleted)&&(identical(other.diarsipkan, _this.diarsipkan) || other.diarsipkan == _this.diarsipkan));
}


@override
int get hashCode {
  final _this = this as PesananModel;
  return Object.hash(runtimeType,_this.id,_this.idPelanggan,_this.idPaket,_this.tanggal,_this.status,_this.diperbarui,_this.isDeleted,_this.diarsipkan);
}

@override
String toString() {
  final _this = this as PesananModel;
  return 'PesananModel(id: ${_this.id}, idPelanggan: ${_this.idPelanggan}, idPaket: ${_this.idPaket}, tanggal: ${_this.tanggal}, status: ${_this.status}, diperbarui: ${_this.diperbarui}, isDeleted: ${_this.isDeleted}, diarsipkan: ${_this.diarsipkan})';
}


}

/// @nodoc
abstract mixin class $PesananModelCopyWith<$Res>  {
  factory $PesananModelCopyWith(PesananModel value, $Res Function(PesananModel) _then) = _$PesananModelCopyWithImpl;
@useResult
$Res call({
 String id, String idPelanggan, String idPaket, DateTime tanggal, String status, DateTime? diperbarui, bool isDeleted, DateTime? diarsipkan
});




}
/// @nodoc
class _$PesananModelCopyWithImpl<$Res>
    implements $PesananModelCopyWith<$Res> {
  _$PesananModelCopyWithImpl(this._self, this._then);

  final PesananModel _self;
  final $Res Function(PesananModel) _then;

/// Create a copy of PesananModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? idPelanggan = null,Object? idPaket = null,Object? tanggal = null,Object? status = null,Object? diperbarui = freezed,Object? isDeleted = null,Object? diarsipkan = freezed,}) {
  return _then(PesananModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,idPelanggan: null == idPelanggan ? _self.idPelanggan : idPelanggan // ignore: cast_nullable_to_non_nullable
as String,idPaket: null == idPaket ? _self.idPaket : idPaket // ignore: cast_nullable_to_non_nullable
as String,tanggal: null == tanggal ? _self.tanggal : tanggal // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,diperbarui: freezed == diperbarui ? _self.diperbarui : diperbarui // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,diarsipkan: freezed == diarsipkan ? _self.diarsipkan : diarsipkan // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PesananModel].
extension PesananModelPatterns on PesananModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PesananModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PesananModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PesananModel value)  $default,){
final _that = this;
switch (_that) {
case _PesananModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PesananModel value)?  $default,){
final _that = this;
switch (_that) {
case _PesananModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String idPelanggan,  String idPaket,  DateTime tanggal,  String status,  DateTime? diperbarui,  bool isDeleted,  DateTime? diarsipkan)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PesananModel() when $default != null:
return $default(_that.id,_that.idPelanggan,_that.idPaket,_that.tanggal,_that.status,_that.diperbarui,_that.isDeleted,_that.diarsipkan);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String idPelanggan,  String idPaket,  DateTime tanggal,  String status,  DateTime? diperbarui,  bool isDeleted,  DateTime? diarsipkan)  $default,) {final _that = this;
switch (_that) {
case _PesananModel():
return $default(_that.id,_that.idPelanggan,_that.idPaket,_that.tanggal,_that.status,_that.diperbarui,_that.isDeleted,_that.diarsipkan);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String idPelanggan,  String idPaket,  DateTime tanggal,  String status,  DateTime? diperbarui,  bool isDeleted,  DateTime? diarsipkan)?  $default,) {final _that = this;
switch (_that) {
case _PesananModel() when $default != null:
return $default(_that.id,_that.idPelanggan,_that.idPaket,_that.tanggal,_that.status,_that.diperbarui,_that.isDeleted,_that.diarsipkan);case _:
  return null;

}
}

}

/// @nodoc


class _PesananModel extends PesananModel {
  const _PesananModel({required this.id, required this.idPelanggan, required this.idPaket, required this.tanggal, required this.status, this.diperbarui, this.isDeleted = false, this.diarsipkan}): super._();
  

@override final  String id;
@override final  String idPelanggan;
@override final  String idPaket;
@override final  DateTime tanggal;
@override final  String status;
@override final  DateTime? diperbarui;
@override@JsonKey() final  bool isDeleted;
@override final  DateTime? diarsipkan;

/// Create a copy of PesananModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PesananModelCopyWith<_PesananModel> get copyWith => __$PesananModelCopyWithImpl<_PesananModel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PesananModel&&(identical(other.id, id) || other.id == id)&&(identical(other.idPelanggan, idPelanggan) || other.idPelanggan == idPelanggan)&&(identical(other.idPaket, idPaket) || other.idPaket == idPaket)&&(identical(other.tanggal, tanggal) || other.tanggal == tanggal)&&(identical(other.status, status) || other.status == status)&&(identical(other.diperbarui, diperbarui) || other.diperbarui == diperbarui)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.diarsipkan, diarsipkan) || other.diarsipkan == diarsipkan));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,idPelanggan,idPaket,tanggal,status,diperbarui,isDeleted,diarsipkan);
}

@override
String toString() {
    return 'PesananModel(id: $id, idPelanggan: $idPelanggan, idPaket: $idPaket, tanggal: $tanggal, status: $status, diperbarui: $diperbarui, isDeleted: $isDeleted, diarsipkan: $diarsipkan)';
}


}

/// @nodoc
abstract mixin class _$PesananModelCopyWith<$Res> implements $PesananModelCopyWith<$Res> {
  factory _$PesananModelCopyWith(_PesananModel value, $Res Function(_PesananModel) _then) = __$PesananModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String idPelanggan, String idPaket, DateTime tanggal, String status, DateTime? diperbarui, bool isDeleted, DateTime? diarsipkan
});




}
/// @nodoc
class __$PesananModelCopyWithImpl<$Res>
    implements _$PesananModelCopyWith<$Res> {
  __$PesananModelCopyWithImpl(this._self, this._then);

  final _PesananModel _self;
  final $Res Function(_PesananModel) _then;

/// Create a copy of PesananModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? idPelanggan = null,Object? idPaket = null,Object? tanggal = null,Object? status = null,Object? diperbarui = freezed,Object? isDeleted = null,Object? diarsipkan = freezed,}) {
  return _then(_PesananModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,idPelanggan: null == idPelanggan ? _self.idPelanggan : idPelanggan // ignore: cast_nullable_to_non_nullable
as String,idPaket: null == idPaket ? _self.idPaket : idPaket // ignore: cast_nullable_to_non_nullable
as String,tanggal: null == tanggal ? _self.tanggal : tanggal // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,diperbarui: freezed == diperbarui ? _self.diperbarui : diperbarui // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,diarsipkan: freezed == diarsipkan ? _self.diarsipkan : diarsipkan // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
