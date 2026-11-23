// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ping_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PingState {

 bool get isLoading; String? get host; int? get latencyMs; bool get success; String? get error; String? get jenisPengukuran;
/// Create a copy of PingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PingStateCopyWith<PingState> get copyWith => _$PingStateCopyWithImpl<PingState>(this as PingState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PingState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PingState&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&(identical(other.host, _this.host) || other.host == _this.host)&&(identical(other.latencyMs, _this.latencyMs) || other.latencyMs == _this.latencyMs)&&(identical(other.success, _this.success) || other.success == _this.success)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.jenisPengukuran, _this.jenisPengukuran) || other.jenisPengukuran == _this.jenisPengukuran));
}


@override
int get hashCode {
  final _this = this as PingState;
  return Object.hash(runtimeType,_this.isLoading,_this.host,_this.latencyMs,_this.success,_this.error,_this.jenisPengukuran);
}

@override
String toString() {
  final _this = this as PingState;
  return 'PingState(isLoading: ${_this.isLoading}, host: ${_this.host}, latencyMs: ${_this.latencyMs}, success: ${_this.success}, error: ${_this.error}, jenisPengukuran: ${_this.jenisPengukuran})';
}


}

/// @nodoc
abstract mixin class $PingStateCopyWith<$Res>  {
  factory $PingStateCopyWith(PingState value, $Res Function(PingState) _then) = _$PingStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, String? host, int? latencyMs, bool success, String? error, String? jenisPengukuran
});




}
/// @nodoc
class _$PingStateCopyWithImpl<$Res>
    implements $PingStateCopyWith<$Res> {
  _$PingStateCopyWithImpl(this._self, this._then);

  final PingState _self;
  final $Res Function(PingState) _then;

/// Create a copy of PingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? host = freezed,Object? latencyMs = freezed,Object? success = null,Object? error = freezed,Object? jenisPengukuran = freezed,}) {
  return _then(PingState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,host: freezed == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String?,latencyMs: freezed == latencyMs ? _self.latencyMs : latencyMs // ignore: cast_nullable_to_non_nullable
as int?,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,jenisPengukuran: freezed == jenisPengukuran ? _self.jenisPengukuran : jenisPengukuran // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PingState].
extension PingStatePatterns on PingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PingState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PingState value)  $default,){
final _that = this;
switch (_that) {
case _PingState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PingState value)?  $default,){
final _that = this;
switch (_that) {
case _PingState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  String? host,  int? latencyMs,  bool success,  String? error,  String? jenisPengukuran)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PingState() when $default != null:
return $default(_that.isLoading,_that.host,_that.latencyMs,_that.success,_that.error,_that.jenisPengukuran);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  String? host,  int? latencyMs,  bool success,  String? error,  String? jenisPengukuran)  $default,) {final _that = this;
switch (_that) {
case _PingState():
return $default(_that.isLoading,_that.host,_that.latencyMs,_that.success,_that.error,_that.jenisPengukuran);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  String? host,  int? latencyMs,  bool success,  String? error,  String? jenisPengukuran)?  $default,) {final _that = this;
switch (_that) {
case _PingState() when $default != null:
return $default(_that.isLoading,_that.host,_that.latencyMs,_that.success,_that.error,_that.jenisPengukuran);case _:
  return null;

}
}

}

/// @nodoc


class _PingState extends PingState {
  const _PingState({this.isLoading = false, this.host, this.latencyMs, this.success = false, this.error, this.jenisPengukuran}): super._();
  

@override@JsonKey() final  bool isLoading;
@override final  String? host;
@override final  int? latencyMs;
@override@JsonKey() final  bool success;
@override final  String? error;
@override final  String? jenisPengukuran;

/// Create a copy of PingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PingStateCopyWith<_PingState> get copyWith => __$PingStateCopyWithImpl<_PingState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PingState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.host, host) || other.host == host)&&(identical(other.latencyMs, latencyMs) || other.latencyMs == latencyMs)&&(identical(other.success, success) || other.success == success)&&(identical(other.error, error) || other.error == error)&&(identical(other.jenisPengukuran, jenisPengukuran) || other.jenisPengukuran == jenisPengukuran));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isLoading,host,latencyMs,success,error,jenisPengukuran);
}

@override
String toString() {
    return 'PingState(isLoading: $isLoading, host: $host, latencyMs: $latencyMs, success: $success, error: $error, jenisPengukuran: $jenisPengukuran)';
}


}

/// @nodoc
abstract mixin class _$PingStateCopyWith<$Res> implements $PingStateCopyWith<$Res> {
  factory _$PingStateCopyWith(_PingState value, $Res Function(_PingState) _then) = __$PingStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, String? host, int? latencyMs, bool success, String? error, String? jenisPengukuran
});




}
/// @nodoc
class __$PingStateCopyWithImpl<$Res>
    implements _$PingStateCopyWith<$Res> {
  __$PingStateCopyWithImpl(this._self, this._then);

  final _PingState _self;
  final $Res Function(_PingState) _then;

/// Create a copy of PingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? host = freezed,Object? latencyMs = freezed,Object? success = null,Object? error = freezed,Object? jenisPengukuran = freezed,}) {
  return _then(_PingState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,host: freezed == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String?,latencyMs: freezed == latencyMs ? _self.latencyMs : latencyMs // ignore: cast_nullable_to_non_nullable
as int?,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,jenisPengukuran: freezed == jenisPengukuran ? _self.jenisPengukuran : jenisPengukuran // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
