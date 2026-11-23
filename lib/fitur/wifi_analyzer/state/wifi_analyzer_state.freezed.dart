// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wifi_analyzer_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WifiAnalyzerState {

 bool get isLoading; String? get connectionError; String? get ssidTerhubung; String? get bssidTerhubung; String? get ipTerhubung; int? get rssiTerhubung; DateTime? get lastInfoAt; DateTime? get lastInfoAttemptAt;
/// Create a copy of WifiAnalyzerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WifiAnalyzerStateCopyWith<WifiAnalyzerState> get copyWith => _$WifiAnalyzerStateCopyWithImpl<WifiAnalyzerState>(this as WifiAnalyzerState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WifiAnalyzerState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WifiAnalyzerState&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&(identical(other.connectionError, _this.connectionError) || other.connectionError == _this.connectionError)&&(identical(other.ssidTerhubung, _this.ssidTerhubung) || other.ssidTerhubung == _this.ssidTerhubung)&&(identical(other.bssidTerhubung, _this.bssidTerhubung) || other.bssidTerhubung == _this.bssidTerhubung)&&(identical(other.ipTerhubung, _this.ipTerhubung) || other.ipTerhubung == _this.ipTerhubung)&&(identical(other.rssiTerhubung, _this.rssiTerhubung) || other.rssiTerhubung == _this.rssiTerhubung)&&(identical(other.lastInfoAt, _this.lastInfoAt) || other.lastInfoAt == _this.lastInfoAt)&&(identical(other.lastInfoAttemptAt, _this.lastInfoAttemptAt) || other.lastInfoAttemptAt == _this.lastInfoAttemptAt));
}


@override
int get hashCode {
  final _this = this as WifiAnalyzerState;
  return Object.hash(runtimeType,_this.isLoading,_this.connectionError,_this.ssidTerhubung,_this.bssidTerhubung,_this.ipTerhubung,_this.rssiTerhubung,_this.lastInfoAt,_this.lastInfoAttemptAt);
}

@override
String toString() {
  final _this = this as WifiAnalyzerState;
  return 'WifiAnalyzerState(isLoading: ${_this.isLoading}, connectionError: ${_this.connectionError}, ssidTerhubung: ${_this.ssidTerhubung}, bssidTerhubung: ${_this.bssidTerhubung}, ipTerhubung: ${_this.ipTerhubung}, rssiTerhubung: ${_this.rssiTerhubung}, lastInfoAt: ${_this.lastInfoAt}, lastInfoAttemptAt: ${_this.lastInfoAttemptAt})';
}


}

