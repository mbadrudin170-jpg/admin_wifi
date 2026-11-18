// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pengaturan_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PengaturanModel {

 int get intervalSinkronisasiOtomatis; int get hapusOtomatisDataArsip; bool get modePemeliharaan; String get infoPemeliharaan; DateTime? get diperbarui;
/// Create a copy of PengaturanModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PengaturanModelCopyWith<PengaturanModel> get copyWith => _$PengaturanModelCopyWithImpl<PengaturanModel>(this as PengaturanModel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PengaturanModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PengaturanModel&&(identical(other.intervalSinkronisasiOtomatis, _this.intervalSinkronisasiOtomatis) || other.intervalSinkronisasiOtomatis == _this.intervalSinkronisasiOtomatis)&&(identical(other.hapusOtomatisDataArsip, _this.hapusOtomatisDataArsip) || other.hapusOtomatisDataArsip == _this.hapusOtomatisDataArsip)&&(identical(other.modePemeliharaan, _this.modePemeliharaan) || other.modePemeliharaan == _this.modePemeliharaan)&&(identical(other.infoPemeliharaan, _this.infoPemeliharaan) || other.infoPemeliharaan == _this.infoPemeliharaan)&&(identical(other.diperbarui, _this.diperbarui) || other.diperbarui == _this.diperbarui));
}


@override
int get hashCode {
  final _this = this as PengaturanModel;
  return Object.hash(runtimeType,_this.intervalSinkronisasiOtomatis,_this.hapusOtomatisDataArsip,_this.modePemeliharaan,_this.infoPemeliharaan,_this.diperbarui);
}

@override
String toString() {
  final _this = this as PengaturanModel;
  return 'PengaturanModel(intervalSinkronisasiOtomatis: ${_this.intervalSinkronisasiOtomatis}, hapusOtomatisDataArsip: ${_this.hapusOtomatisDataArsip}, modePemeliharaan: ${_this.modePemeliharaan}, infoPemeliharaan: ${_this.infoPemeliharaan}, diperbarui: ${_this.diperbarui})';
}


}

/// @nodoc
abstract mixin class $PengaturanModelCopyWith<$Res>  {
  factory $PengaturanModelCopyWith(PengaturanModel value, $Res Function(PengaturanModel) _then) = _$PengaturanModelCopyWithImpl;
@useResult
$Res call({
 int intervalSinkronisasiOtomatis, int hapusOtomatisDataArsip, bool modePemeliharaan, String infoPemeliharaan, DateTime? diperbarui
});




}
/// @nodoc
class _$PengaturanModelCopyWithImpl<$Res>
    implements $PengaturanModelCopyWith<$Res> {
  _$PengaturanModelCopyWithImpl(this._self, this._then);

  final PengaturanModel _self;
  final $Res Function(PengaturanModel) _then;

/// Create a copy of PengaturanModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? intervalSinkronisasiOtomatis = null,Object? hapusOtomatisDataArsip = null,Object? modePemeliharaan = null,Object? infoPemeliharaan = null,Object? diperbarui = freezed,}) {
  return _then(PengaturanModel(
intervalSinkronisasiOtomatis: null == intervalSinkronisasiOtomatis ? _self.intervalSinkronisasiOtomatis : intervalSinkronisasiOtomatis // ignore: cast_nullable_to_non_nullable
as int,hapusOtomatisDataArsip: null == hapusOtomatisDataArsip ? _self.hapusOtomatisDataArsip : hapusOtomatisDataArsip // ignore: cast_nullable_to_non_nullable
as int,modePemeliharaan: null == modePemeliharaan ? _self.modePemeliharaan : modePemeliharaan // ignore: cast_nullable_to_non_nullable
as bool,infoPemeliharaan: null == infoPemeliharaan ? _self.infoPemeliharaan : infoPemeliharaan // ignore: cast_nullable_to_non_nullable
as String,diperbarui: freezed == diperbarui ? _self.diperbarui : diperbarui // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PengaturanModel].
extension PengaturanModelPatterns on PengaturanModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PengaturanModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PengaturanModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PengaturanModel value)  $default,){
final _that = this;
switch (_that) {
case _PengaturanModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PengaturanModel value)?  $default,){
final _that = this;
switch (_that) {
case _PengaturanModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int intervalSinkronisasiOtomatis,  int hapusOtomatisDataArsip,  bool modePemeliharaan,  String infoPemeliharaan,  DateTime? diperbarui)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PengaturanModel() when $default != null:
return $default(_that.intervalSinkronisasiOtomatis,_that.hapusOtomatisDataArsip,_that.modePemeliharaan,_that.infoPemeliharaan,_that.diperbarui);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int intervalSinkronisasiOtomatis,  int hapusOtomatisDataArsip,  bool modePemeliharaan,  String infoPemeliharaan,  DateTime? diperbarui)  $default,) {final _that = this;
switch (_that) {
case _PengaturanModel():
return $default(_that.intervalSinkronisasiOtomatis,_that.hapusOtomatisDataArsip,_that.modePemeliharaan,_that.infoPemeliharaan,_that.diperbarui);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int intervalSinkronisasiOtomatis,  int hapusOtomatisDataArsip,  bool modePemeliharaan,  String infoPemeliharaan,  DateTime? diperbarui)?  $default,) {final _that = this;
switch (_that) {
case _PengaturanModel() when $default != null:
return $default(_that.intervalSinkronisasiOtomatis,_that.hapusOtomatisDataArsip,_that.modePemeliharaan,_that.infoPemeliharaan,_that.diperbarui);case _:
  return null;

}
}

}

