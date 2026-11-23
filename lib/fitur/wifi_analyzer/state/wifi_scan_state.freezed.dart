// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wifi_scan_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WifiScanState {

 bool get isLoading; String? get scanError; List<WiFiAccessPoint> get accessPoints; DateTime? get lastScanAt; DateTime? get lastScanAttemptAt;
/// Create a copy of WifiScanState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WifiScanStateCopyWith<WifiScanState> get copyWith => _$WifiScanStateCopyWithImpl<WifiScanState>(this as WifiScanState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WifiScanState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WifiScanState&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&(identical(other.scanError, _this.scanError) || other.scanError == _this.scanError)&&const DeepCollectionEquality().equals(other.accessPoints, _this.accessPoints)&&(identical(other.lastScanAt, _this.lastScanAt) || other.lastScanAt == _this.lastScanAt)&&(identical(other.lastScanAttemptAt, _this.lastScanAttemptAt) || other.lastScanAttemptAt == _this.lastScanAttemptAt));
}


@override
int get hashCode {
  final _this = this as WifiScanState;
  return Object.hash(runtimeType,_this.isLoading,_this.scanError,const DeepCollectionEquality().hash(_this.accessPoints),_this.lastScanAt,_this.lastScanAttemptAt);
}

@override
String toString() {
  final _this = this as WifiScanState;
  return 'WifiScanState(isLoading: ${_this.isLoading}, scanError: ${_this.scanError}, accessPoints: ${_this.accessPoints}, lastScanAt: ${_this.lastScanAt}, lastScanAttemptAt: ${_this.lastScanAttemptAt})';
}


}

/// @nodoc
abstract mixin class $WifiScanStateCopyWith<$Res>  {
  factory $WifiScanStateCopyWith(WifiScanState value, $Res Function(WifiScanState) _then) = _$WifiScanStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, String? scanError, List<WiFiAccessPoint> accessPoints, DateTime? lastScanAt, DateTime? lastScanAttemptAt
});




}
/// @nodoc
class _$WifiScanStateCopyWithImpl<$Res>
    implements $WifiScanStateCopyWith<$Res> {
  _$WifiScanStateCopyWithImpl(this._self, this._then);

  final WifiScanState _self;
  final $Res Function(WifiScanState) _then;

/// Create a copy of WifiScanState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? scanError = freezed,Object? accessPoints = null,Object? lastScanAt = freezed,Object? lastScanAttemptAt = freezed,}) {
  return _then(WifiScanState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,scanError: freezed == scanError ? _self.scanError : scanError // ignore: cast_nullable_to_non_nullable
as String?,accessPoints: null == accessPoints ? _self.accessPoints : accessPoints // ignore: cast_nullable_to_non_nullable
as List<WiFiAccessPoint>,lastScanAt: freezed == lastScanAt ? _self.lastScanAt : lastScanAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastScanAttemptAt: freezed == lastScanAttemptAt ? _self.lastScanAttemptAt : lastScanAttemptAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WifiScanState].
extension WifiScanStatePatterns on WifiScanState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WifiScanState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WifiScanState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WifiScanState value)  $default,){
final _that = this;
switch (_that) {
case _WifiScanState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WifiScanState value)?  $default,){
final _that = this;
switch (_that) {
case _WifiScanState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  String? scanError,  List<WiFiAccessPoint> accessPoints,  DateTime? lastScanAt,  DateTime? lastScanAttemptAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WifiScanState() when $default != null:
return $default(_that.isLoading,_that.scanError,_that.accessPoints,_that.lastScanAt,_that.lastScanAttemptAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  String? scanError,  List<WiFiAccessPoint> accessPoints,  DateTime? lastScanAt,  DateTime? lastScanAttemptAt)  $default,) {final _that = this;
switch (_that) {
case _WifiScanState():
return $default(_that.isLoading,_that.scanError,_that.accessPoints,_that.lastScanAt,_that.lastScanAttemptAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  String? scanError,  List<WiFiAccessPoint> accessPoints,  DateTime? lastScanAt,  DateTime? lastScanAttemptAt)?  $default,) {final _that = this;
switch (_that) {
case _WifiScanState() when $default != null:
return $default(_that.isLoading,_that.scanError,_that.accessPoints,_that.lastScanAt,_that.lastScanAttemptAt);case _:
  return null;

}
}

}

/// @nodoc


class _WifiScanState extends WifiScanState {
  const _WifiScanState({this.isLoading = false, this.scanError,  List<WiFiAccessPoint> accessPoints = const <WiFiAccessPoint>[], this.lastScanAt, this.lastScanAttemptAt}): _accessPoints = accessPoints,super._();
  

@override@JsonKey() final  bool isLoading;
@override final  String? scanError;
 final  List<WiFiAccessPoint> _accessPoints;
@override@JsonKey() List<WiFiAccessPoint> get accessPoints {
  if (_accessPoints is EqualUnmodifiableListView) return _accessPoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_accessPoints);
}

@override final  DateTime? lastScanAt;
@override final  DateTime? lastScanAttemptAt;

/// Create a copy of WifiScanState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WifiScanStateCopyWith<_WifiScanState> get copyWith => __$WifiScanStateCopyWithImpl<_WifiScanState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WifiScanState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.scanError, scanError) || other.scanError == scanError)&&const DeepCollectionEquality().equals(other.accessPoints, _accessPoints)&&(identical(other.lastScanAt, lastScanAt) || other.lastScanAt == lastScanAt)&&(identical(other.lastScanAttemptAt, lastScanAttemptAt) || other.lastScanAttemptAt == lastScanAttemptAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isLoading,scanError,const DeepCollectionEquality().hash(_accessPoints),lastScanAt,lastScanAttemptAt);
}

@override
String toString() {
    return 'WifiScanState(isLoading: $isLoading, scanError: $scanError, accessPoints: $accessPoints, lastScanAt: $lastScanAt, lastScanAttemptAt: $lastScanAttemptAt)';
}


}

/// @nodoc
abstract mixin class _$WifiScanStateCopyWith<$Res> implements $WifiScanStateCopyWith<$Res> {
  factory _$WifiScanStateCopyWith(_WifiScanState value, $Res Function(_WifiScanState) _then) = __$WifiScanStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, String? scanError, List<WiFiAccessPoint> accessPoints, DateTime? lastScanAt, DateTime? lastScanAttemptAt
});




}
/// @nodoc
class __$WifiScanStateCopyWithImpl<$Res>
    implements _$WifiScanStateCopyWith<$Res> {
  __$WifiScanStateCopyWithImpl(this._self, this._then);

  final _WifiScanState _self;
  final $Res Function(_WifiScanState) _then;

/// Create a copy of WifiScanState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? scanError = freezed,Object? accessPoints = null,Object? lastScanAt = freezed,Object? lastScanAttemptAt = freezed,}) {
  return _then(_WifiScanState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,scanError: freezed == scanError ? _self.scanError : scanError // ignore: cast_nullable_to_non_nullable
as String?,accessPoints: null == accessPoints ? _self._accessPoints : accessPoints // ignore: cast_nullable_to_non_nullable
as List<WiFiAccessPoint>,lastScanAt: freezed == lastScanAt ? _self.lastScanAt : lastScanAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastScanAttemptAt: freezed == lastScanAttemptAt ? _self.lastScanAttemptAt : lastScanAttemptAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