/// @nodoc
abstract mixin class $WifiAnalyzerStateCopyWith<$Res>  {
  factory $WifiAnalyzerStateCopyWith(WifiAnalyzerState value, $Res Function(WifiAnalyzerState) _then) = _$WifiAnalyzerStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, String? connectionError, String? ssidTerhubung, String? bssidTerhubung, String? ipTerhubung, int? rssiTerhubung, DateTime? lastInfoAt, DateTime? lastInfoAttemptAt
});




}
/// @nodoc
class _$WifiAnalyzerStateCopyWithImpl<$Res>
    implements $WifiAnalyzerStateCopyWith<$Res> {
  _$WifiAnalyzerStateCopyWithImpl(this._self, this._then);

  final WifiAnalyzerState _self;
  final $Res Function(WifiAnalyzerState) _then;

/// Create a copy of WifiAnalyzerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? connectionError = freezed,Object? ssidTerhubung = freezed,Object? bssidTerhubung = freezed,Object? ipTerhubung = freezed,Object? rssiTerhubung = freezed,Object? lastInfoAt = freezed,Object? lastInfoAttemptAt = freezed,}) {
  return _then(WifiAnalyzerState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,connectionError: freezed == connectionError ? _self.connectionError : connectionError // ignore: cast_nullable_to_non_nullable
as String?,ssidTerhubung: freezed == ssidTerhubung ? _self.ssidTerhubung : ssidTerhubung // ignore: cast_nullable_to_non_nullable
as String?,bssidTerhubung: freezed == bssidTerhubung ? _self.bssidTerhubung : bssidTerhubung // ignore: cast_nullable_to_non_nullable
as String?,ipTerhubung: freezed == ipTerhubung ? _self.ipTerhubung : ipTerhubung // ignore: cast_nullable_to_non_nullable
as String?,rssiTerhubung: freezed == rssiTerhubung ? _self.rssiTerhubung : rssiTerhubung // ignore: cast_nullable_to_non_nullable
as int?,lastInfoAt: freezed == lastInfoAt ? _self.lastInfoAt : lastInfoAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastInfoAttemptAt: freezed == lastInfoAttemptAt ? _self.lastInfoAttemptAt : lastInfoAttemptAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WifiAnalyzerState].
extension WifiAnalyzerStatePatterns on WifiAnalyzerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WifiAnalyzerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WifiAnalyzerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WifiAnalyzerState value)  $default,){
final _that = this;
switch (_that) {
case _WifiAnalyzerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WifiAnalyzerState value)?  $default,){
final _that = this;
switch (_that) {
case _WifiAnalyzerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  String? connectionError,  String? ssidTerhubung,  String? bssidTerhubung,  String? ipTerhubung,  int? rssiTerhubung,  DateTime? lastInfoAt,  DateTime? lastInfoAttemptAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WifiAnalyzerState() when $default != null:
return $default(_that.isLoading,_that.connectionError,_that.ssidTerhubung,_that.bssidTerhubung,_that.ipTerhubung,_that.rssiTerhubung,_that.lastInfoAt,_that.lastInfoAttemptAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  String? connectionError,  String? ssidTerhubung,  String? bssidTerhubung,  String? ipTerhubung,  int? rssiTerhubung,  DateTime? lastInfoAt,  DateTime? lastInfoAttemptAt)  $default,) {final _that = this;
switch (_that) {
case _WifiAnalyzerState():
return $default(_that.isLoading,_that.connectionError,_that.ssidTerhubung,_that.bssidTerhubung,_that.ipTerhubung,_that.rssiTerhubung,_that.lastInfoAt,_that.lastInfoAttemptAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  String? connectionError,  String? ssidTerhubung,  String? bssidTerhubung,  String? ipTerhubung,  int? rssiTerhubung,  DateTime? lastInfoAt,  DateTime? lastInfoAttemptAt)?  $default,) {final _that = this;
switch (_that) {
case _WifiAnalyzerState() when $default != null:
return $default(_that.isLoading,_that.connectionError,_that.ssidTerhubung,_that.bssidTerhubung,_that.ipTerhubung,_that.rssiTerhubung,_that.lastInfoAt,_that.lastInfoAttemptAt);case _:
  return null;

}
}

}

/// @nodoc


class _WifiAnalyzerState extends WifiAnalyzerState {
  const _WifiAnalyzerState({this.isLoading = false, this.connectionError, this.ssidTerhubung, this.bssidTerhubung, this.ipTerhubung, this.rssiTerhubung, this.lastInfoAt, this.lastInfoAttemptAt}): super._();
  

@override@JsonKey() final  bool isLoading;
@override final  String? connectionError;
@override final  String? ssidTerhubung;
@override final  String? bssidTerhubung;
@override final  String? ipTerhubung;
@override final  int? rssiTerhubung;
@override final  DateTime? lastInfoAt;
@override final  DateTime? lastInfoAttemptAt;

/// Create a copy of WifiAnalyzerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WifiAnalyzerStateCopyWith<_WifiAnalyzerState> get copyWith => __$WifiAnalyzerStateCopyWithImpl<_WifiAnalyzerState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WifiAnalyzerState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.connectionError, connectionError) || other.connectionError == connectionError)&&(identical(other.ssidTerhubung, ssidTerhubung) || other.ssidTerhubung == ssidTerhubung)&&(identical(other.bssidTerhubung, bssidTerhubung) || other.bssidTerhubung == bssidTerhubung)&&(identical(other.ipTerhubung, ipTerhubung) || other.ipTerhubung == ipTerhubung)&&(identical(other.rssiTerhubung, rssiTerhubung) || other.rssiTerhubung == rssiTerhubung)&&(identical(other.lastInfoAt, lastInfoAt) || other.lastInfoAt == lastInfoAt)&&(identical(other.lastInfoAttemptAt, lastInfoAttemptAt) || other.lastInfoAttemptAt == lastInfoAttemptAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isLoading,connectionError,ssidTerhubung,bssidTerhubung,ipTerhubung,rssiTerhubung,lastInfoAt,lastInfoAttemptAt);
}

@override
String toString() {
    return 'WifiAnalyzerState(isLoading: $isLoading, connectionError: $connectionError, ssidTerhubung: $ssidTerhubung, bssidTerhubung: $bssidTerhubung, ipTerhubung: $ipTerhubung, rssiTerhubung: $rssiTerhubung, lastInfoAt: $lastInfoAt, lastInfoAttemptAt: $lastInfoAttemptAt)';
}


}

/// @nodoc
abstract mixin class _$WifiAnalyzerStateCopyWith<$Res> implements $WifiAnalyzerStateCopyWith<$Res> {
  factory _$WifiAnalyzerStateCopyWith(_WifiAnalyzerState value, $Res Function(_WifiAnalyzerState) _then) = __$WifiAnalyzerStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, String? connectionError, String? ssidTerhubung, String? bssidTerhubung, String? ipTerhubung, int? rssiTerhubung, DateTime? lastInfoAt, DateTime? lastInfoAttemptAt
});




}
/// @nodoc
class __$WifiAnalyzerStateCopyWithImpl<$Res>
    implements _$WifiAnalyzerStateCopyWith<$Res> {
  __$WifiAnalyzerStateCopyWithImpl(this._self, this._then);

  final _WifiAnalyzerState _self;
  final $Res Function(_WifiAnalyzerState) _then;

/// Create a copy of WifiAnalyzerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? connectionError = freezed,Object? ssidTerhubung = freezed,Object? bssidTerhubung = freezed,Object? ipTerhubung = freezed,Object? rssiTerhubung = freezed,Object? lastInfoAt = freezed,Object? lastInfoAttemptAt = freezed,}) {
  return _then(_WifiAnalyzerState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,connectionError: freezed == connectionError ? _self.connectionError : connectionError // ignore: cast_nullable_to_non_nullable
as String?,ssidTerhubung: freezed == ssidTerhubung ? _self.ssidTerhubung : ssidTerhubung // ignore: cast_nullable_to_non_nullable
as String?,bssidTerhubung: freezed == bssidTerhubung ? _self.bssidTerhubung : bssidTerhubung // ignore: cast_nullable_to_non_nullable
as String?,ipTerhubung: freezed == ipTerhubung ? _self.ipTerhubung : ipTerhubung // ignore: cast_nullable_to_non_nullable
as String?,rssiTerhubung: freezed == rssiTerhubung ? _self.rssiTerhubung : rssiTerhubung // ignore: cast_nullable_to_non_nullable
as int?,lastInfoAt: freezed == lastInfoAt ? _self.lastInfoAt : lastInfoAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastInfoAttemptAt: freezed == lastInfoAttemptAt ? _self.lastInfoAttemptAt : lastInfoAttemptAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