/// @nodoc


class _PengaturanModel extends PengaturanModel {
  const _PengaturanModel({this.intervalSinkronisasiOtomatis = 24, this.hapusOtomatisDataArsip = 30, this.modePemeliharaan = false, this.infoPemeliharaan = '', this.diperbarui}): super._();
  

@override@JsonKey() final  int intervalSinkronisasiOtomatis;
@override@JsonKey() final  int hapusOtomatisDataArsip;
@override@JsonKey() final  bool modePemeliharaan;
@override@JsonKey() final  String infoPemeliharaan;
@override final  DateTime? diperbarui;

/// Create a copy of PengaturanModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PengaturanModelCopyWith<_PengaturanModel> get copyWith => __$PengaturanModelCopyWithImpl<_PengaturanModel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PengaturanModel&&(identical(other.intervalSinkronisasiOtomatis, intervalSinkronisasiOtomatis) || other.intervalSinkronisasiOtomatis == intervalSinkronisasiOtomatis)&&(identical(other.hapusOtomatisDataArsip, hapusOtomatisDataArsip) || other.hapusOtomatisDataArsip == hapusOtomatisDataArsip)&&(identical(other.modePemeliharaan, modePemeliharaan) || other.modePemeliharaan == modePemeliharaan)&&(identical(other.infoPemeliharaan, infoPemeliharaan) || other.infoPemeliharaan == infoPemeliharaan)&&(identical(other.diperbarui, diperbarui) || other.diperbarui == diperbarui));
}


@override
int get hashCode {
    return Object.hash(runtimeType,intervalSinkronisasiOtomatis,hapusOtomatisDataArsip,modePemeliharaan,infoPemeliharaan,diperbarui);
}

@override
String toString() {
    return 'PengaturanModel(intervalSinkronisasiOtomatis: $intervalSinkronisasiOtomatis, hapusOtomatisDataArsip: $hapusOtomatisDataArsip, modePemeliharaan: $modePemeliharaan, infoPemeliharaan: $infoPemeliharaan, diperbarui: $diperbarui)';
}


}

/// @nodoc
abstract mixin class _$PengaturanModelCopyWith<$Res> implements $PengaturanModelCopyWith<$Res> {
  factory _$PengaturanModelCopyWith(_PengaturanModel value, $Res Function(_PengaturanModel) _then) = __$PengaturanModelCopyWithImpl;
@override @useResult
$Res call({
 int intervalSinkronisasiOtomatis, int hapusOtomatisDataArsip, bool modePemeliharaan, String infoPemeliharaan, DateTime? diperbarui
});




}
/// @nodoc
class __$PengaturanModelCopyWithImpl<$Res>
    implements _$PengaturanModelCopyWith<$Res> {
  __$PengaturanModelCopyWithImpl(this._self, this._then);

  final _PengaturanModel _self;
  final $Res Function(_PengaturanModel) _then;

/// Create a copy of PengaturanModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? intervalSinkronisasiOtomatis = null,Object? hapusOtomatisDataArsip = null,Object? modePemeliharaan = null,Object? infoPemeliharaan = null,Object? diperbarui = freezed,}) {
  return _then(_PengaturanModel(
intervalSinkronisasiOtomatis: null == intervalSinkronisasiOtomatis ? _self.intervalSinkronisasiOtomatis : intervalSinkronisasiOtomatis // ignore: cast_nullable_to_non_nullable
as int,hapusOtomatisDataArsip: null == hapusOtomatisDataArsip ? _self.hapusOtomatisDataArsip : hapusOtomatisDataArsip // ignore: cast_nullable_to_non_nullable
as int,modePemeliharaan: null == modePemeliharaan ? _self.modePemeliharaan : modePemeliharaan // ignore: cast_nullable_to_non_nullable
as bool,infoPemeliharaan: null == infoPemeliharaan ? _self.infoPemeliharaan : infoPemeliharaan // ignore: cast_nullable_to_non_nullable
as String,diperbarui: freezed == diperbarui ? _self.diperbarui : diperbarui // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
