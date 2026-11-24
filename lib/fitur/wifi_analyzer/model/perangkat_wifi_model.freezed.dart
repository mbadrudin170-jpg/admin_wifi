// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'perangkat_wifi_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PerangkatWifiModel {

 String get ip; String? get nama; String? get vendor; int? get latencyMs;
/// Create a copy of PerangkatWifiModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PerangkatWifiModelCopyWith<PerangkatWifiModel> get copyWith => _$PerangkatWifiModelCopyWithImpl<PerangkatWifiModel>(this as PerangkatWifiModel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PerangkatWifiModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PerangkatWifiModel&&(identical(other.ip, _this.ip) || other.ip == _this.ip)&&(identical(other.nama, _this.nama) || other.nama == _this.nama)&&(identical(other.vendor, _this.vendor) || other.vendor == _this.vendor)&&(identical(other.latencyMs, _this.latencyMs) || other.latencyMs == _this.latencyMs));
}


@override
int get hashCode {
  final _this = this as PerangkatWifiModel;
  return Object.hash(runtimeType,_this.ip,_this.nama,_this.vendor,_this.latencyMs);
}

@override
String toString() {
  final _this = this as PerangkatWifiModel;
  return 'PerangkatWifiModel(ip: ${_this.ip}, nama: ${_this.nama}, vendor: ${_this.vendor}, latencyMs: ${_this.latencyMs})';
}


}

/// @nodoc
abstract mixin class $PerangkatWifiModelCopyWith<$Res>  {
  factory $PerangkatWifiModelCopyWith(PerangkatWifiModel value, $Res Function(PerangkatWifiModel) _then) = _$PerangkatWifiModelCopyWithImpl;
@useResult
$Res call({
 String ip, String? nama, String? vendor, int? latencyMs
});




}
/// @nodoc
class _$PerangkatWifiModelCopyWithImpl<$Res>
    implements $PerangkatWifiModelCopyWith<$Res> {
  _$PerangkatWifiModelCopyWithImpl(this._self, this._then);

  final PerangkatWifiModel _self;
  final $Res Function(PerangkatWifiModel) _then;

/// Create a copy of PerangkatWifiModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ip = null,Object? nama = freezed,Object? vendor = freezed,Object? latencyMs = freezed,}) {
  return _then(PerangkatWifiModel(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,nama: freezed == nama ? _self.nama : nama // ignore: cast_nullable_to_non_nullable
as String?,vendor: freezed == vendor ? _self.vendor : vendor // ignore: cast_nullable_to_non_nullable
as String?,latencyMs: freezed == latencyMs ? _self.latencyMs : latencyMs // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [PerangkatWifiModel].
extension PerangkatWifiModelPatterns on PerangkatWifiModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PerangkatWifiModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PerangkatWifiModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PerangkatWifiModel value)  $default,){
final _that = this;
switch (_that) {
case _PerangkatWifiModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PerangkatWifiModel value)?  $default,){
final _that = this;
switch (_that) {
case _PerangkatWifiModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ip,  String? nama,  String? vendor,  int? latencyMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PerangkatWifiModel() when $default != null:
return $default(_that.ip,_that.nama,_that.vendor,_that.latencyMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ip,  String? nama,  String? vendor,  int? latencyMs)  $default,) {final _that = this;
switch (_that) {
case _PerangkatWifiModel():
return $default(_that.ip,_that.nama,_that.vendor,_that.latencyMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ip,  String? nama,  String? vendor,  int? latencyMs)?  $default,) {final _that = this;
switch (_that) {
case _PerangkatWifiModel() when $default != null:
return $default(_that.ip,_that.nama,_that.vendor,_that.latencyMs);case _:
  return null;

}
}

}

/// @nodoc


class _PerangkatWifiModel implements PerangkatWifiModel {
  const _PerangkatWifiModel({required this.ip, this.nama, this.vendor, this.latencyMs});
  

@override final  String ip;
@override final  String? nama;
@override final  String? vendor;
@override final  int? latencyMs;

/// Create a copy of PerangkatWifiModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PerangkatWifiModelCopyWith<_PerangkatWifiModel> get copyWith => __$PerangkatWifiModelCopyWithImpl<_PerangkatWifiModel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PerangkatWifiModel&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.nama, nama) || other.nama == nama)&&(identical(other.vendor, vendor) || other.vendor == vendor)&&(identical(other.latencyMs, latencyMs) || other.latencyMs == latencyMs));
}


@override
int get hashCode {
    return Object.hash(runtimeType,ip,nama,vendor,latencyMs);
}

@override
String toString() {
    return 'PerangkatWifiModel(ip: $ip, nama: $nama, vendor: $vendor, latencyMs: $latencyMs)';
}


}

/// @nodoc
abstract mixin class _$PerangkatWifiModelCopyWith<$Res> implements $PerangkatWifiModelCopyWith<$Res> {
  factory _$PerangkatWifiModelCopyWith(_PerangkatWifiModel value, $Res Function(_PerangkatWifiModel) _then) = __$PerangkatWifiModelCopyWithImpl;
@override @useResult
$Res call({
 String ip, String? nama, String? vendor, int? latencyMs
});




}
/// @nodoc
class __$PerangkatWifiModelCopyWithImpl<$Res>
    implements _$PerangkatWifiModelCopyWith<$Res> {
  __$PerangkatWifiModelCopyWithImpl(this._self, this._then);

  final _PerangkatWifiModel _self;
  final $Res Function(_PerangkatWifiModel) _then;

/// Create a copy of PerangkatWifiModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ip = null,Object? nama = freezed,Object? vendor = freezed,Object? latencyMs = freezed,}) {
  return _then(_PerangkatWifiModel(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,nama: freezed == nama ? _self.nama : nama // ignore: cast_nullable_to_non_nullable
as String?,vendor: freezed == vendor ? _self.vendor : vendor // ignore: cast_nullable_to_non_nullable
as String?,latencyMs: freezed == latencyMs ? _self.latencyMs : latencyMs // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
