// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voucher_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VoucherModel {

 String get id; String get idPaket; DateTime get tanggalDibuat; String get voucher; DateTime? get kadaluarsa;
/// Create a copy of VoucherModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoucherModelCopyWith<VoucherModel> get copyWith => _$VoucherModelCopyWithImpl<VoucherModel>(this as VoucherModel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as VoucherModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoucherModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.idPaket, _this.idPaket) || other.idPaket == _this.idPaket)&&(identical(other.tanggalDibuat, _this.tanggalDibuat) || other.tanggalDibuat == _this.tanggalDibuat)&&(identical(other.voucher, _this.voucher) || other.voucher == _this.voucher)&&(identical(other.kadaluarsa, _this.kadaluarsa) || other.kadaluarsa == _this.kadaluarsa));
}


@override
int get hashCode {
  final _this = this as VoucherModel;
  return Object.hash(runtimeType,_this.id,_this.idPaket,_this.tanggalDibuat,_this.voucher,_this.kadaluarsa);
}

@override
String toString() {
  final _this = this as VoucherModel;
  return 'VoucherModel(id: ${_this.id}, idPaket: ${_this.idPaket}, tanggalDibuat: ${_this.tanggalDibuat}, voucher: ${_this.voucher}, kadaluarsa: ${_this.kadaluarsa})';
}


}

/// @nodoc
abstract mixin class $VoucherModelCopyWith<$Res>  {
  factory $VoucherModelCopyWith(VoucherModel value, $Res Function(VoucherModel) _then) = _$VoucherModelCopyWithImpl;
@useResult
$Res call({
 String id, String idPaket, DateTime tanggalDibuat, String voucher, DateTime? kadaluarsa
});




}
/// @nodoc
class _$VoucherModelCopyWithImpl<$Res>
    implements $VoucherModelCopyWith<$Res> {
  _$VoucherModelCopyWithImpl(this._self, this._then);

  final VoucherModel _self;
  final $Res Function(VoucherModel) _then;

/// Create a copy of VoucherModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? idPaket = null,Object? tanggalDibuat = null,Object? voucher = null,Object? kadaluarsa = freezed,}) {
  return _then(VoucherModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,idPaket: null == idPaket ? _self.idPaket : idPaket // ignore: cast_nullable_to_non_nullable
as String,tanggalDibuat: null == tanggalDibuat ? _self.tanggalDibuat : tanggalDibuat // ignore: cast_nullable_to_non_nullable
as DateTime,voucher: null == voucher ? _self.voucher : voucher // ignore: cast_nullable_to_non_nullable
as String,kadaluarsa: freezed == kadaluarsa ? _self.kadaluarsa : kadaluarsa // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [VoucherModel].
extension VoucherModelPatterns on VoucherModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoucherModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoucherModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoucherModel value)  $default,){
final _that = this;
switch (_that) {
case _VoucherModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoucherModel value)?  $default,){
final _that = this;
switch (_that) {
case _VoucherModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String idPaket,  DateTime tanggalDibuat,  String voucher,  DateTime? kadaluarsa)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoucherModel() when $default != null:
return $default(_that.id,_that.idPaket,_that.tanggalDibuat,_that.voucher,_that.kadaluarsa);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String idPaket,  DateTime tanggalDibuat,  String voucher,  DateTime? kadaluarsa)  $default,) {final _that = this;
switch (_that) {
case _VoucherModel():
return $default(_that.id,_that.idPaket,_that.tanggalDibuat,_that.voucher,_that.kadaluarsa);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String idPaket,  DateTime tanggalDibuat,  String voucher,  DateTime? kadaluarsa)?  $default,) {final _that = this;
switch (_that) {
case _VoucherModel() when $default != null:
return $default(_that.id,_that.idPaket,_that.tanggalDibuat,_that.voucher,_that.kadaluarsa);case _:
  return null;

}
}

}

/// @nodoc


class _VoucherModel extends VoucherModel {
  const _VoucherModel({required this.id, required this.idPaket, required this.tanggalDibuat, required this.voucher, required this.kadaluarsa}): super._();
  

@override final  String id;
@override final  String idPaket;
@override final  DateTime tanggalDibuat;
@override final  String voucher;
@override final  DateTime? kadaluarsa;

/// Create a copy of VoucherModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoucherModelCopyWith<_VoucherModel> get copyWith => __$VoucherModelCopyWithImpl<_VoucherModel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoucherModel&&(identical(other.id, id) || other.id == id)&&(identical(other.idPaket, idPaket) || other.idPaket == idPaket)&&(identical(other.tanggalDibuat, tanggalDibuat) || other.tanggalDibuat == tanggalDibuat)&&(identical(other.voucher, voucher) || other.voucher == voucher)&&(identical(other.kadaluarsa, kadaluarsa) || other.kadaluarsa == kadaluarsa));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,idPaket,tanggalDibuat,voucher,kadaluarsa);
}

@override
String toString() {
    return 'VoucherModel(id: $id, idPaket: $idPaket, tanggalDibuat: $tanggalDibuat, voucher: $voucher, kadaluarsa: $kadaluarsa)';
}


}

/// @nodoc
abstract mixin class _$VoucherModelCopyWith<$Res> implements $VoucherModelCopyWith<$Res> {
  factory _$VoucherModelCopyWith(_VoucherModel value, $Res Function(_VoucherModel) _then) = __$VoucherModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String idPaket, DateTime tanggalDibuat, String voucher, DateTime? kadaluarsa
});




}
/// @nodoc
class __$VoucherModelCopyWithImpl<$Res>
    implements _$VoucherModelCopyWith<$Res> {
  __$VoucherModelCopyWithImpl(this._self, this._then);

  final _VoucherModel _self;
  final $Res Function(_VoucherModel) _then;

/// Create a copy of VoucherModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? idPaket = null,Object? tanggalDibuat = null,Object? voucher = null,Object? kadaluarsa = freezed,}) {
  return _then(_VoucherModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,idPaket: null == idPaket ? _self.idPaket : idPaket // ignore: cast_nullable_to_non_nullable
as String,tanggalDibuat: null == tanggalDibuat ? _self.tanggalDibuat : tanggalDibuat // ignore: cast_nullable_to_non_nullable
as DateTime,voucher: null == voucher ? _self.voucher : voucher // ignore: cast_nullable_to_non_nullable
as String,kadaluarsa: freezed == kadaluarsa ? _self.kadaluarsa : kadaluarsa // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
